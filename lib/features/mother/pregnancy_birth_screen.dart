import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';

class GiveBirthScreen extends ConsumerStatefulWidget {
  const GiveBirthScreen({super.key});

  @override
  ConsumerState<GiveBirthScreen> createState() => _GiveBirthScreenState();
}

class _GiveBirthScreenState extends ConsumerState<GiveBirthScreen> {
  final _name = TextEditingController();
  DateTime _dob = dateOnly(DateTime.now());
  Sex _sex = Sex.male;
  final _weight = TextEditingController();
  final _length = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _weight.dispose();
    _length.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().length < 2) {
      showNuriSnack(
        context,
        'Nama panggilan bayi minimal 2 karakter.',
        error: true,
      );
      return;
    }
    final child = ref
        .read(appControllerProvider.notifier)
        .giveBirth(
          dob: _dob,
          sex: _sex,
          nickname: _name.text,
          birthWeightKg: double.tryParse(_weight.text.replaceAll(',', '.')),
          birthLengthCm: double.tryParse(_length.text.replaceAll(',', '.')),
        );
    if (child == null) {
      showNuriSnack(
        context,
        'Data kehamilan aktif tidak ditemukan.',
        error: true,
      );
      return;
    }
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selamat, Ibu!'),
        content: Text(
          '${child.nickname} sudah lahir. Data kehamilan disimpan sebagai riwayat dan Ibu dapat mulai mencatat tumbuh kembang Si Kecil.',
          style: const TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Mulai pantau'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final pregnancy = state.activePregnancy;
    if (pregnancy == null) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              ScreenHeader(
                title: 'Catat kelahiran',
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Catat kelahiran',
              subtitle: 'Satu langkah lagi untuk memulai 1000 HPK',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const InfoBanner(
                      title: 'Selamat atas kelahiran Si Kecil',
                      body: 'Setelah disimpan, data kehamilan menjadi riwayat dan fokus berpindah ke tumbuh kembang bayi.',
                      icon: Icons.celebration_outlined,
                      background: AppColors.peachSoft,
                      foreground: AppColors.coral,
                    ),
                    const SizedBox(height: 12),
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          NuriTextField(
                            label: 'Nama panggilan bayi',
                            controller: _name,
                            hint: 'Contoh: Rafi',
                            prefixIcon: Icons.child_care_rounded,
                            textCapitalization: TextCapitalization.words,
                          ),
                          const SizedBox(height: 12),
                          NuriDateField(
                            label: 'Tanggal lahir',
                            value: _dob,
                            firstDate: pregnancy.hpht,
                            lastDate: DateTime.now(),
                            onChanged: (value) =>
                                setState(() => _dob = dateOnly(value)),
                          ),
                          const SizedBox(height: 12),
                          const NuriFormLabel(text: 'Jenis kelamin'),
                          NuriSegmentedControl<Sex>(
                            values: const [Sex.male, Sex.female],
                            selected: _sex,
                            labelFor: (value) => value.label,
                            onChanged: (value) => setState(() => _sex = value),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: NuriTextField(
                                  label: 'BB lahir (kg, opsional)',
                                  controller: _weight,
                                  hint: '3,1',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: NuriTextField(
                                  label: 'PB lahir (cm, opsional)',
                                  controller: _length,
                                  hint: '49',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const InfoBanner(
                      title: 'ASI eksklusif 6 bulan',
                      body: 'Mulai menyusui sesegera mungkin, lakukan IMD bila memungkinkan, dan lanjutkan ASI sampai 2 tahun.',
                      icon: Icons.water_drop_outlined,
                    ),
                    const SizedBox(height: 14),
                    NuriButton(
                      label: 'Simpan kelahiran',
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
