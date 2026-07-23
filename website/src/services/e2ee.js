/**
 * End-to-End Encryption Service
 *
 * Uses Web Crypto API:
 *   - ECDH (P-256) for key exchange
 *   - AES-256-GCM for message encryption
 *
 * Key storage: IndexedDB for persistence across sessions.
 *
 * Flow:
 *   1. On first login, generate an ECDH key pair
 *   2. When opening a conversation, send your public key as a KEY_EXCHANGE message
 *   3. On receiving a public key, derive a shared AES key (ECDH + HKDF)
 *   4. Encrypt outgoing messages → send as "E2E:<iv>:<ciphertext>" in the message field
 *   5. Decrypt incoming messages that match the E2E prefix
 */

const DB_NAME = 'messenger_e2ee';
const DB_VERSION = 1;
const KEYS_STORE = 'keys';
const SHARED_STORE = 'shared_keys';

// Message prefix that signals an encrypted payload
export const E2E_PREFIX = 'E2E:';
export const KEY_EXCHANGE_PREFIX = '__KEY_EXCHANGE__:';

// ── IndexedDB Helpers ─────────────────────────────────────────────

function openDB() {
  return new Promise((resolve, reject) => {
    const req = indexedDB.open(DB_NAME, DB_VERSION);
    req.onupgradeneeded = () => {
      const db = req.result;
      if (!db.objectStoreNames.contains(KEYS_STORE)) {
        db.createObjectStore(KEYS_STORE);
      }
      if (!db.objectStoreNames.contains(SHARED_STORE)) {
        db.createObjectStore(SHARED_STORE);
      }
    };
    req.onsuccess = () => resolve(req.result);
    req.onerror = () => reject(req.error);
  });
}

async function dbGet(storeName, key) {
  const db = await openDB();
  return new Promise((resolve, reject) => {
    const tx = db.transaction(storeName, 'readonly');
    const store = tx.objectStore(storeName);
    const req = store.get(key);
    req.onsuccess = () => resolve(req.result ?? null);
    req.onerror = () => reject(req.error);
  });
}

async function dbPut(storeName, key, value) {
  const db = await openDB();
  return new Promise((resolve, reject) => {
    const tx = db.transaction(storeName, 'readwrite');
    const store = tx.objectStore(storeName);
    const req = store.put(value, key);
    req.onsuccess = () => resolve();
    req.onerror = () => reject(req.error);
  });
}

// ── Key Generation ────────────────────────────────────────────────

/**
 * Generate an ECDH key pair (P-256) for the current user.
 * Stored in IndexedDB under the user's phone number.
 */
export async function generateKeyPair(userPhone) {
  const existing = await dbGet(KEYS_STORE, `keypair:${userPhone}`);
  if (existing) {
    console.log('[E2EE] Key pair already exists for', userPhone);
    return;
  }

  const keyPair = await crypto.subtle.generateKey(
    { name: 'ECDH', namedCurve: 'P-256' },
    true, // extractable — needed to export public key
    ['deriveKey', 'deriveBits']
  );

  // Export keys for storage
  const publicKeyJwk = await crypto.subtle.exportKey('jwk', keyPair.publicKey);
  const privateKeyJwk = await crypto.subtle.exportKey('jwk', keyPair.privateKey);

  await dbPut(KEYS_STORE, `keypair:${userPhone}`, {
    publicKey: publicKeyJwk,
    privateKey: privateKeyJwk,
  });

  console.log('[E2EE] Generated new ECDH key pair for', userPhone);
}

/**
 * Get our public key as a JSON string (for sharing with contacts).
 */
export async function getPublicKeyString(userPhone) {
  const stored = await dbGet(KEYS_STORE, `keypair:${userPhone}`);
  if (!stored) throw new Error('No key pair found — call generateKeyPair first');
  return JSON.stringify(stored.publicKey);
}

/**
 * Get our private key as a CryptoKey object.
 */
async function getPrivateKey(userPhone) {
  const stored = await dbGet(KEYS_STORE, `keypair:${userPhone}`);
  if (!stored) throw new Error('No key pair found');
  return crypto.subtle.importKey(
    'jwk',
    stored.privateKey,
    { name: 'ECDH', namedCurve: 'P-256' },
    false,
    ['deriveKey', 'deriveBits']
  );
}

// ── Key Exchange ──────────────────────────────────────────────────

/**
 * Store a contact's public key and derive the shared AES key.
 */
export async function processReceivedPublicKey(userPhone, contactPhone, publicKeyJsonString) {
  try {
    const contactPublicKeyJwk = JSON.parse(publicKeyJsonString);

    // Import contact's public key
    const contactPublicKey = await crypto.subtle.importKey(
      'jwk',
      contactPublicKeyJwk,
      { name: 'ECDH', namedCurve: 'P-256' },
      false,
      []
    );

    // Get our private key
    const privateKey = await getPrivateKey(userPhone);

    // Derive shared bits via ECDH
    const sharedBits = await crypto.subtle.deriveBits(
      { name: 'ECDH', public: contactPublicKey },
      privateKey,
      256
    );

    // Derive a proper AES-256-GCM key via HKDF
    const hkdfKey = await crypto.subtle.importKey(
      'raw',
      sharedBits,
      'HKDF',
      false,
      ['deriveKey']
    );

    const aesKey = await crypto.subtle.deriveKey(
      {
        name: 'HKDF',
        hash: 'SHA-256',
        salt: new TextEncoder().encode('messenger-e2ee-salt'),
        info: new TextEncoder().encode('messenger-aes-key'),
      },
      hkdfKey,
      { name: 'AES-GCM', length: 256 },
      true, // extractable for storage
      ['encrypt', 'decrypt']
    );

    // Export and store the shared AES key
    const aesKeyJwk = await crypto.subtle.exportKey('jwk', aesKey);

    // Store bidirectionally (same key for both directions)
    const pairKey = getConversationKey(userPhone, contactPhone);
    await dbPut(SHARED_STORE, pairKey, aesKeyJwk);

    console.log('[E2EE] Derived shared key for conversation with', contactPhone);
    return true;
  } catch (err) {
    console.error('[E2EE] Failed to process public key:', err);
    return false;
  }
}

