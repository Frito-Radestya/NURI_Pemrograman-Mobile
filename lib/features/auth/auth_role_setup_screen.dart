import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../domain/pregnancy/pregnancy_calculator.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';

class RoleSetupScreen extends ConsumerStatefulWidget {
  const RoleSetupScreen({super.key, required this.role});

  final UserRole role;

  @override
  ConsumerState<RoleSetupScreen> createState() => _RoleSetupScreenState();
}

class _RoleSetupScreenState extends ConsumerState<RoleSetupScreen> {
  bool _pregnant = true;
  bool _hasChild = false;
  DateTime? _hpht = DateTime.now().subtract(const Duration(days: 70));
  final _childName = TextEditingController();
  DateTime? _childDob;
  Sex _childSex = Sex.male;
  final _birthWeight = TextEditingController();
  final _birthLength = TextEditingController();
  late final TextEditingController _posyanduName;
  late final TextEditingController _posyanduArea;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _posyanduName = TextEditingController(
      text: ref.read(appControllerProvider).posyanduName,
    );
    _posyanduArea = TextEditingController(
      text: ref.read(appControllerProvider).posyanduArea,
    );
  }

  @override
  void dispose() {
    _childName.dispose();
    _birthWeight.dispose();
    _birthLength.dispose();
    _posyanduName.dispose();
    _posyanduArea.dispose();
    super.dispose();
  }

  Future<void> _finishMother() async {
    FocusScope.of(context).unfocus();
    if (!_pregnant && !_hasChild) {
      showNuriSnack(
        context,
        'Pilih minimal satu: kehamilan atau data anak.',
        error: true,
      );
      return;
    }
    if (_pregnant && _hpht == null) {
      showNuriSnack(context, 'Tanggal HPHT belum dipilih.', error: true);
      return;
    }
    if (_hasChild && _childName.text.trim().length < 2) {
      showNuriSnack(
        context,
        'Nama panggilan anak minimal 2 karakter.',
        error: true,
      );
      return;
    }
    if (_hasChild && _childDob == null) {
      showNuriSnack(context, 'Tanggal lahir anak belum dipilih.', error: true);
      return;
    }
    setState(() => _saving = true);
    final controller = ref.read(appControllerProvider.notifier);
    if (_pregnant && ref.read(appControllerProvider).activePregnancy == null) {
      controller.addPregnancy(hpht: _hpht!);
    }
    if (_hasChild) {
      final error = controller.addChild(
        nickname: _childName.text,
        dob: _childDob!,
        sex: _childSex,
        birthWeightKg: double.tryParse(_birthWeight.text.replaceAll(',', '.')),
        birthLengthCm: double.tryParse(_birthLength.text.replaceAll(',', '.')),
      );
      if (error != null) {
        if (!mounted) return;
        setState(() => _saving = false);
        showNuriSnack(context, error, error: true);
        return;
      }
    }
    controller.completeOnboarding();
  }

  void _finishCadre() {
    if (_posyanduName.text.trim().length < 3) {
      showNuriSnack(context, 'Nama posyandu minimal 3 karakter.', error: true);
      return;
    }
    final controller = ref.read(appControllerProvider.notifier);
    controller.setPosyandu(name: _posyanduName.text, area: _posyanduArea.text);
    controller.completeOnboarding();
  }

  void _skip() {
    ref.read(appControllerProvider.notifier).completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final isCadre = widget.role == UserRole.cadre;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NuriStepHeader(
                      step: 2,
                      total: 2,
                      title: isCadre
                          ? 'Kenali Posyandu Anda'
                          : 'Kenali Ibu & Si Kecil',
                      subtitle: isCadre
                          ? 'Data ini membantu NURI menampilkan sesi dan sasaran yang tepat.'
                          : 'Pilih apa yang ingin Ibu pantau. Bisa diubah nanti.',
                      onClose: () =>
                          ref.read(appControllerProvider.notifier).logout(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: isCadre ? _buildCadre() : _buildMother(),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                children: [
                  NuriButton(
                    label: isCadre ? 'Mulai kelola sesi' : 'Simpan & mulai',
                    icon: Icons.check_rounded,
                    loading: _saving,
                    onPressed: isCadre ? _finishCadre : _finishMother,
                  ),
                  TextButton(
                    onPressed: _skip,
                    child: const Text('Lewati untuk sekarang'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMother() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SetupToggleCard(
          selected: _pregnant,
          icon: Icons.pregnant_woman_rounded,
          title: 'Saya sedang hamil',
          subtitle: 'Pantau usia kehamilan, TTD, ANC, dan pemeriksaan',
          onTap: () => setState(() => _pregnant = !_pregnant),
        ),
        if (_pregnant) ...[
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                NuriDateField(
                  label: 'Hari pertama haid terakhir (HPHT)',
                  value: _hpht,
                  firstDate: DateTime.now().subtract(const Duration(days: 280)),
                  lastDate: DateTime.now(),
                  helper: _hpht == null
                      ? 'HPHT dipakai untuk menghitung usia kehamilan dan perkiraan lahir.'
                      : 'Perkiraan lahir: ${formatDateId(PregnancyCalculator.hplFromHpht(_hpht!))}',
                  onChanged: (value) => setState(() => _hpht = value),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => setState(
                      () => _hpht = DateTime.now().subtract(
                        const Duration(days: 84),
                      ),
                    ),
                    icon: const Icon(Icons.help_outline_rounded, size: 16),
                    label: const Text(
                      'Tidak tahu HPHT? Pakai perkiraan 12 minggu',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 10),
        _SetupToggleCard(
          selected: _hasChild,
          icon: Icons.child_care_rounded,
          title: 'Saya memiliki anak balita',
          subtitle: 'Catat pengukuran dan gizi harian anak 0–59 bulan',
          onTap: () => setState(() => _hasChild = !_hasChild),
        ),
        if (_hasChild) ...[
          const SizedBox(height: 10),
          AppCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                NuriTextField(
                  label: 'Nama panggilan anak',
                  controller: _childName,
                  hint: 'Contoh: Rafi',
                  prefixIcon: Icons.face_rounded,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 12),
                NuriDateField(
                  label: 'Tanggal lahir',
                  value: _childDob,
                  firstDate: DateTime.now().subtract(
                    const Duration(days: 1856),
                  ),
                  lastDate: DateTime.now(),
                  onChanged: (value) => setState(() => _childDob = value),
                ),
                const SizedBox(height: 12),
                const NuriFormLabel(text: 'Jenis kelamin'),
                NuriSegmentedControl<Sex>(
                  values: const [Sex.male, Sex.female],
                  selected: _childSex,
                  labelFor: (value) => value.label,
                  onChanged: (value) => setState(() => _childSex = value),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: NuriTextField(
                        label: 'BB lahir (kg, opsional)',
                        controller: _birthWeight,
                        hint: '3,1',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: NuriTextField(
                        label: 'PB lahir (cm, opsional)',
                        controller: _birthLength,
                        hint: '49',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        const NuriDisclaimer(),
      ],
    );
  }

  Widget _buildCadre() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              NuriTextField(
                label: 'Nama posyandu',
                controller: _posyanduName,
                hint: 'Contoh: Posyandu Mawar',
                prefixIcon: Icons.home_work_outlined,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 14),
              NuriTextField(
                label: 'Wilayah / kelurahan',
                controller: _posyanduArea,
                hint: 'Contoh: Desa / Kelurahan',
                prefixIcon: Icons.location_on_outlined,
                textCapitalization: TextCapitalization.words,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const InfoBanner(
          title: 'Mode offline siap',
          body: 'Kader dapat mencatat pengukuran tanpa sinyal dan menyinkronkan saat jaringan tersedia.',
          icon: Icons.cloud_off_rounded,
        ),
        const NuriDisclaimer(),
      ],
    );
  }
}

class _SetupToggleCard extends StatelessWidget {
  const _SetupToggleCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.softMint : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(
            color: selected ? AppColors.deepForest : AppColors.line,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.deepForest
                    : AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 21,
                color: selected ? Colors.white : AppColors.muted,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? AppColors.deepForest : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: selected ? AppColors.deepForest : AppColors.line,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 15,
                      color: Colors.white,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
