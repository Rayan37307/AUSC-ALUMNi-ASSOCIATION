import '../models/alumni.dart';
import '../sources/local/local_cache_source.dart';
import '../sources/remote/remote_data_source.dart';

/// Repository pattern implementation for alumni data
class AlumniRepository {
  final RemoteDataSource _remoteDataSource;
  final LocalCacheSource _localCacheSource;

  AlumniRepository({
    required RemoteDataSource remoteDataSource,
    required LocalCacheSource localCacheSource,
  })  : _remoteDataSource = remoteDataSource,
        _localCacheSource = localCacheSource;

  /// Get all alumni (from cache if valid, otherwise from Supabase)
  Future<List<Alumni>> getAlumni() async {
    // Try to get from cache first
    final cachedData = _localCacheSource.getAlumni();
    if (cachedData != null) {
      return (cachedData)
          .map((json) => Alumni.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    // Fetch from remote
    final List<Alumni> alumni = await _remoteDataSource.getAlumni();

    // Cache the result
    await _localCacheSource.cacheAlumni(
      alumni.map((a) => a.toJson()).toList(),
    );

    return alumni;
  }

  /// Get a single alumni by ID
  Future<Alumni> getAlumniById(String id) async {
    return await _remoteDataSource.getAlumniById(id);
  }

  /// Add a new alumni
  Future<Alumni> addAlumni(Alumni alumni) async {
    final newAlumni = await _remoteDataSource.addAlumni(alumni);

    // Refresh cache
    await refreshCache();

    return newAlumni;
  }

  /// Update an existing alumni
  Future<void> updateAlumni(Alumni alumni) async {
    await _remoteDataSource.updateAlumni(alumni);

    // Refresh cache
    await refreshCache();
  }

  /// Delete an alumni
  Future<void> deleteAlumni(String id) async {
    await _remoteDataSource.deleteAlumni(id);

    // Refresh cache
    await refreshCache();
  }

  /// Search alumni by name
  Future<List<Alumni>> searchAlumni(String query) async {
    if (query.isEmpty) {
      return await getAlumni();
    }
    return await _remoteDataSource.searchAlumni(query);
  }

  /// Force refresh data from Supabase
  Future<List<Alumni>> refreshAlumni() async {
    final List<Alumni> alumni = await _remoteDataSource.getAlumni();

    // Update cache
    await _localCacheSource.cacheAlumni(
      alumni.map((a) => a.toJson()).toList(),
    );

    return alumni;
  }

  /// Clear local cache
  Future<void> clearCache() async {
    await _localCacheSource.clearCache();
  }

  /// Refresh cache with current data
  Future<void> refreshCache() async {
    final List<Alumni> alumni = await _remoteDataSource.getAlumni();
    await _localCacheSource.cacheAlumni(
      alumni.map((a) => a.toJson()).toList(),
    );
  }
}
