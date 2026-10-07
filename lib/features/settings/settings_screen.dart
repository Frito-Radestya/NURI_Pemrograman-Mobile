import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/chips.dart';
import '../../core/widgets/nuri_button.dart';
import '../../core/widgets/nuri_card.dart';
import '../../core/widgets/nuri_scaffold.dart';
import '../../core/widgets/nuri_top_bar.dart';
import '../../core/widgets/section.dart';
import '../../core/widgets/tiles.dart';
import '../../data/nuri_repository.dart' show SyncState;
import '../../state/app_state.dart';

/// Layar pengaturan aplikasi — preferensi, pengingat, sinkronisasi, keamanan.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NuriAppState state = NuriScope.of(context);
    final String nama = state.user?.displayName ?? 'Pengguna NURI';
    final (String syncLabel, Color syncColor) = _syncInfo(state);

    return NuriScaffold(
      background: AppColors.canvas,
      topBar: NuriTopBar(
        showBack: true,
        onBack: () => context.canPop() ? context.pop() : context.go('/profile'),
        titleWidget: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('NURI HEALTH', style: AppText.caption),
            Text('Pengaturan', style: AppText.h3),
          ],
        ),
        actions: [
          NuriAvatar(
            initials: _initials(nama),
            background: AppColors.pastelGreen,
            color: AppColors.ink,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        children: [
          // Kartu profil keluarga.
          NuriCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    NuriAvatar(
                      initials: _initials(nama),
                      size: 52,
                      background: AppColors.pastelGreen,
                      color: AppColors.ink,
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Tag(text: 'PROFIL AKTIF'),
                          const SizedBox(height: 8),
                          Text(
                            nama,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.h3,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.user?.posyanduName ??
                                state.user?.email ??
                                'Belum ada data akun',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    const DotBadge(
                      text: 'Data tumbuh kembang aman',
                      background: AppColors.pastelGreen,
                    ),
                    Tag(text: syncLabel, color: syncColor),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Sinkronisasi Posyandu (F12).
          const SectionHeader(title: 'Sinkronisasi Posyandu'),
          const SizedBox(height: 12),
          NuriCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const IconBadge(
                      icon: Icons.cloud_sync_outlined,
                      color: AppColors.pastelGreenSoft,
                      iconColor: AppColors.brand,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status Sinkronisasi',
                            style: AppText.title,
                          ),
                          const SizedBox(height: 3),
                          Text(state.storageLabel, style: AppText.caption),
                        ],
                      ),
                    ),
                    StatusChip(text: syncLabel, color: syncColor),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${state.pendingCount} perubahan menunggu',
                            style: AppText.bodyStrong,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            state.lastSyncedAt == null
                                ? 'Belum pernah sinkron'
                                : 'Terakhir sinkron ${_formatDateTime(state.lastSyncedAt!)}',
                            style: AppText.caption,
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: state.online,
                      onChanged: (bool value) => state.setOnline(value),
                      activeThumbColor: AppColors.brand,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        state.online ? 'Mode online aktif' : 'Mode offline aktif',
                        style: AppText.caption,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                NuriPrimaryButton(
                  label: state.syncing
                      ? 'Menyinkronkan…'
                      : 'Sinkronkan sekarang',
                  icon: Icons.sync_rounded,
                  loading: state.syncing,
                  onPressed: state.syncing ? null : () => _syncNow(context),
                ),
                const SizedBox(height: 12),
                NoteRow(
                  icon: state.cloudEnabled
                      ? Icons.cloud_done_outlined
                      : Icons.cloud_off_outlined,
                  text: state.cloudEnabled
                      ? (state.cloudSignedIn
                          ? 'Terhubung Supabase: ${state.cloudEmail ?? '-'}'
                          : 'Supabase aktif. Masuk ke akun untuk menyinkronkan.')
                      : 'Supabase belum dikonfigurasi (mode demo offline).',
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Notifikasi & pengingat.
          const SectionHeader(title: 'Notifikasi & Pengingat'),
          const SizedBox(height: 12),
          const _SettingGroup(
            children: [
              _SettingRow(
                icon: Icons.event_available_outlined,
                title: 'Jadwal Posyandu & Vaksinasi',
                caption: 'Pengingat otomatis H-1 sebelum jadwal',
                trailing: _SwitchOn(),
              ),
              _SettingRow(
                icon: Icons.restaurant_outlined,
                title: 'Pengingat Piring Makan & MP-ASI',
                caption: 'Notifikasi harian variasi protein hewani si kecil',
                trailing: _SwitchOn(),
              ),
              _SettingRow(
                icon: Icons.schedule_outlined,
                title: 'Waktu Pengingat Harian',
                caption: 'Jadwal evaluasi asupan',
                trailing: Tag(text: '07:00 WIB'),
              ),
              _SettingRow(
                icon: Icons.chat_outlined,
                title: 'Notifikasi WhatsApp',
                caption: 'Pengingat jadwal timbang ke nomor terdaftar',
                trailing: _SwitchOn(),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Preferensi & tampilan.
          const SectionHeader(title: 'Preferensi & Tampilan'),
          const SizedBox(height: 12),
          const _SettingGroup(
            children: [
              _SettingRow(
                icon: Icons.straighten,
                title: 'Satuan Ukur Antropometri',
                caption: 'Standar Baku Kemenkes RI',
                trailing: Tag(text: 'kg & cm'),
              ),
              _SettingRow(
                icon: Icons.text_fields_rounded,
                title: 'Ukuran Teks Tampilan',
                caption: 'Nyaman dibaca, kontras tinggi',
                trailing: Tag(text: 'Normal'),
              ),
              _SettingRow(
                icon: Icons.language_rounded,
                title: 'Bahasa Aplikasi',
                caption: 'Pilihan bahasa untuk Bunda dan Keluarga',
                trailing: Tag(text: 'Indonesia'),
              ),
              _SettingRow(
                icon: Icons.wifi_off_rounded,
                title: 'Mode Hemat Kuota & Sinyal',
                caption: 'Simpan data lokal saat sinyal terbatas',
                trailing: _SwitchOff(),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Keamanan & privasi.
          const SectionHeader(title: 'Keamanan & Privasi'),
          const SizedBox(height: 12),
          const _SettingGroup(
            children: [
              _SettingRow(
                icon: Icons.lock_reset_rounded,
                title: 'Ubah Kata Sandi & PIN',
                caption: 'Perlindungan privasi data tumbuh kembang',
              ),
              _SettingRow(
                icon: Icons.camera_alt_outlined,
                title: 'Izin Kamera & Foto Makanan',
                caption: 'Digunakan untuk pemindaian piring gizi',
                trailing: Tag(text: 'Diizinkan'),
              ),
              _SettingRow(
                icon: Icons.privacy_tip_outlined,
                title: 'Kepatuhan UU PDP & SatuSehat',
                caption: 'Enkripsi data rekam medis anak',
              ),
              _SettingRow(
                icon: Icons.backup_outlined,
                title: 'Cadangkan Data KMS ke Perangkat',
                caption: 'Unduh salinan berkala KMS & riwayat imunisasi',
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Bantuan & dukungan.
          const SectionHeader(title: 'Bantuan & Dukungan'),
          const SizedBox(height: 12),
          const _SettingGroup(
            children: [
              _SettingRow(
                icon: Icons.help_outline_rounded,
                title: 'Pusat Bantuan & Panduan NURI',
                caption: 'Cara membaca kurva KMS & tips menu MP-ASI',
              ),
              _SettingRow(
                icon: Icons.bug_report_outlined,
                title: 'Laporkan Kendala Teknis',
                caption: 'Sampaikan keluhan atau masukan',
              ),
              _SettingRow(
                icon: Icons.info_outline_rounded,
                title: 'NURI Health v2.0.0',
                caption: 'Build 2026',
              ),
            ],
          ),
          const SizedBox(height: 18),

          NuriCard(
            color: AppColors.pastelPink,
            onTap: () => _signOut(context),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: AppColors.ink, size: 20),
                SizedBox(width: 10),
                Text('Keluar dari Akun', style: AppText.bodyStrong),
              ],
            ),
          ),
          const SizedBox(height: 12),
          NuriCard(
            color: AppColors.statusSangatPendekSoft,
            onTap: () => _deleteAccount(context),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete_forever_outlined,
                      color: AppColors.statusSangatPendek,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Hapus Akun & Data',
                      style: AppText.bodyStrong,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Menghapus seluruh data anak, pengukuran, dan catatan '
                  'secara permanen (F13).',
                  textAlign: TextAlign.center,
                  style: AppText.caption.copyWith(
                    color: AppColors.statusSangatPendek,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Center(
            child: NoteRow(
              icon: Icons.verified,
              text: 'NURI berkomitmen melindungi kerahasiaan rekam gizi dan '
                  'tumbuh kembang buah hati.',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _syncNow(BuildContext context) async {
    final NuriAppState state = NuriScope.read(context);
    try {
      final int sent = await state.sync();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sent == 0
                ? 'Semua data sudah tersinkron.'
                : '$sent data berhasil disinkronkan.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sinkronisasi gagal: $e')),
      );
    }
  }

  Future<void> _signOut(BuildContext context) async {
    final NuriAppState state = NuriScope.read(context);
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Keluar dari Akun?'),
        content: const Text('Anda dapat masuk kembali kapan saja.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    state.signOut();
    if (context.mounted) context.go('/login');
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final NuriAppState state = NuriScope.read(context);
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Hapus Akun & Data?'),
        content: const Text(
          'Seluruh data anak, pengukuran, dan catatan akan dihapus '
          'permanen. Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus Permanen'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await state.deleteAccount();
    if (context.mounted) context.go('/login');
  }
}

// ---------------------------------------------------------------------------
// Bagian lokal.
// ---------------------------------------------------------------------------

class _SwitchOn extends StatelessWidget {
  const _SwitchOn();

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: true,
      onChanged: (_) {},
      activeThumbColor: AppColors.brand,
    );
  }
}

class _SwitchOff extends StatelessWidget {
  const _SwitchOff();

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: false,
      onChanged: (_) {},
      activeThumbColor: AppColors.brand,
    );
  }
}

class _SettingGroup extends StatelessWidget {
  const _SettingGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return NuriCard(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                color: AppColors.line,
                indent: 16,
                endIndent: 16,
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.caption,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String caption;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          IconBadge(
            icon: icon,
            size: 42,
            radius: 14,
            color: AppColors.pastelGreenSoft,
            iconColor: AppColors.brand,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.title),
                const SizedBox(height: 3),
                Text(caption, style: AppText.caption),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 10),
            trailing!,
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Utilitas.
// ---------------------------------------------------------------------------

(String, Color) _syncInfo(NuriAppState state) {
  switch (state.syncState) {
    case SyncState.offline:
      return ('Offline', AppColors.lineStrong);
    case SyncState.syncing:
      return ('Menyinkronkan', AppColors.pastelBlue);
    case SyncState.pending:
      return ('Menunggu (${state.pendingCount})', AppColors.pastelPeach);
    case SyncState.synced:
      return ('Tersinkron', AppColors.pastelGreen);
  }
}

String _initials(String name) {
  final List<String> parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((String p) => p.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
      .toUpperCase();
}

const List<String> _bulan = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'Mei',
  'Jun',
  'Jul',
  'Agu',
  'Sep',
  'Okt',
  'Nov',
  'Des',
];

String _formatDateTime(DateTime date) =>
    '${date.day} ${_bulan[date.month - 1]} ${date.year} '
    '${date.hour.toString().padLeft(2, '0')}:'
    '${date.minute.toString().padLeft(2, '0')}';
