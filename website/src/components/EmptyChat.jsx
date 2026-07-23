import './EmptyChat.css';

export default function EmptyChat() {
  return (
    <div className="empty-chat">
      <div className="empty-chat-icon">
        <svg viewBox="0 0 64 64" fill="none" width="80" height="80">
          <defs>
            <linearGradient id="emG" x1="0" y1="0" x2="64" y2="64">
              <stop offset="0%" stopColor="#6366F1" stopOpacity="0.3" />
              <stop offset="100%" stopColor="#06B6D4" stopOpacity="0.3" />
            </linearGradient>
          </defs>
          <rect width="64" height="64" rx="16" fill="url(#emG)" />
          <path
            d="M16 24C16 19.58 19.58 16 24 16H40C44.42 16 48 19.58 48 24V36C48 40.42 44.42 44 40 44H28L20 50V44H24C19.58 44 16 40.42 16 36V24Z"
            fill="white" fillOpacity="0.15" stroke="white" strokeOpacity="0.3" strokeWidth="1.5"
          />
          <circle cx="25" cy="30" r="2.5" fill="white" fillOpacity="0.4" />
          <circle cx="32" cy="30" r="2.5" fill="white" fillOpacity="0.4" />
          <circle cx="39" cy="30" r="2.5" fill="white" fillOpacity="0.4" />
        </svg>
      </div>
      <h2>Welcome to Messenger</h2>
      <p>Select a conversation or start a new chat</p>
    </div>
  );
}
