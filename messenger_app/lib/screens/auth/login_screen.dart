import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';

/// Login screen — phone number + password.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      mobNumber: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
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
                    // ── Logo ──
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
                        Icons.chat_bubble_rounded,
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

                    Text(
                      'Welcome Back',
                      style: GoogleFonts.outfit(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.onSurface,
                      ),
                    ).animate().fadeIn(delay: 200.ms, duration: 400.ms),

                    const SizedBox(height: 6),

                    Text(
                      'Sign in to continue messaging',
                      style: TextStyle(color: AppTheme.onSurfaceDim, fontSize: 14),
                    ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

                    const SizedBox(height: 40),

                    // ── Phone field ──
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'e.g. 9876543210',
                        prefixIcon: Icon(Icons.phone_rounded,
                            color: AppTheme.onSurfaceDim),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(
                          begin: 0.1, end: 0, delay: 400.ms, duration: 400.ms),

                    const SizedBox(height: 16),

                    // ── Password field ──
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_rounded,
                            color: AppTheme.onSurfaceDim),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: AppTheme.onSurfaceDim,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ).animate().fadeIn(delay: 500.ms, duration: 400.ms).slideY(
                          begin: 0.1, end: 0, delay: 500.ms, duration: 400.ms),

                    const SizedBox(height: 12),

                    // ── Error message ──
                    Consumer<AuthProvider>(
                      builder: (_, auth, __) {
                        if (auth.errorMessage == null) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.error.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            auth.errorMessage!,
                            style:
                                TextStyle(color: AppTheme.error, fontSize: 13),
                          ),
                        ).animate().fadeIn(duration: 300.ms).shake();
                      },
                    ),

                    const SizedBox(height: 8),

                    // ── Login button ──
                    Consumer<AuthProvider>(
                      builder: (_, auth, __) {
                        return SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: auth.isLoading ? null : _login,
                            child: auth.isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5, color: Colors.white))
                                : Text('Sign In',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                          ),
                        );
                      },
                    ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

                    const SizedBox(height: 20),

                    // ── Register link ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ",
                            style: TextStyle(color: AppTheme.onSurfaceDim)),
                        TextButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.register),
                          child: const Text('Register'),
                        ),
                      ],
                    ).animate().fadeIn(delay: 700.ms, duration: 400.ms),

                    const SizedBox(height: 8),

                    // ── Change server ──
                    TextButton.icon(
                      onPressed: () => Navigator.pushReplacementNamed(
                          context, AppRoutes.serverConfig),
                      icon: Icon(Icons.dns_rounded,
                          size: 16, color: AppTheme.onSurfaceDim),
                      label: Text(
                        'Change Server',
                        style: TextStyle(
                            color: AppTheme.onSurfaceDim, fontSize: 13),
                      ),
                    ).animate().fadeIn(delay: 800.ms, duration: 400.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
