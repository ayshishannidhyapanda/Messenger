import { useState } from 'react';
import { register as apiRegister } from '../services/api';
import './AuthScreens.css';

export default function RegisterScreen({ onSwitchToLogin, onSwitchToOtp }) {
  const [form, setForm] = useState({
    firstName: '', lastName: '', mobNumber: '', email: '', password: '',
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  const update = (field) => (e) => setForm({ ...form, [field]: e.target.value });

  const handleRegister = async (e) => {
    e.preventDefault();
    if (!form.firstName || !form.lastName || !form.mobNumber || !form.email || !form.password) {
      setError('Please fill in all fields');
      return;
    }

    setLoading(true);
    setError('');
    setSuccess('');

    try {
      await apiRegister({ ...form, mobNumber: `+91${form.mobNumber.replace(/\D/g, '')}` });
      setSuccess('Account created! Check your phone/email for the OTP.');
      setTimeout(() => onSwitchToOtp(), 2000);
    } catch (err) {
      setError(err.message || 'Registration failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="auth-screen">
      <div className="auth-bg">
        <div className="auth-orb auth-orb--1" />
        <div className="auth-orb auth-orb--2" />
      </div>
      <form className="auth-card" onSubmit={handleRegister}>
        <div className="auth-logo">
          <svg viewBox="0 0 40 40" fill="none" width="48" height="48">
            <defs>
              <linearGradient id="lg2" x1="0" y1="0" x2="40" y2="40">
                <stop offset="0%" stopColor="#6366F1" />
                <stop offset="100%" stopColor="#06B6D4" />
              </linearGradient>
            </defs>
            <rect width="40" height="40" rx="10" fill="url(#lg2)" />
            <path d="M10 15C10 12.24 12.24 10 15 10H25C27.76 10 30 12.24 30 15V22.5C30 25.26 27.76 27.5 25 27.5H17.5L12.5 31.25V27.5H15C12.24 27.5 10 25.26 10 22.5V15Z" fill="white" fillOpacity="0.95" />
            <circle cx="15.5" cy="18.75" r="1.875" fill="#6366F1" />
            <circle cx="20" cy="18.75" r="1.875" fill="#818CF8" />
            <circle cx="24.5" cy="18.75" r="1.875" fill="#06B6D4" />
          </svg>
        </div>
        <h1 className="auth-title">Create Account</h1>
        <p className="auth-subtitle">Join Messenger today</p>

        <div className="form-row">
          <div className="form-group">
            <label htmlFor="regFirst">First Name</label>
            <input id="regFirst" type="text" value={form.firstName} onChange={update('firstName')} placeholder="John" />
          </div>
          <div className="form-group">
            <label htmlFor="regLast">Last Name</label>
            <input id="regLast" type="text" value={form.lastName} onChange={update('lastName')} placeholder="Doe" />
          </div>
        </div>

        <div className="form-group">
          <label htmlFor="regMob">Mobile Number</label>
          <div className="phone-input-group">
            <span className="phone-prefix">+91</span>
            <input
              id="regMob"
              type="text"
              value={form.mobNumber}
              onChange={(e) => setForm({ ...form, mobNumber: e.target.value.replace(/\D/g, '').slice(0, 10) })}
              placeholder="XXXXXXXXXX"
              maxLength={10}
            />
          </div>
        </div>

        <div className="form-group">
          <label htmlFor="regEmail">Email</label>
          <input id="regEmail" type="email" value={form.email} onChange={update('email')} placeholder="you@example.com" />
        </div>

        <div className="form-group">
          <label htmlFor="regPass">Password</label>
          <input id="regPass" type="password" value={form.password} onChange={update('password')} placeholder="Min 6 characters" />
        </div>

        <button type="submit" className="btn btn--primary btn--full" disabled={loading}>
          {loading ? <span className="btn-spinner" /> : 'Create Account'}
        </button>

        {error && <div className="error-msg">{error}</div>}
        {success && <div className="success-msg">{success}</div>}

        <p className="auth-footer">
          Already have an account?{' '}
          <a href="#" onClick={(e) => { e.preventDefault(); onSwitchToLogin(); }}>
            Sign In
          </a>
        </p>
      </form>
    </div>
  );
}
