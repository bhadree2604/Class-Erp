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

  // Dark theme equivalents
  static const darkBgPrimary = Color(0xFF1e1e2e);
  static const darkBgSecondary = Color(0xFF181825);
  static const darkBgTertiary = Color(0xFF313244);
  static const darkBgDark = Color(0xFF11111b);
  static const darkTextPrimary = Color(0xFFcdd6f4);
  static const darkTextSecondary = Color(0xFFa6adc8);
  static const darkTextLight = Color(0xFF6c7086);
}

/// Theme extension that provides adaptive colors based on current brightness.
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color textPrimary;
  final Color textSecondary;
  final Color textLight;
  final Color bgPrimary;
  final Color bgSecondary;
  final Color bgTertiary;
  final Color bgDark;

  const AppColorsExtension({
    required this.textPrimary,
    required this.textSecondary,
    required this.textLight,
    required this.bgPrimary,
    required this.bgSecondary,
    required this.bgTertiary,
    required this.bgDark,
  });

  static const light = AppColorsExtension(
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textLight: AppColors.textLight,
    bgPrimary: AppColors.bgPrimary,
    bgSecondary: AppColors.bgSecondary,
    bgTertiary: AppColors.bgTertiary,
    bgDark: AppColors.bgDark,
  );

  static const dark = AppColorsExtension(
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textLight: AppColors.darkTextLight,
    bgPrimary: AppColors.darkBgPrimary,
    bgSecondary: AppColors.darkBgSecondary,
    bgTertiary: AppColors.darkBgTertiary,
    bgDark: AppColors.darkBgDark,
  );

  @override
  AppColorsExtension copyWith({
    Color? textPrimary,
    Color? textSecondary,
    Color? textLight,
    Color? bgPrimary,
    Color? bgSecondary,
    Color? bgTertiary,
    Color? bgDark,
  }) {
    return AppColorsExtension(
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textLight: textLight ?? this.textLight,
      bgPrimary: bgPrimary ?? this.bgPrimary,
      bgSecondary: bgSecondary ?? this.bgSecondary,
      bgTertiary: bgTertiary ?? this.bgTertiary,
      bgDark: bgDark ?? this.bgDark,
    );
  }

  @override
  AppColorsExtension lerp(AppColorsExtension? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textLight: Color.lerp(textLight, other.textLight, t)!,
      bgPrimary: Color.lerp(bgPrimary, other.bgPrimary, t)!,
      bgSecondary: Color.lerp(bgSecondary, other.bgSecondary, t)!,
      bgTertiary: Color.lerp(bgTertiary, other.bgTertiary, t)!,
      bgDark: Color.lerp(bgDark, other.bgDark, t)!,
    );
  }

  /// Convenience accessor from BuildContext.
  static AppColorsExtension of(BuildContext context) {
    return Theme.of(context).extension<AppColorsExtension>() ?? light;
  }
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
      extensions: const [AppColorsExtension.light],
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

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: AppColors.primary,
        primary: AppColors.primaryLight,
        onPrimary: AppColors.darkBgPrimary,
        secondary: AppColors.primaryLight,
        surface: AppColors.darkBgPrimary,
        onSurface: AppColors.darkTextPrimary,
      ),
      scaffoldBackgroundColor: AppColors.darkBgSecondary,
      fontFamily: 'Segoe UI',
    );

    return base.copyWith(
      extensions: const [AppColorsExtension.dark],
      textTheme: base.textTheme.copyWith(
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextPrimary,
        ),
        headlineSmall: base.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
        titleLarge: base.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.darkTextPrimary,
        ),
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
        ),
        titleSmall: base.textTheme.titleSmall?.copyWith(
          color: AppColors.darkTextSecondary,
          fontWeight: FontWeight.w600,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          color: AppColors.darkTextPrimary,
          fontSize: 16,
        ),
        bodySmall: base.textTheme.bodySmall?.copyWith(
          color: AppColors.darkTextSecondary,
          fontSize: 14,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBgDark,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Segoe UI',
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkBgPrimary,
        elevation: 2,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: AppColors.darkBgTertiary),
        ),
        margin: const EdgeInsets.only(bottom: 24),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.darkBgPrimary,
          disabledBackgroundColor: AppColors.darkBgTertiary,
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
        fillColor: AppColors.darkBgTertiary,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.darkBgTertiary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.darkBgTertiary, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.darkBgTertiary),
    );
  }
}
