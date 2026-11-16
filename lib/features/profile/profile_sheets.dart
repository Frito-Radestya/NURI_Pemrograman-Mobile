import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../domain/pregnancy/pregnancy_calculator.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';

class FamilyCodeGeneratorSheet extends ConsumerStatefulWidget {
  const FamilyCodeGeneratorSheet({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  final String subjectId;
  final String subjectName;

  @override
  ConsumerState<FamilyCodeGeneratorSheet> createState() =>
      _FamilyCodeGeneratorSheetState();
}

class _FamilyCodeGeneratorSheetState
    extends ConsumerState<FamilyCodeGeneratorSheet> {
  bool _allowFoodDiary = false;
  LinkCode? _generated;

  void _generate() {
    final scopes = <String>['ukur', if (_allowFoodDiary) 'makan'];
    final code = ref
        .read(appControllerProvider.notifier)
        .createFamilyLinkCode(
          subjectId: widget.subjectId,
          subjectName: widget.subjectName,
          scopes: scopes,
        );
    setState(() => _generated = code);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _generate());
  }

  @override
  Widget build(BuildContext context) {
    final link = _generated;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  'Hubungkan dengan Posyandu',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Untuk ${widget.subjectName} • Token sekali pakai (24 jam)',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Atur izin akses kader:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data pertumbuhan (Wajib)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Melihat grafik dan mencatat hasil pengukuran Posyandu',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.line),
            ),
            value: _allowFoodDiary,
            onChanged: (val) {
              setState(() => _allowFoodDiary = val);
              _generate();
            },
            title: const Text(
              'Catatan makan (Opsional)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            subtitle: const Text(
              'Izinkan kader melihat diary asupan makan harian',
              style: TextStyle(fontSize: 11.5, color: AppColors.muted),
            ),
          ),
          const SizedBox(height: 16),
          if (link != null) ...[
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.line),
                ),
                child: QrImageView(
                  data: link.code,
                  version: QrVersions.auto,
                  size: 185,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.primaryDark,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(
                  link.code,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          NuriButton(
            label: 'Tutup',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class AddChildSheet extends ConsumerStatefulWidget {
  const AddChildSheet({super.key});

  @override
  ConsumerState<AddChildSheet> createState() => _AddChildSheetState();
}

class _AddChildSheetState extends ConsumerState<AddChildSheet> {
  final _name = TextEditingController();
  final _guardian = TextEditingController();
  final _birthWeight = TextEditingController();
  final _birthLength = TextEditingController();
  DateTime? _dob;
  Sex _sex = Sex.male;

  @override
  void dispose() {
    _name.dispose();
    _guardian.dispose();
    _birthWeight.dispose();
    _birthLength.dispose();
    super.dispose();
  }

  double? _parse(TextEditingController controller) =>
      double.tryParse(controller.text.trim().replaceAll(',', '.'));

  void _save() {
    if (_name.text.trim().length < 2) {
      showNuriSnack(context, 'Nama anak minimal 2 karakter.', error: true);
      return;
    }
    if (_dob == null) {
      showNuriSnack(context, 'Tanggal lahir wajib diisi.', error: true);
      return;
    }
    final error = ref
        .read(appControllerProvider.notifier)
        .addChild(
          nickname: _name.text,
          dob: _dob!,
          sex: _sex,
          guardianName: _guardian.text,
          birthWeightKg: _parse(_birthWeight),
          birthLengthCm: _parse(_birthLength),
        );
    if (error != null) {
      showNuriSnack(context, error, error: true);
      return;
    }
    Navigator.of(context).pop();
    showNuriSnack(context, 'Data anak ditambahkan.');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tambah anak', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          NuriTextField(
            label: 'Nama panggilan / lengkap',
            controller: _name,
            hint: 'Contoh: Rafi Ahmad',
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 14),
          NuriDateField(
            label: 'Tanggal lahir',
            value: _dob,
            firstDate: DateTime.now().subtract(const Duration(days: 1856)),
            lastDate: DateTime.now(),
            onChanged: (value) => setState(() => _dob = value),
          ),
          const SizedBox(height: 14),
          const NuriFormLabel(text: 'Jenis kelamin'),
          NuriSegmentedControl<Sex>(
            values: Sex.values,
            selected: _sex,
            labelFor: (value) => value.label,
            onChanged: (value) => setState(() => _sex = value),
          ),
          const SizedBox(height: 14),
          NuriTextField(
            label: 'Nama wali',
            controller: _guardian,
            hint: 'Contoh: Siti Rahma',
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
                  keyboardType: const TextInputType.numberWithOptions(
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
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          NuriButton(
            label: 'Simpan data anak',
            icon: Icons.check_rounded,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}

class AddPregnancySheet extends ConsumerStatefulWidget {
  const AddPregnancySheet({super.key});

  @override
  ConsumerState<AddPregnancySheet> createState() => _AddPregnancySheetState();
}

class _AddPregnancySheetState extends ConsumerState<AddPregnancySheet> {
  DateTime? _hpht;

  void _save() {
    if (_hpht == null) {
      showNuriSnack(
        context,
        'HPHT wajib diisi untuk menghitung HPL.',
        error: true,
      );
      return;
    }
    if (_hpht!.isAfter(DateTime.now())) {
      showNuriSnack(context, 'HPHT tidak boleh di masa depan.', error: true);
      return;
    }
    ref.read(appControllerProvider.notifier).addPregnancy(hpht: _hpht!);
    Navigator.of(context).pop();
    showNuriSnack(
      context,
      'Kehamilan ditambahkan. Jadwal ANC dan TTD siap dipantau.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tambah kehamilan',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          const Text(
            'Masukkan hari pertama haid terakhir (HPHT). NURI menghitung HPL dengan rumus Naegele.',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.muted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          NuriDateField(
            label: 'HPHT',
            value: _hpht,
            firstDate: DateTime.now().subtract(const Duration(days: 300)),
            lastDate: DateTime.now(),
            onChanged: (value) => setState(() => _hpht = value),
            helper: _hpht == null
                ? null
                : 'Perkiraan lahir: ${formatDateId(PregnancyCalculator.hplFromHpht(_hpht!))}',
          ),
          const SizedBox(height: 14),
          const InfoBanner(
            title: 'Kehamilan risiko',
            body: 'Bila ada tekanan darah tinggi, perdarahan, atau keluhan berat, segera hubungi bidan atau faskes.',
            icon: Icons.health_and_safety_outlined,
            background: AppColors.amberSoft,
            foreground: AppColors.amber,
          ),
          const SizedBox(height: 16),
          NuriButton(
            label: 'Simpan kehamilan',
            icon: Icons.check_rounded,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}

class EditPosyanduSheet extends StatefulWidget {
  const EditPosyanduSheet({
    super.key,
    required this.initialName,
    required this.initialArea,
  });

  final String initialName;
  final String initialArea;

  @override
  State<EditPosyanduSheet> createState() => _EditPosyanduSheetState();
}

class _EditPosyanduSheetState extends State<EditPosyanduSheet> {
  late final TextEditingController _name;
  late final TextEditingController _area;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialName);
    _area = TextEditingController(text: widget.initialArea);
  }

  @override
  void dispose() {
    _name.dispose();
    _area.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ubah Posyandu', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          NuriTextField(label: 'Nama Posyandu', controller: _name),
          const SizedBox(height: 14),
          NuriTextField(label: 'Wilayah', controller: _area),
          const SizedBox(height: 16),
          NuriButton(
            label: 'Simpan',
            icon: Icons.check_rounded,
            onPressed: () =>
                Navigator.of(context)
                    .pop((name: _name.text.trim(), area: _area.text.trim())),
          ),
        ],
      ),
    );
  }
}

class ClaimChildSheet extends StatefulWidget {
  const ClaimChildSheet({super.key});

  @override
  State<ClaimChildSheet> createState() => _ClaimChildSheetState();
}

class _ClaimChildSheetState extends State<ClaimChildSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Klaim Data Anak Posyandu',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          const Text(
            'Masukkan kode klaim sekali pakai (contoh: KL-XXXX-XXXX) yang diberikan Kader Posyandu untuk memindahkan riwayat tumbuh kembang anak ke akun Ibu.',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.muted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          NuriTextField(
            label: 'Kode Klaim',
            controller: _controller,
            hint: 'KL-XXXX-XXXX',
            prefixIcon: Icons.vpn_key_outlined,
            textCapitalization: TextCapitalization.characters,
          ),
          const SizedBox(height: 16),
          NuriButton(
            label: 'Verifikasi & Klaim',
            icon: Icons.verified_outlined,
            onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          ),
        ],
      ),
    );
  }
}

