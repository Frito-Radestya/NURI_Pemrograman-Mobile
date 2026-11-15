import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import '../mother/growth_screens.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _line;
  MobileScannerController? _scannerController;
  bool _scanning = false;
  bool _torchOn = false;

  @override
  void initState() {
    super.initState();
    _line = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _line.dispose();
    _scannerController?.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(String rawCode) async {
    if (_scanning) return;
    final code = rawCode.trim();
    if (code.isEmpty) return;

    HapticFeedback.mediumImpact();
    setState(() => _scanning = true);

    // 1. Coba verifikasi kode keluarga lewat link_code grant
    final (grant, linkedChild, error) = await ref
        .read(appControllerProvider.notifier)
        .redeemFamilyLinkCode(code);

    if (!mounted) return;

    if (grant != null) {
      setState(() => _scanning = false);
      await _showFound(
        childId: grant.subjectId ?? 'c_sample',
        rosterId: 'r_${grant.subjectId}',
        name: grant.subjectName,
        meta: linkedChild != null
            ? '${linkedChild.ageLabel(DateTime.now())} • ${linkedChild.sex.label}'
            : 'Terhubung via QR NURI',
        scopes: grant.scopes,
      );
      return;
    }

    // 2. Cek apakah cocok dengan sasaran di roster lokal berdasarkan ID, NIK, atau nama
    final state = ref.read(appControllerProvider);
    final upper = code.toUpperCase();
    RosterEntry? matched;
    for (final entry in state.roster) {
      if (entry.id.toUpperCase() == upper ||
          (entry.subjectId != null &&
              entry.subjectId!.toUpperCase() == upper) ||
          entry.name.toUpperCase().contains(upper)) {
        matched = entry;
        break;
      }
    }

    setState(() => _scanning = false);

    if (matched != null) {
      await _showFound(
        childId: matched.subjectId ?? matched.id,
        rosterId: matched.id,
        name: matched.name,
        meta: '${matched.ageMonths ?? 0} bulan • KMS Terdaftar',
      );
      return;
    }

    // 3. Fallback demo
    if (upper.contains('KENZO')) {
      await _showFound(
        childId: 'c_kenzo',
        rosterId: 'r_kenzo',
        name: 'Kenzo Al-Ghifari',
        meta: '14 bulan • Laki-laki',
      );
      return;
    }

    showNuriSnack(
      context,
      error ?? 'QR Code "$code" tidak ditemukan atau tidak valid.',
      error: true,
    );
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
              'Masukkan Kode Keluarga',
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
            const SizedBox(height: 3),
            const Text(
              'Masukkan token sekali pakai (contoh: NR-XXXX-XXXX) yang ditampilkan pada layar Profil Ibu.',
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
                hintText: 'NR-XXXX-XXXX',
                prefixIcon: Icon(Icons.key_rounded, size: 20),
              ),
            ),
            const SizedBox(height: 14),
            NuriButton(
              label: 'Verifikasi Kode',
              icon: Icons.verified_outlined,
              onPressed: () =>
                  Navigator.of(sheetContext).pop(controller.text.trim()),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (!mounted || code == null || code.isEmpty) return;

    final (grant, linkedChild, error) = await ref
        .read(appControllerProvider.notifier)
        .redeemFamilyLinkCode(code);
    if (!mounted) return;
    if (grant != null) {
      await _showFound(
        childId: grant.subjectId ?? 'c_rafi',
        rosterId: 'r_${grant.subjectId}',
        name: grant.subjectName,
        meta: linkedChild != null
            ? '${linkedChild.ageLabel(DateTime.now())} • ${linkedChild.sex.label}'
            : 'Terhubung dengan izin ibu',
        scopes: grant.scopes,
      );
      return;
    }

    // Fallback untuk akun demo pengembang bila mencoba kode cepat
    final isDemo = ref.read(appControllerProvider).currentUser?.demo == true;
    final upper = code.toUpperCase();
    if (isDemo && upper.contains('KENZO')) {
      await _showFound(
        childId: 'c_kenzo',
        rosterId: 'r_kenzo',
        name: 'Kenzo Al-Ghifari',
        meta: '14 bulan • Laki-laki',
      );
    } else if (isDemo && upper.contains('RAFI')) {
      await _showFound(
        childId: 'c_rafi',
        rosterId: 'r_rafi',
        name: 'Rafi Ahmad',
        meta: '18 bulan • Laki-laki',
      );
    } else {
      showNuriSnack(
        context,
        error ?? 'Kode tidak ditemukan atau sudah kedaluwarsa.',
        error: true,
      );
    }
  }

  Future<void> _showFound({
    required String childId,
    required String rosterId,
    required String name,
    required String meta,
    List<String> scopes = const ['ukur'],
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
            InfoBanner(
              title: 'Cakupan akses: ${scopes.join(", ")}',
              body: scopes.contains('makan')
                  ? 'Ibu memberikan izin pencatatan pengukuran dan pembacaan diary makan anak.'
                  : 'Kader dapat menambah pengukuran. Catatan makan belum diizinkan oleh Ibu.',
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
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: const Text('Batal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final waitingCount = state.roster
        .where((r) => r.attendance == AttendanceStatus.waiting)
        .length;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // Top Curved Organic Header (Inspired by UI_UX/nuri_scan_qr_sasaran_kader)
            CurvedHeader(
              borderRadius: 32,
              padding: EdgeInsets.fromLTRB(
                20,
                MediaQuery.paddingOf(context).top + 8,
                20,
                20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.pill),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: AppColors.secondaryFixed,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Mode Posyandu Online',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              await _scannerController?.toggleTorch();
                              setState(() => _torchOn = !_torchOn);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _torchOn
                                    ? AppColors.secondaryFixed
                                    : Colors.black.withValues(alpha: 0.2),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _torchOn
                                        ? Icons.flashlight_on_rounded
                                        : Icons.flashlight_off_rounded,
                                    size: 14,
                                    color: _torchOn
                                        ? AppColors.primary
                                        : Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _torchOn ? 'Lampu On' : 'Lampu Off',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: _torchOn
                                          ? AppColors.primary
                                          : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.2),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.pill),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.fact_check_outlined,
                                  size: 14,
                                  color: AppColors.secondaryFixed,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Antrean: $waitingCount',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Pindai Sasaran Posyandu',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Verifikasi identitas balita & ibu hamil via QR NURI atau kartu fisik KMS',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.5,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: AspectRatio(
                  aspectRatio: 1.1,
                  child: AppCard(
                    padding: const EdgeInsets.all(8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: MobileScanner(
                            controller: _scannerController,
                            onDetect: (capture) {
                              for (final barcode in capture.barcodes) {
                                final val = barcode.rawValue;
                                if (val != null && val.isNotEmpty) {
                                  _handleBarcode(val);
                                  break;
                                }
                              }
                            },
                            errorBuilder: (context, error) {
                              return Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF1E293B),
                                      Color(0xFF0F172A),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.qr_code_2_rounded,
                                    size: 110,
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const _ScannerCorners(),
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: AnimatedBuilder(
                              animation: _line,
                              builder: (context, child) => Align(
                                alignment: Alignment(
                                  0,
                                  _line.value * 1.7 - 0.85,
                                ),
                                child: Container(
                                  height: 3,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                  ),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.transparent,
                                        AppColors.secondaryFixed,
                                        Colors.transparent,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.secondaryFixed,
                                        blurRadius: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 14,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.pill),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.secondaryFixed,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _scanning ? 'Membaca kode…' : 'Mendeteksi QR…',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (_scanning)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(22),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.secondaryFixed,
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
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.center_focus_strong_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Arahkan kamera ke QR Code di ponsel Ibu atau lembar buku KMS sasaran.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    NuriButton(
                      label: _scanning ? 'Memindai…' : 'Simulasikan Pindai QR',
                      icon: Icons.qr_code_scanner_rounded,
                      loading: _scanning,
                      onPressed: _simulate,
                    ),
                    const SizedBox(height: 8),
                    NuriButton(
                      label: 'Masukkan Kode Manual',
                      icon: Icons.keyboard_alt_outlined,
                      variant: NuriButtonVariant.outlined,
                      onPressed: _scanning ? null : _manualCode,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerCorners extends StatelessWidget {
  const _ScannerCorners();

  @override
  Widget build(BuildContext context) {
    const color = AppColors.secondaryFixed;
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
