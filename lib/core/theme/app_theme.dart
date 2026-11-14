import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // NURI Design System 2.0 (Black & Yellow Healthcare)
  static const Color medicalBlack = Color(0xFF171717);
  static const Color vitalYellow = Color(0xFFFFC800);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color softWhite = Color(0xFFF5F5F2);
  static const Color neutralGray = Color(0xFF777777);
  static const Color deepYellow = Color(0xFFD99B00);
  static const Color borderLine = Color(0xFFE5E5E0);

  // Brand Mapping
  static const Color primary = vitalYellow;
  static const Color primaryDark = deepYellow;
  static const Color primaryDeep = medicalBlack;
  static const Color primarySoft = Color(0xFFFFF7CC); // Soft yellow container
  static const Color highlight = deepYellow;

  // Backgrounds & Surfaces
  static const Color background = softWhite;
  static const Color surface = pureWhite;
  static const Color surfaceSubtle = Color(0xFFEBEBE6);
  static const Color cream = softWhite;
  static const Color line = borderLine;

  // Typography
  static const Color text = medicalBlack;
  static const Color muted = neutralGray;
  static const Color white = pureWhite;

  // Semantic Status Colors (Pembeda status kesehatan: normal, perhatian, bahaya)
  static const Color green = Color(0xFF1B8755);
  static const Color greenSoft = Color(0xFFE8F8F0);
  static const Color mint = greenSoft;
  static const Color mintStrong = Color(0xFFC8F0DC);

  static const Color amber = Color(0xFFD97706);
  static const Color amberSoft = Color(0xFFFFFBEB);
  static const Color peach = Color(0xFFFFD54F);
  static const Color peachSoft = Color(0xFFFFF8E1);
  static const Color coral = Color(0xFFE65100);

  static const Color red = Color(0xFFDC2626);
  static const Color redSoft = Color(0xFFFEF2F2);

  static const Color blue = Color(0xFF2563EB);
  static const Color blueSoft = Color(0xFFEFF6FF);

  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleSoft = Color(0xFFF5F3FF);
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
      primary: AppColors.vitalYellow,
      onPrimary: AppColors.medicalBlack,
      primaryContainer: AppColors.primarySoft,
      onPrimaryContainer: AppColors.medicalBlack,
      secondary: AppColors.medicalBlack,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.surfaceSubtle,
      onSecondaryContainer: AppColors.medicalBlack,
      surface: AppColors.surface,
      onSurface: AppColors.medicalBlack,
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
          borderSide: const BorderSide(color: AppColors.medicalBlack, width: 1.8),
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
          backgroundColor: AppColors.vitalYellow,
          foregroundColor: AppColors.medicalBlack,
          minimumSize: const Size(48, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.medicalBlack,
          backgroundColor: AppColors.surface,
          minimumSize: const Size(48, 50),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          side: const BorderSide(color: AppColors.line, width: 1.2),
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
          foregroundColor: AppColors.medicalBlack,
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.vitalYellow,
        labelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: AppColors.medicalBlack,
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
        indicatorColor: AppColors.vitalYellow,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: 'Inter',
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: states.contains(WidgetState.selected)
                ? AppColors.medicalBlack
                : AppColors.neutralGray,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.medicalBlack
                : AppColors.neutralGray,
            size: 23,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.medicalBlack,
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
