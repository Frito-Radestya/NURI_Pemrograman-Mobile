import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/chips.dart';
import '../../core/widgets/nuri_button.dart';
import '../../core/widgets/nuri_logo.dart';
import '../../core/widgets/nuri_scaffold.dart';
import '../../core/widgets/nuri_top_bar.dart';
import '../../core/widgets/section.dart';
import '../../core/widgets/tiles.dart';
import '../../state/app_state.dart';

/// Pemilihan peran utama NURI: Ibu Hamil, Ibu Balita, atau Kader Posyandu.
class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NuriScaffold(
      topBar: NuriTopBar(
        onBack: () =>
            context.canPop() ? context.pop() : context.go('/onboarding'),
        titleWidget: const NuriBrand(markSize: 30),
        actions: const [NuriAvatar()],
      ),
      body: const _RoleBody(),
    );
  }
}

class _RoleBody extends StatefulWidget {
  const _RoleBody();

  @override
  State<_RoleBody> createState() => _RoleBodyState();
}

class _RoleBodyState extends State<_RoleBody> {
  int _selected = 1;

  static const List<_RoleOption> _roles = [
    _RoleOption(
      title: 'Ibu Hamil',
      icon: Icons.pregnant_woman_rounded,
      badge: 'Fase Prenatal • Trimester 1–3',
      subtitle:
          'Nutrisi esensial 1000 Hari Pertama Kehidupan (HPK), kalkulator '
          'berat badan ibu, dan pencegahan risiko anemia sejak dini.',
      cta: 'Lanjut ke ruang hamil',
      route: '/pregnant',
    ),
    _RoleOption(
      title: 'Ibu Balita',
      icon: Icons.child_care_rounded,
      badge: 'Usia 0–5 Tahun • Standar WHO',
      subtitle:
          'Pantau grafik tinggi & berat badan WHO, jadwal menu MP-ASI kaya '
          'protein hewani, serta deteksi risiko stunting berkala.',
      cta: 'Lanjut data balita',
      route: '/child-data',
    ),
    _RoleOption(
      title: 'Kader Posyandu',
      icon: Icons.groups_rounded,
      badge: 'Multi-Profil Anak • Laporan Posyandu',
      subtitle:
          'Pencatatan antropometri massal hari buka posyandu, identifikasi '
          'rujukan balita gizi kurang, dan sinkronisasi data wilayah.',
      cta: 'Lanjut ke ruang kader',
      route: '/kader',
    ),
  ];

  void _continue() {
    final NuriAppState state = NuriScope.read(context);
    final _RoleOption role = _roles[_selected];
    final String code = switch (role.title) {
      'Ibu Hamil' => 'ibu_hamil',
      'Kader Posyandu' => 'kader',
      _ => 'ibu_balita',
    };
    state.signIn(
      name: state.user?.displayName ?? 'Bunda',
      role: code,
    );
    context.go(role.route);
  }

  Widget _selectedFooter(_RoleOption role) {
    return Row(
      children: [
        const StatusChip(
          text: '✓ Dipilih',
          color: AppColors.brand,
          onColor: Colors.white,
        ),
        const Spacer(),
        Text(role.cta, style: AppText.bodySm),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 6, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PillLabel(text: 'LANGKAH 1 DARI 3 • PILIHAN PERAN'),
          const SizedBox(height: 18),
          const Text(
            'Bagaimana Anda akan menggunakan NURI?',
            style: AppText.h1,
          ),
          const SizedBox(height: 12),
          const Text(
            'Pilih peran utama Anda untuk mendapatkan panduan nutrisi terarah, '
            'pemantauan kurva WHO, dan rekomendasi harian yang tepat.',
            style: AppText.body,
          ),
          const SizedBox(height: 20),
          for (int i = 0; i < _roles.length; i++) ...[
            ChoiceCard(
              title: _roles[i].title,
              icon: _roles[i].icon,
              badge: _roles[i].badge,
              subtitle: _roles[i].subtitle,
              selected: _selected == i,
              onTap: () => setState(() => _selected = i),
              footer: _selected == i ? _selectedFooter(_roles[i]) : null,
            ),
            if (i < _roles.length - 1) const SizedBox(height: 14),
          ],
          const SizedBox(height: 20),
          const NoteBox(
            icon: Icons.verified_user_outlined,
            child: Text(
              'Anda dapat menambah atau berpindah peran kapan saja melalui menu '
              'Profil Keluarga tanpa kehilangan data historis pemantauan.',
              style: AppText.body,
            ),
          ),
          const SizedBox(height: 24),
          NuriPrimaryButton(
            label: 'Lanjutkan',
            trailingArrow: true,
            onPressed: _continue,
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Langkah berikutnya: Pengisian data tumbuh kembang awal',
              textAlign: TextAlign.center,
              style: AppText.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleOption {
  const _RoleOption({
    required this.title,
    required this.icon,
    required this.badge,
    required this.subtitle,
    required this.cta,
    required this.route,
  });

  final String title;
  final IconData icon;
  final String badge;
  final String subtitle;
  final String cta;
  final String route;
}
