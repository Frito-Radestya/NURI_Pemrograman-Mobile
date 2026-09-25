import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../models/user_role.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;
  bool _isLoggedIn = false;
  bool _keepSignedIn = false;

  /// Password akun demo. Pada coursework ini disimpan plainly di memori.
  static const demoPassword = 'password123';

  final Map<String, _Account> _accounts = {};
  int _idCounter = 0;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get keepSignedIn => _keepSignedIn;

  void setKeepSignedIn(bool value) {
    _keepSignedIn = value;
  }

  void setCurrentUser(UserModel user) {
    _currentUser = user;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  void updateProfile({String? name, String? emailOrPhone}) {
    final current = _currentUser;
    if (current == null) return;
    setCurrentUser(
      UserModel(
        id: current.id,
        name: name?.trim().isNotEmpty == true ? name!.trim() : current.name,
        emailOrPhone: emailOrPhone?.trim().isNotEmpty == true
            ? emailOrPhone!.trim()
            : current.emailOrPhone,
        role: current.role,
        avatarUrl: current.avatarUrl,
        childName: current.childName,
        childAgeMonths: current.childAgeMonths,
        pregnancyWeeks: current.pregnancyWeeks,
        posyanduName: current.posyanduName,
      ),
    );
  }

  /// Akun demo yang tersedia untuk semua role.
  static List<UserModel> get demoUsers => [
    UserModel.demoIbuBalita(),
    UserModel.demoIbuHamil(),
    UserModel.demoKader(),
  ];

  static UserModel demoUserForRole(UserRole role) {
    return demoUsers.firstWhere((user) => user.role == role);
  }

  Future<bool> login({
    required String identifier,
    required String password,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final key = identifier.trim().toLowerCase();

    final demoUser = demoUserForRole(role);
    if (demoUser.emailOrPhone.toLowerCase() == key &&
        password == demoPassword) {
      setCurrentUser(demoUser);
      return true;
    }

    final account = _accounts[key];
    if (account != null &&
        account.user.role == role &&
        account.password == password) {
      setCurrentUser(account.user);
      return true;
    }
    return false;
  }

  Future<bool> register({
    required String name,
    required String emailOrPhone,
    required String password,
    required UserRole role,
    String? childName,
    int? childAgeMonths,
    int? pregnancyWeeks,
    String? posyanduName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final key = emailOrPhone.trim().toLowerCase();
    if (_accounts.containsKey(key) ||
        demoUsers.any((user) => user.emailOrPhone.toLowerCase() == key)) {
      return false;
    }

    _idCounter++;
    final newUser = UserModel(
      id: 'usr_reg_$_idCounter',
      name: name.trim(),
      emailOrPhone: emailOrPhone.trim(),
      role: role,
      childName: childName,
      childAgeMonths: childAgeMonths,
      pregnancyWeeks: pregnancyWeeks,
      posyanduName: posyanduName,
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&h=200&fit=crop',
    );
    _accounts[key] = _Account(user: newUser, password: password);
    setCurrentUser(newUser);
    return true;
  }

  Future<bool> sendOtp(String contact) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return contact.trim().isNotEmpty;
  }

  /// OTP demo hanya menerima kode 1234.
  Future<bool> verifyOtp(String code) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return code == '1234';
  }

  Future<bool> resetPassword({
    required String contact,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final key = contact.trim().toLowerCase();
    final account = _accounts[key];
    if (account != null) {
      _accounts[key] = _Account(user: account.user, password: newPassword);
      return true;
    }
    // Akun demo: kredensial demo tetap berlaku untuk keperluan demo.
    return demoUsers.any((user) => user.emailOrPhone.toLowerCase() == key);
  }
}

class _Account {
  final UserModel user;
  final String password;

  const _Account({required this.user, required this.password});
}
