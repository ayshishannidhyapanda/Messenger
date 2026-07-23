import { useState } from 'react';
import { login as apiLogin, setBaseUrl, isSelfHosted } from '../services/api';
import { useAuth } from '../context/AuthContext';
import './AuthScreens.css';

export default function LoginScreen({ onSwitchToRegister, onSwitchToOtp }) {
  const { loginUser } = useAuth();
  const [serverUrl, setServerUrl] = useState(localStorage.getItem('serverUrl') || 'http://localhost:8080');
  const [mobNumber, setMobNumber] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleLogin = async (e) => {
    e.preventDefault();
    if (!mobNumber.trim() || !password.trim()) {
      setError('Please fill in all fields');
      return;
    }

    setLoading(true);
    setError('');

    try {
      setBaseUrl(serverUrl);
      const fullPhone = `+91${mobNumber.replace(/\D/g, '')}`;
      const res = await apiLogin({ mobNumber: fullPhone, password });
      const userData = res.data || res;
      loginUser({
        mobNumber: userData.mobNumber || mobNumber,
        email: userData.email || '',
        firstName: userData.firstName || '',
        lastName: userData.lastName || '',
      });
    } catch (err) {
      setError(err.message || 'Login failed');
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
      <form className="auth-card" onSubmit={handleLogin}>
        <div className="auth-logo">
          <svg viewBox="0 0 40 40" fill="none" width="48" height="48">
            <defs>
              <linearGradient id="lg" x1="0" y1="0" x2="40" y2="40">
                <stop offset="0%" stopColor="#6366F1" />
                <stop offset="100%" stopColor="#06B6D4" />
              </linearGradient>
            </defs>
            <rect width="40" height="40" rx="10" fill="url(#lg)" />
            <path d="M10 15C10 12.24 12.24 10 15 10H25C27.76 10 30 12.24 30 15V22.5C30 25.26 27.76 27.5 25 27.5H17.5L12.5 31.25V27.5H15C12.24 27.5 10 25.26 10 22.5V15Z" fill="white" fillOpacity="0.95" />
            <circle cx="15.5" cy="18.75" r="1.875" fill="#6366F1" />
            <circle cx="20" cy="18.75" r="1.875" fill="#818CF8" />
            <circle cx="24.5" cy="18.75" r="1.875" fill="#06B6D4" />
          </svg>
        </div>
        <h1 className="auth-title">Messenger</h1>
        <p className="auth-subtitle">Sign in to your account</p>

        {!isSelfHosted() && (
          <div className="form-group">
            <label htmlFor="serverUrl">Server URL</label>
            <input
              id="serverUrl"
              type="text"
              value={serverUrl}
              onChange={(e) => setServerUrl(e.target.value)}
              placeholder="http://localhost:8080"
            />
          </div>
        )}

        <div className="form-group">
          <label htmlFor="mobNumber">Mobile Number</label>
          <div className="phone-input-group">
            <span className="phone-prefix">+91</span>
            <input
              id="mobNumber"
              type="text"
              value={mobNumber}
              onChange={(e) => setMobNumber(e.target.value.replace(/\D/g, '').slice(0, 10))}
              placeholder="XXXXXXXXXX"
              maxLength={10}
              autoComplete="tel"
            />
          </div>
        </div>

        <div className="form-group">
          <label htmlFor="password">Password</label>
          <input
            id="password"
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="Enter your password"
            autoComplete="current-password"
          />
        </div>

        <button type="submit" className="btn btn--primary btn--full" disabled={loading}>
          {loading ? <span className="btn-spinner" /> : 'Sign In'}
        </button>

        {error && <div className="error-msg">{error}</div>}

        <p className="auth-footer">
          Don't have an account?{' '}
          <a href="#" onClick={(e) => { e.preventDefault(); onSwitchToRegister(); }}>
            Register
          </a>
        </p>
        <p className="auth-footer">
          <a href="#" onClick={(e) => { e.preventDefault(); onSwitchToOtp(); }}>
            Verify OTP
          </a>
        </p>
      </form>
    </div>
  );
}
