import 'package:flutter/foundation.dart';
import '../../data/models/alumni.dart';
import '../../data/repositories/alumni_repository.dart';

/// Provider state for alumni list
class AlumniListProvider with ChangeNotifier {
  final AlumniRepository _repository;

  List<Alumni> _alumni = [];
  List<Alumni> _filteredAlumni = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  String _error = '';
  String _searchQuery = '';

  AlumniListProvider(this._repository);

  // Getters
  List<Alumni> get alumni => _filteredAlumni.isEmpty ? _alumni : _filteredAlumni;
  List<Alumni> get allAlumni => _alumni;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String get error => _error;
  String get searchQuery => _searchQuery;
  bool get hasError => _error.isNotEmpty;
  bool get isEmpty => _alumni.isEmpty && !_isLoading;
  bool get hasNoResults => _filteredAlumni.isEmpty && _searchQuery.isNotEmpty && !_isLoading;

  /// Load alumni from repository
  Future<void> loadAlumni() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _alumni = await _repository.getAlumni();
      _applyFilter();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh alumni data
  Future<void> refreshAlumni() async {
    if (_isRefreshing) return;

    _isRefreshing = true;
    _error = '';
    notifyListeners();

    try {
      _alumni = await _repository.refreshAlumni();
      _applyFilter();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Search alumni
  void search(String query) {
    _searchQuery = query;
    _applyFilter();
    notifyListeners();
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _filteredAlumni = [];
    notifyListeners();
  }

  /// Apply filter based on search query
  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredAlumni = [];
      return;
    }

    final queryLower = _searchQuery.toLowerCase();
    _filteredAlumni = _alumni.where((alumni) {
      return alumni.name.toLowerCase().contains(queryLower) ||
          alumni.position.toLowerCase().contains(queryLower) ||
          alumni.currentlyDoing.toLowerCase().contains(queryLower) ||
          alumni.currentAddress.toLowerCase().contains(queryLower) ||
          alumni.permanentAddress.toLowerCase().contains(queryLower);
    }).toList();
  }

  /// Add a new alumni
  Future<void> addAlumni(Alumni alumni) async {
    await _repository.addAlumni(alumni);
    await loadAlumni();
  }

  /// Update an existing alumni
  Future<void> updateAlumni(Alumni alumni) async {
    await _repository.updateAlumni(alumni);
    await loadAlumni();
  }

  /// Delete an alumni
  Future<void> deleteAlumni(String id) async {
    await _repository.deleteAlumni(id);
    await loadAlumni();
  }

  /// Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }
}
