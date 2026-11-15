import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // NURI Maternal & Child Health System Palette (Soft Modern Organic)
  static const Color primary = Color(0xFF0D631B); // Forest Emerald
  static const Color primaryDark = Color(0xFF0A4E15);
  static const Color primaryDeep = Color(0xFF002204);
  static const Color primaryContainer = Color(0xFF2E7D32);
  static const Color onPrimaryContainer = Color(0xFFCBFFC2);
  static const Color primaryFixed = Color(0xFFA3F69C);
  static const Color primaryFixedDim = Color(0xFF88D982);
  static const Color surfaceTint = Color(0xFF1B6D24);

  // Secondary & Accents
  static const Color secondary = Color(0xFF3E6A00); // Leaf Olive
  static const Color secondaryContainer = Color(0xFFB9F474); // Vibrant Leaf Lime
  static const Color onSecondaryContainer = Color(0xFF437000);
  static const Color secondaryFixed = Color(0xFFB9F474);
  static const Color secondaryFixedDim = Color(0xFF9ED75B);

  // Tertiary
  static const Color tertiary = Color(0xFF006419);
  static const Color tertiaryContainer = Color(0xFF127F26);
  static const Color onTertiaryContainer = Color(0xFFCAFFC2);

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF9F9FF);
  static const Color surface = Color(0xFFF9F9FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF0F3FF);
  static const Color surfaceContainer = Color(0xFFE7EEFF);
  static const Color surfaceContainerHigh = Color(0xFFDEE8FF);
  static const Color surfaceContainerHighest = Color(0xFFD8E3FB);
  static const Color surfaceSubtle = Color(0xFFF0F3FF);
  static const Color cream = Color(0xFFF9F9FF);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color white = Color(0xFFFFFFFF);

  // Borders & Outlines
  static const Color outline = Color(0xFF707A6C);
  static const Color outlineVariant = Color(0xFFBFCABA);
  static const Color borderLine = Color(0xFFE2E8F0);
  static const Color line = Color(0xFFE5EBE3);

  // Typography
  static const Color onSurface = Color(0xFF111C2D);
  static const Color onSurfaceVariant = Color(0xFF40493D);
  static const Color text = Color(0xFF111C2D);
  static const Color muted = Color(0xFF64748B);
  static const Color secondaryText = Color(0xFF64748B);

  // Compatibility aliases
  static const Color deepForest = primary;
  static const Color freshGreen = primaryContainer;
  static const Color leafGreen = secondaryFixedDim;
  static const Color softMint = Color(0xFFDCFCE7);
  static const Color naturalWhite = background;
  static const Color darkGreen = onSurface;
  static const Color primarySoft = Color(0xFFDCFCE7);
  static const Color highlight = secondaryContainer;

  // Semantic Status Colors (Normal, Perhatian, Bahaya/Rujukan, Info)
  static const Color green = primaryContainer;
  static const Color greenSoft = Color(0xFFDCFCE7);
  static const Color mint = Color(0xFFDCFCE7);
  static const Color mintStrong = Color(0xFFB9F474);

  static const Color amber = Color(0xFFD97706);
  static const Color amberSoft = Color(0xFFFEF3C7);
  static const Color peach = Color(0xFFFFD54F);
  static const Color peachSoft = Color(0xFFFFF8E1);
  static const Color coral = Color(0xFFE65100);

  static const Color red = Color(0xFFBA1A1A);
  static const Color redSoft = Color(0xFFFFDAD6);

  static const Color blue = Color(0xFF0284C7);
  static const Color blueSoft = Color(0xFFE0F2FE);

  static const Color purple = Color(0xFF7C3AED);
  static const Color purpleSoft = Color(0xFFF5F3FF);
}

class AppGradients {
  const AppGradients._();

  static const LinearGradient header = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0D631B),
      Color(0xFF2E7D32),
      Color(0xFF1B6D24),
    ],
  );

  static const LinearGradient headerWide = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0D631B),
      Color(0xFF2E7D32),
      Color(0xFF3E6A00),
    ],
  );

  static const LinearGradient primary = LinearGradient(
    colors: [
      Color(0xFF0D631B),
      Color(0xFF2E7D32),
    ],
  );

  static const LinearGradient button = LinearGradient(
    colors: [
      Color(0xFF0D631B),
      Color(0xFF2E7D32),
    ],
  );

  static const LinearGradient accent = LinearGradient(
    colors: [
      Color(0xFF2E7D32),
      Color(0xFF8BC34A),
    ],
  );

  static const LinearGradient secondary = LinearGradient(
    colors: [
      Color(0xFFB9F474),
      Color(0xFF9ED75B),
    ],
  );
}

class AppRadius {
  static const double card = 20;
  static const double button = 16;
  static const double input = 16;
  static const double header = 32;
  static const double pill = 9999;
}

class AppShadows {
  static const List<BoxShadow> soft = [
    BoxShadow(color: Color(0x120D631B), blurRadius: 18, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0F0D631B), blurRadius: 16, offset: Offset(0, 4)),
    BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2)),
  ];

  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x1F111C2D), blurRadius: 28, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> glow = [
    BoxShadow(color: Color(0x402E7D32), blurRadius: 18, offset: Offset(0, 6)),
  ];
}

class AppTheme {
  static ThemeData light() {
    const colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      error: AppColors.red,
      onError: Colors.white,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
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
          borderSide: const BorderSide(color: AppColors.deepForest, width: 1.8),
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
          backgroundColor: AppColors.deepForest,
          foregroundColor: Colors.white,
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
          foregroundColor: AppColors.deepForest,
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
          foregroundColor: AppColors.deepForest,
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.deepForest,
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
        indicatorColor: AppColors.softMint,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: 'Inter',
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: states.contains(WidgetState.selected)
                ? AppColors.deepForest
                : AppColors.secondaryText,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.deepForest
                : AppColors.secondaryText,
            size: 23,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkGreen,
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
