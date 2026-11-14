import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../domain/nutrition/nutrition_calculator.dart';
import '../../domain/pregnancy/pregnancy_calculator.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import '../consultation/consultation_screen.dart';
import '../education/education_screen.dart';
import 'diary_screen.dart';
import 'food_flow.dart';
import 'growth_screens.dart';
import 'pregnancy_screens.dart';
import 'recommendation_screen.dart';

class MotherHomeScreen extends ConsumerWidget {
  const MotherHomeScreen({super.key});

  static MealType _mealForNow() {
    final hour = DateTime.now().hour;
    if (hour < 11) return MealType.breakfast;
    if (hour < 15) return MealType.lunch;
    if (hour < 18) return MealType.snack;
    return MealType.dinner;
  }

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final user = state.currentUser;
    if (user == null) return const SizedBox.shrink();
    final pregnancy = state.activePregnancy;
    final children = state.myChildren;
    final child = state.activeChild;
    final hasBoth = pregnancy != null && children.isNotEmpty;
    final showPregnancy = hasBoth ? state.pregnancyContext : pregnancy != null;
    final today = dateOnly(DateTime.now());

    final pregnancyProgress = pregnancy == null
        ? null
        : PregnancyCalculator.progress(
            hpht: pregnancy.hpht,
            hpl: pregnancy.hpl,
            today: today,
          );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await Future<void>.delayed(const Duration(milliseconds: 450));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_greeting()},',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.muted,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontSize: 23, letterSpacing: -0.4),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${formatWeekday(today)}, ${formatDateId(today, withYear: false)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    RoundIconButton(
                      icon: Icons.notifications_none_rounded,
                      onTap: () =>
                          _showNotifications(context, state, showPregnancy),
                    ),
                    const SizedBox(width: 10),
                    AppAvatar(
                      name: user.name,
                      size: 42,
                      imageAsset: user.avatarAsset,
                      showBadge: true,
                    ),
                  ],
                ),
                if (hasBoth) ...[
                  const SizedBox(height: 14),
                  NuriSegmentedControl<bool>(
                    values: const [true, false],
                    selected: showPregnancy,
                    labelFor: (value) => value
                        ? 'Kehamilan'
                        : child?.nickname.split(' ').first ?? 'Anak',
                    onChanged: (value) => ref
                        .read(appControllerProvider.notifier)
                        .selectContext(pregnancy: value),
                  ),
                ],
                const SizedBox(height: 16),
                if (showPregnancy)
                  _PregnancyHero(
                    pregnancy: pregnancy,
                    progress: pregnancyProgress!,
                  )
                else if (child != null)
                  _ChildHero(
                    child: child,
                    onTap: () => _push(context, const GrowthDetailScreen()),
                  )
                else
                  const _EmptyDataCard(),
                const SizedBox(height: 14),
                if (showPregnancy) ...[
                  _PregnancyTodayCard(
                    pregnancy: pregnancy,
                    today: today,
                    onTtd: () => _push(context, const TtdScreen()),
                    onTakeTtd: () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(appControllerProvider.notifier)
                          .toggleTtdForDate(today);
                      showNuriSnack(
                        context,
                        pregnancy.ttdDates.contains(dateToIso(today))
                            ? 'Catatan TTD hari ini dibatalkan.'
                            : 'Hebat! TTD hari ini sudah dicatat.',
                      );
                    },
                    onAnc: () => _push(context, const AncScreen()),
                    onCheckup: () =>
                        _push(context, const PregnancyCheckupScreen()),
                  ),
                  const SizedBox(height: 14),
                  _NutritionCard(
                    title: 'Gizi kehamilan hari ini',
                    subtitle: 'Perkiraan dari catatan makan Ibu',
                    totals: state.totalsFor(pregnancy.id, today),
                    target: const AkgReference().forPregnancy(
                      pregnancyProgress!.trimester,
                    ),
                    onOpenDiary: () => _push(
                      context,
                      DiaryScreen(
                        subjectId: pregnancy.id,
                        subjectLabel: 'Kehamilan',
                      ),
                    ),
                    onLog: () =>
                        _openCamera(context, pregnancy.id, 'Kehamilan'),
                    primaryAction: false,
                  ),
                ] else if (child != null) ...[
                  _NutritionCard(
                    title: 'Gizi ${child.nickname.split(' ').first} hari ini',
                    subtitle: 'Perkiraan dari catatan makan',
                    totals: state.totalsFor(child.id, today),
                    target: const AkgReference().forChild(
                      child.ageMonthsAt(today),
                      child.sex,
                    ),
                    onOpenDiary: () => _push(
                      context,
                      DiaryScreen(
                        subjectId: child.id,
                        subjectLabel: child.nickname,
                      ),
                    ),
                    onLog: () => _openCamera(context, child.id, child.nickname),
                    primaryAction: true,
                    onMeasure: () => _push(
                      context,
                      MeasurementInputScreen(childId: child.id),
                    ),
                  ),
                ],
                if (state.nextPosyanduDate != null) ...[
                  const SizedBox(height: 14),
                  _PosyanduReminder(
                    date: state.nextPosyanduDate!,
                    name: state.posyanduName,
                    area: state.posyanduArea,
                    onTap: () => _showPosyanduSheet(context, state),
                  ),
                ],
                const SizedBox(height: 12),
                AppCard(
                  padding: const EdgeInsets.all(14),
                  child: InkWell(
                    onTap: () => _push(context, const ConsultationScreen()),
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.medical_services_outlined,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Konsultasi Bidan & Nakes',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Bidan desa dan perawat siap mendampingi',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.muted,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SectionHeader(
                  title: 'Untuk Ibu',
                  actionLabel: 'Edukasi',
                  onAction: () =>
                      _push(context, const EducationScreen(showBack: true)),
                ),
                const SizedBox(height: 10),
                _ForYouCard(
                  article: _articleFor(state.contents, showPregnancy),
                  onArticle: () {
                    final article = _articleFor(state.contents, showPregnancy);
                    if (article == null) return;
                    ref
                        .read(appControllerProvider.notifier)
                        .markArticleRead(article.id);
                    _push(context, ArticleDetailScreen(article: article));
                  },
                  onMenu: () => _push(
                    context,
                    RecommendationScreen(
                      subjectLabel: showPregnancy
                          ? 'Kehamilan'
                          : child?.nickname ?? 'Si Kecil',
                      pregnancyMode: showPregnancy,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const NuriDisclaimer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  void _openCamera(
    BuildContext context,
    String subjectId,
    String subjectLabel,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FoodCameraScreen(
          subjectId: subjectId,
          subjectLabel: subjectLabel,
          initialMeal: _mealForNow(),
        ),
      ),
    );
  }

  ContentArticle? _articleFor(List<ContentArticle> contents, bool pregnancy) {
    final id = pregnancy ? 'art_trimester2' : 'art_protein';
    for (final article in contents) {
      if (article.id == id) return article;
    }
    return contents.isEmpty ? null : contents.first;
  }

  void _showNotifications(
    BuildContext context,
    AppState state,
    bool pregnancy,
  ) {
    showNuriSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Pengingat',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                const Pill(
                  label: 'Hari ini',
                  background: AppColors.mint,
                  foreground: AppColors.primaryDark,
                ),
              ],
            ),
            const SizedBox(height: 16),
            NuriInfoRow(
              icon: pregnancy
                  ? Icons.medication_rounded
                  : Icons.restaurant_rounded,
              title: pregnancy
                  ? 'Minum tablet tambah darah'
                  : 'Selingan sehat Si Kecil',
              subtitle: pregnancy
                  ? 'Setelah makan malam • 1 tablet'
                  : 'Buah atau telur rebus • porsi kecil',
              color: AppColors.coral,
              background: AppColors.peachSoft,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            NuriInfoRow(
              icon: Icons.event_available_rounded,
              title: 'Posyandu berikutnya',
              subtitle: state.nextPosyanduDate == null
                  ? 'Jadwal menyusul'
                  : formatDateId(state.nextPosyanduDate!),
              color: AppColors.primary,
              background: AppColors.mint,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            NuriInfoRow(
              icon: Icons.menu_book_rounded,
              title: 'Artikel untuk Ibu',
              subtitle: pregnancy
                  ? 'Panduan aman trimester 2'
                  : 'Protein hewani di usia 1–2 tahun',
              color: AppColors.blue,
              background: AppColors.blueSoft,
            ),
            const SizedBox(height: 14),
            const NuriDisclaimer(compact: true),
          ],
        ),
      ),
    );
  }

  void _showPosyanduSheet(BuildContext context, AppState state) {
    showNuriSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jadwal Posyandu',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              '${state.posyanduName} • ${state.posyanduArea}',
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            InfoBanner(
              title: state.nextPosyanduDate == null
                  ? 'Menunggu jadwal'
                  : formatDateId(state.nextPosyanduDate!),
              body: '07.30–11.00 • Penimbangan & konsultasi',
              icon: Icons.calendar_month_rounded,
              background: AppColors.peachSoft,
              foreground: AppColors.coral,
            ),
            const SizedBox(height: 12),
            const InfoBanner(
              title: 'Yang perlu dibawa',
              body: 'Buku KIA, kartu NURI, dan catatan makan anak bila ada.',
              icon: Icons.checklist_rounded,
            ),
            const SizedBox(height: 14),
            NuriButton(
              label: 'Tutup',
              variant: NuriButtonVariant.outlined,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PregnancyHero extends StatelessWidget {
  const _PregnancyHero({required this.pregnancy, required this.progress});

  final Pregnancy pregnancy;
  final PregnancyProgress progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF171717), Color(0xFF262626)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Pill(
                label: 'Trimester ${progress.trimester}',
                background: AppColors.vitalYellow,
                foreground: AppColors.medicalBlack,
                fontSize: 11.5,
                bold: true,
              ),
              const Spacer(),
              Text(
                progress.daysToHpl >= 0
                    ? '${progress.daysToHpl} hari menuju HPL'
                    : 'Sudah waktunya',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Usia kehamilan',
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${progress.weeks} minggu ${progress.days} hari',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 28,
              height: 1.12,
              letterSpacing: -0.4,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress.progress),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) => Stack(
                children: [
                  Container(
                    height: 6,
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                  FractionallySizedBox(
                    widthFactor: value.clamp(0.0, 1.0),
                    child: Container(height: 6, color: AppColors.vitalYellow),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Perkiraan lahir ${formatDateId(pregnancy.hpl, withYear: true)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.child_care_rounded,
                  size: 19,
                  color: AppColors.vitalYellow,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    'Si Kecil ${progress.sizeLabel}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  '±${progress.fetalWeightG} g',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.82),
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildHero extends StatelessWidget {
  const _ChildHero({required this.child, required this.onTap});

  final Child child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final latest = child.latestMeasurement;
    final status = latest == null ? null : _plainGrowthStatus(latest.category);
    return AppCard(
      onTap: onTap,
      shadow: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              AppAvatar(
                name: child.nickname,
                index: child.avatarIndex,
                size: 50,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.nickname,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${child.ageLabel()} • ${child.sex.label}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (status != null)
                Pill(
                  label: status.label,
                  icon: status.icon,
                  background: status.background,
                  foreground: status.foreground,
                  fontSize: 11,
                  bold: true,
                ),
            ],
          ),
          if (latest != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _HeroMetric(
                    label: 'Berat',
                    value: fmt1(latest.weightKg),
                    unit: 'kg',
                  ),
                  const _MetricDivider(),
                  _HeroMetric(
                    label: 'Panjang',
                    value: fmt1(latest.measuredCm),
                    unit: 'cm',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.history_rounded,
                  size: 14,
                  color: AppColors.muted,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Diukur ${relativeDayLabel(latest.date).toLowerCase()} • ${latest.source == 'kader' ? 'oleh kader' : 'mandiri'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.muted,
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 14),
            const InfoBanner(
              title: 'Belum ada pengukuran',
              body: 'Catat panjang dan berat badan pertama untuk melihat posisi tumbuh Si Kecil.',
              icon: Icons.straighten_rounded,
            ),
          ],
        ],
      ),
    );
  }
}

({String label, IconData icon, Color background, Color foreground})
_plainGrowthStatus(GrowthCategory category) => (
  label: category.plainLabel,
  icon: switch (category) {
    GrowthCategory.normal => Icons.check_circle_outline_rounded,
    GrowthCategory.stunted => Icons.trending_down_rounded,
    GrowthCategory.severelyStunted => Icons.error_outline_rounded,
    GrowthCategory.tall => Icons.trending_up_rounded,
  },
  background: switch (category) {
    GrowthCategory.normal => AppColors.mint,
    GrowthCategory.stunted => AppColors.amberSoft,
    GrowthCategory.severelyStunted => AppColors.redSoft,
    GrowthCategory.tall => AppColors.blueSoft,
  },
  foreground: switch (category) {
    GrowthCategory.normal => AppColors.primaryDark,
    GrowthCategory.stunted => AppColors.amber,
    GrowthCategory.severelyStunted => AppColors.red,
    GrowthCategory.tall => AppColors.blue,
  },
);

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({
    required this.label,
    required this.value,
    required this.unit,
  });
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
          ),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 17.5,
                    fontWeight: FontWeight.w800,
                    fontFeatures: [FontFeature.tabularFigures()],
                    color: AppColors.text,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(fontSize: 11, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 28, color: AppColors.line);
}

class _EmptyDataCard extends StatelessWidget {
  const _EmptyDataCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: AppColors.surfaceSubtle,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.spa_rounded,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Data Ibu belum lengkap',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tambahkan data kehamilan atau anak dari menu Profil untuk mulai memantau.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.muted,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _PregnancyTodayCard extends StatelessWidget {
  const _PregnancyTodayCard({
    required this.pregnancy,
    required this.today,
    required this.onTtd,
    required this.onTakeTtd,
    required this.onAnc,
    required this.onCheckup,
  });

  final Pregnancy pregnancy;
  final DateTime today;
  final VoidCallback onTtd;
  final VoidCallback onTakeTtd;
  final VoidCallback onAnc;
  final VoidCallback onCheckup;

  @override
  Widget build(BuildContext context) {
    final takenToday = pregnancy.ttdDates.contains(dateToIso(today));
    final checkup = pregnancy.latestCheckup;
    final ancRemaining = (AkgReference.ancTarget - pregnancy.ancCount).clamp(
      0,
      AkgReference.ancTarget,
    );
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Hari ini', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Text(
                formatDateId(today, withYear: false),
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _TodayRow(
            icon: Icons.medication_rounded,
            color: AppColors.coral,
            tint: AppColors.peachSoft,
            title: 'Tablet Tambah Darah',
            subtitle: takenToday
                ? 'Sudah dicatat hari ini'
                : 'Minum 1 tablet setelah makan malam',
            onTap: onTtd,
            trailing: takenToday
                ? const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 22,
                  )
                : FilledButton(
                    onPressed: onTakeTtd,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      textStyle: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Catat'),
                  ),
          ),
          const Divider(height: 24),
          _TodayRow(
            icon: Icons.event_available_rounded,
            color: AppColors.primary,
            tint: AppColors.mint,
            title: 'Kunjungan ANC',
            subtitle: ancRemaining == 0
                ? '${pregnancy.ancCount} kunjungan tercatat'
                : '${pregnancy.ancCount}/${AkgReference.ancTarget} tercatat • $ancRemaining lagi',
            onTap: onAnc,
            trailing: const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.muted,
            ),
          ),
          const Divider(height: 24),
          _TodayRow(
            icon: Icons.monitor_heart_outlined,
            color: AppColors.blue,
            tint: AppColors.blueSoft,
            title: 'Pemeriksaan terakhir',
            subtitle: checkup == null
                ? 'Belum ada catatan pemeriksaan'
                : '${relativeDayLabel(checkup.date)} • BB ${fmt1(checkup.weightKg)} kg • LiLA ${fmt1(checkup.lilaCm)} cm',
            onTap: onCheckup,
            trailing: const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.muted,
            ),
          ),
          if (checkup?.needsConsultation == true) ...[
            const SizedBox(height: 12),
            const InfoBanner(
              title: 'Perlu konsultasi',
              body: 'LiLA < 23,5 cm atau Hb < 11 g/dL. Diskusikan dengan bidan atau dokter.',
              icon: Icons.warning_amber_rounded,
              background: AppColors.amberSoft,
              foreground: AppColors.amber,
            ),
          ],
        ],
      ),
    );
  }
}

