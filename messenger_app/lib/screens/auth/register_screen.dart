import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';

/// Registration screen — collects user details.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final request = UserCreateRequest(
      username: _usernameCtrl.text.trim(),
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      mobNumber: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    final success = await auth.register(request);

    if (success && mounted) {
      // Navigate to OTP screen with the phone number
      Navigator.pushNamed(
        context,
        AppRoutes.otp,
        arguments: _phoneCtrl.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.subtleGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Join Messenger',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
                  ).animate().fadeIn(duration: 400.ms),

                  const SizedBox(height: 4),
                  Text(
                    'Fill in your details to get started',
                    style: TextStyle(color: AppTheme.onSurfaceDim, fontSize: 14),
                  ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

                  const SizedBox(height: 28),

                  _buildField(
                    controller: _usernameCtrl,
                    label: 'Username',
                    icon: Icons.alternate_email_rounded,
                    hint: 'min 3 characters',
                    validator: (v) => (v != null && v.length >= 3)
                        ? null
                        : 'Min 3 characters',
                    delay: 200,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          controller: _firstNameCtrl,
                          label: 'First Name',
                          icon: Icons.person_outline_rounded,
                          validator: (v) => (v != null && v.length >= 2)
                              ? null
                              : 'Min 2 chars',
                          delay: 300,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildField(
                          controller: _lastNameCtrl,
                          label: 'Last Name',
                          icon: Icons.person_outline_rounded,
                          validator: (v) => (v != null && v.length >= 2)
                              ? null
                              : 'Min 2 chars',
                          delay: 350,
                        ),
                      ),
                    ],
                  ),

                  _buildField(
                    controller: _phoneCtrl,
                    label: 'Phone Number',
                    icon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                    hint: '10-digit number',
                    validator: (v) => (v != null && v.length == 10)
                        ? null
                        : 'Enter 10-digit number',
                    delay: 400,
                  ),

                  _buildField(
                    controller: _emailCtrl,
                    label: 'Email',
                    icon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v != null && v.contains('@'))
                        ? null
                        : 'Enter valid email',
                    delay: 450,
                  ),

                  _buildField(
                    controller: _passwordCtrl,
                    label: 'Password',
                    icon: Icons.lock_rounded,
                    obscure: _obscure,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: AppTheme.onSurfaceDim,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    validator: (v) =>
                        (v != null && v.length >= 4) ? null : 'Min 4 chars',
                    delay: 500,
                  ),

                  // ── Error ──
                  Consumer<AuthProvider>(
                    builder: (_, auth, __) {
                      if (auth.errorMessage == null) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppTheme.error.withValues(alpha: 0.3)),
                        ),
                        child: Text(auth.errorMessage!,
                            style: TextStyle(
                                color: AppTheme.error, fontSize: 13)),
                      ).animate().fadeIn(duration: 300.ms);
                    },
                  ),

                  // ── Register button ──
                  Consumer<AuthProvider>(
                    builder: (_, auth, __) {
                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _register,
                          child: auth.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5, color: Colors.white))
                              : Text('Create Account',
                                  style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                        ),
                      );
                    },
                  ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

                  const SizedBox(height: 16),

                  // ── Login link ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ',
                          style: TextStyle(color: AppTheme.onSurfaceDim)),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Sign In'),
                      ),
                    ],
                  ).animate().fadeIn(delay: 700.ms, duration: 400.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    int delay = 0,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: AppTheme.onSurfaceDim),
          suffixIcon: suffixIcon,
        ),
        validator: validator,
      ).animate().fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms),
    );
  }
}
