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
import '../consultation/consultation_screen.dart';
import '../mother/pregnancy_screens.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final user = state.currentUser;
    if (user == null) {
      return const SafeArea(
        child: EmptyState(
          title: 'Belum masuk',
          icon: Icons.person_outline_rounded,
        ),
      );
    }
    final isCadre = state.isCadre;
    final pregnancy = state.activePregnancy;
    final child = state.activeChild;
    final grants = state.accessGrants
        .where((g) => g.ownerUid == user.id)
        .toList();

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NuriPageHeader(
              title: 'Profil',
              subtitle: 'Akun, keluarga, dan pengaturan privasi.',
              trailing: Pill(
                label: user.role.label,
                icon: isCadre ? Icons.groups_rounded : Icons.favorite_rounded,
                background: AppColors.softMint,
                foreground: AppColors.deepForest,
                fontSize: 11.5,
                bold: true,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _ProfileCard(
                user: user,
                onEdit: () => _editName(context, ref, user),
              ),
            ),
            if (!isCadre) ...[
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(
                  title: 'Keluarga',
                  subtitle: 'Pilih anak untuk beranda dan grafik',
                  actionLabel: 'Tambah',
                  onAction: () => _addChild(context, ref),
                ),
              ),
              const SizedBox(height: 10),
              if (state.myChildren.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: InfoBanner(
                    title: 'Belum ada data anak',
                    body: 'Tambahkan data anak untuk mulai memantau tumbuh kembang.',
                    icon: Icons.child_care_rounded,
                  ),
                )
              else
                ...state.myChildren.map(
                  (item) => Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                    child: _ChildRow(
                      child: item,
                      selected: item.id == child?.id,
                      onTap: () {
                        ref
                            .read(appControllerProvider.notifier)
                            .selectChild(item.id);
                        showNuriSnack(
                          context,
                          'Beranda sekarang menampilkan ${item.nickname}.',
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _PregnancyCard(
                  pregnancy: pregnancy,
                  onAdd: () => _addPregnancy(context, ref),
                  onTtd: () => _push(context, const TtdScreen()),
                  onAnc: () => _push(context, const AncScreen()),
                  onCheckup: () =>
                      _push(context, const PregnancyCheckupScreen()),
                  onBirth: () => _push(context, const GiveBirthScreen()),
                  onEnd: () async {
                    final ok = await showNuriConfirm(
                      context: context,
                      title: 'Akhiri kehamilan?',
                      message: 'Data kehamilan tetap tersimpan sebagai riwayat. Kamu dapat menambahkan kehamilan baru kapan saja.',
                      confirmLabel: 'Akhiri',
                      danger: true,
                    );
                    if (!ok) return;
                    ref.read(appControllerProvider.notifier).endPregnancy();
                    if (context.mounted) {
                      showNuriSnack(context, 'Kehamilan ditandai berakhir.');
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _FamilyCodeCard(
                  child: child,
                  pregnancy: pregnancy,
                  onShow: () => _showFamilyCode(context, ref, child, pregnancy),
                  onClaim: () => _claimChildFromPosyandu(context, ref),
                ),
              ),
            ] else ...[
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(
                  title: 'Posyandu',
                  actionLabel: 'Ubah',
                  onAction: () => _editPosyandu(context, ref, state),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _PosyanduCard(
                  name: state.posyanduName,
                  area: state.posyanduArea,
                  target: state.myRoster.length,
                  onQr: () => _showPosyanduCode(context, state),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _SyncCard(
                  pending: state.pendingWrites,
                  lastSyncAt: state.lastSyncAt,
                  onSync: () async {
                    final ok = await ref
                        .read(appControllerProvider.notifier)
                        .syncNow();
                    if (!context.mounted) return;
                    showNuriSnack(
                      context,
                      ok
                          ? 'Semua data tersinkron.'
                          : 'Sinkronisasi gagal. Periksa koneksi internet.',
                      error: !ok,
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 22),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SectionHeader(title: 'Privasi & pengaturan'),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _PrivacyCard(
                grants: grants,
                onRevoke: (grant) async {
                  final ok = await showNuriConfirm(
                    context: context,
                    title: 'Cabut akses?',
                    message:
                        '${grant.granteeName} tidak lagi dapat melihat atau menambah data ${grant.subjectName}.',
                    confirmLabel: 'Cabut akses',
                    danger: true,
                  );
                  if (!ok) return;
                  ref
                      .read(appControllerProvider.notifier)
                      .revokeGrant(grant.id);
                  if (context.mounted) {
                    showNuriSnack(
                      context,
                      'Akses ${grant.granteeName} dicabut.',
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: state.remindersEnabled,
                      onChanged: (_) {
                        ref
                            .read(appControllerProvider.notifier)
                            .toggleReminders();
                        showNuriSnack(
                          context,
                          state.remindersEnabled
                              ? 'Pengingat dimatikan.'
                              : 'Pengingat diaktifkan.',
                        );
                      },
                      secondary: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.primary,
                      ),
                      title: const Text(
                        'Pengingat lokal',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        'TTD, ANC, ukur bulanan, dan jadwal Posyandu.',
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.medical_services_outlined,
                        color: AppColors.primary,
                      ),
                      title: const Text(
                        'Konsultasi Bidan & Nakes',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        'Daftar bidan dan perawat yang siap mendampingi.',
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: AppColors.muted,
                      ),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ConsultationScreen(),
                        ),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.verified_user_outlined,
                        color: AppColors.primary,
                      ),
                      title: const Text(
                        'Disclaimer skrining',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        'Baca ulang batas penggunaan NURI.',
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: AppColors.muted,
                      ),
                      onTap: () => _showAbout(context),
                    ),
                    const Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.primary,
                      ),
                      title: const Text(
                        'Tentang NURI',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        'Versi demo 0.2 • sumber data & lisensi.',
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: AppColors.muted,
                      ),
                      onTap: () => _showAbout(context),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final ok = await showNuriConfirm(
                          context: context,
                          title: 'Reset akun?',
                          message: 'Semua perubahan data pada akun ini akan dikembalikan ke kondisi awal. Tindakan ini tidak dapat dibatalkan.',
                          confirmLabel: 'Reset akun',
                          danger: true,
                        );
                        if (!ok) return;
                        ref.read(appControllerProvider.notifier).resetDemo();
                        if (context.mounted) {
                          showNuriSnack(
                            context,
                            'Data akun berhasil direset ke kondisi awal.',
                          );
                        }
                      },
                      icon: const Icon(Icons.restart_alt_rounded, size: 18),
                      label: const Text('Reset akun'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final ok = await showNuriConfirm(
                          context: context,
                          title: 'Keluar dari akun?',
                          message: 'Data tetap tersimpan di perangkat. Kamu dapat masuk kembali kapan saja.',
                          confirmLabel: 'Keluar',
                          danger: true,
                        );
                        if (!ok) return;
                        ref.read(appControllerProvider.notifier).logout();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.red,
                      ),
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text('Keluar'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: NuriDisclaimer(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editName(
    BuildContext context,
    WidgetRef ref,
    AppUser user,
  ) async {
    final controller = TextEditingController(text: user.name);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ubah nama'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Nama lengkap'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null || result.length < 2) return;
    ref.read(appControllerProvider.notifier).updateProfile(name: result);
    if (context.mounted) showNuriSnack(context, 'Nama diperbarui.');
  }

  Future<void> _addChild(BuildContext context, WidgetRef ref) async {
    await showNuriSheet<void>(
      context: context,
      builder: (_) => const _AddChildSheet(),
    );
  }

  Future<void> _addPregnancy(BuildContext context, WidgetRef ref) async {
    await showNuriSheet<void>(
      context: context,
      builder: (_) => const _AddPregnancySheet(),
    );
  }

  Future<void> _editPosyandu(
    BuildContext context,
    WidgetRef ref,
    AppState state,
  ) async {
    final name = TextEditingController(text: state.posyanduName);
    final area = TextEditingController(text: state.posyanduArea);
    final saved = await showNuriSheet<bool>(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ubah Posyandu',
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
            const SizedBox(height: 14),
            NuriTextField(label: 'Nama Posyandu', controller: name),
            const SizedBox(height: 14),
            NuriTextField(label: 'Wilayah', controller: area),
            const SizedBox(height: 16),
            NuriButton(
              label: 'Simpan',
              icon: Icons.check_rounded,
              onPressed: () => Navigator.of(sheetContext).pop(true),
            ),
          ],
        ),
      ),
    );
    if (saved == true) {
      ref
          .read(appControllerProvider.notifier)
          .setPosyandu(name: name.text, area: area.text);
      if (context.mounted) showNuriSnack(context, 'Data Posyandu diperbarui.');
    }
    name.dispose();
    area.dispose();
  }

  Future<void> _showFamilyCode(
    BuildContext context,
    WidgetRef ref,
    Child? child,
    Pregnancy? pregnancy,
  ) async {
    final subjectId = child?.id ?? pregnancy?.id;
    final subjectName =
        child?.nickname ?? (pregnancy != null ? 'Kehamilan' : null);
    if (subjectId == null || subjectName == null) {
      showNuriSnack(
        context,
        'Tambahkan profil anak atau kehamilan terlebih dahulu untuk membuat Kode Keluarga.',
        error: true,
      );
      return;
    }
    await showNuriSheet<void>(
      context: context,
      builder: (_) => _FamilyCodeGeneratorSheet(
        subjectId: subjectId,
        subjectName: subjectName,
      ),
    );
  }

  Future<void> _claimChildFromPosyandu(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final controller = TextEditingController();
    final code = await showNuriSheet<String>(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Klaim Data Anak Posyandu',
              style: Theme.of(sheetContext).textTheme.titleLarge,
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
              controller: controller,
              hint: 'KL-XXXX-XXXX',
              prefixIcon: Icons.vpn_key_outlined,
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 16),
            NuriButton(
              label: 'Verifikasi & Klaim',
              icon: Icons.verified_outlined,
              onPressed: () =>
                  Navigator.of(sheetContext).pop(controller.text.trim()),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (!context.mounted || code == null || code.isEmpty) return;
    final (claimed, error) = await ref
        .read(appControllerProvider.notifier)
        .redeemChildClaimCode(code);
    if (!context.mounted) return;
    if (error != null) {
      showNuriSnack(context, error, error: true);
      return;
    }
    showNuriSnack(
      context,
      'Profil ${claimed?.nickname ?? "anak"} beserta riwayat pengukurannya berhasil terhubung ke akun Ibu!',
    );
  }

  Future<void> _showPosyanduCode(BuildContext context, AppState state) async {
    await showNuriSheet<void>(
      context: context,
      builder: (sheetContext) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          children: [
            Text(
              'Kode Posyandu',
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              state.posyanduName,
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
              onPressed: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAbout(BuildContext context) async {
    await showNuriSheet<void>(
      context: context,
      builder: (sheetContext) => SingleChildScrollView(
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
              style: Theme.of(sheetContext).textTheme.titleLarge,
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
              onPressed: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user, required this.onEdit});

  final AppUser user;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      shadow: true,
      child: Row(
        children: [
          AppAvatar(
            name: user.name,
            index: user.role == UserRole.cadre ? 7 : 0,
            imageAsset: user.avatarAsset,
            size: 54,
            showBadge: true,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.muted,
                  ),
                ),
                if (user.authUid != null) ...[
                  const SizedBox(height: 6),
                  const Pill(
                    label: 'Firebase Auth',
                    icon: Icons.verified_user_outlined,
                    fontSize: 11,
                    background: AppColors.softMint,
                    foreground: AppColors.deepForest,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(
              Icons.edit_outlined,
              size: 20,
              color: AppColors.deepForest,
            ),
            tooltip: 'Ubah nama',
          ),
        ],
      ),
    );
  }
}

class _ChildRow extends StatelessWidget {
  const _ChildRow({
    required this.child,
    required this.selected,
    required this.onTap,
  });

  final Child child;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final latest = child.latestMeasurement;
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      borderColor: selected ? AppColors.primary : AppColors.line,
      child: Row(
        children: [
          AppAvatar(name: child.nickname, index: child.avatarIndex, size: 42),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        child.nickname,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (selected) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${child.ageLabel()} • ${child.sex.label} • ${child.measurements.length} pengukuran',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          if (latest != null)
            GrowthStatusBadge(category: latest.category, compact: true),
        ],
      ),
    );
  }
}

class _PregnancyCard extends StatelessWidget {
  const _PregnancyCard({
    required this.pregnancy,
    required this.onAdd,
    required this.onTtd,
    required this.onAnc,
    required this.onCheckup,
    required this.onBirth,
    required this.onEnd,
  });

  final Pregnancy? pregnancy;
  final VoidCallback onAdd;
  final VoidCallback onTtd;
  final VoidCallback onAnc;
  final VoidCallback onCheckup;
  final VoidCallback onBirth;
  final VoidCallback onEnd;

  @override
  Widget build(BuildContext context) {
    if (pregnancy == null) {
      return AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.pregnant_woman_rounded,
                  size: 20,
                  color: AppColors.purple,
                ),
                SizedBox(width: 8),
                Text(
                  'Kehamilan',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Belum ada kehamilan aktif. Tambahkan HPHT untuk memantau usia kehamilan, TTD, dan ANC.',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.muted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            NuriButton(
              label: 'Tambah kehamilan',
              icon: Icons.add_rounded,
              variant: NuriButtonVariant.outlined,
              onPressed: onAdd,
            ),
          ],
        ),
      );
    }
    final active = pregnancy!;
    final progress = PregnancyCalculator.progress(
      hpht: active.hpht,
      hpl: active.hpl,
    );
    final trimester = progress.trimester;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.pregnant_woman_rounded,
                size: 20,
                color: AppColors.purple,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Kehamilan aktif',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Pill(
                label: 'Trimester $trimester',
                background: AppColors.purpleSoft,
                foreground: AppColors.purple,
                fontSize: 11,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _PregnancyStat(
                label: 'Usia',
                value: '${progress.weeks}',
                unit: 'mgg',
              ),
              _PregnancyStat(
                label: 'Hari',
                value: '${progress.days}',
                unit: 'hari',
              ),
              _PregnancyStat(
                label: 'HPL',
                value: formatDateId(
                  active.hpl,
                  withYear: false,
                  shortMonth: true,
                ),
                unit: '',
              ),
              _PregnancyStat(
                label: 'TTD',
                value: '${active.ttdCount}',
                unit: 'tab',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _PregnancyAction(
                  icon: Icons.medication_outlined,
                  label: 'TTD',
                  onTap: onTtd,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PregnancyAction(
                  icon: Icons.event_available_outlined,
                  label: 'ANC',
                  onTap: onAnc,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PregnancyAction(
                  icon: Icons.monitor_heart_outlined,
                  label: 'Periksa',
                  onTap: onCheckup,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onBirth,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                  ),
                  icon: const Icon(Icons.child_friendly_rounded, size: 17),
                  label: const Text('Lahirkan'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextButton(
                  onPressed: onEnd,
                  style: TextButton.styleFrom(foregroundColor: AppColors.muted),
                  child: const Text('Akhiri kehamilan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PregnancyStat extends StatelessWidget {
  const _PregnancyStat({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
          ),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    fontFeatures: [FontFeature.tabularFigures()],
                    color: AppColors.text,
                  ),
                ),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PregnancyAction extends StatelessWidget {
  const _PregnancyAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceSubtle,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FamilyCodeCard extends StatelessWidget {
  const _FamilyCodeCard({
    required this.child,
    required this.pregnancy,
    required this.onShow,
    required this.onClaim,
  });

  final Child? child;
  final Pregnancy? pregnancy;
  final VoidCallback onShow;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final subject =
        child?.nickname ?? (pregnancy != null ? 'Kehamilan' : 'Keluarga');
    return AppCard(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  size: 22,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Koneksi Keluarga & Posyandu',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Buat QR izin akses untuk $subject (sekali pakai, 24 jam)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: onShow,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  textStyle: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Buat QR'),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          InkWell(
            onTap: onClaim,
            borderRadius: BorderRadius.circular(10),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.vpn_key_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Punya kode klaim anak dari Kader Posyandu? Masukkan di sini',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FamilyCodeGeneratorSheet extends ConsumerStatefulWidget {
  const _FamilyCodeGeneratorSheet({
    required this.subjectId,
    required this.subjectName,
  });

  final String subjectId;
  final String subjectName;

  @override
  ConsumerState<_FamilyCodeGeneratorSheet> createState() =>
      _FamilyCodeGeneratorSheetState();
}

class _FamilyCodeGeneratorSheetState
    extends ConsumerState<_FamilyCodeGeneratorSheet> {
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

class _PosyanduCard extends StatelessWidget {
  const _PosyanduCard({
    required this.name,
    required this.area,
    required this.target,
    required this.onQr,
  });

  final String name;
  final String area;
  final int target;
  final VoidCallback onQr;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.home_work_outlined,
                  size: 21,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      area,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Pill(label: '$target sasaran', fontSize: 11.5),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onQr,
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
              icon: const Icon(Icons.qr_code_2_rounded, size: 17),
              label: const Text('Tampilkan Kode Posyandu'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncCard extends StatelessWidget {
  const _SyncCard({
    required this.pending,
    required this.lastSyncAt,
    required this.onSync,
  });

  final int pending;
  final DateTime? lastSyncAt;
  final VoidCallback onSync;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Icon(
            pending == 0
                ? Icons.cloud_done_rounded
                : Icons.cloud_upload_outlined,
            size: 24,
            color: pending == 0 ? AppColors.primary : AppColors.amber,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pending == 0
                      ? 'Semua data tersinkron'
                      : '$pending perubahan tertunda',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  lastSyncAt == null
                      ? 'Belum pernah sinkron'
                      : 'Terakhir ${formatDateId(lastSyncAt!, withYear: false)} ${formatTime(lastSyncAt!)}',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onSync,
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 38),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            child: const Text('Sinkron'),
          ),
        ],
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard({required this.grants, required this.onRevoke});

  final List<AccessGrant> grants;
  final ValueChanged<AccessGrant> onRevoke;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_outlined, size: 19, color: AppColors.primary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Akses yang kamu berikan',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Kader hanya dapat mengakses data yang diizinkan. Cabut kapan saja.',
            style: TextStyle(fontSize: 12, color: AppColors.muted, height: 1.4),
          ),
          const SizedBox(height: 10),
          if (grants.isEmpty)
            const Text(
              'Belum ada akses aktif.',
              style: TextStyle(fontSize: 12.5, color: AppColors.muted),
            )
          else
            ...grants.map(
              (grant) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              grant.granteeName,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${grant.subjectName} • ${grant.scopes.join(', ')}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (grant.status == 'aktif')
                        TextButton(
                          onPressed: () => onRevoke(grant),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.red,
                            minimumSize: const Size(0, 36),
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                          ),
                          child: const Text('Cabut'),
                        )
                      else
                        const Pill(
                          label: 'Dicabut',
                          background: AppColors.redSoft,
                          foreground: AppColors.red,
                          fontSize: 11,
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddChildSheet extends ConsumerStatefulWidget {
  const _AddChildSheet();

  @override
  ConsumerState<_AddChildSheet> createState() => _AddChildSheetState();
}

class _AddChildSheetState extends ConsumerState<_AddChildSheet> {
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

class _AddPregnancySheet extends ConsumerStatefulWidget {
  const _AddPregnancySheet();

  @override
  ConsumerState<_AddPregnancySheet> createState() => _AddPregnancySheetState();
}

class _AddPregnancySheetState extends ConsumerState<_AddPregnancySheet> {
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
