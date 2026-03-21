import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

/// Cache data wrapper with expiry check
class CacheData<T> {
  final T data;
  final int timestamp;

  CacheData({
    required this.data,
    required this.timestamp,
  });

  /// Check if cache is still valid (not expired)
  bool get isValid {
    final now = DateTime.now().millisecondsSinceEpoch;
    return now - timestamp < AppConstants.cacheExpiryMs;
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'data': data is List
          ? (data as List).map((e) => e is Map ? e : (e as dynamic).toJson?.call() ?? e).toList()
          : (data as dynamic).toJson?.call() ?? data,
      'timestamp': timestamp,
    };
  }
}

/// Local cache source using SharedPreferences
class LocalCacheSource {
  final SharedPreferences _prefs;

  LocalCacheSource(this._prefs);

  /// Get cached alumni list
  List<dynamic>? getAlumni() {
    final jsonString = _prefs.getString(AppConstants.alumniCacheKey);
    if (jsonString == null) return null;

    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
    final timestamp = jsonData['timestamp'] as int;
    final data = jsonData['data'];

    final cacheData = CacheData<List<dynamic>>(
      data: data as List<dynamic>,
      timestamp: timestamp,
    );

    if (!cacheData.isValid) {
      // Cache expired, remove it
      _prefs.remove(AppConstants.alumniCacheKey);
      return null;
    }

    return cacheData.data;
  }

  /// Cache alumni list
  Future<void> cacheAlumni(List<Map<String, dynamic>> alumni) async {
    final cacheData = CacheData<List<Map<String, dynamic>>>(
      data: alumni,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );

    final jsonData = jsonEncode({
      'data': alumni,
      'timestamp': cacheData.timestamp,
    });

    await _prefs.setString(AppConstants.alumniCacheKey, jsonData);
  }

  /// Clear all cache
  Future<void> clearCache() async {
    await _prefs.remove(AppConstants.alumniCacheKey);
  }

  /// Check if cache exists and is valid
  bool hasValidCache() {
    final data = getAlumni();
    return data != null;
  }
}
