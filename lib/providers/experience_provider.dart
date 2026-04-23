import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/experience_model.dart';
import '../services/firestore_service.dart';

/// Provider para gestionar el listado de experiencias,
/// filtros activos y paginación.
///
/// ✅ Todos los filtros (industria, fechas, texto) se aplican aquí en el
/// cliente sobre la lista recibida del stream. Esto evita el error
/// [cloud_firestore/failed-precondition] que requiere índices compuestos.
class ExperienceProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  // ── Estado de filtros ──────────────────────────────────────
  String _searchQuery = '';
  String _industryFilter = '';
  DateTime? _startDate;
  DateTime? _endDate;

  String get searchQuery => _searchQuery;
  String get industryFilter => _industryFilter;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  bool get hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _industryFilter.isNotEmpty ||
      _startDate != null ||
      _endDate != null;

  // ── Paginación ─────────────────────────────────────────────
  bool _isLoadingMore = false;
  bool _hasMore = true;

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  // ── Stream tiempo real (sin filtros en Firestore) ──────────
  Stream<List<ExperienceModel>> get experiencesStream =>
      _service.experiencesStream();

  // ── Filtrado en CLIENTE ────────────────────────────────────
  /// Aplica búsqueda por texto, industria y rango de fechas
  /// sobre la lista ya recibida del stream, sin tocar Firestore.
  List<ExperienceModel> filteredExperiences(List<ExperienceModel> all) {
    return all.where((e) {
      // 1. Filtro texto (nombre empresa)
      if (_searchQuery.isNotEmpty &&
          !e.companyName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase())) {
        return false;
      }
      // 2. Filtro industria
      if (_industryFilter.isNotEmpty && e.industry != _industryFilter) {
        return false;
      }
      // 3. Filtro fecha inicio
      if (_startDate != null) {
        final startOfDay = DateTime(
            _startDate!.year, _startDate!.month, _startDate!.day, 0, 0, 0);
        if (e.registrationDate.isBefore(startOfDay)) return false;
      }
      // 4. Filtro fecha fin
      if (_endDate != null) {
        final endOfDay = DateTime(
            _endDate!.year, _endDate!.month, _endDate!.day, 23, 59, 59);
        if (e.registrationDate.isAfter(endOfDay)) return false;
      }
      return true;
    }).toList();
  }

  // ── Setters de filtros ─────────────────────────────────────
  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setIndustryFilter(String industry) {
    _industryFilter = industry;
    notifyListeners();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _industryFilter = '';
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  // ── Paginación: cargar más ─────────────────────────────────
  Future<void> loadMore(List<ExperienceModel> currentList) async {
    if (_isLoadingMore || !_hasMore || currentList.isEmpty) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final lastId = currentList.last.id;
      final lastSnap = await FirebaseFirestore.instance
          .collection('experiences')
          .doc(lastId)
          .get();

      final more = await _service.loadMore(lastDocument: lastSnap);
      if (more.length < 10) _hasMore = false;
    } catch (e) {
      debugPrint('Error al cargar más: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void resetPagination() {
    _hasMore = true;
    notifyListeners();
  }

  // ── Estadísticas ───────────────────────────────────────────
  Future<Map<String, dynamic>> getStats() => _service.getStats();

  // ── CRUD ───────────────────────────────────────────────────
  Future<String> addExperience(ExperienceModel exp) =>
      _service.addExperience(exp);

  Future<void> updateExperience(String id, Map<String, dynamic> data) =>
      _service.updateExperience(id, data);

  Future<void> deleteExperience(String id) => _service.deleteExperience(id);
}