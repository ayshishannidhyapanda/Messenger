import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/server_config_provider.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/chat_service.dart';
import 'services/server_config_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for the dark theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A0A0F),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialise storage (SharedPreferences)
  final storage = StorageService();
  await storage.init();

  // Build the service graph
  final serverConfigService = ServerConfigService(storage);
  final apiService = ApiService(serverConfigService, storage);
  final authService = AuthService(apiService, storage);
  final chatSocketService = ChatSocketService(serverConfigService, storage);

  runApp(
    MultiProvider(
      providers: [
        // ── Services (non-listenable, available via Provider.of / context.read) ──
        Provider<StorageService>.value(value: storage),
        Provider<ServerConfigService>.value(value: serverConfigService),
        Provider<ApiService>.value(value: apiService),
        Provider<AuthService>.value(value: authService),
        Provider<ChatSocketService>.value(value: chatSocketService),

        // ── Providers (listenable, available via Consumer / context.watch) ──
        ChangeNotifierProvider(
          create: (_) => ServerConfigProvider(serverConfigService),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService, storage),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(
            chatSocketService,
            storage.userPhone ?? '',
          ),
        ),
      ],
      child: const MessengerApp(),
    ),
  );
}