class PosyanduQrSheet extends StatelessWidget {
  const PosyanduQrSheet({super.key, required this.posyanduName});

  final String posyanduName;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        children: [
          Text('Kode Posyandu', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            posyanduName,
            style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.line),
            ),
            child: QrImageView(
              data: 'POSYANDU-MELATI-II-2026',
              version: QrVersions.auto,
              size: 190,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.primaryDark,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const SelectableText(
            'POSYANDU-MELATI-II-2026',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          const InfoBanner(
            title: 'Bagikan ke ibu',
            body: 'Ibu memindai kode ini untuk bergabung ke Posyandu dan menghubungkan data keluarga.',
            icon: Icons.groups_rounded,
          ),
          const SizedBox(height: 14),
          NuriButton(
            label: 'Tutup',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class AboutNuriSheet extends StatelessWidget {
  const AboutNuriSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              NuriLogo(compact: true),
              Spacer(),
              Pill(label: 'Demo v0.2', fontSize: 11.5),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Skrining awal, bukan diagnosis',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'NURI membantu keluarga dan kader memantau pertumbuhan, asupan makan, dan tanda risiko selama kehamilan. '
            'Semua hasil adalah skrining awal berbasis data yang diisi pengguna. NURI tidak menggantikan pemeriksaan, '
            'diagnosis, atau pengobatan oleh bidan, dokter, atau fasilitas kesehatan.',
            style: TextStyle(
              fontSize: 13.5,
              height: 1.55,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 14),
          const InfoBanner(
            title: 'Sumber data',
            body:
                'WHO Child Growth Standards 2006 (LMS panjang/tinggi menurut umur), '
                'TKPI 2017 (subset makanan), dan AKG Kemenkes 2019 untuk target gizi.',
            icon: Icons.menu_book_outlined,
          ),
          const SizedBox(height: 10),
          const InfoBanner(
            title: 'Privasi',
            body:
                'Kredensial login diproses oleh Firebase Authentication. Data kesehatan demo masih tersimpan '
                'lokal di perangkat dan belum diunggah ke Firestore pada tahap ini.',
            icon: Icons.lock_outline_rounded,
          ),
          const SizedBox(height: 14),
          NuriButton(
            label: 'Tutup',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
