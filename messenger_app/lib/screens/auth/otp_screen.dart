import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../config/app_theme.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';

/// OTP verification screen.
class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String? _identifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _identifier ??= ModalRoute.of(context)?.settings.arguments as String?;
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    final otp = _otpCode;
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full 6-digit OTP')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.verifyOtp(
      OtpVerifyRequest(identifier: _identifier ?? '', otp: otp),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Phone verified! Please sign in.'),
          backgroundColor: AppTheme.success,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.login, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.subtleGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Icon ──
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(Icons.verified_user_rounded,
                        color: AppTheme.primary, size: 36),
                  ).animate().fadeIn(duration: 400.ms).scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                        duration: 400.ms,
                        curve: Curves.easeOutBack,
                      ),

                  const SizedBox(height: 24),

                  Text(
                    'Verification Code',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.onSurface,
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 8),

                  Text(
                    'We sent a 6-digit code to\n${_identifier ?? "your phone"}',
                    style: TextStyle(color: AppTheme.onSurfaceDim, fontSize: 14),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 36),

                  // ── OTP fields ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (i) {
                      return Container(
                        width: 46,
                        height: 54,
                        margin: EdgeInsets.only(
                          left: i == 0 ? 0 : 8,
                          right: i == 2 ? 12 : 0, // gap in middle
                        ),
                        child: TextFormField(
                          controller: _controllers[i],
                          focusNode: _focusNodes[i],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            contentPadding: EdgeInsets.zero,
                            filled: true,
                            fillColor: AppTheme.surfaceVariant,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color: AppTheme.primary, width: 2),
                            ),
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (val) {
                            if (val.isNotEmpty && i < 5) {
                              _focusNodes[i + 1].requestFocus();
                            } else if (val.isEmpty && i > 0) {
                              _focusNodes[i - 1].requestFocus();
                            }
                            if (_otpCode.length == 6) {
                              _verify();
                            }
                          },
                        ),
                      ).animate().fadeIn(
                            delay: Duration(milliseconds: 400 + i * 60),
                            duration: 300.ms,
                          );
                    }),
                  ),

                  const SizedBox(height: 16),

                  // ── Error ──
                  Consumer<AuthProvider>(
                    builder: (_, auth, __) {
                      if (auth.errorMessage == null) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
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

                  const SizedBox(height: 28),

                  // ── Verify button ──
                  Consumer<AuthProvider>(
                    builder: (_, auth, __) {
                      return SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: auth.isLoading ? null : _verify,
                          child: auth.isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5, color: Colors.white))
                              : Text('Verify',
                                  style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                        ),
                      );
                    },
                  ).animate().fadeIn(delay: 700.ms, duration: 400.ms),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () {
                      // TODO: resend OTP
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('OTP resent!')),
                      );
                    },
                    child: Text('Resend Code',
                        style: TextStyle(color: AppTheme.onSurfaceDim)),
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
