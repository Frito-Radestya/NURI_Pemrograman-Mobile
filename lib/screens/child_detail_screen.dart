import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/child_profile.dart';
import '../services/child_service.dart';
import '../theme/app_colors.dart';
import 'child_form_screen.dart';
import 'stunting_screening_screen.dart';
import 'growth_curve_screen.dart';

/// Halaman detail Data Anak (Read satu record).
class ChildDetailScreen extends StatefulWidget {
  final String childId;

  const ChildDetailScreen({super.key, required this.childId});

  @override
  State<ChildDetailScreen> createState() => _ChildDetailScreenState();
}

class _ChildDetailScreenState extends State<ChildDetailScreen> {
  ChildProfile? _child;

  @override
  void initState() {
    super.initState();
    _child = ChildService().findById(widget.childId);
  }

  Future<void> _edit() async {
    final child = _child;
    if (child == null) return;
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ChildFormScreen(child: child, ownerUserId: child.ownerUserId),
      ),
    );
    if (changed == true && mounted) {
      setState(() => _child = ChildService().findById(widget.childId));
    }
  }

  Future<void> _delete() async {
    final child = _child;
    if (child == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus data anak?'),
        content: Text(
          'Data ${child.name} akan dihapus dari daftar. Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ChildService().deleteChild(child.id);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = _child;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('Detail Data Anak'),
        actions: [
          IconButton(
            onPressed: child == null ? null : _edit,
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit data anak',
          ),
          IconButton(
            onPressed: child == null ? null : _delete,
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'Hapus data anak',
          ),
        ],
      ),
      body: child == null
          ? const Center(child: Text('Data anak tidak ditemukan.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.headerGradient,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        child: Text(
                          child.name.characters.first.toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              child.name,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${child.ageLabel()} · ${child.genderLabel}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _statusChip(child.status),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _infoCard(child),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StuntingScreeningScreen(
                              initialChildId: child.id,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.medical_services_outlined),
                        label: const Text('Skrining'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                GrowthCurveScreen(childId: child.id),
                          ),
                        ),
                        icon: const Icon(Icons.show_chart),
                        label: const Text('Kurva'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE8E8E8)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Catatan',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        child.notes.isEmpty
                            ? 'Belum ada catatan tambahan.'
                            : child.notes,
                        style: GoogleFonts.poppins(
                          color: AppColors.textGrey,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Relasi data: childId=${child.id}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _infoCard(ChildProfile child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _row(
            Icons.cake_outlined,
            'Tanggal Lahir',
            '${child.birthDate.day}/${child.birthDate.month}/${child.birthDate.year}',
          ),
          _row(Icons.family_restroom_rounded, 'Ibu/Keluarga', child.motherName),
          _row(
            Icons.monitor_weight_outlined,
            'Berat Badan',
            '${child.weightKg.toStringAsFixed(1)} kg',
          ),
          _row(
            Icons.height_rounded,
            'Tinggi Badan',
            '${child.heightCm.toStringAsFixed(1)} cm',
          ),
          _row(
            Icons.event_available_outlined,
            'Pemeriksaan Terakhir',
            '${child.lastCheckDate.day}/${child.lastCheckDate.month}/${child.lastCheckDate.year}',
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textGrey,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    final color = switch (status) {
      'Normal' => Colors.greenAccent,
      'Risiko Stunting' => Colors.redAccent,
      _ => Colors.orangeAccent,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
