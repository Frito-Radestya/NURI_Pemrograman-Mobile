import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';

class CheckupFormScreen extends ConsumerStatefulWidget {
  const CheckupFormScreen({super.key});

  @override
  ConsumerState<CheckupFormScreen> createState() => _CheckupFormScreenState();
}

class _CheckupFormScreenState extends ConsumerState<CheckupFormScreen> {
  final _weight = TextEditingController();
  final _lila = TextEditingController();
  final _hb = TextEditingController();
  final _systolic = TextEditingController();
  final _diastolic = TextEditingController();
  DateTime _date = dateOnly(DateTime.now());

  @override
  void dispose() {
    _weight.dispose();
    _lila.dispose();
    _hb.dispose();
    _systolic.dispose();
    _diastolic.dispose();
    super.dispose();
  }

  double? _value(TextEditingController controller) =>
      double.tryParse(controller.text.trim().replaceAll(',', '.'));

  void _save() {
    final weight = _value(_weight);
    final lila = _value(_lila);
    if (weight == null || weight <= 0 || lila == null || lila <= 0) {
      showNuriSnack(
        context,
        'Berat dan LiLA wajib diisi dengan benar.',
        error: true,
      );
      return;
    }
    final hb = _value(_hb);
    final systolic = int.tryParse(_systolic.text.trim());
    final diastolic = int.tryParse(_diastolic.text.trim());
    ref
        .read(appControllerProvider.notifier)
        .addCheckup(
          weightKg: weight,
          lilaCm: lila,
          hbGdl: hb,
          systolic: systolic,
          diastolic: diastolic,
          date: _date,
        );
    Navigator.of(context).pop();
    showNuriSnack(context, 'Pemeriksaan tersimpan.');
  }

  @override
  Widget build(BuildContext context) {
    final hb = _value(_hb);
    final lila = _value(_lila);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Catat pemeriksaan',
              subtitle: 'Hasil dari bidan atau puskesmas',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          NuriDateField(
                            label: 'Tanggal pemeriksaan',
                            value: _date,
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 300),
                            ),
                            lastDate: DateTime.now(),
                            onChanged: (value) =>
                                setState(() => _date = dateOnly(value)),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: NuriTextField(
                                  label: 'Berat badan (kg)',
                                  controller: _weight,
                                  hint: '58,5',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: NuriTextField(
                                  label: 'LiLA (cm)',
                                  controller: _lila,
                                  hint: '24,5',
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
                          NuriTextField(
                            label: 'Hemoglobin / Hb (g/dL, opsional)',
                            controller: _hb,
                            hint: '11,8',
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: NuriTextField(
                                  label: 'Tekanan sistolik',
                                  controller: _systolic,
                                  hint: '115',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: NuriTextField(
                                  label: 'Tekanan diastolik',
                                  controller: _diastolic,
                                  hint: '75',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (lila != null && lila < 23.5) ...[
                      const SizedBox(height: 10),
                      const InfoBanner(
                        title: 'LiLA di bawah 23,5 cm',
                        body: 'Indikasi risiko kekurangan energi kronis (KEK). Perlu konsultasi dan tindak lanjut tenaga kesehatan.',
                        icon: Icons.warning_amber_rounded,
                        background: AppColors.amberSoft,
                        foreground: AppColors.amber,
                      ),
                    ],
                    if (hb != null && hb < 11) ...[
                      const SizedBox(height: 10),
                      const InfoBanner(
                        title: 'Hb di bawah 11 g/dL',
                        body: 'Indikasi anemia pada kehamilan. Diskusikan suplementasi dan pola makan dengan bidan atau dokter.',
                        icon: Icons.warning_amber_rounded,
                        background: AppColors.redSoft,
                        foreground: AppColors.red,
                      ),
                    ],
                    const SizedBox(height: 14),
                    const InfoBanner(
                      title: 'Catatan',
                      body: 'NURI hanya menyimpan hasil yang Ibu masukkan. Pemeriksaan tetap dilakukan oleh tenaga kesehatan.',
                      icon: Icons.verified_user_outlined,
                    ),
                    const SizedBox(height: 14),
                    NuriButton(
                      label: 'Simpan pemeriksaan',
                      icon: Icons.check_rounded,
                      onPressed: _save,
                    ),
                    const NuriDisclaimer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
