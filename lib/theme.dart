import 'package:flutter/material.dart';

/// Design tokens extracted from `student/styles.css` / `mentor/styles.css`.
abstract class AppColors {
  // Primary
  static const primary = Color(0xFF1d4ed8);
  static const primaryDark = Color(0xFF1e40af);
  static const primaryLight = Color(0xFF3b82f6);

  // Secondary / accent
  static const secondary = Color(0xFF1e40af);
  static const accent = Color(0xFFdc2626);

  // Neutrals
  static const textPrimary = Color(0xFF2c3e50);
  static const textSecondary = Color(0xFF6c757d);
  static const textLight = Color(0xFF95a5a6);

  // Backgrounds
  static const bgPrimary = Color(0xFFffffff);
  static const bgSecondary = Color(0xFFf8f9fa);
  static const bgTertiary = Color(0xFFe9ecef);
  static const bgDark = Color(0xFF2c3e50);

  // Status
  static const success = Color(0xFF27ae60);
  static const warning = Color(0xFFf39c12);
  static const danger = Color(0xFFe74c3c);
  static const info = Color(0xFF3498db);

  // Status badge colors
  static const pendingBadgeFg = Color(0xFFd63031);
  static const submittedBadgeFg = Color(0xFF00693e);
  static const gradedBadgeFg = Color(0xFF0652dd);

  // Login button (matches .login-btn in styles.css)
  static const loginGradientStart = Color(0xFF4a90e2);
  static const loginGradientEnd = Color(0xFF357abd);

  // Error / success message (from styles.css)
  static const errorBg = Color(0xFFfee2e2);
  static const errorFg = Color(0xFF991b1b);
  static const successBg = Color(0xFFd1fae5);
  static const successFg = Color(0xFF065f46);
}

/// Shared ThemeData replicating the web app's CSS conventions.
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.secondary,
        surface: AppColors.bgPrimary,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.bgSecondary,
      fontFamily: 'Segoe UI',
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleSmall: base.textTheme.titleSmall?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgDark,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Segoe UI',
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgPrimary,
        elevation: 2,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: AppColors.bgTertiary),
        ),
        margin: const EdgeInsets.only(bottom: 24),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.bgTertiary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgPrimary,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.bgTertiary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.bgTertiary, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.bgTertiary),
    );
  }
}