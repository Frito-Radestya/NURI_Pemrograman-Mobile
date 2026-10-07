import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/chips.dart';
import '../../core/widgets/nuri_button.dart';
import '../../core/widgets/nuri_card.dart';
import '../../core/widgets/nuri_scaffold.dart';
import '../../core/widgets/nuri_tabs.dart';
import '../../core/widgets/nuri_top_bar.dart';
import '../../core/widgets/section.dart';
import '../../core/widgets/tiles.dart';
import '../../domain/models/child.dart';
import '../../state/app_state.dart';

/// Profil bunda — akun, data anak, personalisasi, dan privasi.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NuriAppState state = NuriScope.of(context);
    final String nama = state.user?.displayName ?? 'Bunda';
    final String posyandu =
        state.user?.posyanduName ?? 'Posyandu Melati RW 04';
    final List<Child> children = state.children;

    return NuriScaffold(
      background: AppColors.canvasMint,
      bottomNavigationBar: const MomTabBar(active: '/profile'),
      topBar: NuriTopBar(
        showBack: true,
        onBack: () => context.canPop() ? context.pop() : context.go('/home'),
        titleWidget: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('NURI HEALTH', style: AppText.caption),
            Text('Profil', style: AppText.h3),
          ],
        ),
        actions: [
          NuriSoftButton(
            icon: Icons.ios_share_rounded,
            background: AppColors.surface.withValues(alpha: 0.85),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          NuriSoftButton(
            icon: Icons.edit_outlined,
            background: AppColors.surface.withValues(alpha: 0.85),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        children: [
          // Kartu profil bunda.
          NuriCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        NuriAvatar(
                          initials: _initials(nama),
                          size: 64,
                          background: AppColors.pastelGreen,
                          color: AppColors.ink,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.brand,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.surface,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 11,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Tag(
                            text: state.user == null
                                ? 'Belum Masuk'
                                : '${state.user!.role.label} Terverifikasi',
                          ),
                          const SizedBox(height: 8),
                          Text(nama, style: AppText.h3),
                          const SizedBox(height: 6),
                          NoteRow(
                            icon: Icons.location_on_outlined,
                            text: posyandu,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (state.user != null) ...[
                  const SizedBox(height: 12),
                  NoteRow(
                    icon: Icons.mail_outline_rounded,
                    text: state.user!.email,
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      NuriAvatar(
                        initials: children.isEmpty
                            ? '?'
                            : _initials(children.first.nickname),
                        size: 40,
                        background: AppColors.pastelBlue,
                        color: AppColors.ink,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              children.isEmpty
                                  ? 'Belum ada anak terdaftar'
                                  : '${children.first.nickname} '
                                      '(${children.first.ageLabelAt(state.today)})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.title,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              children.length > 1
                                  ? '${children.length} anak terdaftar'
                                  : 'Anak Terdaftar',
                              style: AppText.caption,
                            ),
                          ],
                        ),
                      ),
                      if (children.isNotEmpty) const Tag(text: 'Aktif'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          SectionHeader(
            title: 'Data Buah Hati & Kehamilan',
            actionLabel: '${children.length} balita terdaftar',
          ),
          const SizedBox(height: 12),
          if (children.isEmpty)
            const NoteBox(
              background: AppColors.surfaceSoft,
              icon: Icons.child_care_rounded,
              child: Text(
                'Belum ada data anak. Tambahkan buah hati untuk mulai memantau '
                'tumbuh kembangnya.',
                style: AppText.bodySm,
              ),
            )
          else
            for (final Child child in children) ...[
              _ChildProfileCard(
                child: child,
                today: state.today,
                onDelete: () => _confirmDelete(context, child),
              ),
              const SizedBox(height: 12),
            ],
          NuriCard(
            border: AppColors.lineStrong,
            onTap: () => context.push('/child-data'),
            child: const Row(
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 28,
                  color: AppColors.brand,
                ),
                SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tambah Anak atau Kehamilan', style: AppText.h3),
                      SizedBox(height: 3),
                      Text(
                        'Catat riwayat tumbuh kembang anak baru',
                        style: AppText.caption,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.inkFaint),
              ],
            ),
          ),
          const SizedBox(height: 22),

          const SectionHeader(
            title: 'Personalisasi & Pemantauan AI',
            subtitle: 'Sesuaikan pengalaman aplikasi untuk keluarga',
          ),
          const SizedBox(height: 12),
          const _SettingGroup(
            children: [
              _SettingRow(
                icon: Icons.tune_rounded,
                title: 'Fase Pemantauan',
                caption: 'Ibu-Balita (0-5 Tahun)',
                trailing: Tag(text: 'Ubah'),
              ),
              _SettingRow(
                icon: Icons.notifications_active_outlined,
                title: 'Pengingat Posyandu & Vaksin',
                caption: 'Notifikasi H-1 & H-7 (07:00 WIB)',
                trailing: _SwitchOn(),
              ),
              _SettingRow(
                icon: Icons.restaurant_outlined,
                title: 'Menu Rekomendasi Piring Gizi',
                caption: 'Saran pangan lokal tinggi protein hewani',
                trailing: _SwitchOn(),
              ),
              _SettingRow(
                icon: Icons.straighten,
                title: 'Standar Pengukuran',
                caption: 'Standar Antropometri Kemenkes RI',
                trailing: Tag(text: 'kg/cm'),
              ),
            ],
          ),
          const SizedBox(height: 22),

          const SectionHeader(title: 'Akun & Pendamping Keluarga'),
          const SizedBox(height: 12),
          _SettingGroup(
            children: [
              _SettingRow(
                icon: Icons.mail_outline_rounded,
                title: 'Email Terdaftar',
                caption: state.user?.email ?? 'Belum ada email',
                trailing: Tag(
                  text: state.user == null ? 'Belum' : 'Terverifikasi',
                ),
              ),
              const _SettingRow(
                icon: Icons.chat_outlined,
                title: 'WhatsApp Notifikasi',
                caption: 'Belum diatur',
              ),
              const _SettingRow(
                icon: Icons.groups_2_outlined,
                title: 'Akses Pendamping',
                caption: 'Hubungkan pendamping keluarga',
              ),
              const _SettingRow(
                icon: Icons.lock_outline,
                title: 'PIN Keamanan Aplikasi',
                caption: 'Aktif',
              ),
            ],
          ),
          const SizedBox(height: 22),

          const SectionHeader(title: 'Privasi & Rekam Medis'),
          const SizedBox(height: 12),
          const _SettingGroup(
            children: [
              _SettingRow(
                icon: Icons.security_outlined,
                title: 'Enkripsi Rekam Medis Aman',
                caption:
                    'Data KMS anak Bunda dienkripsi sesuai standar UU '
                    'Perlindungan Data Pribadi (UU PDP) dan regulasi SatuSehat '
                    'Kemenkes RI.',
              ),
              _SettingRow(
                icon: Icons.verified_user_outlined,
                title: 'Izin Akses Bidan & Kader',
                caption: 'Disinkronkan ke Bidan/Puskesmas',
              ),
              _SettingRow(
                icon: Icons.download_outlined,
                title: 'Unduh Resume Rekam Medis KIA',
                caption: 'Dokumen cetak PDF',
              ),
              _SettingRow(
                icon: Icons.policy_outlined,
                title: 'Kebijakan Privasi & Syarat Layanan',
                caption: 'Hukum dan data pribadi',
              ),
            ],
          ),
          const SizedBox(height: 22),

          const SectionHeader(title: 'Bantuan & Konsultasi'),
          const SizedBox(height: 12),
          const _SettingGroup(
            children: [
              _SettingRow(
                icon: Icons.support_agent_rounded,
                title: 'Tanya Bidan & Ahli Gizi NURI',
                caption: 'Konsultasi langsung dengan tenaga kesehatan',
              ),
              _SettingRow(
                icon: Icons.help_outline_rounded,
                title: 'Panduan Aplikasi & Pertanyaan Umum',
                caption: 'Cara pakai dan tanya jawab',
              ),
              _SettingRow(
                icon: Icons.phone_in_talk_outlined,
                title: 'Kontak Kader Posyandu',
                caption: 'Hubungi kader setempat',
              ),
            ],
          ),
          const SizedBox(height: 18),
          NuriCard(
            color: AppColors.pastelPink,
            onTap: () => _confirmSignOut(context),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: AppColors.ink, size: 20),
                SizedBox(width: 10),
                Text('Keluar dari Akun Bunda', style: AppText.bodyStrong),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'NURI Health v2.0.0 • Antropometri Indonesia Awal • '
            'Pemantauan Stunting',
            textAlign: TextAlign.center,
            style: AppText.caption,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final NuriAppState state = NuriScope.read(context);
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Keluar dari Akun Bunda?'),
        content: const Text(
          'Anda dapat masuk kembali kapan saja dengan akun yang sama.',
        ),
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

  Future<void> _confirmDelete(BuildContext context, Child child) async {
    final NuriAppState state = NuriScope.read(context);
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text('Hapus data ${child.nickname}?'),
        content: const Text(
          'Riwayat pengukuran anak akan disembunyikan dari daftar. '
          'Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    state.deleteChild(child.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data ${child.nickname} dihapus.')),
      );
    }
  }
}

// ---------------------------------------------------------------------------
// Bagian lokal.
// ---------------------------------------------------------------------------

class _ChildProfileCard extends StatelessWidget {
  const _ChildProfileCard({
    required this.child,
    required this.today,
    required this.onDelete,
  });

  final Child child;
  final DateTime today;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return NuriCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NuriAvatar(
                initials: _initials(child.nickname),
                size: 48,
                background: AppColors.pastelBlue,
                color: AppColors.ink,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.nickname,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.h3,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${child.ageLabelAt(today)} • '
                      '${_formatDate(child.birthDate)}',
                      style: AppText.caption,
                    ),
                  ],
                ),
              ),
              Tag(
                text: child.sex.label,
                color: child.sex.label == 'Perempuan'
                    ? AppColors.pastelPurple
                    : AppColors.pastelBlue,
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.statusPendek,
                ),
                tooltip: 'Hapus anak',
              ),
            ],
          ),
          const SizedBox(height: 12),
          NoteRow(
            icon: Icons.location_on_outlined,
            text: child.posyanduName ?? 'Posyandu Melati RW 04',
          ),
        ],
      ),
    );
  }
}

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

String _formatDate(DateTime date) =>
    '${date.day} ${_bulan[date.month - 1]} ${date.year}';
