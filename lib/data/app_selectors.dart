import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models.dart';
import 'app_controller.dart';

/// Selector turunan agar layar hanya dibangun ulang saat potongan state yang
/// benar-benar dipakai berubah.
final currentUserProvider = Provider<AppUser?>(
  (ref) =>
      ref.watch(appControllerProvider.select((state) => state.currentUser)),
);

final activePregnancyProvider = Provider<Pregnancy?>(
  (ref) =>
      ref.watch(appControllerProvider.select((state) => state.activePregnancy)),
);

final activeChildProvider = Provider<Child?>(
  (ref) =>
      ref.watch(appControllerProvider.select((state) => state.activeChild)),
);

final pregnancyContextProvider = Provider<bool>(
  (ref) => ref.watch(
    appControllerProvider.select((state) => state.pregnancyContext),
  ),
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

final nextPosyanduDateProvider = Provider<DateTime?>(
  (ref) => ref.watch(
    appControllerProvider.select((state) => state.nextPosyanduDate),
  ),
);

final contentsProvider = Provider<List<ContentArticle>>(
  (ref) => ref.watch(appControllerProvider.select((state) => state.contents)),
);
