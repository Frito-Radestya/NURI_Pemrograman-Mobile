import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/demo.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/chips.dart';
import '../../core/widgets/nuri_button.dart';
import '../../core/widgets/nuri_card.dart';
import '../../core/widgets/nuri_photo.dart';
import '../../core/widgets/nuri_top_bar.dart';
import '../../core/widgets/nuri_scaffold.dart';
import '../../core/widgets/nutrient.dart';
import '../../core/widgets/section.dart';
import '../../core/widgets/tiles.dart';
import '../../domain/models/child.dart';
import '../../domain/models/food_item.dart';
import '../../domain/models/food_log.dart';
import '../../domain/models/nutrient.dart';
import '../../state/app_state.dart';

/// Tinjauan foto piring: pilih kandidat makanan & porsi sebelum dianalisis.
class MealReviewScreen extends StatefulWidget {
  const MealReviewScreen({super.key});

  @override
  State<MealReviewScreen> createState() => _MealReviewScreenState();
}

class _MealReviewScreenState extends State<MealReviewScreen> {
  String? _selectedFoodId;
  FoodPortion? _selectedPortion;

  void _selectCandidate(FoodCandidate candidate) {
    setState(() {
      _selectedFoodId = candidate.food.id;
      _selectedPortion = candidate.food.defaultPortion;
    });
  }

