import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_routes.dart';
import 'config/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/server_config/server_config_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'services/storage_service.dart';

/// Root widget — sets up theme, routing, and initial navigation.
class MessengerApp extends StatelessWidget {
  const MessengerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.read<StorageService>();
    final serverConfigured = storage.hasServerUrl;
    final hasSession = storage.hasSession;

    // Determine initial route
    String initialRoute;
    if (!serverConfigured) {
      initialRoute = AppRoutes.serverConfig;
    } else if (!hasSession) {
      initialRoute = AppRoutes.login;
    } else {
      initialRoute = AppRoutes.home;
    }

    return MaterialApp(
      title: 'Messenger',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: initialRoute,
      routes: {
        AppRoutes.serverConfig: (_) => const ServerConfigScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.otp: (_) => const OtpScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.chat: (_) => const ChatScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
      },
    );
  }
}
