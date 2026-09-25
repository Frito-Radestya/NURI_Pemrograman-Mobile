import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/child_profile.dart';
import '../services/child_service.dart';
import '../theme/app_colors.dart';

/// Form Create/Update untuk modul Data Anak.
class ChildFormScreen extends StatefulWidget {
  final ChildProfile? child;
  final String ownerUserId;

  const ChildFormScreen({super.key, required this.ownerUserId, this.child});

  @override
  State<ChildFormScreen> createState() => _ChildFormScreenState();
}

class _ChildFormScreenState extends State<ChildFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _motherCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _notesCtrl;
  late DateTime _birthDate;
  late String _gender;
  late String _status;

  static const statuses = ['Normal', 'Perlu Pemantauan', 'Risiko Stunting'];

  bool get isEditing => widget.child != null;

  @override
  void initState() {
    super.initState();
    final child = widget.child;
    _nameCtrl = TextEditingController(text: child?.name ?? '');
    _motherCtrl = TextEditingController(text: child?.motherName ?? '');
    _weightCtrl = TextEditingController(
      text: child == null ? '' : child.weightKg.toStringAsFixed(1),
    );
    _heightCtrl = TextEditingController(
      text: child == null ? '' : child.heightCm.toStringAsFixed(1),
    );
    _notesCtrl = TextEditingController(text: child?.notes ?? '');
    _birthDate =
        child?.birthDate ?? DateTime.now().subtract(const Duration(days: 365));
    _gender = child?.gender ?? 'P';
    _status = child?.status ?? 'Perlu Pemantauan';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _motherCtrl.dispose();
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime.now(),
      helpText: 'Pilih Tanggal Lahir',
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final service = ChildService();
    final id = widget.child?.id ?? service.generateId(widget.ownerUserId);
    final profile = ChildProfile(
      id: id,
      ownerUserId: widget.ownerUserId,
      name: _nameCtrl.text.trim(),
      birthDate: _birthDate,
      gender: _gender,
      weightKg: double.parse(_weightCtrl.text.trim()),
      heightCm: double.parse(_heightCtrl.text.trim()),
      motherName: _motherCtrl.text.trim(),
      lastCheckDate: widget.child?.lastCheckDate ?? DateTime.now(),
      status: _status,
      notes: _notesCtrl.text.trim(),
    );

    if (isEditing) {
      service.updateChild(profile);
    } else {
      service.addChild(profile);
    }
    Navigator.pop(context, true);
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label wajib diisi';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          isEditing ? 'Edit Data Anak' : 'Tambah Data Anak',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.softGreen,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.child_care_rounded,
                    color: AppColors.primary,
                    size: 36,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEditing
                          ? 'Perbarui data untuk monitor tumbuh kembang.'
                          : 'Lengkapi data anak. Data ini terhubung dengan Food Diary.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        height: 1.4,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _field(
              _nameCtrl,
              'Nama Anak',
              Icons.child_care_outlined,
              validator: (v) => _required(v, 'Nama anak'),
            ),
            const SizedBox(height: 14),
            _field(
              _motherCtrl,
              'Nama Ibu/Keluarga',
              Icons.family_restroom_rounded,
              validator: (v) => _required(v, 'Nama ibu'),
            ),
            const SizedBox(height: 14),
            InkWell(
              onTap: _pickBirthDate,
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Tanggal Lahir',
                  prefixIcon: const Icon(Icons.cake_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  '${_birthDate.day}/${_birthDate.month}/${_birthDate.year}',
                  style: GoogleFonts.poppins(color: AppColors.textDark),
                ),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _gender,
              decoration: _decoration('Jenis Kelamin', Icons.face_3_outlined),
              items: const [
                DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _gender = value);
              },
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _field(
                    _weightCtrl,
                    'Berat (kg)',
                    Icons.monitor_weight_outlined,
                    numeric: true,
                    validator: (v) {
                      final value = double.tryParse(v?.trim() ?? '');
                      if (value == null) return 'Masukkan angka';
                      if (value < 1 || value > 40) return '1-40 kg';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _field(
                    _heightCtrl,
                    'Tinggi (cm)',
                    Icons.height_rounded,
                    numeric: true,
                    validator: (v) {
                      final value = double.tryParse(v?.trim() ?? '');
                      if (value == null) return 'Masukkan angka';
                      if (value < 30 || value > 130) return '30-130 cm';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: _decoration(
                'Status Tumbuh',
                Icons.health_and_safety_outlined,
              ),
              items: statuses
                  .map(
                    (status) =>
                        DropdownMenuItem(value: status, child: Text(status)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _status = value);
              },
            ),
            const SizedBox(height: 14),
            _field(
              _notesCtrl,
              'Catatan Kader',
              Icons.notes_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _save,
              icon: Icon(isEditing ? Icons.save_rounded : Icons.add_rounded),
              label: Text(isEditing ? 'Simpan Perubahan' : 'Tambah Data Anak'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool numeric = false,
    int maxLines = 1,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      validator: validator,
      decoration: _decoration(label, icon),
    );
  }
}
