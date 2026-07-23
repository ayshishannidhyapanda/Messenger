/**
 * STOMP-over-WebSocket chat service.
 * Mirrors the Flutter ChatSocketService.
 */
import { Client } from '@stomp/stompjs';
import { getWsUrl } from './api';

const STOMP = {
  sendPrivate: '/app/chat.private',
  queueMessages: '/user/queue/messages',
  queueErrors: '/user/queue/errors',
  topicPresence: '/topic/presence',
};

let client = null;
let listeners = {
  onMessage: [],
  onPresence: [],
  onError: [],
  onConnection: [],
};

export function onMessage(cb) { listeners.onMessage.push(cb); return () => { listeners.onMessage = listeners.onMessage.filter(l => l !== cb); }; }
export function onPresence(cb) { listeners.onPresence.push(cb); return () => { listeners.onPresence = listeners.onPresence.filter(l => l !== cb); }; }
export function onError(cb) { listeners.onError.push(cb); return () => { listeners.onError = listeners.onError.filter(l => l !== cb); }; }
export function onConnection(cb) { listeners.onConnection.push(cb); return () => { listeners.onConnection = listeners.onConnection.filter(l => l !== cb); }; }

function emit(type, data) {
  listeners[type].forEach(cb => {
    try { cb(data); } catch (e) { console.error('Listener error:', e); }
  });
}

export function isConnected() {
  return client?.connected ?? false;
}

export function connect() {
  if (client?.connected) return;

  const wsUrl = getWsUrl();
  console.log('[WS] Connecting to:', wsUrl);

  emit('onConnection', 'connecting');

  client = new Client({
    brokerURL: wsUrl,
    connectHeaders: {},
    reconnectDelay: 3000,
    heartbeatIncoming: 10000,
    heartbeatOutgoing: 10000,

    onConnect: () => {
      console.log('[WS] Connected');
      emit('onConnection', 'connected');

      client.subscribe(STOMP.queueMessages, (frame) => {
        try {
          const body = JSON.parse(frame.body);
          emit('onMessage', body);
        } catch (e) {
          console.error('[WS] Parse error:', e);
        }
      });

      client.subscribe(STOMP.queueErrors, (frame) => {
        try {
          const body = JSON.parse(frame.body);
          emit('onError', body.message || body.error || 'Unknown error');
        } catch {
          emit('onError', frame.body);
        }
      });

      client.subscribe(STOMP.topicPresence, (frame) => {
        try {
          const body = JSON.parse(frame.body);
          emit('onPresence', body);
        } catch {
          // ignore
        }
      });
    },

    onDisconnect: () => {
      console.log('[WS] Disconnected');
      emit('onConnection', 'disconnected');
    },

    onStompError: (frame) => {
      console.error('[WS] STOMP error:', frame.body);
      emit('onError', frame.body || 'STOMP error');
    },

    onWebSocketError: (event) => {
      console.error('[WS] WebSocket error:', event);
      emit('onConnection', 'disconnected');
    },

    onWebSocketClose: () => {
      emit('onConnection', 'disconnected');
    },
  });

  client.activate();
}

export function disconnect() {
  if (client) {
    client.deactivate();
    client = null;
  }
  emit('onConnection', 'disconnected');
}

export function sendPrivateMessage({ senderPhone, receiverPhone, message, messageType = 'TEXT' }) {
  if (!client?.connected) {
    console.warn('[WS] Not connected, cannot send');
    return false;
  }

  client.publish({
    destination: STOMP.sendPrivate,
    headers: {
      senderPhone,
      receiverPhone,
      'content-type': 'application/json',
    },
    body: JSON.stringify({
      message,
      messageType,
    }),
  });

  return true;
}
