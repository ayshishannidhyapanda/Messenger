import { useState, useRef, useEffect } from 'react';
import './ChatView.css';

function getInitials(name) {
  if (!name) return '?';
  return name.split(' ').map((w) => w[0]).join('').slice(0, 2).toUpperCase();
}

function formatTime(ts) {
  if (!ts) return '';
  return new Date(ts).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
}

export default function ChatView({ phone, messages, onSend, onBack, isOnline, currentUser, conversationName, isEncrypted }) {
  const [text, setText] = useState('');
  const bottomRef = useRef(null);
  const inputRef = useRef(null);

  const displayName = conversationName || phone;

  // Auto-scroll on new messages
  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  // Focus input on chat switch
  useEffect(() => {
    inputRef.current?.focus();
  }, [phone]);

  const handleSend = (e) => {
    e?.preventDefault();
    if (!text.trim()) return;
    onSend(text);
    setText('');
  };

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  return (
    <div className="chat-view">
      {/* Header */}
      <div className="chat-header">
        <button className="icon-btn chat-back-btn" onClick={onBack} aria-label="Back">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <line x1="19" y1="12" x2="5" y2="12" />
            <polyline points="12 19 5 12 12 5" />
          </svg>
        </button>
        <div className="chat-header-avatar">{getInitials(displayName)}</div>
        <div className="chat-header-info">
          <h3>{displayName}</h3>
          <span className={`chat-header-status ${isOnline ? 'online' : ''}`}>
            {isOnline ? 'Online' : 'Offline'}
          </span>
        </div>
        {isEncrypted && (
          <div className="e2ee-badge" title="End-to-end encrypted">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <rect x="3" y="11" width="18" height="11" rx="2" ry="2" />
              <path d="M7 11V7a5 5 0 0110 0v4" />
            </svg>
            <span>E2EE</span>
          </div>
        )}
      </div>

      {/* Messages */}
      <div className="messages-container">
        {messages.length === 0 && (
          <div className="messages-empty-hint">
            <p>No messages yet. Say hello! 👋</p>
          </div>
        )}
        {messages.map((msg, i) => {
          const isSent = msg.sender === currentUser.mobNumber;
          return (
            <div key={msg.id || i} className={`message-row ${isSent ? 'sent' : 'received'}`}>
              <div className="message-bubble">
                <div className="message-text">{msg.message}</div>
                {msg.encrypted && <span className="msg-lock" title="Encrypted">🔒</span>}
                <div className="message-time">
                  {formatTime(msg.timestamp)}
                  {isSent && (
                    <span className="message-status">
                      {msg.isRead ? '✓✓' : msg.isReceived ? '✓✓' : '✓'}
                    </span>
                  )}
                </div>
              </div>
            </div>
          );
        })}
        <div ref={bottomRef} />
      </div>

      {/* Input */}
      <div className="message-input-area">
        <form className="message-input-wrap" onSubmit={handleSend}>
          <input
            ref={inputRef}
            type="text"
            value={text}
            onChange={(e) => setText(e.target.value)}
            onKeyDown={handleKeyDown}
            placeholder="Type a message..."
            autoComplete="off"
          />
          <button type="submit" className="send-btn" aria-label="Send message">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <line x1="22" y1="2" x2="11" y2="13" />
              <polygon points="22 2 15 22 11 13 2 9 22 2" />
            </svg>
          </button>
        </form>
      </div>
    </div>
  );
}
