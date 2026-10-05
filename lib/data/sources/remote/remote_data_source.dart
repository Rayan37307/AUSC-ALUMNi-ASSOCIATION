import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/alumni.dart';
import '../../models/photo.dart';

/// Remote data source for Supabase
class RemoteDataSource {
  final SupabaseClient? _client;

  RemoteDataSource() : _client = _resolveClient();

  static SupabaseClient? _resolveClient() {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  SupabaseClient get _safeClient {
    final client = _client;
    if (client == null) {
      throw Exception('Supabase is not initialized. Check your configuration.');
    }
    return client;
  }

  /// Get all alumni ordered by creation date (newest first)
  Future<List<Alumni>> getAlumni() async {
    try {
      final response = await _safeClient
          .from('alumni')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((row) => Alumni.fromSupabase(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}. Please create the alumni table in Supabase.');
    } catch (e) {
      throw Exception('Failed to fetch alumni: $e');
    }
  }

  /// Get a single alumni by ID
  Future<Alumni> getAlumniById(String id) async {
    try {
      final response = await _safeClient
          .from('alumni')
          .select()
          .eq('id', id)
          .single();

      return Alumni.fromSupabase(response);
    } catch (e) {
      throw Exception('Failed to fetch alumni: $e');
    }
  }

  /// Add a new alumni
  Future<Alumni> addAlumni(Alumni alumni) async {
    try {
      final response = await _safeClient
          .from('alumni')
          .insert(alumni.toSupabaseInsert())
          .select()
          .single();

      return Alumni.fromSupabase(response);
    } catch (e) {
      throw Exception('Failed to add alumni: $e');
    }
  }

  /// Update an existing alumni
  Future<void> updateAlumni(Alumni alumni) async {
    try {
      await _safeClient
          .from('alumni')
          .update(alumni.toSupabaseUpdate())
          .eq('id', alumni.id);
    } catch (e) {
      throw Exception('Failed to update alumni: $e');
    }
  }

  /// Delete an alumni
  Future<void> deleteAlumni(String id) async {
    try {
      await _safeClient
          .from('alumni')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete alumni: $e');
    }
  }

  /// Search alumni by name
  Future<List<Alumni>> searchAlumni(String query) async {
    try {
      final response = await _safeClient
          .from('alumni')
          .select()
          .order('created_at', ascending: false);

      final queryLower = query.toLowerCase();
      return (response as List)
          .map((row) => Alumni.fromSupabase(row as Map<String, dynamic>))
          .where((alumni) =>
              alumni.name.toLowerCase().contains(queryLower) ||
              alumni.position.toLowerCase().contains(queryLower) ||
              alumni.currentlyDoing.toLowerCase().contains(queryLower))
          .toList();
    } catch (e) {
      throw Exception('Failed to search alumni: $e');
    }
  }

  /// Get all photos
  Future<List<Photo>> getPhotos() async {
    try {
      final response = await _safeClient
          .from('photos')
          .select('*')
          .order('created_at', ascending: false);

      return (response as List)
          .map((row) => Photo.fromSupabase(row as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw Exception('Database error: ${e.message}. Please create the photos table in Supabase.');
    } catch (e) {
      throw Exception('Failed to fetch photos: $e');
    }
  }

  /// Register an uploaded photo. Admin only (enforced by RLS).
  Future<Photo> addPhoto(Photo photo) async {
    try {
      final response = await _safeClient
          .from('photos')
          .insert(photo.toSupabaseInsert())
          .select()
          .single();

      return Photo.fromSupabase(response);
    } catch (e) {
      throw Exception('Failed to add photo: $e');
    }
  }

  /// Delete a photo row. Admin only (enforced by RLS).
  Future<void> deletePhoto(String id) async {
    try {
      await _safeClient.from('photos').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete photo: $e');
    }
  }
}
