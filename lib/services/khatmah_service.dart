import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/khatmah.dart';

class KhatmahService {
  static const String _keyActive = 'active_khatmah';
  static const String _keyHistory = 'khatmah_history';

  static Khatmah? _activeKhatmah;
  static final List<Khatmah> _history = [];
  static bool _isLoaded = false;

  /// Reactive notifier for the active Khatmah state
  static final ValueNotifier<Khatmah?> activeKhatmahNotifier = ValueNotifier<Khatmah?>(null);

  static Future<void> _ensureLoaded() async {
    if (_isLoaded) return;
    _isLoaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load active Khatmah
      final String? activeJsonStr = prefs.getString(_keyActive);
      if (activeJsonStr != null && activeJsonStr.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(activeJsonStr);
        _activeKhatmah = Khatmah.fromJson(map);
      } else {
        _activeKhatmah = null;
      }
      activeKhatmahNotifier.value = _activeKhatmah;

      // Load History
      final List<String>? historyJsonList = prefs.getStringList(_keyHistory);
      _history.clear();
      if (historyJsonList != null) {
        for (var item in historyJsonList) {
          try {
            _history.add(Khatmah.fromJson(jsonDecode(item)));
          } catch (_) {}
        }
      }
    } catch (_) {}
  }

  /// Get the current active Khatmah (or null if none started)
  static Future<Khatmah?> getActiveKhatmah() async {
    await _ensureLoaded();
    return _activeKhatmah;
  }

  /// Start a new Khatmah. If one already exists in progress, archives it to history first.
  static Future<Khatmah> startNewKhatmah() async {
    await _ensureLoaded();

    // If an existing Khatmah is present, archive it to history
    if (_activeKhatmah != null) {
      _history.insert(0, _activeKhatmah!);
    }

    final newKhatmah = Khatmah(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startedAt: DateTime.now(),
      currentPage: 1,
      status: KhatmahStatus.inProgress,
      lastUpdatedAt: DateTime.now(),
    );

    _activeKhatmah = newKhatmah;
    activeKhatmahNotifier.value = _activeKhatmah;

    await _saveToPrefs();
    return newKhatmah;
  }

  /// Update the current page progress (1 to 604) for the active Khatmah
  static Future<bool> updateProgress(int page) async {
    await _ensureLoaded();
    if (_activeKhatmah == null) return false;

    final int safePage = page.clamp(1, 604);
    final bool justCompleted = safePage >= 604 && _activeKhatmah!.status != KhatmahStatus.completed;

    final updated = _activeKhatmah!.copyWith(
      currentPage: safePage,
      status: safePage >= 604 ? KhatmahStatus.completed : KhatmahStatus.inProgress,
      completedAt: safePage >= 604 ? (_activeKhatmah!.completedAt ?? DateTime.now()) : null,
      lastUpdatedAt: DateTime.now(),
    );

    _activeKhatmah = updated;
    activeKhatmahNotifier.value = _activeKhatmah;

    await _saveToPrefs();
    return justCompleted;
  }

  /// Complete the current active Khatmah explicitly
  static Future<void> completeActiveKhatmah() async {
    await _ensureLoaded();
    if (_activeKhatmah == null) return;

    final completed = _activeKhatmah!.copyWith(
      currentPage: 604,
      status: KhatmahStatus.completed,
      completedAt: DateTime.now(),
      lastUpdatedAt: DateTime.now(),
    );

    _activeKhatmah = completed;
    activeKhatmahNotifier.value = _activeKhatmah;

    await _saveToPrefs();
  }

  /// Get the full Khatmah history (past and archived Khatmahs)
  static Future<List<Khatmah>> getHistory() async {
    await _ensureLoaded();
    return List.unmodifiable(_history);
  }

  /// Save active and history to local storage
  static Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (_activeKhatmah != null) {
        await prefs.setString(_keyActive, jsonEncode(_activeKhatmah!.toJson()));
      } else {
        await prefs.remove(_keyActive);
      }

      final historyStrList = _history.map((k) => jsonEncode(k.toJson())).toList();
      await prefs.setStringList(_keyHistory, historyStrList);
    } catch (_) {}
  }

  /// Helper to reset in-memory state for testing
  @visibleForTesting
  static void resetForTesting() {
    _activeKhatmah = null;
    _history.clear();
    _isLoaded = false;
    activeKhatmahNotifier.value = null;
  }
}
