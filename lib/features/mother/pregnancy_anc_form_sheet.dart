import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';

class AncFormSheet extends ConsumerStatefulWidget {
  const AncFormSheet({super.key});

  @override
  ConsumerState<AncFormSheet> createState() => _AncFormSheetState();
}

class _AncFormSheetState extends ConsumerState<AncFormSheet> {
  DateTime _date = dateOnly(DateTime.now());
  final _facility = TextEditingController(text: 'Posyandu Melati II');
  final _note = TextEditingController();

  @override
  void dispose() {
    _facility.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    ref
        .read(appControllerProvider.notifier)
        .addAncVisit(
          date: _date,
          facility: _facility.text.trim().isEmpty
              ? null
              : _facility.text.trim(),
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        );
    Navigator.of(context).pop();
    showNuriSnack(context, 'Kunjungan ANC tercatat.');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Catat kunjungan ANC',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          const Text(
            'Catat pemeriksaan yang sudah dilakukan bersama bidan atau dokter.',
            style: TextStyle(
              fontSize: 11.5,
              color: AppColors.muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          NuriDateField(
            label: 'Tanggal kunjungan',
            value: _date,
            firstDate: DateTime.now().subtract(const Duration(days: 300)),
            lastDate: DateTime.now(),
            onChanged: (value) => setState(() => _date = dateOnly(value)),
          ),
          const SizedBox(height: 12),
          NuriTextField(
            label: 'Fasilitas / tenaga kesehatan',
            controller: _facility,
            hint: 'Posyandu, puskesmas, atau bidan',
            prefixIcon: Icons.local_hospital_outlined,
          ),
          const SizedBox(height: 12),
          NuriTextField(
            label: 'Catatan (opsional)',
            controller: _note,
            hint: 'Contoh: tekanan darah normal, imunisasi TT',
            maxLines: 2,
          ),
          const SizedBox(height: 14),
          NuriButton(
            label: 'Simpan kunjungan',
            icon: Icons.check_rounded,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}
