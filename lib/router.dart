import 'package:go_router/go_router.dart';

import 'features/auth/email_sent_screen.dart';
import 'features/auth/forgot_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/role_screen.dart';
import 'features/child/child_data_screen.dart';
import 'features/child/first_measure_screen.dart';
import 'features/gallery/design_gallery_screen.dart';
import 'features/home/growth_screen.dart';
import 'features/home/mom_home_screen.dart';
import 'features/home/nutrition_screen.dart';
import 'features/home/profile_screen.dart';
import 'features/kader/kader_activity_screen.dart';
import 'features/kader/kader_entry_screen.dart';
import 'features/kader/kader_home_screen.dart';
import 'features/kader/kader_result_screen.dart';
import 'features/kader/kader_target_detail_screen.dart';
import 'features/kader/kader_targets_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/nutrition/meal_analyzing_screen.dart';
import 'features/nutrition/meal_fail_screen.dart';
import 'features/nutrition/meal_history_screen.dart';
import 'features/nutrition/meal_result_screen.dart';
import 'features/nutrition/meal_review_screen.dart';
import 'features/nutrition/plate_camera_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/pregnancy/pregnant_home_screen.dart';
import 'features/pregnancy/pregnant_monitor_screen.dart';
import 'features/pregnancy/pregnant_nutrition_screen.dart';
import 'features/pregnancy/pregnant_recommend_screen.dart';
import 'features/screening/posture_camera_screen.dart';
import 'features/screening/screening_result_screen.dart';
import 'features/screening/screening_start_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/splash/splash_screen.dart';

/// Peta navigasi NURI v2.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ---- Awal & orientasi ---------------------------------------------------
    GoRoute(path: '/', builder: (c, s) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
    GoRoute(path: '/gallery', builder: (c, s) => const DesignGalleryScreen()),

    // ---- Akun ---------------------------------------------------------------
    GoRoute(path: '/role', builder: (c, s) => const RoleSelectScreen()),
    GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
    GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
    GoRoute(path: '/forgot', builder: (c, s) => const ForgotPasswordScreen()),
    GoRoute(path: '/forgot-sent', builder: (c, s) => const EmailSentScreen()),

    // ---- Penyiapan anak -----------------------------------------------------
    GoRoute(path: '/child-data', builder: (c, s) => const ChildDataScreen()),
    GoRoute(path: '/child-measure', builder: (c, s) => const FirstMeasureScreen()),

    // ---- Ruang Ibu (Balita) -------------------------------------------------
    GoRoute(path: '/home', builder: (c, s) => const MomHomeScreen()),
    GoRoute(path: '/growth', builder: (c, s) => const GrowthScreen()),
    GoRoute(path: '/nutrition', builder: (c, s) => const NutritionScreen()),
    GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),

    // ---- Skrining & kamera --------------------------------------------------
    GoRoute(path: '/screening', builder: (c, s) => const ScreeningStartScreen()),
    GoRoute(
      path: '/screening-result',
      builder: (c, s) => const ScreeningResultScreen(),
    ),
    GoRoute(
      path: '/camera-posture',
      builder: (c, s) => const PostureCameraScreen(),
    ),

    // ---- Analisis piring makan ---------------------------------------------
    GoRoute(path: '/camera-plate', builder: (c, s) => const PlateCameraScreen()),
    GoRoute(path: '/meal-review', builder: (c, s) => const MealReviewScreen()),
    GoRoute(
      path: '/meal-analyzing',
      builder: (c, s) => const MealAnalyzingScreen(),
    ),
    GoRoute(path: '/meal-result', builder: (c, s) => const MealResultScreen()),
    GoRoute(path: '/meal-fail', builder: (c, s) => const MealFailScreen()),
    GoRoute(path: '/meal-history', builder: (c, s) => const MealHistoryScreen()),

    // ---- Ruang Ibu Hamil ----------------------------------------------------
    GoRoute(path: '/pregnant', builder: (c, s) => const PregnantHomeScreen()),
    GoRoute(
      path: '/pregnant-nutrition',
      builder: (c, s) => const PregnantNutritionScreen(),
    ),
    GoRoute(
      path: '/pregnant-monitor',
      builder: (c, s) => const PregnantMonitorScreen(),
    ),
    GoRoute(
      path: '/pregnant-recommend',
      builder: (c, s) => const PregnantRecommendScreen(),
    ),

    // ---- Ruang Kader Posyandu ----------------------------------------------
    GoRoute(path: '/kader', builder: (c, s) => const KaderHomeScreen()),
    GoRoute(path: '/kader-targets', builder: (c, s) => const KaderTargetsScreen()),
    GoRoute(
      path: '/kader-target-detail',
      builder: (c, s) => const KaderTargetDetailScreen(),
    ),
    GoRoute(path: '/kader-entry', builder: (c, s) => const KaderEntryScreen()),
    GoRoute(path: '/kader-result', builder: (c, s) => const KaderResultScreen()),
    GoRoute(
      path: '/kader-activity',
      builder: (c, s) => const KaderActivityScreen(),
    ),

    // ---- Lain-lain ----------------------------------------------------------
    GoRoute(
      path: '/notifications',
      builder: (c, s) => const NotificationsScreen(),
    ),
    GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
  ],
);
