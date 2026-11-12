import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/growth/who_lms.dart';
import '../domain/models.dart';
import '../domain/nutrition/food_catalog.dart';
import 'app_repository.dart';
import 'auth_service.dart';
import 'demo_seed.dart';

export 'controllers/auth_actions.dart';
export 'controllers/cadre_actions.dart';
export 'controllers/child_actions.dart';
export 'controllers/food_actions.dart';
export 'controllers/pregnancy_actions.dart';

final localRepositoryProvider = Provider<AppRepository>(
  (ref) => throw UnimplementedError('Repository harus di-override di main().'),
);

final whoReferenceProvider = Provider<WhoReference>(
  (ref) => WhoReference.instance,
);

final foodCatalogProvider = Provider<FoodCatalog>(
  (ref) => FoodCatalog.instance,
);

final appControllerProvider = NotifierProvider<AppController, AppState>(
  () => throw UnimplementedError('AppController harus di-override di main().'),
);

/// Inti state aplikasi. Aksi fitur berada di extension terpisah agar file ini
/// tetap kecil dan mudah diuji.
class AppController extends Notifier<AppState> {
  AppController(this._initial, this._repository, {AuthService? authService})
    : _authService = authService ?? FirebaseAuthService();

  final AppState _initial;
  final AppRepository _repository;
  final AuthService _authService;

  @override
  AppState build() => _initial;

  /// Akses baca untuk extension aksi fitur. Setter tetap melalui [commitState]
  /// agar setiap perubahan tersimpan lewat satu jalur.
  AppState get currentState => state;

  AuthService get authService => _authService;

  bool get isFirebaseAuthAvailable => _authService.isAvailable;

  void commitState(AppState next) {
    state = next;
    unawaited(_repository.save(next));
  }

  Future<void> signOutAuthQuietly() async {
    if (!_authService.isAvailable) return;
    try {
      await _authService.signOut();
    } catch (error) {
      debugPrint('Firebase signOut gagal: $error');
    }
  }

  void resetDemo() {
    final seed = DemoSeed.build(who: WhoReference.instance);
    commitState(seed);
    unawaited(signOutAuthQuietly());
  }
}
