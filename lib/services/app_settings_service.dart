import 'package:flutter/foundation.dart';

/// Pengaturan lokal aplikasi. Nilai masih in-memory untuk simulasi coursework.
class AppSettingsService extends ChangeNotifier {
  static final AppSettingsService _instance = AppSettingsService._internal();
  factory AppSettingsService() => _instance;
  AppSettingsService._internal();

  bool _dailyReminder = true;
  bool _mealReminder = true;
  bool _soundEnabled = true;
  bool _showGrowthChart = true;

  bool get dailyReminder => _dailyReminder;
  bool get mealReminder => _mealReminder;
  bool get soundEnabled => _soundEnabled;
  bool get showGrowthChart => _showGrowthChart;

  void setDailyReminder(bool value) {
    _dailyReminder = value;
    notifyListeners();
  }

  void setMealReminder(bool value) {
    _mealReminder = value;
    notifyListeners();
  }

  void setSoundEnabled(bool value) {
    _soundEnabled = value;
    notifyListeners();
  }

  void setShowGrowthChart(bool value) {
    _showGrowthChart = value;
    notifyListeners();
  }
}
