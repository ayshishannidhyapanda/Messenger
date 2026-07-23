import { useState } from 'react';
import { AuthProvider, useAuth } from './context/AuthContext';
import LoginScreen from './screens/LoginScreen';
import RegisterScreen from './screens/RegisterScreen';
import OtpScreen from './screens/OtpScreen';
import ChatScreen from './screens/ChatScreen';

function AppRouter() {
  const { isAuthenticated } = useAuth();
  const [authView, setAuthView] = useState('login'); // 'login' | 'register' | 'otp'

  if (isAuthenticated) {
    return <ChatScreen />;
  }

  switch (authView) {
    case 'register':
      return (
        <RegisterScreen
          onSwitchToLogin={() => setAuthView('login')}
          onSwitchToOtp={() => setAuthView('otp')}
        />
      );
    case 'otp':
      return (
        <OtpScreen
          onSwitchToLogin={() => setAuthView('login')}
        />
      );
    default:
      return (
        <LoginScreen
          onSwitchToRegister={() => setAuthView('register')}
          onSwitchToOtp={() => setAuthView('otp')}
        />
      );
  }
}

export default function App() {
  return (
    <AuthProvider>
      <AppRouter />
    </AuthProvider>
  );
}
