import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/demo.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/chips.dart';
import '../../core/widgets/nuri_button.dart';
import '../../core/widgets/nuri_card.dart';
import '../../core/widgets/nuri_photo.dart';
import '../../core/widgets/nuri_scaffold.dart';
import '../../core/widgets/nuri_tabs.dart';
import '../../core/widgets/nuri_top_bar.dart' show NuriAvatar;
import '../../core/widgets/nutrient.dart';
import '../../core/widgets/section.dart';
import '../../core/widgets/tiles.dart';
import '../../core/widgets/who_growth_chart.dart';
import '../../data/nuri_repository.dart';
import '../../domain/models/child.dart';
import '../../domain/models/food_log.dart';
import '../../domain/models/growth_result.dart';
import '../../domain/models/growth_status.dart';
import '../../domain/models/nutrient.dart';
import '../../domain/models/nutrition_summary.dart';
import '../../state/app_state.dart';

/// Beranda ruang ibu (balita) — ringkasan tumbuh kembang harian.
class MomHomeScreen extends StatelessWidget {
  const MomHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NuriAppState state = NuriScope.of(context);
    final Child? child = state.selectedChild;

    return NuriScaffold(
      bottomNavigationBar: const MomTabBar(active: '/home'),
      topBar: const _HomeTopBar(),
      body: child == null
          ? ListView(
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              children: [
                _Greeting(state: state),
                const SizedBox(height: 18),
                const _EmptyChildCard(),
              ],
            )
          : _HomeBody(state: state, child: child),
    );
  }
}

/// Isi beranda ketika sudah ada anak terpilih.
class _HomeBody extends StatelessWidget {
  const _HomeBody({required this.state, required this.child});

