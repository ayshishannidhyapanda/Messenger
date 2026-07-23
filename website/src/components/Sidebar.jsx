import './Sidebar.css';

function getInitials(name) {
  if (!name) return '?';
  return name
    .split(' ')
    .map((w) => w[0])
    .join('')
    .slice(0, 2)
    .toUpperCase();
}

export default function Sidebar({
  conversations,
  activeChat,
  onSelectChat,
  onNewChat,
  onLogout,
  connectionStatus,
  onlineUsers,
  user,
  visible,
  encryptedChats = new Set(),
}) {
  const statusClass =
    connectionStatus === 'connected'
      ? 'status--connected'
      : connectionStatus === 'connecting'
      ? 'status--connecting'
      : 'status--disconnected';

  const statusLabel =
    connectionStatus === 'connected'
      ? 'Connected'
      : connectionStatus === 'connecting'
      ? 'Connecting...'
      : 'Disconnected';

  return (
    <aside className={`sidebar ${visible ? '' : 'sidebar--hidden'}`}>
      {/* Header */}
      <div className="sidebar-header">
        <div className="sidebar-brand">
          <svg viewBox="0 0 32 32" fill="none" width="28" height="28">
            <defs>
              <linearGradient id="sbG" x1="0" y1="0" x2="32" y2="32">
                <stop offset="0%" stopColor="#6366F1" />
                <stop offset="100%" stopColor="#06B6D4" />
              </linearGradient>
            </defs>
            <rect width="32" height="32" rx="8" fill="url(#sbG)" />
            <path d="M8 12C8 9.79 9.79 8 12 8H20C22.21 8 24 9.79 24 12V18C24 20.21 22.21 22 20 22H14L10 25V22H12C9.79 22 8 20.21 8 18V12Z" fill="white" fillOpacity="0.95" />
            <circle cx="12.5" cy="15" r="1.5" fill="#6366F1" />
            <circle cx="16" cy="15" r="1.5" fill="#818CF8" />
            <circle cx="19.5" cy="15" r="1.5" fill="#06B6D4" />
          </svg>
          <span>Messenger</span>
        </div>
        <button className="icon-btn" onClick={onNewChat} title="New Chat" aria-label="New Chat">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <line x1="12" y1="5" x2="12" y2="19" />
            <line x1="5" y1="12" x2="19" y2="12" />
          </svg>
        </button>
      </div>

      {/* Connection Status */}
      <div className={`connection-status ${statusClass}`}>
        <span className="status-dot" />
        <span>{statusLabel}</span>
      </div>

      {/* Conversations */}
      <div className="contacts-list">
        {conversations.length === 0 ? (
          <div className="contacts-empty">
            <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="var(--text-dim)" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
              <path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z" />
            </svg>
            <p>No conversations yet</p>
            <span>Start a new chat to begin messaging</span>
          </div>
        ) : (
          conversations.map((conv) => (
            <div
              key={conv.phone}
              className={`contact-item ${activeChat === conv.phone ? 'active' : ''}`}
              onClick={() => onSelectChat(conv.phone)}
            >
              <div className="contact-avatar">{getInitials(conv.name)}</div>
              {onlineUsers.has(conv.phone) && <span className="contact-online-dot" />}
              <div className="contact-info">
                <div className="contact-name">
                  {conv.name || conv.phone}
                  {encryptedChats.has(conv.phone) && <span className="contact-lock" title="E2E Encrypted">🔒</span>}
                </div>
                <div className="contact-last-msg">{conv.lastMessage || 'Tap to chat'}</div>
              </div>
              <div className="contact-meta">
                {conv.time && <span className="contact-time">{conv.time}</span>}
                {conv.unread > 0 && <span className="contact-unread">{conv.unread}</span>}
              </div>
            </div>
          ))
        )}
      </div>

      {/* User Footer */}
      <div className="sidebar-footer">
        <div className="user-info">
          <div className="user-avatar">{getInitials(`${user?.firstName} ${user?.lastName}`)}</div>
          <div className="user-details">
            <span className="user-name">{user?.firstName} {user?.lastName}</span>
            <span className="user-phone">{user?.mobNumber}</span>
          </div>
        </div>
        <button className="icon-btn" onClick={onLogout} title="Logout" aria-label="Logout">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4" />
            <polyline points="16 17 21 12 16 7" />
            <line x1="21" y1="12" x2="9" y2="12" />
          </svg>
        </button>
      </div>
    </aside>
  );
}
