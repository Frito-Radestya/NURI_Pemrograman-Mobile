import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import '../mother/growth_screens.dart';
import 'roster_screen.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _line;
  bool _scanning = false;

  @override
  void initState() {
    super.initState();
    _line = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _line.dispose();
    super.dispose();
  }

  Future<void> _simulate() async {
    if (_scanning) return;
    HapticFeedback.lightImpact();
    setState(() => _scanning = true);
    await Future<void>.delayed(const Duration(milliseconds: 1300));
    if (!mounted) return;
    setState(() => _scanning = false);
    await _showFound(
      childId: 'c_kenzo',
      rosterId: 'r_kenzo',
      name: 'Kenzo Al-Ghifari',
      meta: '14 bulan • Laki-laki',
    );
  }

  Future<void> _manualCode() async {
    final controller = TextEditingController(text: 'NURI-KENZO-2026');
    final code = await showNuriSheet<String>(
      context: context,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masukkan Kode Keluarga',
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
            const SizedBox(height: 3),
            const Text(
              'Kode 8–12 karakter dari layar ibu. Untuk demo, coba NURI-KENZO-2026.',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.muted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                hintText: 'NURI-XXXX-2026',
                prefixIcon: Icon(Icons.key_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 14),
            NuriButton(
              label: 'Cari kode',
              icon: Icons.search_rounded,
              onPressed: () =>
                  Navigator.of(sheetContext).pop(controller.text.trim()),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (!mounted || code == null || code.isEmpty) return;
    final upper = code.toUpperCase();
    if (upper.contains('KENZO')) {
      await _showFound(
        childId: 'c_kenzo',
        rosterId: 'r_kenzo',
        name: 'Kenzo Al-Ghifari',
        meta: '14 bulan • Laki-laki',
      );
    } else if (upper.contains('RAFI')) {
      await _showFound(
        childId: 'c_rafi',
        rosterId: 'r_rafi',
        name: 'Rafi Ahmad',
        meta: '18 bulan • Laki-laki',
      );
    } else if (upper.contains('MAYA')) {
      await _showFound(
        childId: 'c_maya',
        rosterId: 'r_maya',
        name: 'Maya Clarissa',
        meta: '22 bulan • Perempuan',
      );
    } else {
      showNuriSnack(
        context,
        'Kode tidak ditemukan atau sudah kedaluwarsa.',
        error: true,
      );
    }
  }

  Future<void> _showFound({
    required String childId,
    required String rosterId,
    required String name,
    required String meta,
  }) async {
    final state = ref.read(appControllerProvider);
    RosterEntry? entry;
    for (final item in state.roster) {
      if (item.id == rosterId) {
        entry = item;
        break;
      }
    }
    await showNuriSheet<void>(
      context: context,
      builder: (sheetContext) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: AppColors.mint,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.primary,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kode keluarga ditemukan',
                        style: Theme.of(sheetContext).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Akses ukur aktif untuk sesi ini.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  AppAvatar(
                    name: name,
                    index: entry?.avatarIndex ?? 1,
                    size: 48,
                  ),
                  const SizedBox(width: 11),
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
                          meta,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                        if (entry != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (entry.category != null)
                                GrowthStatusBadge(
                                  category: entry.category!,
                                  compact: true,
                                ),
                              const SizedBox(width: 5),
                              SyncBadge(pending: entry.pendingSync),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const InfoBanner(
              title: 'Cakupan akses: ukur',
              body: 'Kader dapat menambah pengukuran. Catatan makan hanya terbuka bila ibu memberi izin terpisah.',
              icon: Icons.verified_user_outlined,
            ),
            const SizedBox(height: 14),
            NuriButton(
              label: 'Ukur sekarang',
              icon: Icons.straighten_rounded,
              onPressed: () {
                Navigator.of(sheetContext).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        MeasurementInputScreen(childId: childId, isCadre: true),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (entry != null) {
                        ref
                            .read(appControllerProvider.notifier)
                            .markAttendance(entry.id, AttendanceStatus.present);
                      }
                      Navigator.of(sheetContext).pop();
                      showNuriSnack(context, '$name ditandai hadir di sesi.');
                    },
                    icon: const Icon(Icons.how_to_reg_rounded, size: 17),
                    label: const Text(
                      'Tandai hadir',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RosterScreen(embedded: false),
                        ),
                      );
                    },
                    icon: const Icon(Icons.groups_rounded, size: 17),
                    label: const Text(
                      'Daftar sasaran',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF07231E),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Pindai Kode Keluarga',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.flash_on_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _scanning
                    ? 'Membaca kode…'
                    : 'Arahkan kamera ke QR Kode Keluarga ibu',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.72),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: AspectRatio(
                      aspectRatio: 0.92,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF123F36), Color(0xFF0A2C25)],
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Center(
                              child: Icon(
                                Icons.qr_code_2_rounded,
                                size: 118,
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                          ),
                          const _ScannerCorners(),
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: AnimatedBuilder(
                                animation: _line,
                                builder: (context, child) => Align(
                                  alignment: Alignment(
                                    0,
                                    _line.value * 1.7 - 0.85,
                                  ),
                                  child: Container(
                                    height: 2,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 30,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          AppColors.peach.withValues(
                                            alpha: 0.9,
                                          ),
                                          Colors.transparent,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.peach.withValues(
                                            alpha: 0.35,
                                          ),
                                          blurRadius: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (_scanning)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF07231E)
                                      .withValues(alpha: 0.55),
                                  borderRadius: BorderRadius.circular(28),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.peach,
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            color: AppColors.mint,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.schedule_rounded,
                            size: 17,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 9),
                        const Expanded(
                          child: Text(
                            'Kode berlaku 24 jam • akses ukur saja',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 13),
                    NuriButton(
                      label: _scanning ? 'Memindai…' : 'Simulasikan pindai QR',
                      icon: Icons.qr_code_scanner_rounded,
                      loading: _scanning,
                      onPressed: _simulate,
                    ),
                    const SizedBox(height: 8),
                    NuriButton(
                      label: 'Masukkan kode manual',
                      icon: Icons.keyboard_alt_outlined,
                      variant: NuriButtonVariant.outlined,
                      onPressed: _scanning ? null : _manualCode,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Demo: hasil pindai menampilkan Kenzo Al-Ghifari dari roster.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScannerCorners extends StatelessWidget {
  const _ScannerCorners();

  @override
  Widget build(BuildContext context) {
    const color = AppColors.peach;
    return Stack(
      children: const [
        Positioned(
          top: 22,
          left: 22,
          child: _Corner(color: color, top: true, left: true),
        ),
        Positioned(
          top: 22,
          right: 22,
          child: _Corner(color: color, top: true, left: false),
        ),
        Positioned(
          bottom: 22,
          left: 22,
          child: _Corner(color: color, top: false, left: true),
        ),
        Positioned(
          bottom: 22,
          right: 22,
          child: _Corner(color: color, top: false, left: false),
        ),
      ],
    );
  }
}

class _Corner extends StatelessWidget {
  const _Corner({required this.color, required this.top, required this.left});

  final Color color;
  final bool top;
  final bool left;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        border: Border(
          top: top ? BorderSide(color: color, width: 3) : BorderSide.none,
          bottom: !top ? BorderSide(color: color, width: 3) : BorderSide.none,
          left: left ? BorderSide(color: color, width: 3) : BorderSide.none,
          right: !left ? BorderSide(color: color, width: 3) : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: top && left ? const Radius.circular(12) : Radius.zero,
          topRight: top && !left ? const Radius.circular(12) : Radius.zero,
          bottomLeft: !top && left ? const Radius.circular(12) : Radius.zero,
          bottomRight: !top && !left ? const Radius.circular(12) : Radius.zero,
        ),
      ),
    );
  }
}
