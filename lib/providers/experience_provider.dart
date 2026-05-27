import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/experience_model.dart';
import '../services/firestore_service.dart';
import '../services/ai_service.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// Provider para gestionar el listado de experiencias,
/// filtros activos y paginación.
///
/// ✅ Todos los filtros (industria, fechas, texto) se aplican aquí en el
/// cliente sobre la lista recibida del stream. Esto evita el error
/// [cloud_firestore/failed-precondition] que requiere índices compuestos.
class ExperienceProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();
  final AIService _aiService = AIService(
    apiKey: const String.fromEnvironment(
      'GEMINI_API_KEY',
      defaultValue: '',
    ),
  );

  AIService get aiService => _aiService;

  // ── Estado del Copilot ──────────────────────────────────────
  final List<Map<String, String>> _chatMessages = [];
  bool _isAiResponding = false;
  ChatSession? _chatSession;

  List<Map<String, String>> get chatMessages => _chatMessages;
  bool get isAiResponding => _isAiResponding;
  bool get isAiEnabled => _aiService.isEnabled;

  // ── Cache para RAG ─────────────────────────────────────────
  List<Map<String, dynamic>>? _cachedCompact;
  List<Map<String, dynamic>>? get cachedCompact => _cachedCompact;

  // ── Estado de filtros ──────────────────────────────────────
  String _searchQuery = '';
  String _industryFilter = '';
  DateTime? _startDate;
  DateTime? _endDate;
  Timer? _searchDebounce;

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
      // 1. Filtro texto (nombre empresa, industria, tags, summary, retos, beneficios)
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchesSearch = e.companyName.toLowerCase().contains(q) ||
            e.industry.toLowerCase().contains(q) ||
            e.tags.any((t) => t.toLowerCase().contains(q)) ||
            e.summary.toLowerCase().contains(q) ||
            e.keyChallenges.any((c) => c.toLowerCase().contains(q)) ||
            e.keyBenefits.any((b) => b.toLowerCase().contains(q));
        if (!matchesSearch) return false;
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
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      notifyListeners();
    });
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
    _searchDebounce?.cancel();
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

  // ── Métodos del Copilot Chatbot ────────────────────────────
  Future<void> initCopilotSession({bool forceRefresh = false}) async {
    if (!isAiEnabled) return;

    if (!forceRefresh && _cachedCompact != null && _chatSession != null) return;

    _isAiResponding = true;
    notifyListeners();

    try {
      // 1. Obtener experiencias en formato compacto (con caché)
      _cachedCompact ??= await _service.getAllExperiencesCompact();
      
      // 2. Iniciar sesión de chat con el contexto inyectado
      _chatSession = _aiService.startCopilotSession(_cachedCompact!);
      
      // 3. Limpiar mensajes anteriores y agregar mensaje de bienvenida
      if (_chatMessages.isEmpty) {
        _chatMessages.add({
          'sender': 'copilot',
          'text': '¡Hola! Soy tu Copilot de Blockchain Empresarial. Analizo todas las lecciones aprendidas y registros cargados en la plataforma. ¿En qué puedo ayudarte hoy?'
        });
      }
    } catch (e) {
      debugPrint('Error al inicializar Copilot: $e');
    } finally {
      _isAiResponding = false;
      notifyListeners();
    }
  }

  Future<void> sendCopilotMessage(String message) async {
    if (!isAiEnabled || message.trim().isEmpty) return;

    // Asegurar que la sesión de chat esté inicializada
    if (_chatSession == null) {
      await initCopilotSession();
    }

    if (_chatSession == null) return;

    // 1. Agregar el mensaje del usuario
    _chatMessages.add({
      'sender': 'user',
      'text': message,
    });
    _isAiResponding = true;
    notifyListeners();

    try {
      // 2. Enviar a Gemini y esperar respuesta (con timeout de 60s)
      final response = await _chatSession!.sendMessage(
        Content.text(message),
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw TimeoutException('Gemini no respondió en 60 segundos.'),
      );
      final replyText = response.text ?? 'Lo siento, no he podido procesar esa pregunta.';
      
      // 3. Agregar respuesta de la IA
      _chatMessages.add({
        'sender': 'copilot',
        'text': replyText,
      });
    } on TimeoutException {
      _chatMessages.add({
        'sender': 'copilot',
        'text': '⏱️ La consulta está tomando más de lo esperado. ¿Quieres reformular la pregunta o intentar de nuevo?',
      });
    } catch (e, stack) {
      debugPrint('=== Error en sendCopilotMessage ===');
      debugPrint('Tipo: ${e.runtimeType}');
      debugPrint('Mensaje: $e');
      debugPrint('Stack: $stack');
      _chatMessages.add({
        'sender': 'copilot',
        'text': '⚠️ Hubo un error de conexión con el servicio de IA. Inténtalo de nuevo más tarde.',
      });
    } finally {
      _isAiResponding = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _chatMessages.clear();
    _chatSession = null;
    initCopilotSession();
  }
}