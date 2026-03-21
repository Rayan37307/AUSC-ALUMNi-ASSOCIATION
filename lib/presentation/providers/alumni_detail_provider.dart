import 'package:flutter/foundation.dart';
import '../../data/models/alumni.dart';
import '../../data/repositories/alumni_repository.dart';

/// Provider state for single alumni detail
class AlumniDetailProvider with ChangeNotifier {
  final AlumniRepository _repository;

  Alumni? _alumni;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String _error = '';

  AlumniDetailProvider(this._repository);

  // Getters
  Alumni? get alumni => _alumni;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String get error => _error;
  bool get hasError => _error.isNotEmpty;

  /// Load alumni by ID
  Future<void> loadAlumni(String id) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _alumni = await _repository.getAlumniById(id);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh alumni data
  Future<void> refreshAlumni(String id) async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    _error = '';
    notifyListeners();

    try {
      _alumni = await _repository.getAlumniById(id);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Update alumni
  Future<void> updateAlumni(Alumni alumni) async {
    await _repository.updateAlumni(alumni);
    _alumni = alumni;
    notifyListeners();
  }

  /// Delete alumni
  Future<void> deleteAlumni(String id) async {
    await _repository.deleteAlumni(id);
    _alumni = null;
    notifyListeners();
  }

  /// Clear current alumni
  void clear() {
    _alumni = null;
    _error = '';
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }
}
