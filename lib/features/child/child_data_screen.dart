import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/demo.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/chips.dart';
import '../../core/widgets/nuri_button.dart';
import '../../core/widgets/nuri_card.dart';
import '../../core/widgets/nuri_logo.dart';
import '../../core/widgets/nuri_scaffold.dart';
import '../../core/widgets/nuri_top_bar.dart';
import '../../core/widgets/section.dart';
import '../../core/widgets/step_dots.dart';
import '../../core/widgets/tiles.dart';
import '../../domain/engines/age_calculator.dart';
import '../../domain/models/sex.dart';
import '../../state/app_state.dart';

/// Langkah 1 dari 2: pengisian profil si kecil.
class ChildDataScreen extends StatefulWidget {
  const ChildDataScreen({super.key});

  @override
  State<ChildDataScreen> createState() => _ChildDataScreenState();
}

class _ChildDataScreenState extends State<ChildDataScreen> {
  final TextEditingController _nameController =
      TextEditingController(text: 'Muhammad Al-Fatih');
  final TextEditingController _nicknameController =
      TextEditingController(text: 'Fatih');
  bool _isMale = true;

  /// Contoh tanggal lahir yang menghasilkan umur sekitar 18 bulan.
  DateTime _birthDate = DateTime.now().subtract(const Duration(days: 550));

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      helpText: 'Pilih tanggal lahir si kecil',
      cancelText: 'Batal',
      confirmText: 'Simpan',
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  /// Menyimpan profil anak ke state lalu lanjut ke pengukuran.
  void _continue() {
    final NuriAppState state = NuriScope.read(context);
    final String nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama panggilan si kecil wajib diisi.')),
      );
      return;
    }
    try {
      final child = state.addChild(
        nickname: nickname,
        birthDate: _birthDate,
        sex: _isMale ? Sex.lakiLaki : Sex.perempuan,
        posyanduName: 'Posyandu Melati',
      );
      state.selectChild(child.id);
      context.go('/child-measure');
    } on FormatException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/register');
    }
  }

  @override
  Widget build(BuildContext context) {
    final NuriAppState state = NuriScope.of(context);
    final int ageMonths = AgeCalculator.inMonths(_birthDate, state.today);
    return NuriScaffold(
      topBar: NuriTopBar(
        showBack: true,
        onBack: _back,
        titleWidget: const NuriBrand(markSize: 28),
        actions: [
          NuriAvatar(imageUrl: DemoImages.avatarMother),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Flexible(
                  child: PillLabel(text: 'Langkah 1 dari 2 • Profil Si Kecil'),
                ),
                const Spacer(),
                Text('50% Selesai', style: AppText.caption),
              ],
            ),
            const SizedBox(height: 10),
            const StepProgress(value: 0.5),
            const SizedBox(height: 20),

            // Kartu sambutan.
            NuriCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const IconBadge(icon: Icons.eco_rounded),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Kenalkan Si Kecil pada NURI',
                            style: AppText.h3),
                        const SizedBox(height: 6),
                        Text(
                          'Data ini membantu NURI menyesuaikan panduan gizi '
                          'harian dan kurva tumbuh kembang baku WHO yang paling '
                          'presisi untuk buah hati tercinta.',
                          style: AppText.body.copyWith(fontSize: 13.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Kartu nama.
            NuriCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('NAMA LENGKAP SI KECIL', style: AppText.label),
                      const Spacer(),
                      Text(
                        '*Wajib',
                        style: AppText.caption.copyWith(
                          color: AppColors.statusSangatPendek,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _InputField(
                    controller: _nameController,
                    hint: 'Nama lengkap',
                    suffixIcon: Icons.check_circle_rounded,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'NAMA PANGGILAN SAYANG',
                          style: AppText.label,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Sapaan Personal', style: AppText.caption),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _InputField(
                    controller: _nicknameController,
                    hint: 'Nama panggilan',
                    suffixIcon: Icons.favorite_border_rounded,
                  ),
                  const SizedBox(height: 14),
                  const NoteRow(
                    icon: Icons.schedule,
                    text:
                        'Digunakan untuk menyapa di rekomendasi menu MP-ASI '
                        'harian Bunda.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Kartu jenis kelamin.
            NuriCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('JENIS KELAMIN', style: AppText.label),
                      const Spacer(),
                      Text(
                        '*Wajib',
                        style: AppText.caption.copyWith(
                          color: AppColors.statusSangatPendek,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Standar deviasi grafik WHO berbeda secara biologis untuk '
                    'anak laki-laki dan perempuan.',
                    style: AppText.bodySm,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      SegmentedChoice(
                        label: 'Laki-laki',
                        caption: 'Putra',
                        icon: Icons.male_rounded,
                        selected: _isMale,
                        onTap: () => setState(() => _isMale = true),
                      ),
                      const SizedBox(width: 12),
                      SegmentedChoice(
                        label: 'Perempuan',
                        caption: 'Putri',
                        icon: Icons.female_rounded,
                        selected: !_isMale,
                        onTap: () => setState(() => _isMale = false),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Kartu tanggal lahir.
            NuriCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('TANGGAL LAHIR', style: AppText.label),
                      const Spacer(),
                      Text(
                        '*Wajib',
                        style: AppText.caption.copyWith(
                          color: AppColors.statusSangatPendek,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Menghitung milestone motorik dan kalender imunisasi '
                    'posyandu.',
                    style: AppText.bodySm,
                  ),
                  const SizedBox(height: 14),
                  _DateField(value: _birthDate, onTap: _pickBirthDate),
                  const SizedBox(height: 14),
                  NoteBox(
                    background: AppColors.pastelGreenSoft,
                    icon: Icons.auto_awesome,
                    child: RichText(
                      text: TextSpan(
                        style: AppText.bodySm,
                        children: [
                          const TextSpan(text: 'Usia Saat Ini: '),
                          TextSpan(
                            text: AgeCalculator.label(ageMonths),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const TextSpan(
                            text:
                                '  ·  Fase MP-ASI Tekstur Padat & Eksplorasi '
                                'Motorik',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  NoteBox(
                    background: AppColors.surfaceSand,
                    icon: Icons.shield_outlined,
                    child: RichText(
                      text: const TextSpan(
                        style: AppText.bodySm,
                        children: [
                          TextSpan(
                            text: 'PRIVASI REKAM TUMBUH KEMBANG',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                              letterSpacing: 0.3,
                            ),
                          ),
                          TextSpan(
                            text:
                                '\nTanggal lahir dan jenis kelamin semata-mata '
                                'digunakan sebagai acuan parameter baku WHO '
                                'MGRS. Tidak dibagikan ke pihak ketiga.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            NuriPrimaryButton(
              label: 'Lanjutkan ke Pengukuran',
              trailingArrow: true,
              onPressed: _continue,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_downward_rounded,
                    size: 14, color: AppColors.inkFaint),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Langkah berikutnya: Input berat & panjang badan perdana',
                    style: AppText.caption,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    this.hint,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String? hint;
  final IconData? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.line),
      ),
      child: TextField(
        controller: controller,
        style: AppText.bodyStrong,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: AppText.body.copyWith(color: AppColors.inkFaint),
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          suffixIcon: suffixIcon == null
              ? null
              : Icon(suffixIcon, size: 20, color: AppColors.brand),
        ),
      ),
    );
  }
}

const List<String> _monthNames = <String>[
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

String _formatDate(DateTime date) =>
    '${date.day} ${_monthNames[date.month - 1]} ${date.year}';

class _DateField extends StatelessWidget {
  const _DateField({required this.value, required this.onTap});

  final DateTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceSoft,
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(_formatDate(value), style: AppText.bodyStrong),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.calendar_today_rounded,
                size: 20,
                color: AppColors.brand,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
