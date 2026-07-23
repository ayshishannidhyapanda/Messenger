import { useState } from 'react';
import './NewChatModal.css';

export default function NewChatModal({ onClose, onStart }) {
  const [phone, setPhone] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    if (phone.trim()) {
      onStart(phone.trim());
    }
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <h3>New Conversation</h3>
          <button className="icon-btn" onClick={onClose} aria-label="Close">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <line x1="18" y1="6" x2="6" y2="18" />
              <line x1="6" y1="6" x2="18" y2="18" />
            </svg>
          </button>
        </div>
        <form onSubmit={handleSubmit}>
          <div className="modal-body">
            <div className="form-group">
              <label htmlFor="newChatPhone">Recipient Phone Number</label>
              <input
                id="newChatPhone"
                type="text"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                placeholder="+91XXXXXXXXXX"
                autoFocus
                autoComplete="off"
              />
            </div>
          </div>
          <div className="modal-footer">
            <button type="submit" className="btn btn--primary">Start Chat</button>
          </div>
        </form>
      </div>
    </div>
  );
}