  final NuriAppState state;
  final Child child;

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final ScreeningRecord? latest = state.latestForSelected;
    final List<ScreeningRecord> records = state.screeningsFor(child.id);
    final NutritionSummary summary = state.nutritionSummaryFor(
      child: child,
      date: state.today,
    );
    final List<FoodLogItem> items = state.foodItemsFor(
      childId: child.id,
      date: state.today,
    );

    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      children: [
        _Greeting(state: state),
        const SizedBox(height: 18),

        // Ringkasan anak.
        NuriCard(
          onTap: () => context.go('/growth'),
          child: Row(
            children: [
              const NuriAvatar(imageUrl: DemoImages.avatarChild, size: 48),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            child.nickname,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.title,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Tag(text: child.ageLabelAt(now)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      latest == null
                          ? 'Belum ada pengukuran'
                          : 'Terakhir: ${_fmtNum(latest.measurement.weightKg)} kg'
                                ' • ${_fmtNum(latest.measurement.lengthHeightCm)} cm'
                                '${child.posyanduName != null ? ' di ${child.posyanduName}' : ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.caption,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.inkFaint),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Kartu kabar hijau.
        _KabarCard(
          child: child,
          latest: latest,
          records: records,
        ),
        const SizedBox(height: 14),

        // Kartu analisis piring (pink).
        NuriCard(
          color: AppColors.pastelPink,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DotBadge(
                text: '✦ NURI SMART VISION',
                background: AppColors.surface,
                dotColor: AppColors.brand,
              ),
              const SizedBox(height: 14),
              const Text('Pindai Piring MP–ASI Si Kecil', style: AppText.h3),
              const SizedBox(height: 8),
              const Text(
                'Ambil foto makanan saat ini, lalu biarkan AI menganalisis '
                'kecukupan protein hewani dan zat besi hari ini.',
                style: AppText.body,
              ),
              const SizedBox(height: 16),
              _WhitePillButton(
                label: 'Buka Kamera Analisis AI',
                onPressed: () => context.go('/camera-plate'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Dua ubin aksi.
        LayoutBuilder(
          builder: (context, constraints) {
            final Widget first = ActionTile(
              title: 'Jadwal Pengukuran Posyandu',
              subtitle: child.posyanduName ?? 'Posyandu',
              icon: Icons.event_note_outlined,
              showChevron: false,
            );
            final Widget second = ActionTile(
              title: 'Catat Mandiri di Input Ukuran Rumah',
              background: AppColors.pastelGreen,
              leading: const IconBadge(icon: Icons.add_rounded),
              onTap: () => context.go('/screening'),
              showChevron: false,
            );
            if (constraints.maxWidth < 360) {
              return Column(
                children: [first, const SizedBox(height: 12), second],
              );
            }
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: first),
                  const SizedBox(width: 12),
                  Expanded(child: second),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 22),

        SectionHeader(
          title: 'Menu Nutrisi Hari Ini',
          actionLabel: 'Lihat',
          onAction: () => context.go('/nutrition'),
        ),
        const SizedBox(height: 12),

        // Kartu menu bergambar + progres gizi nyata.
        NuriCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimens.radiusXl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NuriPhoto(
                  url: DemoImages.plateMeal,
                  height: 210,
                  radius: 0,
                  overlay: Stack(
                    children: [
                      Positioned(
                        left: 16,
                        top: 16,
                        child: PhotoTag(
                          label: 'Usia ${child.ageLabelAt(now)} • MP-ASI',
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FOKUS GIZI HARI INI',
                          style: AppText.label
                              .copyWith(color: AppColors.inkFaint)),
                      const SizedBox(height: 8),
                      const Text('Progres Energi & Protein Hewani',
                          style: AppText.h3),
                      const SizedBox(height: 8),
                      Text(
                        'Pantau asupan ${child.nickname} hari ini terhadap '
                        'Angka Kecukupan Gizi (AKG) usia '
                        '${child.ageLabelAt(now)}.',
                        style: AppText.body,
                      ),
                      const SizedBox(height: 14),
                      _NutrientProgress(intake: summary.energy),
                      const SizedBox(height: 12),
                      _NutrientProgress(
                        intake: summary.intakeFor(Nutrient.protein),
                      ),
                      const SizedBox(height: 14),
                      if (summary.isEmpty)
                        const NoteRow(
                          icon: Icons.restaurant_outlined,
                          text: 'Belum ada catatan makan hari ini. '
                              'Tambahkan lewat menu gizi.',
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final MealType meal in MealType.values)
                              SoftChip(
                                label:
                                    '${meal.label} ${_mealDone(items, meal) ? '✓ Selesai' : 'Belum'}',
                                icon: _mealDone(items, meal)
                                    ? Icons.check_circle_outline
                                    : Icons.schedule,
                                color: _mealDone(items, meal)
                                    ? AppColors.pastelGreen
                                    : AppColors.surfaceSoft,
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),

        SectionHeader(
          title: 'Metrik Terakhir',
          actionLabel: 'Lihat Kurva',
          onAction: () => context.go('/growth'),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: MetricBox(
                label: 'BERAT BADAN',
                value: latest == null
                    ? '—'
                    : _fmtNum(latest.measurement.weightKg),
                unit: 'kg',
                trend: latest == null
                    ? 'Belum diukur'
                    : latest.result.status.label,
                trendColor: latest == null
                    ? AppColors.inkFaint
                    : _statusColor(latest.result.status),
                icon: Icons.monitor_weight_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricBox(
                label: 'TINGGI BADAN',
                value: latest == null
                    ? '—'
                    : _fmtNum(latest.measurement.lengthHeightCm),
                unit: 'cm',
                trend: latest == null
                    ? 'Belum diukur'
                    : 'Z ${latest.result.zLabel} SD',
                trendColor: latest == null
                    ? AppColors.inkFaint
                    : _statusColor(latest.result.status),
                icon: Icons.straighten,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ActionTile(
          title: child.posyanduName ?? 'Posyandu',
          subtitle: 'Pemantauan rutin tumbuh kembang balita',
          icon: Icons.event_available_outlined,
          onTap: () => context.go('/screening'),
        ),
        const SizedBox(height: 22),

        SectionHeader(
          title: 'NURI CARE • EDUKASI',
          subtitle: 'Rekomendasi untuk ${child.ageLabelAt(now)}',
        ),
        const SizedBox(height: 12),
        const NuriCard(
          child: Row(
            children: [
              NuriPhoto(
                  url: DemoImages.motherBaby,
                  width: 76,
                  height: 76,
                  radius: 16),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Bimbingan Gizi Parenting', style: AppText.h3),
                    SizedBox(height: 2),
                    Text('3 menit bacaan', style: AppText.bodySm),
                    SizedBox(height: 10),
                    Text(
                      'Tips Menghadapi Fase Memilih Makanan',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.bodySm,
                    ),
                    SizedBox(height: 6),
                    NutrientBar(value: 0.4, height: 6),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: AppColors.inkFaint),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ActionTile(
          title: 'Resep MP-ASI Hemat',
          subtitle: 'Olahan lokal kaya gizi untuk si kecil',
          icon: Icons.menu_book_outlined,
          onTap: () => context.go('/nutrition'),
        ),
        const SizedBox(height: 10),
        ActionTile(
          title: 'Stimulasi Motorik ${child.ageLabelAt(now)}',
          subtitle: 'Rangsangan gerak sesuai usia',
          icon: Icons.directions_run_rounded,
          onTap: () => context.go('/growth'),
        ),
        const SizedBox(height: 10),
        ActionTile(
          title: 'Tanda Bahaya Stunting',
          subtitle: 'Kenali gejala sedini mungkin',
          icon: Icons.health_and_safety_outlined,
          onTap: () => context.go('/screening'),
        ),
      ],
    );
  }
}

/// Kartu hijau "Kabar si kecil" yang mengambil status dari hasil terakhir.
class _KabarCard extends StatelessWidget {
  const _KabarCard({
    required this.child,
    required this.latest,
    required this.records,
  });

  final Child child;
  final ScreeningRecord? latest;
  final List<ScreeningRecord> records;

  @override
  Widget build(BuildContext context) {
    final NuriAppState state = NuriScope.of(context);

    if (latest == null) {
      return NuriCard(
        gradient: AppColors.brandGradient,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'KABAR SI KECIL HARI INI',
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 14),
            Text('Belum Ada Pengukuran',
                style: AppText.h2.copyWith(color: Colors.white)),
            const SizedBox(height: 10),
            Text(
              'Yuk ukur berat dan tinggi ${child.nickname} untuk melihat '
              'status gizi serta kurva pertumbuhannya.',
              style: AppText.body.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 16),
            NuriCard(
              color: AppColors.surface,
              radius: 20,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mulai dari sini', style: AppText.title),
                  const SizedBox(height: 4),
                  const Text(
                    'Butuh kurang dari 1 menit untuk mencatat ukuran.',
                    style: AppText.bodySm,
                  ),
                  const SizedBox(height: 12),
                  NuriPrimaryButton(
                    label: 'Ukur sekarang',
                    icon: Icons.add_rounded,
                    onPressed: () => context.go('/screening'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final GrowthResult result = latest!.result;
    final GrowthStatus status = result.status;
    final List<WhoChartPoint> points = <WhoChartPoint>[
      for (int i = 0; i < records.length; i++)
        WhoChartPoint(
          month: records[i].result.ageMonths,
          cm: records[i].measurement.adjustedCm,
          isLatest: i == records.length - 1,
        ),
    ];

    return NuriCard(
      gradient: AppColors.brandGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'KABAR SI KECIL HARI INI',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.label.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 10.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Tag(
                text: status == GrowthStatus.normal
                    ? 'Pita Hijau WHO'
                    : status.label,
                color: AppColors.surface,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            status.plainLanguage,
            style: AppText.h2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            result.recommendation?.summary ??
                'Terus pantau pertumbuhan ${child.nickname} secara rutin agar '
                    'asupan gizi dan tumbuh kembangnya tetap optimal.',
            style: AppText.body.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Kurva Pertumbuhan ${child.ageLabelAt(DateTime.now())}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.title.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Z-Score: ${result.zLabel} SD',
                  style: AppText.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          NuriCard(
            color: AppColors.surface,
            radius: 20,
            padding: const EdgeInsets.fromLTRB(8, 14, 8, 4),
            child: WhoGrowthChart(
              table: state.reference.whoLms,
              sex: child.sex,
              points: points,
              height: 150,
              maxMonth: 60,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DarkMetric(
                  label: 'BERAT',
                  value: '${_fmtNum(latest!.measurement.weightKg)} kg',
                ),
              ),
              Expanded(
                child: _DarkMetric(
                  label: 'TINGGI',
                  value: '${_fmtNum(latest!.measurement.lengthHeightCm)} cm',
                ),
              ),
              Expanded(
                child: _DarkMetric(
                  label: 'Z-SCORE',
                  value: '${result.zLabel} SD',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Sapaan dengan nama pengguna dari state.
class _Greeting extends StatelessWidget {
  const _Greeting({required this.state});

  final NuriAppState state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.pastelGreenSoft,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.eco_rounded,
              color: AppColors.brandText, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Selamat Pagi, ${state.user?.displayName ?? 'Bunda'}',
            style: AppText.h1,
          ),
        ),
      ],
    );
  }
}

/// Keadaan kosong saat belum ada anak terdaftar.
class _EmptyChildCard extends StatelessWidget {
  const _EmptyChildCard();

  @override
  Widget build(BuildContext context) {
    return NuriCard(
      child: Column(
        children: [
          const IconBadge(icon: Icons.child_care_rounded, size: 60, radius: 20),
          const SizedBox(height: 14),
          const Text('Belum Ada Data Anak',
              style: AppText.h3, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text(
            'Tambahkan profil anak untuk mulai memantau tumbuh kembang, '
            'gizi, dan skrining stunting.',
            style: AppText.body,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          NuriPrimaryButton(
            label: 'Tambah anak',
            icon: Icons.add_rounded,
            onPressed: () => context.go('/child-data'),
          ),
        ],
      ),
    );
  }
}

/// Progres satu nutrien terhadap target AKG.
class _NutrientProgress extends StatelessWidget {
  const _NutrientProgress({required this.intake});

  final NutrientIntake intake;

  @override
  Widget build(BuildContext context) {
    final double ratio = intake.hasTarget ? (intake.percent / 100).clamp(0, 1) : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                intake.nutrient.label,
                style: AppText.bodyStrong.copyWith(fontSize: 13.5),
              ),
            ),
            Text(
              intake.hasTarget
                  ? '${intake.percent.round()}% • ${intake.light.label}'
                  : 'Belum ada target',
              style: AppText.caption,
            ),
          ],
        ),
        const SizedBox(height: 6),
        NutrientBar(value: ratio, color: _trafficColor(intake.light)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Helper format & warna.

String _fmtNum(double value, {int digits = 1}) =>
    value.toStringAsFixed(digits).replaceAll('.', ',');

bool _mealDone(List<FoodLogItem> items, MealType meal) =>
    items.any((FoodLogItem item) => item.meal == meal);

Color _statusColor(GrowthStatus status) => switch (status) {
      GrowthStatus.sangatPendek => AppColors.statusSangatPendek,
      GrowthStatus.pendek => AppColors.statusPendek,
      GrowthStatus.normal => AppColors.statusNormal,
      GrowthStatus.tinggi => AppColors.statusTinggi,
    };

Color _trafficColor(TrafficLight light) => switch (light) {
      TrafficLight.kurang => AppColors.statusPendek,
      TrafficLight.cukup => AppColors.statusNormal,
      TrafficLight.lebih => AppColors.statusSangatPendek,
    };

// ---------------------------------------------------------------------------

/// Bilah atas khusus beranda: avatar bunda, nama anak, dan aksi cepat.
class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar();

  @override
  Widget build(BuildContext context) {
    final NuriAppState state = NuriScope.of(context);
    final Child? child = state.selectedChild;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            const NuriAvatar(imageUrl: DemoImages.avatarMother, size: 44),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Panduan Antarkuwa & Asisten AI',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption,
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          child == null
                              ? 'Belum ada anak'
                              : '${child.nickname} • ${child.ageLabelAt(DateTime.now())}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.h3,
                        ),
                      ),
                      const Icon(Icons.expand_more_rounded,
                          size: 20, color: AppColors.inkSoft),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            NuriSoftButton(
              icon: Icons.calendar_month_outlined,
              onPressed: () => context.go('/screening'),
            ),
            const SizedBox(width: 8),
            const NuriAvatar(
              icon: Icons.notifications_none_rounded,
              background: AppColors.surface,
              color: AppColors.ink,
            ),
          ],
        ),
      ),
    );
  }
}

/// Metrik kecil bertulisan putih untuk kartu hijau.
class _DarkMetric extends StatelessWidget {
  const _DarkMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppText.caption.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: AppText.h3.copyWith(color: Colors.white)),
      ],
    );
  }
}

/// Tombol pil putih dengan teks hijau dan panah.
class _WhitePillButton extends StatelessWidget {
  const _WhitePillButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        onTap: onPressed,
        child: Container(
          height: AppDimens.buttonHeight,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppText.button.copyWith(color: AppColors.brand),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_rounded,
                  color: AppColors.brand, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
