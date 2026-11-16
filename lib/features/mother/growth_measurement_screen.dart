import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_controller.dart';
import '../../domain/growth/growth_calculator.dart';
import '../../domain/growth/who_lms.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import 'growth_preview_card.dart';

class MeasurementInputScreen extends ConsumerStatefulWidget {
  const MeasurementInputScreen({
    super.key,
    required this.childId,
    this.isCadre = false,
  });

  final String childId;
  final bool isCadre;

  @override
  ConsumerState<MeasurementInputScreen> createState() =>
      _MeasurementInputScreenState();
}

class _MeasurementInputScreenState
    extends ConsumerState<MeasurementInputScreen> {
  final _weight = TextEditingController();
  final _height = TextEditingController();
  DateTime _date = dateOnly(DateTime.now());
  MeasurementMethod? _method;
  bool _saving = false;

  @override
  void dispose() {
    _weight.dispose();
    _height.dispose();
    super.dispose();
  }

  double? _parse(TextEditingController controller) =>
      double.tryParse(controller.text.trim().replaceAll(',', '.'));

  (GrowthEvaluation?, String?) _evaluate(Child child) {
    final weight = _parse(_weight);
    final height = _parse(_height);
    if (weight == null || height == null) return (null, null);

    if (weight < 1.0 || weight > 40.0) {
      return (
        null,
        'Berat badan ($weight kg) di luar batas wajar balita (1 – 40 kg). Periksa kembali angka atau desimal (contoh: 11.2).',
      );
    }
    if (height < 30.0 || height > 140.0) {
      return (
        null,
        'Panjang/tinggi ($height cm) di luar batas wajar (30 – 140 cm). Periksa kembali angka atau desimal (contoh: 82.5).',
      );
    }

    final method =
        _method ??
        GrowthCalculator.defaultMethodForAge(child.ageMonthsAt(_date));
    try {
      final evaluation = GrowthCalculator(reference: WhoReference.instance)
          .evaluate(
            heightCm: height,
            weightKg: weight,
            sex: child.sex,
            dob: child.dob,
            measureDate: _date,
            method: method,
          );
      return (evaluation, null);
    } on GrowthValidationException catch (error) {
      return (null, error.message);
    }
  }

  Future<void> _save(Child child, GrowthEvaluation? evaluation) async {
    FocusScope.of(context).unfocus();
    final weight = _parse(_weight);
    final height = _parse(_height);
    if (weight == null || height == null) {
      showNuriSnack(
        context,
        'Lengkapi berat dan panjang/tinggi badan.',
        error: true,
      );
      return;
    }
    if (weight < 1.5 || weight > 35.0 || height < 35.0 || height > 130.0) {
      final proceed = await showNuriConfirm(
        context: context,
        title: 'Konfirmasi Nilai Ekstrem',
        message:
            'Nilai berat ${fmt1(weight)} kg atau tinggi ${fmt1(height)} cm berada di luar rentang wajar balita. Yakin angka ini benar dan bukan kesalahan ketik (typo)?',
        confirmLabel: 'Ya, Angka Benar',
        danger: true,
      );
      if (!proceed || !mounted) return;
    }
    if (evaluation != null && evaluation.implausible) {
      final proceed = await showNuriConfirm(
        context: context,
        title: 'Nilai sangat tidak biasa',
        message:
            'Z-score ${evaluation.zScore.toStringAsFixed(1)} SD berada di luar batas wajar. Periksa kembali alat ukur dan tanggal lahir sebelum menyimpan.',
        confirmLabel: 'Simpan tetap',
        danger: true,
      );
      if (!proceed || !mounted) return;
    }
    setState(() => _saving = true);
    final result = ref
        .read(appControllerProvider.notifier)
        .addMeasurement(
          childId: child.id,
          weightKg: weight,
          heightCm: height,
          date: _date,
          method:
              _method ??
              GrowthCalculator.defaultMethodForAge(child.ageMonthsAt(_date)),
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (result == null) {
      showNuriSnack(
        context,
        'Pengukuran gagal disimpan. Coba lagi.',
        error: true,
      );
      return;
    }
    final status = result.category.plainLabel;
    if (!widget.isCadre) {
      showNuriSnack(context, 'Pengukuran tersimpan • $status');
      Navigator.of(context).pop(result);
      return;
    }

    final next = _nextWaitingChild(child.id);
    await showNuriSheet<void>(
      context: context,
      isDismissible: false,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.mint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pengukuran tersimpan',
                        style: Theme.of(sheetContext).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${child.nickname} • $status',
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            InfoBanner(
              title:
                  'Berat ${fmt1(result.weightKg)} kg • Panjang ${fmt1(result.measuredCm)} cm',
              body: 'Sasaran otomatis ditandai hadir pada sesi ini.',
              icon: Icons.straighten_rounded,
            ),
            const SizedBox(height: 14),
            if (next != null) ...[
              NuriButton(
                label: 'Ukur ${next.name} berikutnya',
                icon: Icons.arrow_forward_rounded,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => MeasurementInputScreen(
                        childId: next.subjectId!,
                        isCadre: true,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Selesai'),
                ),
              ),
            ] else
              NuriButton(
                label: 'Kembali ke sesi',
                icon: Icons.check_rounded,
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
          ],
        ),
      ),
    );
  }

  RosterEntry? _nextWaitingChild(String currentChildId) {
    final roster = ref.read(appControllerProvider).roster;
    final candidates =
        roster
            .where(
              (entry) =>
                  entry.type == RosterType.child &&
                  entry.attendance == AttendanceStatus.waiting &&
                  entry.subjectId != null &&
                  entry.subjectId != currentChildId,
            )
            .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    return candidates.isEmpty ? null : candidates.first;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    Child? child;
    for (final item in state.children) {
      if (item.id == widget.childId) {
        child = item;
        break;
      }
    }

    if (child == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              ScreenHeader(
                title: 'Input pengukuran',
                onBack: () => Navigator.of(context).pop(),
              ),
              const Expanded(
                child: EmptyState(
                  title: 'Data anak tidak ditemukan',
                  body: 'Pilih sasaran lain dari daftar.',
                  icon: Icons.person_search_rounded,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final activeChild = child;
    final method =
        _method ??
        GrowthCalculator.defaultMethodForAge(activeChild.ageMonthsAt(_date));
    final (evaluation, error) = _evaluate(activeChild);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CurvedHeader(
            borderRadius: 32,
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.paddingOf(context).top + 8,
              20,
              20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Catat Antropometri',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              widget.isCadre
                                  ? 'Kader • Sesi Posyandu'
                                  : 'Catatan Mandiri Ibu',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.cloud_done_rounded,
                            size: 13,
                            color: AppColors.secondaryFixed,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Offline-Ready',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AppAvatar(
                              name: activeChild.nickname,
                              index: activeChild.avatarIndex,
                              size: 44,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activeChild.nickname,
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    '${activeChild.ageLabel(_date)} • ${activeChild.sex.label}',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (activeChild.latestMeasurement != null)
                              GrowthStatusBadge(
                                category:
                                    activeChild.latestMeasurement!.category,
                                compact: true,
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        NuriDateField(
                          label: 'Tanggal ukur',
                          value: _date,
                          firstDate: activeChild.dob,
                          lastDate: DateTime.now(),
                          onChanged: (value) => setState(() {
                            _date = dateOnly(value);
                            _method = null;
                          }),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: NuriTextField(
                                label: 'Berat badan (kg)',
                                controller: _weight,
                                hint: '11,2',
                                helper: 'Rentang normal: 2 – 30 kg',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: NuriTextField(
                                label: 'Panjang/tinggi (cm)',
                                controller: _height,
                                hint: '82,5',
                                helper: 'Rentang normal: 40 – 125 cm',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const NuriFormLabel(text: 'Cara ukur'),
                        NuriSegmentedControl<MeasurementMethod>(
                          values: MeasurementMethod.values,
                          selected: method,
                          labelFor: (value) => value == MeasurementMethod.lying
                              ? 'Berbaring'
                              : 'Berdiri',
                          onChanged: (value) => setState(() => _method = value),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          activeChild.ageMonthsAt(_date) < 24
                              ? 'Usia < 24 bulan: ukur berbaring (PB). Bila berdiri, NURI menambahkan koreksi +0,7 cm.'
                              : 'Usia ≥ 24 bulan: ukur berdiri (TB). Bila berbaring, NURI mengurangi 0,7 cm.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (error != null)
                    InfoBanner(
                      title: 'Periksa input',
                      body: error,
                      icon: Icons.error_outline_rounded,
                      background: AppColors.redSoft,
                      foreground: AppColors.red,
                    )
                  else if (evaluation != null)
                    GrowthPreviewCard(evaluation: evaluation)
                  else
                    const InfoBanner(
                      title: 'Pratinjau z-score',
                      body: 'Isi berat dan panjang/tinggi badan untuk melihat klasifikasi WHO sebelum menyimpan.',
                      icon: Icons.insights_rounded,
                    ),
                  const SizedBox(height: 14),
                  NuriButton(
                    label: 'Simpan pengukuran',
                    icon: Icons.check_rounded,
                    loading: _saving,
                    onPressed: () => _save(activeChild, evaluation),
                  ),
                  const SizedBox(height: 8),
                  const NuriDisclaimer(compact: true),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