/**
 * Check if we have a shared key with a contact.
 */
export async function hasSharedKey(userPhone, contactPhone) {
  const pairKey = getConversationKey(userPhone, contactPhone);
  const stored = await dbGet(SHARED_STORE, pairKey);
  return !!stored;
}

/**
 * Get the stored AES shared key for a conversation.
 */
async function getSharedAESKey(userPhone, contactPhone) {
  const pairKey = getConversationKey(userPhone, contactPhone);
  const stored = await dbGet(SHARED_STORE, pairKey);
  if (!stored) return null;

  return crypto.subtle.importKey(
    'jwk',
    stored,
    { name: 'AES-GCM', length: 256 },
    false,
    ['encrypt', 'decrypt']
  );
}

function getConversationKey(phone1, phone2) {
  // Deterministic key regardless of order
  return [phone1, phone2].sort().join(':');
}

// ── Encrypt / Decrypt ─────────────────────────────────────────────

/**
 * Encrypt a plaintext message for a specific contact.
 * Returns: "E2E:<iv_base64>:<ciphertext_base64>"
 * Returns null if no shared key exists (key exchange not yet done).
 */
export async function encryptMessage(userPhone, contactPhone, plaintext) {
  const aesKey = await getSharedAESKey(userPhone, contactPhone);
  if (!aesKey) {
    console.warn('[E2EE] No shared key for', contactPhone, '— sending plaintext');
    return null;
  }

  const iv = crypto.getRandomValues(new Uint8Array(12)); // 96-bit IV for GCM
  const encoded = new TextEncoder().encode(plaintext);

  const ciphertext = await crypto.subtle.encrypt(
    { name: 'AES-GCM', iv },
    aesKey,
    encoded
  );

  const ivB64 = arrayBufferToBase64(iv);
  const ctB64 = arrayBufferToBase64(new Uint8Array(ciphertext));

  return `${E2E_PREFIX}${ivB64}:${ctB64}`;
}

/**
 * Decrypt an E2E-encrypted message.
 * Input: "E2E:<iv_base64>:<ciphertext_base64>"
 * Returns the plaintext, or null if decryption fails.
 */
export async function decryptMessage(userPhone, contactPhone, encryptedPayload) {
  if (!encryptedPayload || !encryptedPayload.startsWith(E2E_PREFIX)) {
    return encryptedPayload; // Not encrypted, return as-is
  }

  const aesKey = await getSharedAESKey(userPhone, contactPhone);
  if (!aesKey) {
    console.warn('[E2EE] No shared key to decrypt message from', contactPhone);
    return '🔒 Encrypted message (key not available)';
  }

  try {
    const payload = encryptedPayload.slice(E2E_PREFIX.length);
    const [ivB64, ctB64] = payload.split(':');

    const iv = base64ToArrayBuffer(ivB64);
    const ciphertext = base64ToArrayBuffer(ctB64);

    const decrypted = await crypto.subtle.decrypt(
      { name: 'AES-GCM', iv },
      aesKey,
      ciphertext
    );

    return new TextDecoder().decode(decrypted);
  } catch (err) {
    console.error('[E2EE] Decryption failed:', err);
    return '🔒 Decryption failed';
  }
}

/**
 * Check if a message payload is an E2E encrypted message.
 */
export function isEncryptedMessage(message) {
  return message && message.startsWith(E2E_PREFIX);
}

/**
 * Check if a message is a key exchange message.
 */
export function isKeyExchangeMessage(message) {
  return message && message.startsWith(KEY_EXCHANGE_PREFIX);
}

/**
 * Extract the public key from a key exchange message.
 */
export function extractPublicKey(message) {
  if (!isKeyExchangeMessage(message)) return null;
  return message.slice(KEY_EXCHANGE_PREFIX.length);
}

/**
 * Create a key exchange message containing our public key.
 */
export async function createKeyExchangeMessage(userPhone) {
  const pubKey = await getPublicKeyString(userPhone);
  return `${KEY_EXCHANGE_PREFIX}${pubKey}`;
}

// ── Base64 Helpers ────────────────────────────────────────────────

function arrayBufferToBase64(buffer) {
  const bytes = buffer instanceof Uint8Array ? buffer : new Uint8Array(buffer);
  let binary = '';
  for (let i = 0; i < bytes.length; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return btoa(binary);
}

function base64ToArrayBuffer(base64) {
  const binary = atob(base64);
  const bytes = new Uint8Array(binary.length);
  for (let i = 0; i < binary.length; i++) {
    bytes[i] = binary.charCodeAt(i);
  }
  return bytes;
}
