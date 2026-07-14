import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/server_config_provider.dart';
import '../../services/storage_service.dart';

/// Settings screen — profile, server URL, logout.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = context.read<StorageService>();
    final serverConfig = context.read<ServerConfigProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // ── Profile card ──
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                  child: Text(
                    _initials(storage.userFirstName, storage.userLastName),
                    style: GoogleFonts.outfit(
                      color: AppTheme.primaryLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        storage.userName ?? 'User',
                        style: GoogleFonts.inter(
                          color: AppTheme.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        storage.userPhone ?? '',
                        style: TextStyle(
                          color: AppTheme.onSurfaceDim,
                          fontSize: 13,
                        ),
                      ),
                      if (storage.userEmail != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          storage.userEmail!,
                          style: TextStyle(
                            color: AppTheme.onSurfaceDim,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 8),

          // ── Server URL ──
          _SettingsTile(
            icon: Icons.dns_rounded,
            iconColor: AppTheme.accent,
            title: 'Server URL',
            subtitle: serverConfig.currentUrl ?? 'Not configured',
            onTap: () => Navigator.pushReplacementNamed(
                context, AppRoutes.serverConfig),
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

          // ── Connection status ──
          Consumer<ChatProvider>(
            builder: (_, chat, __) {
              return _SettingsTile(
                icon: chat.isConnected
                    ? Icons.wifi_rounded
                    : Icons.wifi_off_rounded,
                iconColor:
                    chat.isConnected ? AppTheme.success : AppTheme.error,
                title: 'Connection',
                subtitle: chat.isConnected
                    ? 'Connected to server'
                    : 'Disconnected',
                onTap: () {
                  if (chat.isConnected) {
                    chat.disconnect();
                  } else {
                    chat.connect();
                  }
                },
              );
            },
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

          const Divider(indent: 16, endIndent: 16),

          // ── Logout ──
          _SettingsTile(
            icon: Icons.logout_rounded,
            iconColor: AppTheme.error,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppTheme.surfaceVariant,
                  title: Text('Logout',
                      style: TextStyle(color: AppTheme.onSurface)),
                  content: Text(
                      'Are you sure you want to sign out?',
                      style: TextStyle(color: AppTheme.onSurfaceDim)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style:
                          TextButton.styleFrom(foregroundColor: AppTheme.error),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                context.read<ChatProvider>().disconnect();
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.login, (route) => false);
                }
              }
            },
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

          const SizedBox(height: 40),

          // ── App version ──
          Center(
            child: Text(
              'Messenger v1.0.0',
              style: TextStyle(
                color: AppTheme.onSurfaceDim.withValues(alpha: 0.4),
                fontSize: 12,
              ),
            ),
          ).animate().fadeIn(delay: 500.ms),
        ],
      ),
    );
  }

  String _initials(String? first, String? last) {
    final f = (first?.isNotEmpty == true) ? first![0] : '';
    final l = (last?.isNotEmpty == true) ? last![0] : '';
    return '$f$l'.toUpperCase();
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          color: AppTheme.onSurface,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: AppTheme.onSurfaceDim, fontSize: 13),
      ),
      trailing: Icon(Icons.chevron_right_rounded,
          color: AppTheme.onSurfaceDim, size: 20),
      onTap: onTap,
    );
  }
}
