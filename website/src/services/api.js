/**
 * API service – mirrors the Spring Boot backend endpoints.
 *
 * Self-hosting mode: When the React app is built and served by Spring Boot
 * (same origin), all API calls use relative paths. No CORS issues.
 *
 * Dev mode: Uses the configured server URL (defaults to localhost:8080).
 */

const API = {
  register: '/api/v1/register',
  verifyOtp: '/api/v1/verifyOtp',
  login: '/api/v1/login',
  sendOtp: '/api/v1/sendOtp',
  wsEndpoint: '/api/ws',
};

// Auto-detect: if we're served from the same origin as the backend, use relative paths
function isSameOrigin() {
  // In production build served by Spring Boot, the page is at /api/web/
  // In dev mode, the page is at localhost:5173
  return window.location.pathname.startsWith('/api/web');
}

let baseUrl = isSameOrigin()
  ? ''  // same origin → relative paths
  : (localStorage.getItem('serverUrl') || 'http://localhost:8080');

export function getBaseUrl() {
  return baseUrl;
}

export function setBaseUrl(url) {
  if (isSameOrigin()) return; // Don't override in self-hosted mode
  baseUrl = url.replace(/\/+$/, '');
  localStorage.setItem('serverUrl', baseUrl);
}

export function getWsUrl() {
  if (isSameOrigin()) {
    // Same origin: derive WS URL from the page's own location
    const protocol = window.location.protocol === 'https:' ? 'wss' : 'ws';
    return `${protocol}://${window.location.host}${API.wsEndpoint}`;
  }
  const protocol = baseUrl.startsWith('https') ? 'wss' : 'ws';
  const host = baseUrl.replace(/^https?:\/\//, '');
  return `${protocol}://${host}${API.wsEndpoint}`;
}

export function isSelfHosted() {
  return isSameOrigin();
}

async function request(path, options = {}) {
  const url = `${baseUrl}${path}`;
  const res = await fetch(url, {
    credentials: 'include',
    ...options,
  });
  return res;
}

export async function login({ mobNumber, password, deviceModel, deviceOs, deviceId, deviceToken }) {
  const params = new URLSearchParams({
    mobNumber,
    password,
    deviceModel: deviceModel || 'Web Browser',
    deviceOs: deviceOs || navigator.platform || 'Web',
    deviceId: deviceId || crypto.randomUUID(),
    deviceToken: deviceToken || 'web-token',
  });

  const res = await request(`${API.login}?${params.toString()}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
  });

  const data = await res.json();
  if (!res.ok) throw new Error(data?.message || data?.error || 'Login failed');
  return data;
}

export async function register({ firstName, lastName, mobNumber, email, password }) {
  const res = await request(API.register, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ firstName, lastName, mobNumber, email, password }),
  });

  const data = await res.json();
  if (!res.ok) throw new Error(data?.message || data?.error || 'Registration failed');
  return data;
}

export async function verifyOtp({ identifier, otp }) {
  const res = await request(API.verifyOtp, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ identifier, otp }),
  });

  const text = await res.text();
  if (!res.ok) throw new Error(text || 'OTP verification failed');
  return text;
}

export async function sendOtp({ mobNumber }) {
  const res = await request(API.sendOtp, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ mobNumber }),
  });

  const text = await res.text();
  if (!res.ok) throw new Error(text || 'Failed to send OTP');
  return text;
}
