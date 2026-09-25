import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/child_profile.dart';
import '../services/auth_service.dart';
import '../services/child_service.dart';
import '../theme/app_colors.dart';
import 'child_detail_screen.dart';
import 'child_form_screen.dart';

/// Halaman daftar Data Anak (Read) + Create/Edit/Delete.
class ChildListScreen extends StatefulWidget {
  const ChildListScreen({super.key});

  @override
  State<ChildListScreen> createState() => _ChildListScreenState();
}

class _ChildListScreenState extends State<ChildListScreen> {
  final _searchController = TextEditingController();
  String _selectedStatus = 'Semua';
  String _query = '';

  static const statuses = [
    'Semua',
    'Normal',
    'Perlu Pemantauan',
    'Risiko Stunting',
  ];

  String get _userId => AuthService().currentUser?.id ?? 'guest';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ChildProfile> get _children {
    final all = ChildService().getChildren(_userId);
    return all.where((child) {
      final matchStatus =
          _selectedStatus == 'Semua' || child.status == _selectedStatus;
      final query = _query.trim().toLowerCase();
      final matchQuery =
          query.isEmpty ||
          child.name.toLowerCase().contains(query) ||
          child.motherName.toLowerCase().contains(query);
      return matchStatus && matchQuery;
    }).toList();
  }

  Future<void> _openForm({ChildProfile? child}) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ChildFormScreen(ownerUserId: _userId, child: child),
      ),
    );
    if (changed == true && mounted) setState(() {});
  }

  Future<void> _openDetail(ChildProfile child) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ChildDetailScreen(childId: child.id)),
    );
    if (changed == true && mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final children = _children;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text('Data Anak'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Cari nama anak atau ibu...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: statuses.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final status = statuses[index];
                final active = status == _selectedStatus;
                return ChoiceChip(
                  label: Text(status),
                  selected: active,
                  onSelected: (_) => setState(() => _selectedStatus = status),
                  selectedColor: AppColors.primaryLight,
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? Colors.white : AppColors.textDark,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Row(
              children: [
                Text(
                  '${children.length} data anak',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
                const Spacer(),
                const Text(
                  'ID anak menjadi relasi Food Diary',
                  style: TextStyle(fontSize: 10, color: AppColors.textLight),
                ),
              ],
            ),
          ),
          Expanded(
            child: children.isEmpty
                ? const _EmptyChildList()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
                    itemCount: children.length,
                    itemBuilder: (context, index) {
                      final child = children[index];
                      return _ChildCard(
                        child: child,
                        onTap: () => _openDetail(child),
                        onEdit: () => _openForm(child: child),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah Anak'),
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  final ChildProfile child;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const _ChildCard({
    required this.child,
    required this.onTap,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (child.status) {
      'Normal' => Colors.green,
      'Risiko Stunting' => Colors.redAccent,
      _ => Colors.orange,
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.softGreen,
                child: Text(
                  child.name.isEmpty ? '?' : child.name[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${child.ageLabel()} · ${child.weightKg.toStringAsFixed(1)} kg · ${child.heightCm.toStringAsFixed(0)} cm',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        child.status,
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                tooltip: 'Edit ${child.name}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyChildList extends StatelessWidget {
  const _EmptyChildList();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.child_care_rounded,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada data anak',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tambahkan data anak untuk mulai memantau tumbuh kembang.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: AppColors.textGrey,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