  void _submit(NuriAppState state, FoodCandidate candidate, FoodPortion portion) {
    final Child? child = state.selectedChild;
    if (child == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih data anak terlebih dahulu sebelum mencatat.'),
        ),
      );
      context.go('/child-data');
      return;
    }
    state.addFoodItem(
      child: child,
      date: state.today,
      meal: MealType.siang,
      food: candidate.food,
      portion: portion,
      source: FoodSource.scan,
      confidence: candidate.confidence,
    );
    context.go('/meal-result');
  }

  @override
  Widget build(BuildContext context) {
    final NuriAppState state = NuriScope.of(context);
    final Child? child = state.selectedChild;
    final List<FoodCandidate> candidates = state.mockScan();

    FoodCandidate? selected;
    if (candidates.isNotEmpty) {
      selected = candidates.firstWhere(
        (FoodCandidate c) => c.food.id == _selectedFoodId,
        orElse: () => candidates.firstWhere(
          (FoodCandidate c) => c.isConfident,
          orElse: () => candidates.first,
        ),
      );
    }

    FoodPortion? portion;
    if (selected != null) {
      portion = _selectedPortion;
      if (portion == null || !selected.food.portions.contains(portion)) {
        portion = selected.food.defaultPortion;
      }
    }

    return NuriScaffold(
      background: AppColors.canvas,
      topBar: NuriTopBar(
        leading: TextButton(
          onPressed: () => context.go('/camera-plate'),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            minimumSize: const Size(0, 40),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Batal',
            style: AppText.bodyStrong.copyWith(
              color: AppColors.inkSoft,
              fontSize: 14,
            ),
          ),
        ),
        titleWidget: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '😊 Piring Makan ${child?.nickname ?? 'Si Kecil'} • '
            '${MealType.siang.label}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.bodySm.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ),
        actions: const [
          NuriAvatar(initials: 'B', background: AppColors.brand),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 4),
            const Center(
              child: StatusChip(
                text: '✓ Foto Siap Dianalisis',
                color: AppColors.pastelGreen,
                onColor: AppColors.brandText,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Piring Makan ${child?.nickname ?? 'Si Kecil'}',
              textAlign: TextAlign.center,
              style: AppText.h2,
            ),
            const SizedBox(height: 4),
            Text(
              child == null
                  ? 'Belum ada data anak'
                  : '${child.ageLabelAt(state.today)} • '
                        'Jadwal Makan ${MealType.siang.label}',
              textAlign: TextAlign.center,
              style: AppText.caption,
            ),
            const SizedBox(height: 16),
            NuriPhoto(
              url: DemoImages.plateMeal,
              height: 300,
              overlay: Stack(
                children: [
                  const Positioned(
                    left: 14,
                    top: 14,
                    child: PhotoTag(
                      label: 'Pencahayaan Jelas',
                      icon: Icons.wb_sunny_outlined,
                    ),
                  ),
                  Positioned(
                    right: 14,
                    top: 14,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.94),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.crop_free_rounded,
                        size: 20,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  if (selected != null && portion != null)
                    Positioned(
                      left: 14,
                      bottom: 14,
                      child: _DarkPill(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              selected.food.emoji,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${selected.food.name} • '
                              '${portion.grams.toStringAsFixed(0)} g',
                              style: AppText.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            NuriCard(
              color: AppColors.surfaceSoft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      IconBadge(
                        icon: Icons.auto_awesome,
                        color: AppColors.pastelGreen,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('NURI SMART VISION', style: AppText.label),
                            SizedBox(height: 2),
                            Text('Presisi AI Stunting', style: AppText.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    candidates.isEmpty
                        ? 'Katalog makanan belum tersedia. Coba lagi nanti.'
                        : 'AI mendeteksi ${candidates.length} kemungkinan '
                              'makanan pada piring. Periksa kebenarannya, '
                              'lalu pilih porsi yang paling sesuai.',
                    style: AppText.body.copyWith(fontSize: 13.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ---- Kandidat makanan -------------------------------------------
            const SectionHeader(
              title: 'Kandidat Makanan Terdeteksi',
              subtitle: 'Ketuk untuk memilih makanan yang paling sesuai',
            ),
            const SizedBox(height: 12),
            if (candidates.isEmpty)
              NuriCard(
                color: AppColors.surfaceSoft,
                child: NoteRow(
                  icon: Icons.search_off_rounded,
                  text: 'Tidak ada kandidat makanan yang terdeteksi.',
                ),
              )
            else
              for (int i = 0; i < candidates.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _CandidateCard(
                  candidate: candidates[i],
                  selected: candidates[i].food.id == selected?.food.id,
                  onTap: () => _selectCandidate(candidates[i]),
                ),
              ],

            if (selected != null && portion != null) ...[
              const SizedBox(height: 20),
              const SectionHeader(
                title: 'Pilih Porsi',
                subtitle: 'Sesuaikan takaran dengan piring Si Kecil',
              ),
              const SizedBox(height: 12),
              NuriCard(
                color: AppColors.surfaceSoft,
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final FoodPortion p in selected.food.portions)
                          _PortionChip(
                            portion: p,
                            selected: p == portion,
                            onTap: () =>
                                setState(() => _selectedPortion = p),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _NutritionPreview(
                      food: selected.food,
                      grams: portion.grams,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            NuriPrimaryButton(
              label: 'Analisis Piring Makan',
              icon: Icons.psychology_outlined,
              trailingArrow: true,
              onPressed: selected == null || portion == null
                  ? null
                  : () => _submit(state, selected!, portion!),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: NuriSecondaryButton(
                    label: 'Foto Ulang',
                    icon: Icons.camera_alt_outlined,
                    filled: true,
                    onPressed: () => context.go('/camera-plate'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NuriSecondaryButton(
                    label: 'Riwayat Makan',
                    icon: Icons.menu_book_outlined,
                    filled: true,
                    onPressed: () => context.go('/meal-history'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const NoteRow(
              icon: Icons.verified_user_outlined,
              text:
                  'Data asupan tervalidasi standar pedoman gizi Kemenkes RI',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({
    required this.candidate,
    required this.selected,
    required this.onTap,
  });

  final FoodCandidate candidate;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final int percent = (candidate.confidence * 100).round();
    final Color confidenceColor = candidate.isConfident
        ? AppColors.brand
        : AppColors.accent;
    return NuriCard(
      color: selected ? AppColors.canvasGreen : AppColors.surface,
      border: selected ? AppColors.brand : AppColors.line,
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              candidate.food.emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        candidate.food.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.title.copyWith(fontSize: 14.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$percent%',
                      style: AppText.bodyStrong.copyWith(
                        color: confidenceColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  candidate.food.group,
                  style: AppText.caption,
                ),
                const SizedBox(height: 8),
                NutrientBar(
                  value: candidate.confidence,
                  color: confidenceColor,
                  height: 6,
                ),
                const SizedBox(height: 6),
                Text(
                  candidate.isConfident
                      ? 'Keyakinan tinggi'
                      : 'Perlu konfirmasi Bunda',
                  style: AppText.caption.copyWith(
                    color: confidenceColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: selected ? AppColors.brand : AppColors.surfaceSoft,
              shape: BoxShape.circle,
            ),
            child: selected
                ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                : null,
          ),
        ],
      ),
    );
  }
}

class _PortionChip extends StatelessWidget {
  const _PortionChip({
    required this.portion,
    required this.selected,
    required this.onTap,
  });

  final FoodPortion portion;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.brand : AppColors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.brand : AppColors.line,
            ),
          ),
          child: Text(
            '${portion.label} • ${portion.grams.toStringAsFixed(0)} g',
            style: AppText.bodySm.copyWith(
              color: selected ? Colors.white : AppColors.ink,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _NutritionPreview extends StatelessWidget {
  const _NutritionPreview({required this.food, required this.grams});

  final TkpiFood food;
  final double grams;

  @override
  Widget build(BuildContext context) {
    if (!food.hasNutritionData) {
      return const NoteRow(
        icon: Icons.info_outline_rounded,
        text: 'Nilai gizi untuk makanan ini belum tersedia di TKPI.',
      );
    }
    final Map<Nutrient, double> values = food.nutrientsFor(grams);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: MetricBox(
            label: Nutrient.energy.label,
            value: (values[Nutrient.energy] ?? 0).toStringAsFixed(1),
            unit: Nutrient.energy.unit,
            icon: Icons.local_fire_department_outlined,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: MetricBox(
            label: Nutrient.protein.label,
            value: (values[Nutrient.protein] ?? 0).toStringAsFixed(1),
            unit: Nutrient.protein.unit,
            icon: Icons.fitness_center_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: MetricBox(
            label: Nutrient.iron.label,
            value: (values[Nutrient.iron] ?? 0).toStringAsFixed(1),
            unit: Nutrient.iron.unit,
            icon: Icons.water_drop_outlined,
          ),
        ),
      ],
    );
  }
}

class _DarkPill extends StatelessWidget {
  const _DarkPill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: child,
    );
  }
}
