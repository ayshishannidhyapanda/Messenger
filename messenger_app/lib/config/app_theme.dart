import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Premium dark theme for the Messenger app.
class AppTheme {
  AppTheme._();

  // ── Brand colours ──────────────────────────────────────────────────────
  static const Color _primary = Color(0xFF6366F1);       // Indigo-500
  static const Color _primaryLight = Color(0xFF818CF8);   // Indigo-400
  static const Color _accent = Color(0xFF06B6D4);         // Cyan-500
  static const Color _surface = Color(0xFF111118);         // Deep dark
  static const Color _surfaceVariant = Color(0xFF1A1A24);  // Card dark
  static const Color _background = Color(0xFF0A0A0F);     // Deepest dark
  static const Color _onSurface = Color(0xFFE2E8F0);      // Slate-200
  static const Color _onSurfaceDim = Color(0xFF94A3B8);   // Slate-400
  static const Color _error = Color(0xFFF87171);          // Red-400
  static const Color _success = Color(0xFF34D399);        // Emerald-400
  static const Color _sentBubble = Color(0xFF4338CA);     // Indigo-700
  static const Color _receivedBubble = Color(0xFF1E1E2E); // Dark surface

  // ── Gradients ──────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [_primary, _accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient subtleGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ── Colours accessors ──────────────────────────────────────────────────
  static Color get primary => _primary;
  static Color get primaryLight => _primaryLight;
  static Color get accent => _accent;
  static Color get surface => _surface;
  static Color get surfaceVariant => _surfaceVariant;
  static Color get background => _background;
  static Color get onSurface => _onSurface;
  static Color get onSurfaceDim => _onSurfaceDim;
  static Color get error => _error;
  static Color get success => _success;
  static Color get sentBubble => _sentBubble;
  static Color get receivedBubble => _receivedBubble;

  // ── ThemeData ──────────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _background,
      colorScheme: const ColorScheme.dark(
        primary: _primary,
        secondary: _accent,
        surface: _surface,
        error: _error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _onSurface,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: _onSurface,
        displayColor: _onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: _surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _onSurface,
        ),
        iconTheme: const IconThemeData(color: _onSurface),
      ),
      cardTheme: CardThemeData(
        color: _surfaceVariant,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: TextStyle(color: _onSurfaceDim.withValues(alpha: 0.6)),
        labelStyle: const TextStyle(color: _onSurfaceDim),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryLight,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _surfaceVariant,
        contentTextStyle: GoogleFonts.inter(color: _onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.06),
        thickness: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _surface,
        selectedItemColor: _primary,
        unselectedItemColor: _onSurfaceDim,
      ),
    );
  }
}
