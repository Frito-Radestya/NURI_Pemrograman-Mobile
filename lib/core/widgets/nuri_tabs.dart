import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'nuri_bottom_nav.dart';

/// Kumpulan bilah navigasi sesuai peran, agar konsisten di semua layar.
class NuriTabs {
  NuriTabs._();

  static const List<NuriNavItem> mom = [
    NuriNavItem(icon: Icons.home_rounded, label: 'Beranda'),
    NuriNavItem(icon: Icons.show_chart_rounded, label: 'Tumbuh'),
    NuriNavItem(icon: Icons.restaurant_rounded, label: 'Gizi'),
    NuriNavItem(icon: Icons.person_rounded, label: 'Profil'),
  ];

  static const List<String> momRoutes = ['/home', '/growth', '/nutrition', '/profile'];

  static const List<NuriNavItem> kader = [
    NuriNavItem(icon: Icons.home_rounded, label: 'Beranda'),
    NuriNavItem(icon: Icons.groups_rounded, label: 'Sasaran'),
    NuriNavItem(icon: Icons.fact_check_rounded, label: 'Skrining'),
    NuriNavItem(icon: Icons.assessment_rounded, label: 'Laporan'),
  ];

  static const List<String> kaderRoutes = [
    '/kader',
    '/kader-targets',
    '/kader-entry',
    '/kader-activity',
  ];

  static const List<NuriNavItem> pregnant = [
    NuriNavItem(icon: Icons.home_rounded, label: 'Beranda'),
    NuriNavItem(icon: Icons.child_friendly_rounded, label: 'Janin'),
    NuriNavItem(icon: Icons.restaurant_rounded, label: 'Nutrisi'),
    NuriNavItem(icon: Icons.person_rounded, label: 'Profil'),
  ];

  static const List<String> pregnantRoutes = [
    '/pregnant',
    '/pregnant-monitor',
    '/pregnant-nutrition',
    '/profile',
  ];
}

/// Bilah bawah ibu (balita): Beranda, Tumbuh, Gizi, Profil.
class MomTabBar extends StatelessWidget {
  const MomTabBar({super.key, required this.active});

  final String active;

  @override
  Widget build(BuildContext context) => _Bar(
        items: NuriTabs.mom,
        routes: NuriTabs.momRoutes,
        active: active,
      );
}

/// Bilah bawah ibu hamil.
class PregnantTabBar extends StatelessWidget {
  const PregnantTabBar({super.key, required this.active});

  final String active;

  @override
  Widget build(BuildContext context) => _Bar(
        items: NuriTabs.pregnant,
        routes: NuriTabs.pregnantRoutes,
        active: active,
      );
}

/// Bilah bawah kader posyandu.
class KaderTabBar extends StatelessWidget {
  const KaderTabBar({super.key, required this.active});

  final String active;

  @override
  Widget build(BuildContext context) => _Bar(
        items: NuriTabs.kader,
        routes: NuriTabs.kaderRoutes,
        active: active,
      );
}

class _Bar extends StatelessWidget {
  const _Bar({required this.items, required this.routes, required this.active});

  final List<NuriNavItem> items;
  final List<String> routes;
  final String active;

  @override
  Widget build(BuildContext context) {
    final index = routes.indexOf(active);
    return NuriBottomNav(
      items: items,
      currentIndex: index < 0 ? 0 : index,
      onTap: (i) {
        if (routes[i] != active) context.go(routes[i]);
      },
    );
  }
}
