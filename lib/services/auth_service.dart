import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/user_role.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser = UserModel.demoIbuBalita();
  bool _isLoggedIn = true;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

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

  Future<bool> login({
    required String identifier,
    required String password,
    required UserRole role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    UserModel user;
    switch (role) {
      case UserRole.ibuBalita:
        user = UserModel(
          id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
          name: identifier.contains('@')
              ? identifier.split('@').first
              : identifier,
          emailOrPhone: identifier,
          role: role,
          childName: 'Ahmad',
          childAgeMonths: 14,
          avatarUrl:
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&h=200&fit=crop',
        );
        break;
      case UserRole.ibuHamil:
        user = UserModel(
          id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
          name: identifier.contains('@')
              ? identifier.split('@').first
              : identifier,
          emailOrPhone: identifier,
          role: role,
          pregnancyWeeks: 20,
          avatarUrl:
              'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&h=200&fit=crop',
        );
        break;
      case UserRole.kaderPosyandu:
        user = UserModel(
          id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
          name: identifier.contains('@')
              ? identifier.split('@').first
              : identifier,
          emailOrPhone: identifier,
          role: role,
          posyanduName: 'Posyandu Melati',
          avatarUrl:
              'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=200&h=200&fit=crop',
        );
        break;
    }
    setCurrentUser(user);
    return true;
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
    await Future.delayed(const Duration(milliseconds: 1000));
    final newUser = UserModel(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      emailOrPhone: emailOrPhone,
      role: role,
      childName: childName,
      childAgeMonths: childAgeMonths,
      pregnancyWeeks: pregnancyWeeks,
      posyanduName: posyanduName,
      avatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&h=200&fit=crop',
    );
    setCurrentUser(newUser);
    return true;
  }

  Future<bool> sendOtp(String contact) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return true;
  }

  Future<bool> verifyOtp(String code) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return code == '1234' || code.length == 4;
  }

  Future<bool> resetPassword(String newPassword) async {
    await Future.delayed(const Duration(milliseconds: 900));
    return true;
  }
}
