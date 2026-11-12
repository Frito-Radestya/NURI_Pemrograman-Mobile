import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF0B6B5B);
  static const Color primaryDark = Color(0xFF074D41);
  static const Color primaryDeep = Color(0xFF04342C);
  static const Color primarySoft = Color(0xFFDCEEE7);
  static const Color mint = Color(0xFFEEF6F2);
  static const Color mintStrong = Color(0xFFD6EAE1);
  static const Color cream = Color(0xFFFAF9F6);
  static const Color background = Color(0xFFF6F8F7);
  static const Color surface = Colors.white;
  static const Color surfaceSubtle = Color(0xFFF1F4F2);
  static const Color text = Color(0xFF132622);
  static const Color muted = Color(0xFF5B6B66);
  static const Color line = Color(0xFFE5EAE7);
  static const Color peach = Color(0xFFFFC6A8);
  static const Color peachSoft = Color(0xFFFFF2EA);
  static const Color coral = Color(0xFFD96B48);
  static const Color amber = Color(0xFFC27B16);
  static const Color amberSoft = Color(0xFFFEF4E2);
  static const Color red = Color(0xFFC94040);
  static const Color redSoft = Color(0xFFFEECEC);
  static const Color blue = Color(0xFF3B6E9C);
  static const Color blueSoft = Color(0xFFECF3FA);
  static const Color purple = Color(0xFF6A589C);
  static const Color purpleSoft = Color(0xFFF2EFFA);
  static const Color white = Colors.white;
}

class AppRadius {
  static const double card = 18;
  static const double button = 14;
  static const double input = 14;
  static const double pill = 100;
}

class AppShadows {
  static const List<BoxShadow> soft = [
    BoxShadow(color: Color(0x0A0B241E), blurRadius: 16, offset: Offset(0, 4)),
  ];
}

class AppTheme {
  static ThemeData light() {
    const colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.coral,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.peachSoft,
      onSecondaryContainer: AppColors.text,
      surface: AppColors.surface,
      onSurface: AppColors.text,
      error: AppColors.red,
      onError: Colors.white,
      outline: AppColors.line,
      outlineVariant: AppColors.line,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Inter',
      splashFactory: InkSparkle.splashFactory,
    );

    const text = AppColors.text;
    final textTheme = base.textTheme
        .copyWith(
          displayLarge: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 40,
            height: 1.08,
            letterSpacing: -0.8,
            fontWeight: FontWeight.w800,
          ),
          displayMedium: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 34,
            height: 1.1,
            letterSpacing: -0.6,
            fontWeight: FontWeight.w800,
          ),
          displaySmall: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 28,
            height: 1.12,
            letterSpacing: -0.5,
            fontWeight: FontWeight.w800,
          ),
          headlineLarge: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 28,
            height: 1.15,
            letterSpacing: -0.5,
            fontWeight: FontWeight.w800,
          ),
          headlineMedium: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 24,
            height: 1.18,
            letterSpacing: -0.4,
            fontWeight: FontWeight.w800,
          ),
          headlineSmall: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 22,
            height: 1.2,
            letterSpacing: -0.3,
            fontWeight: FontWeight.w800,
          ),
          titleLarge: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 19,
            height: 1.25,
            letterSpacing: -0.3,
            fontWeight: FontWeight.w800,
          ),
          titleMedium: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            height: 1.3,
            letterSpacing: -0.2,
            fontWeight: FontWeight.w700,
          ),
          titleSmall: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            height: 1.5,
            fontWeight: FontWeight.w400,
          ),
          bodyMedium: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            height: 1.45,
            fontWeight: FontWeight.w400,
          ),
          bodySmall: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12.5,
            height: 1.4,
            fontWeight: FontWeight.w400,
          ),
          labelLarge: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            height: 1.2,
            fontWeight: FontWeight.w600,
          ),
          labelMedium: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12.5,
            height: 1.2,
            fontWeight: FontWeight.w600,
          ),
          labelSmall: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 11.5,
            height: 1.2,
            fontWeight: FontWeight.w600,
          ),
        )
        .apply(bodyColor: text, displayColor: text);

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: AppColors.text,
        titleTextStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
          color: AppColors.text,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.line,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 14,
        ),
        hintStyle: TextStyle(
          color: AppColors.muted.withValues(alpha: 0.45),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
        prefixIconColor: AppColors.muted,
        suffixIconColor: AppColors.muted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.red, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          backgroundColor: AppColors.surface,
          minimumSize: const Size(48, 50),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          side: const BorderSide(color: AppColors.line),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary,
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        side: const BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        showCheckmark: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primarySoft,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: 'Inter',
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.muted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.muted,
            size: 23,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.primaryDeep,
        contentTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
