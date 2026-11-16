import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models.dart';
import 'app_controller.dart';

/// Selector turunan agar layar hanya dibangun ulang saat potongan state yang
/// benar-benar dipakai berubah.
final currentUserProvider = Provider<AppUser?>(
  (ref) =>
      ref.watch(appControllerProvider.select((state) => state.currentUser)),
);

final rosterProvider = Provider<List<RosterEntry>>(
  (ref) => ref.watch(appControllerProvider.select((state) => state.myRoster)),
);

final activeSessionProvider = Provider<PosyanduSession?>(
  (ref) =>
      ref.watch(appControllerProvider.select((state) => state.activeSession)),
);

final pendingWritesProvider = Provider<int>(
  (ref) =>
      ref.watch(appControllerProvider.select((state) => state.pendingWrites)),
);

final posyanduNameProvider = Provider<String>(
  (ref) =>
      ref.watch(appControllerProvider.select((state) => state.posyanduName)),
);

