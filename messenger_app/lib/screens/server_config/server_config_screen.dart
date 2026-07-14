import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../providers/server_config_provider.dart';

/// Screen where users enter and test their server URL.
/// Shown on first launch or when the server URL needs to change.
class ServerConfigScreen extends StatefulWidget {
  const ServerConfigScreen({super.key});

  @override
  State<ServerConfigScreen> createState() => _ServerConfigScreenState();
}

class _ServerConfigScreenState extends State<ServerConfigScreen> {
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final provider = context.read<ServerConfigProvider>();
    if (provider.currentUrl != null) {
      _urlController.text = provider.currentUrl!;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testAndSave() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ServerConfigProvider>();
    final url = _urlController.text.trim();

    final success = await provider.testConnection(url);
    if (success && mounted) {
      await provider.saveUrl(url);
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.subtleGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ── Icon ──
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.dns_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ).animate().fadeIn(duration: 500.ms).scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1, 1),
                          duration: 500.ms,
                          curve: Curves.easeOutBack,
                        ),

                    const SizedBox(height: 32),

                    // ── Title ──
                    Text(
                      'Connect to Server',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurface,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                    const SizedBox(height: 8),

                    Text(
                      'Enter your Messenger server URL to get started',
                      style: TextStyle(
                        color: AppTheme.onSurfaceDim,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                    const SizedBox(height: 40),

                    // ── URL Input ──
                    TextFormField(
                      controller: _urlController,
                      keyboardType: TextInputType.url,
                      autocorrect: false,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Server URL',
                        hintText: 'e.g. http://192.168.1.5:8080',
                        prefixIcon: Icon(
                          Icons.link_rounded,
                          color: AppTheme.onSurfaceDim,
                        ),
                        suffixIcon: Consumer<ServerConfigProvider>(
                          builder: (_, provider, __) {
                            if (provider.isTesting) {
                              return const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }
                            if (provider.testResult == true) {
                              return Icon(Icons.check_circle,
                                  color: AppTheme.success);
                            }
                            if (provider.testResult == false) {
                              return Icon(Icons.error, color: AppTheme.error);
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a server URL';
                        }
                        return null;
                      },
                      onChanged: (_) {
                        context.read<ServerConfigProvider>().resetTestState();
                      },
                    ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(
                          begin: 0.1,
                          end: 0,
                          delay: 400.ms,
                          duration: 400.ms,
                        ),

                    const SizedBox(height: 12),

                    // ── Error message ──
                    Consumer<ServerConfigProvider>(
                      builder: (_, provider, __) {
                        if (provider.errorMessage == null) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.error.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  color: AppTheme.error, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  provider.errorMessage!,
                                  style: TextStyle(
                                    color: AppTheme.error,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 300.ms);
                      },
                    ),

                    const SizedBox(height: 24),

                    // ── Hints card ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '💡 Tips',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onSurface,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _hintRow('Same WiFi:', 'http://<PC-IP>:8080'),
                          _hintRow('ngrok:', 'https://xxxx.ngrok.io'),
                          _hintRow('Cloud:', 'https://your-domain.com'),
                        ],
                      ),
                    ).animate().fadeIn(delay: 500.ms, duration: 400.ms),

                    const SizedBox(height: 32),

                    // ── Connect button ──
                    Consumer<ServerConfigProvider>(
                      builder: (_, provider, __) {
                        return SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: provider.isTesting ? null : _testAndSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: provider.isTesting
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.power_settings_new,
                                          size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Test & Connect',
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      },
                    ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _hintRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(color: AppTheme.onSurfaceDim, fontSize: 12),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.accent,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
