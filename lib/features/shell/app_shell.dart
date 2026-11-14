import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../shared/widgets.dart';
import '../education/education_screen.dart';
import '../kader/followup_screen.dart';
import '../kader/kader_home.dart';
import '../kader/recap_screen.dart';
import '../kader/roster_screen.dart';
import '../mother/food_flow.dart';
import '../mother/growth_screens.dart';
import '../mother/mother_home.dart';
import '../profile/profile_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  static MealType mealForNow() {
    final hour = DateTime.now().hour;
    if (hour < 11) return MealType.breakfast;
    if (hour < 15) return MealType.lunch;
    if (hour < 18) return MealType.snack;
    return MealType.dinner;
  }

  void _openQuickLog() {
    final state = ref.read(appControllerProvider);
    final pregnancy = state.activePregnancy;
    final child = state.activeChild;
    String? subjectId;
    String subjectLabel = '';
    if (state.pregnancyContext && pregnancy != null) {
      subjectId = pregnancy.id;
      subjectLabel = 'Kehamilan';
    } else if (child != null) {
      subjectId = child.id;
      subjectLabel = child.nickname;
    } else if (pregnancy != null) {
      subjectId = pregnancy.id;
      subjectLabel = 'Kehamilan';
    }
    if (subjectId == null) {
      showNuriSnack(
        context,
        'Tambahkan data anak atau kehamilan dulu untuk mencatat makan.',
        error: true,
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FoodCameraScreen(
          subjectId: subjectId!,
          subjectLabel: subjectLabel,
          initialMeal: mealForNow(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final isCadre = state.isCadre;

    final pages = isCadre
        ? const <Widget>[
            KaderHomeScreen(),
            RosterScreen(embedded: true),
            RecapScreen(embedded: true),
            FollowUpScreen(embedded: true),
            ProfileScreen(),
          ]
        : const <Widget>[
            MotherHomeScreen(),
            GrowthDetailScreen(embedded: true),
            SizedBox.shrink(),
            EducationScreen(),
            ProfileScreen(),
          ];

    final items = isCadre
        ? const <BottomNavItem>[
            BottomNavItem(
              icon: Icons.event_note_outlined,
              activeIcon: Icons.event_note_rounded,
              label: 'Sesi',
            ),
            BottomNavItem(
              icon: Icons.groups_outlined,
              activeIcon: Icons.groups_rounded,
              label: 'Sasaran',
            ),
            BottomNavItem(
              icon: Icons.insert_chart_outlined_rounded,
              activeIcon: Icons.insert_chart_rounded,
              label: 'Rekap',
            ),
            BottomNavItem(
              icon: Icons.follow_the_signs_outlined,
              activeIcon: Icons.follow_the_signs_rounded,
              label: 'Tindak',
            ),
            BottomNavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'Profil',
            ),
          ]
        : const <BottomNavItem>[
            BottomNavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Beranda',
            ),
            BottomNavItem(
              icon: Icons.show_chart_rounded,
              activeIcon: Icons.show_chart_rounded,
              label: 'Tumbuh',
            ),
            BottomNavItem(
              icon: Icons.add_a_photo_outlined,
              activeIcon: Icons.add_a_photo_rounded,
              label: 'Catat',
              isCenter: true,
            ),
            BottomNavItem(
              icon: Icons.menu_book_outlined,
              activeIcon: Icons.menu_book_rounded,
              label: 'Edukasi',
            ),
            BottomNavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'Profil',
            ),
          ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NuriBottomNav(
        items: items,
        selectedIndex: _index,
        onTap: (index) {
          if (!isCadre && index == 2) {
            _openQuickLog();
            return;
          }
          setState(() => _index = index);
        },
      ),
    );
  }
}
