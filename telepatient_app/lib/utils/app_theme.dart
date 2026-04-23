import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────

class AppColors {
  // Primary palette — medical blue
  static const Color primary        = Color(0xFF2563EB);
  static const Color primaryLight   = Color(0xFF3B82F6);
  static const Color primaryDark    = Color(0xFF1D4ED8);
  static const Color primarySurface = Color(0xFFEFF6FF);

  // Accent — teal
  static const Color accent         = Color(0xFF0891B2);
  static const Color accentSurface  = Color(0xFFECFEFF);

  // Semantic
  static const Color success        = Color(0xFF16A34A);
  static const Color successSurface = Color(0xFFF0FDF4);
  static const Color warning        = Color(0xFFD97706);
  static const Color warningSurface = Color(0xFFFFFBEB);
  static const Color error          = Color(0xFFDC2626);
  static const Color errorSurface   = Color(0xFFFEF2F2);
  static const Color critical       = Color(0xFFB91C1C);
  static const Color urgent         = Color(0xFFEA580C);
  static const Color normal         = Color(0xFF15803D);

  // Neutral — light
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF8FAFC);
  static const Color background     = Color(0xFFF1F5F9);
  static const Color border         = Color(0xFFE2E8F0);
  static const Color borderFocus    = Color(0xFF93C5FD);
  static const Color textPrimary    = Color(0xFF0F172A);
  static const Color textSecondary  = Color(0xFF64748B);
  static const Color textHint       = Color(0xFF94A3B8);

  // Neutral — dark
  static const Color darkBackground     = Color(0xFF0F172A);
  static const Color darkSurface        = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  static const Color darkBorder         = Color(0xFF334155);
  static const Color darkTextPrimary    = Color(0xFFF8FAFC);
  static const Color darkTextSecondary  = Color(0xFF94A3B8);
}

class AppSpacing {
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
  static const double lg  = 24;
  static const double xl  = 32;
  static const double xxl = 48;
}

class AppRadius {
  static const double sm  = 8;
  static const double md  = 12;
  static const double lg  = 16;
  static const double xl  = 24;
  static const double full = 999;
}

class AppTextStyles {
  static const TextStyle displayLg = TextStyle(
    fontSize: 30, fontWeight: FontWeight.w700, letterSpacing: -0.5, height: 1.2);
  static const TextStyle displayMd = TextStyle(
    fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.3, height: 1.3);
  static const TextStyle displaySm = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: -0.2, height: 1.3);
  static const TextStyle titleLg = TextStyle(
    fontSize: 18, fontWeight: FontWeight.w600, height: 1.4);
  static const TextStyle titleMd = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600, height: 1.4);
  static const TextStyle titleSm = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w600, height: 1.4);
  static const TextStyle bodyLg = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w400, height: 1.6);
  static const TextStyle bodyMd = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400, height: 1.6);
  static const TextStyle bodySm = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w400, height: 1.5);
  static const TextStyle labelLg = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1);
  static const TextStyle labelMd = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.1);
  static const TextStyle labelSm = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.2);
}

// ─── Theme ────────────────────────────────────────────────────────────────────

class AppTheme {
  // Keep legacy aliases so existing code doesn't break
  static const Color primary     = AppColors.primary;
  static const Color primaryDark = AppColors.primaryDark;
  static const Color accent      = AppColors.accent;
  static const Color success     = AppColors.success;
  static const Color warning     = AppColors.warning;
  static const Color error       = AppColors.error;
  static const Color critical    = AppColors.critical;
  static const Color urgent      = AppColors.urgent;
  static const Color normal      = AppColors.normal;

  // ─── Light ──────────────────────────────────────────────────────────────────
  static ThemeData get light {
    final cs = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      surfaceContainerHighest: AppColors.surfaceVariant,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Roboto',

      // ── AppBar ──────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.border,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTextStyles.titleLg.copyWith(
          color: AppColors.textPrimary),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),

      // ── Cards ───────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        color: AppColors.surface,
        margin: EdgeInsets.zero,
      ),

      // ── Buttons ─────────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
          elevation: 0,
          textStyle: AppTextStyles.labelLg.copyWith(
              fontSize: 15, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          textStyle: AppTextStyles.labelLg.copyWith(
              fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.labelLg,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),

      // ── Inputs ──────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: AppTextStyles.bodyMd.copyWith(
            color: AppColors.textSecondary),
        hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.textHint),
        prefixIconColor: AppColors.textSecondary,
        suffixIconColor: AppColors.textSecondary,
      ),

      // ── Bottom Nav ──────────────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        backgroundColor: AppColors.surface,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),

      // ── Divider ─────────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),

      // ── Chip ────────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        labelStyle: AppTextStyles.labelMd,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full)),
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      // ── ListTile ────────────────────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth: 0,
      ),
    );
  }

  // ─── Dark ───────────────────────────────────────────────────────────────────
  static ThemeData get dark {
    final cs = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primaryLight,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      surface: AppColors.darkSurface,
      surfaceContainerHighest: AppColors.darkSurfaceVariant,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: AppColors.darkBackground,
      fontFamily: 'Roboto',

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: AppColors.darkBorder,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTextStyles.titleLg.copyWith(
            color: AppColors.darkTextPrimary),
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
        color: AppColors.darkSurface,
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
          elevation: 0,
          textStyle: AppTextStyles.labelLg.copyWith(
              fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md)),
          side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          textStyle: AppTextStyles.labelLg,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: AppTextStyles.bodyMd.copyWith(
            color: AppColors.darkTextSecondary),
        hintStyle: AppTextStyles.bodyMd.copyWith(
            color: AppColors.darkTextSecondary),
        prefixIconColor: AppColors.darkTextSecondary,
        suffixIconColor: AppColors.darkTextSecondary,
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.darkTextSecondary,
        backgroundColor: AppColors.darkSurface,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        labelStyle: AppTextStyles.labelMd.copyWith(
            color: AppColors.darkTextPrimary),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.full)),
        side: const BorderSide(color: AppColors.darkBorder),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth: 0,
      ),
    );
  }
}
