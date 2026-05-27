import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

const Duration _aiTimeout = Duration(seconds: 60);

/// Servicio unificado de Inteligencia Artificial usando Google Gemini.
///
/// Mantiene DOS instancias separadas de GenerativeModel:
/// - [_jsonModel]: para extracción de Insights (con responseMimeType JSON).
/// - Chat: se crea con systemInstruction por cada sesión en [startCopilotSession].
///
/// IMPORTANTE: NO se usa Content.system() dentro del historial de startChat,
/// ya que causaba un AssertionError en _aggregate del paquete google_generative_ai.
/// En cambio, systemInstruction se pasa al constructor de GenerativeModel.
class AIService {
  final String _apiKey;

  // Modelo para extracción de Insights (retorna JSON estricto)
  GenerativeModel? _jsonModel;

  AIService({required String apiKey}) : _apiKey = apiKey {
    if (_apiKey.isNotEmpty) {
      _jsonModel = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
        ),
      );
    } else {
      if (kDebugMode) {
        print('Warning: GEMINI_API_KEY is empty. AI features will be disabled.');
      }
    }
  }

  bool get isEnabled => _jsonModel != null && _apiKey.isNotEmpty;

  // ── Extractor de Insights ──────────────────────────────────────────────────

  /// Analiza el resumen de una experiencia y extrae etiquetas, retos y beneficios.
  Future<Map<String, List<String>>> extractInsights(String summary) async {
    if (!isEnabled) {
      return {'tags': [], 'challenges': [], 'benefits': []};
    }

    final prompt = '''
Analiza la siguiente lección aprendida sobre la implementación de Blockchain en una empresa y extrae información clave en formato JSON.

El JSON retornado debe cumplir estrictamente con esta estructura (sin texto adicional):
{
  "tags": ["Tag1", "Tag2", "Tag3"],
  "challenges": ["Reto1", "Reto2", "Reto3"],
  "benefits": ["Beneficio1", "Beneficio2", "Beneficio3"]
}

Reglas:
- De 2 a 4 tags representativos (ej: "Ethereum", "Logística", "Solidity", "Trazabilidad").
- De 1 a 3 retos técnicos o de negocio principales.
- De 1 a 3 beneficios medibles u aprendizajes clave.
- Responde ÚNICAMENTE con el objeto JSON válido.

Texto de la experiencia:
"$summary"
''';

    try {
      final response = await _jsonModel!.generateContent(
        [Content.text(prompt)],
      ).timeout(_aiTimeout, onTimeout: () => throw TimeoutException('Gemini no respondió en 60 segundos.'));
      final jsonText = response.text;
      if (jsonText == null || jsonText.isEmpty) {
        throw Exception('Respuesta vacía de Gemini.');
      }

      // Limpiar posibles bloques de código markdown (```json ... ```)
      final cleaned = jsonText
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();

      final Map<String, dynamic> parsed = jsonDecode(cleaned);

      return {
        'tags': parsed['tags'] != null
            ? List<String>.from(parsed['tags'] as List)
            : <String>[],
        'challenges': parsed['challenges'] != null
            ? List<String>.from(parsed['challenges'] as List)
            : <String>[],
        'benefits': parsed['benefits'] != null
            ? List<String>.from(parsed['benefits'] as List)
            : <String>[],
      };
    } on TimeoutException catch (e) {
      if (kDebugMode) print('Timeout en extractInsights: $e');
      return {'tags': [], 'challenges': [], 'benefits': []};
    } catch (e) {
      if (kDebugMode) {
        print('Error en extractInsights: $e');
      }
      return {'tags': [], 'challenges': [], 'benefits': []};
    }
  }

  // ── Copilot Conversacional (RAG) ───────────────────────────────────────────

  /// Crea una sesión de chat con el contexto de la base de datos inyectado.
  ///
  /// Se crea un GenerativeModel NUEVO con [systemInstruction] por cada sesión.
  /// [startChat] sólo recibe historial vacío (roles user/model únicamente).
  ChatSession? startCopilotSession(List<Map<String, dynamic>> experiencesJson) {
    if (!isEnabled) return null;

    final systemInstructionText = '''
Eres el Copilot Experto de Blockchain en la Empresa. Eres un asistente virtual diseñado para analizar lecciones aprendidas de implementaciones de blockchain empresarial.

Tu conocimiento fundamental para responder se basa ÚNICAMENTE en la siguiente base de datos en formato JSON que representa las experiencias registradas por diversas empresas:

${jsonEncode(experiencesJson)}

Reglas críticas:
1. Si el usuario pregunta sobre un caso, empresa, reto o tecnología que NO está en el JSON, indícalo amablemente. NO inventes información.
2. Responde con tono formal, profesional y analítico (como un consultor senior de tecnología blockchain).
3. Usa Markdown en tus respuestas: negritas, listas, tablas comparativas cuando sea útil.
4. Relaciona y contrasta experiencias cuando te hagan preguntas comparativas.
''';

    // GenerativeModel con systemInstruction — la forma correcta de inyectar contexto.
    // startChat recibe historial vacío: solo roles 'user' y 'model' son válidos allí.
    final sessionModel = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(systemInstructionText),
    );

    return sessionModel.startChat(history: []);
  }
}
