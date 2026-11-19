import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import '../consultation/consultation_screen.dart';
import '../mother/pregnancy_screens.dart';
import 'profile_cards.dart';
import 'profile_sheets.dart';

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
    final isCadre = state.isCadre || state.isAdmin;
    final pregnancy = state.activePregnancy;
    final child = state.activeChild;
    final grants = state.accessGrants
        .where((g) => g.ownerUid == user.id)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CurvedHeader(
            borderRadius: 32,
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.paddingOf(context).top + 8,
              20,
              24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCadre
                                ? Icons.badge_rounded
                                : Icons.favorite_rounded,
                            size: 13,
                            color: AppColors.secondaryFixed,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            user.role.label,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Profil & Pengaturan',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const Text(
                  'Kelola akun, data keluarga, & privasi data',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ProfileCard(
                user: user,
                onEdit: () => _editName(context, ref, user),
              ),
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
                  child: ProfileChildRow(
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
              child: ProfilePregnancyCard(
                pregnancy: pregnancy,
                onAdd: () => _addPregnancy(context, ref),
                onTtd: () => _push(context, const TtdScreen()),
                onAnc: () => _push(context, const AncScreen()),
                onCheckup: () => _push(context, const PregnancyCheckupScreen()),
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
              child: ProfileFamilyCodeCard(
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
              child: ProfilePosyanduCard(
                name: state.posyanduName,
                area: state.posyanduArea,
                target: state.myRoster.length,
                onQr: () => _showPosyanduCode(context, state),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ProfileSyncCard(
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
            child: ProfilePrivacyCard(
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
                ref.read(appControllerProvider.notifier).revokeGrant(grant.id);
                if (context.mounted) {
                  showNuriSnack(context, 'Akses ${grant.granteeName} dicabut.');
                }
              },
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ProfileSettingsCard(
              remindersEnabled: state.remindersEnabled,
              onToggleReminders: (_) {
                ref.read(appControllerProvider.notifier).toggleReminders();
                showNuriSnack(
                  context,
                  state.remindersEnabled
                      ? 'Pengingat dimatikan.'
                      : 'Pengingat diaktifkan.',
                );
              },
              onConsultation: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ConsultationScreen()),
              ),
              onDisclaimer: () => _showAbout(context),
              onAbout: () => _showAbout(context),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ProfileAccountActions(
              onReset: () async {
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
              onLogout: () async {
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
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _editName(
    BuildContext context,
    WidgetRef ref,
    AppUser user,
  ) async {
    final result = await showNuriSheet<String>(
      context: context,
      builder: (_) => EditNameSheet(initialName: user.name),
    );
    if (result == null || result.length < 2) return;
    ref.read(appControllerProvider.notifier).updateProfile(name: result);
    if (context.mounted) showNuriSnack(context, 'Nama diperbarui.');
  }

  Future<void> _addChild(BuildContext context, WidgetRef ref) async {
    await showNuriSheet<void>(
      context: context,
      builder: (_) => const AddChildSheet(),
    );
  }

  Future<void> _addPregnancy(BuildContext context, WidgetRef ref) async {
    await showNuriSheet<void>(
      context: context,
      builder: (_) => const AddPregnancySheet(),
    );
  }

  Future<void> _editPosyandu(
    BuildContext context,
    WidgetRef ref,
    AppState state,
  ) async {
    final result = await showNuriSheet<({String name, String area})>(
      context: context,
      builder: (_) => EditPosyanduSheet(
        initialName: state.posyanduName,
        initialArea: state.posyanduArea,
      ),
    );
    if (result != null) {
      ref
          .read(appControllerProvider.notifier)
          .setPosyandu(name: result.name, area: result.area);
      if (context.mounted) showNuriSnack(context, 'Data Posyandu diperbarui.');
    }
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
      builder: (_) => FamilyCodeGeneratorSheet(
        subjectId: subjectId,
        subjectName: subjectName,
      ),
    );
  }

  Future<void> _claimChildFromPosyandu(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final code = await showNuriSheet<String>(
      context: context,
      builder: (_) => const ClaimChildSheet(),
    );
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
      builder: (_) => PosyanduQrSheet(posyanduName: state.posyanduName),
    );
  }

  Future<void> _showAbout(BuildContext context) async {
    await showNuriSheet<void>(
      context: context,
      builder: (_) => const AboutNuriSheet(),
    );
  }
}
