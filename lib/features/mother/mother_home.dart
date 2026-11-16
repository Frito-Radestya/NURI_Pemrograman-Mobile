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
import 'widgets/mother_for_you_card.dart';
import 'widgets/mother_hero_cards.dart';
import 'widgets/mother_nutrition_card.dart';
import 'widgets/mother_quick_actions.dart';
import 'widgets/mother_today_card.dart';

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
                          ? MotherPregnancyHero(
                              pregnancy: pregnancy,
                              progress: pregnancyProgress!,
                            )
                          : child != null
                          ? MotherChildHero(
                              child: child,
                              onTap: () =>
                                  _push(context, const GrowthDetailScreen()),
                            )
                          : const MotherEmptyDataCard(),
                    ),
                    // Quick Action Categories (Foodie style icons)
                    MotherQuickActions(
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
                      MotherPregnancyTodayCard(
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
                      MotherNutritionCard(
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
                      MotherNutritionCard(
                        title:
                            'Gizi ${child.nickname.split(' ').first} hari ini',
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
                        onLog: () =>
                            _openCamera(context, child.id, child.nickname),
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
                    MotherForYouCard(
                      article: _articleFor(state.contents, showPregnancy),
                      onArticle: () {
                        final article = _articleFor(
                          state.contents,
                          showPregnancy,
                        );
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
