import { useState } from 'react';
import { verifyOtp as apiVerifyOtp, sendOtp as apiSendOtp } from '../services/api';
import './AuthScreens.css';

export default function OtpScreen({ onSwitchToLogin }) {
  const [phone, setPhone] = useState('');
  const [otp, setOtp] = useState('');
  const [loading, setLoading] = useState(false);
  const [sending, setSending] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [otpSent, setOtpSent] = useState(false);

  const fullPhone = `+91${phone.replace(/\D/g, '')}`;

  const handleSendOtp = async () => {
    const digits = phone.replace(/\D/g, '');
    if (digits.length !== 10) {
      setError('Enter a valid 10-digit number');
      return;
    }

    setSending(true);
    setError('');
    setSuccess('');

    try {
      const res = await apiSendOtp({ mobNumber: fullPhone });
      setSuccess(res || `OTP sent to ${fullPhone}`);
      setOtpSent(true);
    } catch (err) {
      setError(err.message || 'Failed to send OTP');
    } finally {
      setSending(false);
    }
  };

  const handleVerify = async (e) => {
    e.preventDefault();
    if (!otp.trim()) {
      setError('Please enter the OTP');
      return;
    }

    setLoading(true);
    setError('');
    setSuccess('');

    try {
      const res = await apiVerifyOtp({ identifier: fullPhone, otp });
      setSuccess(res || 'OTP verified successfully!');
      setTimeout(() => onSwitchToLogin(), 2000);
    } catch (err) {
      setError(err.message || 'Verification failed');
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
      <form className="auth-card" onSubmit={handleVerify}>
        <div className="auth-logo">
          <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="url(#otpG)" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
            <defs>
              <linearGradient id="otpG" x1="0" y1="0" x2="24" y2="24">
                <stop offset="0%" stopColor="#6366F1" />
                <stop offset="100%" stopColor="#06B6D4" />
              </linearGradient>
            </defs>
            <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
          </svg>
        </div>
        <h1 className="auth-title">Verify OTP</h1>
        <p className="auth-subtitle">We'll send an OTP to your phone number</p>

        <div className="form-group">
          <label htmlFor="otpPhone">Phone Number</label>
          <div className="phone-input-group">
            <span className="phone-prefix">+91</span>
            <input
              id="otpPhone"
              type="text"
              value={phone}
              onChange={(e) => setPhone(e.target.value.replace(/\D/g, '').slice(0, 10))}
              placeholder="XXXXXXXXXX"
              maxLength={10}
              autoComplete="tel"
            />
          </div>
        </div>

        <button
          type="button"
          className="btn btn--send-otp btn--full"
          onClick={handleSendOtp}
          disabled={sending || phone.replace(/\D/g, '').length !== 10}
        >
          {sending ? <span className="btn-spinner" /> : otpSent ? 'Resend OTP' : 'Send OTP'}
        </button>

        {otpSent && (
          <>
            <div className="form-group" style={{ marginTop: 16 }}>
              <label htmlFor="otpCode">OTP Code</label>
              <input
                id="otpCode"
                type="text"
                value={otp}
                onChange={(e) => setOtp(e.target.value.replace(/\D/g, '').slice(0, 6))}
                placeholder="Enter 6-digit OTP"
                maxLength={6}
                autoComplete="one-time-code"
                autoFocus
              />
            </div>

            <button type="submit" className="btn btn--primary btn--full" disabled={loading || otp.length < 6}>
              {loading ? <span className="btn-spinner" /> : 'Verify'}
            </button>
          </>
        )}

        {error && <div className="error-msg">{error}</div>}
        {success && <div className="success-msg">{success}</div>}

        <p className="auth-footer">
          <a href="#" onClick={(e) => { e.preventDefault(); onSwitchToLogin(); }}>
            Back to Sign In
          </a>
        </p>
      </form>
    </div>
  );
}
