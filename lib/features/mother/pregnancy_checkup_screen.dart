import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import 'pregnancy_checkup_form_screen.dart';
import 'pregnancy_checkup_widgets.dart';

export 'pregnancy_checkup_form_screen.dart';

class PregnancyCheckupScreen extends ConsumerWidget {
  const PregnancyCheckupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final pregnancy = state.activePregnancy;
    if (pregnancy == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              ScreenHeader(
                title: 'Pemeriksaan kehamilan',
                onBack: () => Navigator.of(context).pop(),
              ),
              const Expanded(
                child: EmptyState(title: 'Tidak ada kehamilan aktif'),
              ),
            ],
          ),
        ),
      );
    }
    final checkups = List<Checkup>.from(pregnancy.checkups)
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Pemeriksaan kehamilan',
              subtitle: '${checkups.length} catatan',
              onBack: () => Navigator.of(context).pop(),
              action: RoundIconButton(
                icon: Icons.add_rounded,
                filled: true,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CheckupFormScreen()),
                ),
              ),
            ),
            Expanded(
              child: checkups.isEmpty
                  ? EmptyState(
                      title: 'Belum ada pemeriksaan',
                      body:
                          'Catat hasil pemeriksaan dari bidan atau puskesmas.',
                      icon: Icons.monitor_heart_outlined,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemCount: checkups.length + 1,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        if (index == checkups.length) {
                          return Column(
                            children: [
                              const SizedBox(height: 4),
                              NuriButton(
                                label: 'Catat pemeriksaan baru',
                                icon: Icons.add_rounded,
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const CheckupFormScreen(),
                                  ),
                                ),
                              ),
                              const NuriDisclaimer(),
                            ],
                          );
                        }
                        return CheckupTile(checkup: checkups[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
