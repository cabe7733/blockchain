import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/experience_model.dart';

/// Servicio de Firestore para operaciones CRUD de experiencias.
///
/// ⚠️  IMPORTANTE: Los filtros de industria y fechas se aplican en el
/// CLIENTE (ExperienceProvider), NO aquí. Firestore exige índices compuestos
/// cuando se combina orderBy con where en campos distintos, lo que causa
/// el error [failed-precondition]. Esta arquitectura lo evita completamente.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String _col = 'experiences';
  static const int _pageSize = 10;

  // ── Stream tiempo real — SOLO orderBy, sin where ───────────
  // Los filtros se delegan a ExperienceProvider.filteredExperiences()
  Stream<List<ExperienceModel>> experiencesStream() {
    return _db
        .collection(_col)
        .orderBy('createdAt', descending: true)
        .limit(_pageSize)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => ExperienceModel.fromDocument(d)).toList());
  }

  // ── Paginación: cargar más después del último doc ──────────
  Future<List<ExperienceModel>> loadMore({
    required DocumentSnapshot lastDocument,
  }) async {
    try {
      final snap = await _db
          .collection(_col)
          .orderBy('createdAt', descending: true)
          .startAfterDocument(lastDocument)
          .limit(_pageSize)
          .get();
      return snap.docs.map((d) => ExperienceModel.fromDocument(d)).toList();
    } catch (e) {
      throw Exception('Error al cargar más experiencias: $e');
    }
  }

  // ── Crear experiencia ──────────────────────────────────────
  Future<String> addExperience(ExperienceModel experience) async {
    try {
      final ref = await _db.collection(_col).add(experience.toMap());
      return ref.id;
    } catch (e) {
      throw Exception('Error al guardar experiencia: $e');
    }
  }

  // ── Actualizar (ej: añadir attachments) ───────────────────
  Future<void> updateExperience(String id, Map<String, dynamic> data) async {
    try {
      await _db.collection(_col).doc(id).update(data);
    } catch (e) {
      throw Exception('Error al actualizar experiencia: $e');
    }
  }

  // ── Eliminar (solo admin) ──────────────────────────────────
  Future<void> deleteExperience(String id) async {
    try {
      await _db.collection(_col).doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar experiencia: $e');
    }
  }

  // ── Estadísticas del dashboard ─────────────────────────────
  Future<Map<String, dynamic>> getStats() async {
    try {
      final snap = await _db.collection(_col).get();
      final docs =
          snap.docs.map((d) => ExperienceModel.fromDocument(d)).toList();

      final companies = docs.map((e) => e.companyName).toSet();
      final industries = <String, int>{};
      final registrationsByMonth = <String, int>{};
      int totalPdfs = 0;

      for (final exp in docs) {
        // Conteo de industrias
        industries[exp.industry] = (industries[exp.industry] ?? 0) + 1;
        
        // Conteo de adjuntos
        totalPdfs += exp.attachments.length;

        // Tendencia mensual (ej: "2024-03")
        final monthKey = "${exp.registrationDate.year}-${exp.registrationDate.month.toString().padLeft(2, '0')}";
        registrationsByMonth[monthKey] = (registrationsByMonth[monthKey] ?? 0) + 1;
      }

      String topIndustry = '';
      if (industries.isNotEmpty) {
        topIndustry =
            industries.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      }

      // Ordenar histórico por fecha (las keys de los mapas no garantizan orden)
      final sortedMonths = registrationsByMonth.keys.toList()..sort();
      final monthlyData = {
        for (var k in sortedMonths) k: registrationsByMonth[k]
      };

      return {
        'total': docs.length,
        'companies': companies.length,
        'topIndustry': topIndustry,
        'totalPdfs': totalPdfs,
        'industryDistribution': Map<String, int>.from(industries),
        'monthlyTrend': Map<String, int>.from(monthlyData),
      };
    } catch (e) {
      return {
        'total': 0,
        'companies': 0,
        'topIndustry': '-',
        'totalPdfs': 0,
        'industryDistribution': <String, int>{},
        'monthlyTrend': <String, int>{},
      };
    }
  }

  // ─────────────────────────────────────────────────────────
  // REGLAS DE FIRESTORE SUGERIDAS (consola Firebase → Reglas):
  //
  // rules_version = '2';
  // service cloud.firestore {
  //   match /databases/{database}/documents {
  //     match /users/{userId} {
  //       allow read, write: if request.auth != null
  //                          && request.auth.uid == userId;
  //     }
  //     match /experiences/{docId} {
  //       allow read: if request.auth != null;
  //       allow create, update: if request.auth != null;
  //       allow delete: if request.auth != null &&
  //         get(/databases/$(database)/documents/users/$(request.auth.uid))
  //           .data.role == "admin";
  //     }
  //   }
  // }
  // ─────────────────────────────────────────────────────────
}