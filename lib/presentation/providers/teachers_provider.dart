import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/teacher.dart';
import '../../data/sources/remote/school_api.dart';

/// Loads the teacher directory from the school website, keeping the last
/// successful result so the page still works offline.
class TeachersProvider with ChangeNotifier {
  static const String _cacheKey = 'teachers_cache_v1';

  final SchoolApi _api;
  final SharedPreferences _prefs;

  List<Teacher> _teachers = [];
  bool _isLoading = false;
  String _error = '';

  TeachersProvider(this._api, this._prefs) {
    _loadCache();
  }

  List<Teacher> get teachers => _teachers;
  bool get isLoading => _isLoading;
  bool get hasError => _error.isNotEmpty;
  String get error => _error;

  Teacher? _firstWith(String designation) {
    for (final t in _teachers) {
      if (t.designation == designation) return t;
    }
    return null;
  }

  Teacher? get principal => _firstWith('Principal');
  Teacher? get assistantHead => _firstWith('Asst. Head Teacher');

  /// Designations in seniority order, for filter chips.
  List<String> get designations {
    final seen = <String>{};
    return [
      for (final t in _teachers)
        if (seen.add(t.designation)) t.designation,
    ];
  }

  void _loadCache() {
    final raw = _prefs.getString(_cacheKey);
    if (raw == null) return;
    try {
      _teachers = (jsonDecode(raw) as List)
          .map((e) => Teacher.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      _prefs.remove(_cacheKey);
    }
  }

  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final fetched = await _api.fetchTeachers();
      // Stable sort: keep the website's order within each designation.
      final indexed = fetched.asMap().entries.toList()
        ..sort((a, b) {
          final byRank = a.value.rank.compareTo(b.value.rank);
          return byRank != 0 ? byRank : a.key.compareTo(b.key);
        });
      _teachers = [for (final e in indexed) e.value];
      await _prefs.setString(
        _cacheKey,
        jsonEncode(_teachers.map((t) => t.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Failed to load teachers: $e');
      _error = 'Couldn\'t load the teacher directory.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
