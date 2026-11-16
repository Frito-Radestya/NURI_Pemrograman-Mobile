import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import '../mother/growth_screens.dart';

class ScanManualCodeSheet extends StatefulWidget {
  const ScanManualCodeSheet({super.key});

  @override
  State<ScanManualCodeSheet> createState() => _ScanManualCodeSheetState();
}

class _ScanManualCodeSheetState extends State<ScanManualCodeSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Masukkan Kode Keluarga',
            style: Theme.of(context).textTheme.titleLarge,
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
            controller: _controller,
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
            onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          ),
        ],
      ),
    );
  }
}

class ScanFoundSheet extends StatelessWidget {
  const ScanFoundSheet({
    super.key,
    required this.childId,
    required this.name,
    required this.meta,
    this.entry,
    this.scopes = const ['ukur'],
  });

  final String childId;
  final String name;
  final String meta;
  final RosterEntry? entry;
  final List<String> scopes;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Akses ukur aktif untuk sesi ini.',
                      style: TextStyle(fontSize: 12.5, color: AppColors.muted),
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
                AppAvatar(name: name, index: entry?.avatarIndex ?? 1, size: 48),
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
                            if (entry!.category != null)
                              GrowthStatusBadge(
                                category: entry!.category!,
                                compact: true,
                              ),
                            const SizedBox(width: 5),
                            SyncBadge(pending: entry!.pendingSync),
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
              Navigator.of(context).pop();
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
          ),
        ],
      ),
    );
  }
}
