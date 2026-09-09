import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:masbhty/core/models/dhikr_model.dart';
import 'package:masbhty/core/models/counter_session.dart';
import 'package:masbhty/core/models/theme_mode_enum.dart';
import 'package:masbhty/core/constants/default_azkar.dart';

class StorageService {
  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // --- Dhikr Azkar Persistence ---
  List<DhikrModel> getAzkar() {
    final String? azkarJson = _prefs.getString('azkar_list');
    if (azkarJson == null) {
      // Initialize with default azkar
      final defaultList = DefaultAzkar.list;
      saveAzkar(defaultList);
      return defaultList;
    }
    try {
      final List<dynamic> decoded = json.decode(azkarJson);
      return decoded.map((e) => DhikrModel.fromMap(e)).toList();
    } catch (_) {
      return DefaultAzkar.list;
    }
  }

  Future<void> saveAzkar(List<DhikrModel> list) async {
    final String encoded = json.encode(list.map((e) => e.toMap()).toList());
    await _prefs.setString('azkar_list', encoded);
  }

  Future<void> addCustomDhikr(DhikrModel dhikr) async {
    final list = getAzkar();
    list.add(dhikr);
    await saveAzkar(list);
  }

  Future<void> updateDhikr(DhikrModel updated) async {
    final list = getAzkar();
    final index = list.indexWhere((element) => element.id == updated.id);
    if (index != -1) {
      list[index] = updated;
      await saveAzkar(list);
    }
  }

  Future<void> deleteDhikr(String id) async {
    final list = getAzkar();
    list.removeWhere((element) => element.id == id);
    await saveAzkar(list);
  }

  // --- Selected Dhikr ---
  String getSelectedDhikrId() {
    return _prefs.getString('selected_dhikr_id') ?? 'subhanallah';
  }

  Future<void> setSelectedDhikrId(String id) async {
    await _prefs.setString('selected_dhikr_id', id);
  }

  // --- Session Analytics Logs ---
  List<CounterSession> getSessions() {
    final String? sessionsJson = _prefs.getString('counter_sessions');
    if (sessionsJson == null) return [];
    try {
      final List<dynamic> decoded = json.decode(sessionsJson);
      return decoded.map((e) => CounterSession.fromMap(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSessions(List<CounterSession> list) async {
    final String encoded = json.encode(list.map((e) => e.toMap()).toList());
    await _prefs.setString('counter_sessions', encoded);
  }

  Future<void> addSession(CounterSession session) async {
    final list = getSessions();
    list.add(session);
    await saveSessions(list);
    await updateStreaks();
  }

  // --- Streaks Logic ---
  int getStreakCount() {
    return _prefs.getInt('streak_count') ?? 0;
  }

  String getLastActiveDate() {
    return _prefs.getString('last_active_date') ?? '';
  }

  Future<void> updateStreaks() async {
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final lastActive = getLastActiveDate();

    if (lastActive.isEmpty) {
      await _prefs.setInt('streak_count', 1);
      await _prefs.setString('last_active_date', todayStr);
      return;
    }

    if (lastActive == todayStr) {
      return; // Already active today, streak safe
    }

    final lastDate = DateTime.parse(lastActive);
    final todayDate = DateTime.parse(todayStr);
    final diff = todayDate.difference(lastDate).inDays;

    if (diff == 1) {
      // Consecutive day!
      final currentStreak = getStreakCount();
      await _prefs.setInt('streak_count', currentStreak + 1);
    } else if (diff > 1) {
      // Streak broken
      await _prefs.setInt('streak_count', 1);
    }
    await _prefs.setString('last_active_date', todayStr);
  }

  // --- App Settings ---
  bool isDarkTheme() => _prefs.getBool('is_dark_theme') ?? true;
  Future<void> setDarkTheme(bool val) => _prefs.setBool('is_dark_theme', val);

  bool hasSeenOnboarding() => _prefs.getBool('has_seen_onboarding') ?? false;
  Future<void> setHasSeenOnboarding(bool val) => _prefs.setBool('has_seen_onboarding', val);

  bool isSoundEnabled() => _prefs.getBool('sound_enabled') ?? true;
  Future<void> setSoundEnabled(bool val) => _prefs.setBool('sound_enabled', val);

  bool isVibrationEnabled() => _prefs.getBool('vibration_enabled') ?? true;
  Future<void> setVibrationEnabled(bool val) => _prefs.setBool('vibration_enabled', val);

  bool isKeepAwakeEnabled() => _prefs.getBool('keep_awake_enabled') ?? false;
  Future<void> setKeepAwakeEnabled(bool val) => _prefs.setBool('keep_awake_enabled', val);

  int getDailyGoal() => _prefs.getInt('daily_goal') ?? 1000;
  Future<void> setDailyGoal(int val) => _prefs.setInt('daily_goal', val);

  CounterSkin getCounterSkin() {
    final str = _prefs.getString('counter_skin') ?? CounterSkin.electronicRing.name;
    return CounterSkin.values.firstWhere((e) => e.name == str, orElse: () => CounterSkin.electronicRing);
  }

  Future<void> setCounterSkin(CounterSkin skin) => _prefs.setString('counter_skin', skin.name);

  // --- Export / Import Backup ---
  String exportBackupJson() {
    final data = {
      'azkar': getAzkar().map((e) => e.toMap()).toList(),
      'sessions': getSessions().map((e) => e.toMap()).toList(),
      'streak': getStreakCount(),
      'lastActiveDate': getLastActiveDate(),
      'settings': {
        'isDarkTheme': isDarkTheme(),
        'soundEnabled': isSoundEnabled(),
        'vibrationEnabled': isVibrationEnabled(),
        'keepAwake': isKeepAwakeEnabled(),
        'dailyGoal': getDailyGoal(),
        'counterSkin': getCounterSkin().name,
      }
    };
    return json.encode(data);
  }

  Future<bool> importBackupJson(String jsonStr) async {
    try {
      final decoded = json.decode(jsonStr) as Map<String, dynamic>;
      
      if (decoded.containsKey('azkar')) {
        final List<dynamic> azMap = decoded['azkar'];
        await saveAzkar(azMap.map((e) => DhikrModel.fromMap(e)).toList());
      }
      if (decoded.containsKey('sessions')) {
        final List<dynamic> sesMap = decoded['sessions'];
        await saveSessions(sesMap.map((e) => CounterSession.fromMap(e)).toList());
      }
      if (decoded.containsKey('streak')) {
        await _prefs.setInt('streak_count', decoded['streak']);
      }
      if (decoded.containsKey('lastActiveDate')) {
        await _prefs.setString('last_active_date', decoded['lastActiveDate']);
      }
      if (decoded.containsKey('settings')) {
        final s = decoded['settings'] as Map<String, dynamic>;
        if (s.containsKey('isDarkTheme')) await setDarkTheme(s['isDarkTheme']);
        if (s.containsKey('soundEnabled')) await setSoundEnabled(s['soundEnabled']);
        if (s.containsKey('vibrationEnabled')) await setVibrationEnabled(s['vibrationEnabled']);
        if (s.containsKey('keepAwake')) await setKeepAwakeEnabled(s['keepAwake']);
        if (s.containsKey('dailyGoal')) await setDailyGoal(s['dailyGoal']);
        if (s.containsKey('counterSkin')) {
          final skin = CounterSkin.values.firstWhere((e) => e.name == s['counterSkin'], orElse: () => CounterSkin.electronicRing);
          await setCounterSkin(skin);
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}