class _TodayRow extends StatelessWidget {
  const _TodayRow({
    required this.icon,
    required this.color,
    required this.tint,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color tint;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, size: 19, color: color),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.muted,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        trailing,
      ],
    );
    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: content,
      ),
    );
  }
}

class _NutritionCard extends StatefulWidget {
  const _NutritionCard({
    required this.title,
    required this.subtitle,
    required this.totals,
    required this.target,
    required this.onOpenDiary,
    required this.onLog,
    required this.primaryAction,
    this.onMeasure,
  });

  final String title;
  final String subtitle;
  final NutritionTotals totals;
  final AkgTarget target;
  final VoidCallback onOpenDiary;
  final VoidCallback onLog;
  final bool primaryAction;
  final VoidCallback? onMeasure;

  @override
  State<_NutritionCard> createState() => _NutritionCardState();
}

class _NutritionCardState extends State<_NutritionCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final totals = widget.totals;
    final target = widget.target;
    final kcal = totals.kcal;
    final percent =
        (NutritionCalculator.percent(kcal, target.energyKcal) ?? 0) / 100;
    final status = NutritionCalculator.status(kcal, target.energyKcal);
    final statusColor = switch (status) {
      NutrientStatus.low => AppColors.amber,
      NutrientStatus.high => AppColors.coral,
      _ => AppColors.primary,
    };
    final statusLabel = switch (status) {
      NutrientStatus.low => 'Perlu dilengkapi',
      NutrientStatus.high => 'Melebihi anjuran',
      _ => 'Sesuai anjuran',
    };

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: widget.onOpenDiary,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Catatan'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _CalorieRing(percent: percent, color: statusColor),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: kcal == null ? '—' : kcal.round().toString(),
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 27,
                              fontWeight: FontWeight.w800,
                              fontFeatures: [FontFeature.tabularFigures()],
                              color: AppColors.text,
                              height: 1,
                            ),
                          ),
                          TextSpan(
                            text: ' / ${target.energyKcal.round()} kkal',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            '$statusLabel • ${target.label}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (totals.incomplete) ...[
                      const SizedBox(height: 3),
                      const Text(
                        'Sebagian nilai gizi belum lengkap',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => setState(() => _expanded = !_expanded),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                minimumSize: const Size(0, 34),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              icon: Icon(
                _expanded
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                size: 18,
              ),
              label: Text(
                _expanded ? 'Sembunyikan rincian' : 'Lihat rincian gizi',
              ),
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: _MacroBar(
                    label: 'Protein',
                    value: totals.proteinG,
                    target: target.proteinG,
                    color: AppColors.coral,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MacroBar(
                    label: 'Lemak',
                    value: totals.fatG,
                    target: target.fatG,
                    color: AppColors.amber,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MacroBar(
                    label: 'Karbo',
                    value: totals.carbG,
                    target: target.carbG,
                    color: AppColors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _MicroValue(
                  label: 'Zat besi',
                  value: totals.ironMg,
                  unit: 'mg',
                ),
                const SizedBox(width: 10),
                _MicroValue(label: 'Zink', value: totals.zincMg, unit: 'mg'),
              ],
            ),
          ],
          const SizedBox(height: 12),
          if (widget.primaryAction)
            NuriButton(
              label: 'Catat makan',
              icon: Icons.add_a_photo_outlined,
              height: 46,
              onPressed: widget.onLog,
            )
          else
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: widget.onLog,
                icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                label: const Text('Catat makan'),
              ),
            ),
          if (widget.onMeasure != null) ...[
            const Divider(height: 24),
            _TodayRow(
              icon: Icons.straighten_rounded,
              color: AppColors.primary,
              tint: AppColors.mint,
              title: 'Ukur anak',
              subtitle: 'Perbarui berat dan panjang badan',
              onTap: widget.onMeasure,
              trailing: const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.muted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MicroValue extends StatelessWidget {
  const _MicroValue({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final double? value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
              ),
            ),
            Text(
              value == null ? '—' : '${value!.toStringAsFixed(1)} $unit',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalorieRing extends StatelessWidget {
  const _CalorieRing({required this.percent, required this.color});

  final double percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final safe = percent.clamp(0.0, 1.0);
    return SizedBox(
      width: 68,
      height: 68,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: safe),
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) => Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 68,
              height: 68,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: 7,
                backgroundColor: AppColors.surfaceSubtle,
                valueColor: AlwaysStoppedAnimation(color),
                strokeCap: StrokeCap.round,
              ),
            ),
            Text(
              '${(percent * 100).round()}%',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({
    required this.label,
    required this.value,
    required this.target,
    required this.color,
  });

  final String label;
  final double? value;
  final double target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ratio = ((value ?? 0) / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
              ),
            ),
            Text(
              value == null ? '—' : '${value!.round()}/${target.round()}g',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 5,
            backgroundColor: AppColors.surfaceSubtle,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _PosyanduReminder extends StatelessWidget {
  const _PosyanduReminder({
    required this.date,
    required this.name,
    required this.area,
    required this.onTap,
  });

  final DateTime date;
  final String name;
  final String area;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final days = dateOnly(date).difference(dateOnly(DateTime.now())).inDays;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      color: AppColors.peachSoft,
      borderColor: AppColors.peachSoft,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: AppColors.coral,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Jadwal posyandu berikutnya',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppColors.coral,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatDateId(date, withYear: false)} • ${days > 0 ? '$days hari lagi' : 'Hari ini'}',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.coral),
        ],
      ),
    );
  }
}

class _ForYouCard extends StatelessWidget {
  const _ForYouCard({
    required this.article,
    required this.onArticle,
    required this.onMenu,
  });

  final ContentArticle? article;
  final VoidCallback onArticle;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final item = article;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          if (item != null)
            InkWell(
              onTap: onArticle,
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    NuriImage(
                      asset:
                          item.imageAsset ?? 'assets/images/article_food.jpg',
                      width: 72,
                      height: 72,
                      radius: 12,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.category,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 14.5,
                              height: 1.25,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.readMinutes} menit baca',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.muted,
                    ),
                  ],
                ),
              ),
            ),
          if (item != null) const Divider(height: 1),
          InkWell(
            onTap: onMenu,
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Row(
                children: [
                  SizedBox(
                    width: 38,
                    height: 38,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.mint,
                        borderRadius: BorderRadius.all(Radius.circular(11)),
                      ),
                      child: Icon(
                        Icons.restaurant_menu_rounded,
                        color: AppColors.primary,
                        size: 19,
                      ),
                    ),
                  ),
                  SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Inspirasi menu hari ini',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Menu tinggi protein hewani yang mudah dibuat.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppColors.muted,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
