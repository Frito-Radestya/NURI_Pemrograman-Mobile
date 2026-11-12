import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';

class AddTargetScreen extends ConsumerStatefulWidget {
  const AddTargetScreen({super.key});

  @override
  ConsumerState<AddTargetScreen> createState() => _AddTargetScreenState();
}

class _AddTargetScreenState extends ConsumerState<AddTargetScreen> {
  final _name = TextEditingController();
  final _guardian = TextEditingController();
  final _birthWeight = TextEditingController();
  final _birthLength = TextEditingController();
  final _weeks = TextEditingController(text: '20');
  final _lila = TextEditingController();
  final _hb = TextEditingController();

  RosterType _type = RosterType.child;
  Sex _sex = Sex.male;
  DateTime? _dob;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _guardian.dispose();
    _birthWeight.dispose();
    _birthLength.dispose();
    _weeks.dispose();
    _lila.dispose();
    _hb.dispose();
    super.dispose();
  }

  double? _parse(TextEditingController controller) =>
      double.tryParse(controller.text.trim().replaceAll(',', '.'));

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (_name.text.trim().length < 2) {
      showNuriSnack(context, 'Nama sasaran minimal 2 karakter.', error: true);
      return;
    }
    if (_type == RosterType.child && _dob == null) {
      showNuriSnack(context, 'Tanggal lahir anak wajib diisi.', error: true);
      return;
    }
    final weeks = int.tryParse(_weeks.text.trim());
    if (_type == RosterType.pregnant &&
        (weeks == null || weeks < 1 || weeks > 42)) {
      showNuriSnack(context, 'Usia kehamilan harus 1–42 minggu.', error: true);
      return;
    }
    final lila = _parse(_lila);
    if (_type == RosterType.pregnant &&
        lila != null &&
        (lila < 10 || lila > 40)) {
      showNuriSnack(context, 'LiLA harus di antara 10–40 cm.', error: true);
      return;
    }
    final hb = _parse(_hb);
    if (_type == RosterType.pregnant && hb != null && (hb < 5 || hb > 20)) {
      showNuriSnack(context, 'Hb harus di antara 5–20 g/dL.', error: true);
      return;
    }
    final birthWeight = _type == RosterType.child ? _parse(_birthWeight) : null;
    if (birthWeight != null && (birthWeight < 0.5 || birthWeight > 6)) {
      showNuriSnack(context, 'BB lahir harus di antara 0,5–6 kg.', error: true);
      return;
    }
    final birthLength = _type == RosterType.child ? _parse(_birthLength) : null;
    if (birthLength != null && (birthLength < 20 || birthLength > 70)) {
      showNuriSnack(context, 'PB lahir harus di antara 20–70 cm.', error: true);
      return;
    }

    setState(() => _saving = true);
    final error = ref
        .read(appControllerProvider.notifier)
        .addRosterTarget(
          name: _name.text,
          type: _type,
          dob: _type == RosterType.child ? _dob : null,
          sex: _type == RosterType.child ? _sex : null,
          guardianName: _guardian.text,
          pregnancyWeeks: _type == RosterType.pregnant ? weeks : null,
          lilaCm: _type == RosterType.pregnant ? lila : null,
          hbGdl: _type == RosterType.pregnant ? hb : null,
          birthWeightKg: birthWeight,
          birthLengthCm: birthLength,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      showNuriSnack(context, error, error: true);
      return;
    }
    showNuriSnack(context, 'Sasaran baru ditambahkan ke sesi.');
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isChild = _type == RosterType.child;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Tambah sasaran',
              subtitle: 'Tanpa akun • langsung masuk roster sesi',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    NuriSegmentedControl<RosterType>(
                      values: RosterType.values,
                      selected: _type,
                      labelFor: (value) =>
                          value == RosterType.child ? 'Balita' : 'Ibu Hamil',
                      onChanged: (value) => setState(() => _type = value),
                    ),
                    const SizedBox(height: 16),
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NuriTextField(
                            label: isChild ? 'Nama anak' : 'Nama ibu',
                            controller: _name,
                            hint: isChild
                                ? 'Contoh: Alif Pratama'
                                : 'Contoh: Ibu Anisa Wardani',
                            textCapitalization: TextCapitalization.words,
                          ),
                          if (isChild) ...[
                            const SizedBox(height: 14),
                            NuriDateField(
                              label: 'Tanggal lahir',
                              value: _dob,
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 1856),
                              ),
                              lastDate: DateTime.now(),
                              onChanged: (value) =>
                                  setState(() => _dob = value),
                              helper: 'Usia anak harus 0–59 bulan.',
                            ),
                            const SizedBox(height: 14),
                            const NuriFormLabel(text: 'Jenis kelamin'),
                            NuriSegmentedControl<Sex>(
                              values: Sex.values,
                              selected: _sex,
                              labelFor: (value) => value.label,
                              onChanged: (value) =>
                                  setState(() => _sex = value),
                            ),
                            const SizedBox(height: 14),
                            NuriTextField(
                              label: 'Nama wali / orang tua',
                              controller: _guardian,
                              hint: 'Contoh: Ibu Dewi Lestari',
                              textCapitalization: TextCapitalization.words,
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: NuriTextField(
                                    label: 'BB lahir (kg) — opsional',
                                    controller: _birthWeight,
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
                                    label: 'PB lahir (cm) — opsional',
                                    controller: _birthLength,
                                    hint: '49',
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            const SizedBox(height: 14),
                            NuriTextField(
                              label: 'Usia kehamilan (minggu)',
                              controller: _weeks,
                              hint: '20',
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: NuriTextField(
                                    label: 'LiLA (cm) — opsional',
                                    controller: _lila,
                                    hint: '24,0',
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: NuriTextField(
                                    label: 'Hb (g/dL) — opsional',
                                    controller: _hb,
                                    hint: '11,5',
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                          decimal: true,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            NuriTextField(
                              label: 'Pendamping / keterangan',
                              controller: _guardian,
                              hint: 'Contoh: RT 04 / RW 04',
                              textCapitalization: TextCapitalization.words,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    NuriButton(
                      label: 'Simpan sasaran',
                      icon: Icons.person_add_alt_1_rounded,
                      loading: _saving,
                      onPressed: _save,
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Data minimal tanpa NIK • tersimpan offline di perangkat.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
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
