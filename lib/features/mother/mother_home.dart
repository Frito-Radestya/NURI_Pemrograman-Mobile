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
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          final ok = await ref.read(appControllerProvider.notifier).syncNow();
          if (context.mounted) {
            showNuriSnack(
              context,
              ok
                  ? 'Data berhasil diperbarui & disinkronkan.'
                  : 'Mode offline: data lokal termutakhir telah dimuat.',
            );
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Curved Organic Header Canvas
              CurvedHeader(
                borderRadius: 36,
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.paddingOf(context).top + 8,
                  20,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const NuriLogo(
                          compact: false,
                          onDark: true,
                          subtitle: 'NURI BUNDA',
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => _showNotifications(
                                context,
                                state,
                                showPregnancy,
                              ),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                  size: 19,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            AppAvatar(
                              name: user.name,
                              size: 38,
                              imageAsset: user.avatarAsset,
                              showBadge: true,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${formatWeekday(today)}, ${formatDateId(today, withYear: false)}',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondaryFixed,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.secondaryFixed,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Posyandu Aktif',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10.5,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${_greeting()}, ${user.name.split(' ').first}! 👋',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (state.nextPosyanduDate != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x25000000),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: AppGradients.secondary,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.calendar_month_rounded,
                                    size: 20,
                                    color: AppColors.primary,
                                  ),
                                  Text(
                                    'JADWAL',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 1.5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.secondaryContainer,
                                      borderRadius: BorderRadius.circular(
                                        AppRadius.pill,
                                      ),
                                    ),
                                    child: const Text(
                                      'Jadwal Terdekat',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.onSecondaryContainer,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    state.posyanduName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                  Text(
                                    '${formatDateId(state.nextPosyanduDate!)} • Penimbangan Balita',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showPosyanduSheet(context, state),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Lihat',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 2),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 13,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasBoth) ...[
                      const SizedBox(height: 12),
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
                    Transform.translate(
                      offset: const Offset(0, -10),
                      child: showPregnancy
                          ? _PregnancyHero(
                              pregnancy: pregnancy,
                              progress: pregnancyProgress!,
                            )
                          : child != null
                              ? _ChildHero(
                                  child: child,
                                  onTap: () => _push(
                                    context,
                                    const GrowthDetailScreen(),
                                  ),
                                )
                              : const _EmptyDataCard(),
                    ),
                    // Quick Action Categories (Foodie style icons)
                    _QuickActions(
                      onDiary: () {
                        if (showPregnancy) {
                          _push(
                            context,
                            DiaryScreen(
                              subjectId: pregnancy.id,
                              subjectLabel: 'Kehamilan',
                            ),
                          );
                        } else if (child != null) {
                          _push(
                            context,
                            DiaryScreen(
                              subjectId: child.id,
                              subjectLabel: child.nickname,
                            ),
                          );
                        }
                      },
                      onCamera: () {
                        if (showPregnancy) {
                          _openCamera(context, pregnancy.id, 'Kehamilan');
                        } else if (child != null) {
                          _openCamera(context, child.id, child.nickname);
                        }
                      },
                      onGrowth: () =>
                          _push(context, const GrowthDetailScreen()),
                      onAnc: () => _push(
                        context,
                        showPregnancy
                            ? const AncScreen()
                            : const GrowthDetailScreen(),
                      ),
                      onConsultation: () =>
                          _push(context, const ConsultationScreen()),
                    ),
                    const SizedBox(height: 16),
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
                const SizedBox(height: 18),
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
        ],
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
          colors: [Color(0xFF145C45), Color(0xFF0E4332)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF145C45).withValues(alpha: 0.22),
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
                background: AppColors.softMint,
                foreground: AppColors.deepForest,
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
                    child: Container(height: 6, color: AppColors.leafGreen),
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
                  color: AppColors.leafGreen,
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

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.onDiary,
    required this.onCamera,
    required this.onGrowth,
    required this.onAnc,
    required this.onConsultation,
  });

  final VoidCallback onDiary;
  final VoidCallback onCamera;
  final VoidCallback onGrowth;
  final VoidCallback onAnc;
  final VoidCallback onConsultation;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Aksi Cepat Bunda',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            GestureDetector(
              onTap: onGrowth,
              child: const Text(
                'Semua Fitur',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _QuickActionItem(
              icon: Icons.restaurant_menu_rounded,
              label: 'Buku Makan',
              onTap: onDiary,
            ),
            _QuickActionItem(
              icon: Icons.document_scanner_rounded,
              label: 'Foto Piring',
              isPrimary: true,
              onTap: onCamera,
            ),
            _QuickActionItem(
              icon: Icons.show_chart_rounded,
              label: 'Grafik WHO',
              onTap: onGrowth,
            ),
            _QuickActionItem(
              icon: Icons.event_available_rounded,
              label: 'Jadwal ANC',
              onTap: onAnc,
            ),
            _QuickActionItem(
              icon: Icons.support_agent_rounded,
              label: 'Tanya Bidan',
              onTap: onConsultation,
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: isPrimary ? AppGradients.button : null,
              color: isPrimary ? null : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18),
              boxShadow: isPrimary ? AppShadows.glow : null,
            ),
            child: Icon(
              icon,
              size: 24,
              color: isPrimary ? Colors.white : AppColors.primary,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isPrimary ? FontWeight.w700 : FontWeight.w600,
              color: isPrimary ? AppColors.primary : AppColors.onSurface,
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
                size: 46,
              ),
              const SizedBox(width: 12),
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
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(
                              AppRadius.pill,
                            ),
                          ),
                          child: Text(
                            child.ageLabel(),
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          status?.label ?? 'Pantau Tumbuh Kembang',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
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
          if (latest != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 9,
                      horizontal: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Berat Badan',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            text: fmt1(latest.weightKg),
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                            children: const [
                              TextSpan(
                                text: ' kg',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryFixed.withValues(
                              alpha: 0.4,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppRadius.pill,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.trending_up_rounded,
                                size: 11,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 2),
                              Text(
                                '+0.3 kg',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 9,
                      horizontal: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Tinggi Badan',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            text: fmt1(latest.measuredCm),
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.onSurface,
                            ),
                            children: const [
                              TextSpan(
                                text: ' cm',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryFixed.withValues(
                              alpha: 0.4,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppRadius.pill,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 11,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 2),
                              Text(
                                'Normal',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 9,
                      horizontal: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Lingkar Kepala',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '47.0 cm',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(
                              AppRadius.pill,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_rounded,
                                size: 11,
                                color: AppColors.onSurfaceVariant,
                              ),
                              SizedBox(width: 2),
                              Text(
                                'Normal',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 12),
            const InfoBanner(
              title: 'Belum ada pengukuran',
              body:
                  'Catat panjang dan berat badan pertama untuk melihat posisi tumbuh Si Kecil.',
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

class _EmptyDataCard extends StatelessWidget {
  const _EmptyDataCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x100D631B),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(6),
            child: Image.asset(
              'assets/images/nuri_logo_mark.png',
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.spa_rounded,
                color: AppColors.primary,
                size: 26,
              ),
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
