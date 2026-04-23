import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/attachment_model.dart';

/// Servicio para subida y eliminación de archivos PDF en Firebase Storage.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Límite de 10 MB por archivo
  static const int maxFileSizeBytes = 10 * 1024 * 1024;

  /// Sube un PDF y retorna [AttachmentModel] con URL de descarga.
  /// [onProgress] recibe un valor entre 0.0 y 1.0
  Future<AttachmentModel> uploadPdf({
    required Uint8List bytes,
    required String fileName,
    required String experienceId,
    void Function(double)? onProgress,
  }) async {
    if (bytes.length > maxFileSizeBytes) {
      throw Exception(
          'El archivo "$fileName" supera el límite de 10 MB');
    }

    try {
      final ref = _storage
          .ref()
          .child('attachments/$experienceId/$fileName');

      final metadata = SettableMetadata(contentType: 'application/pdf');
      final task = ref.putData(bytes, metadata);

      // Escuchar progreso de subida
      if (onProgress != null) {
        task.snapshotEvents.listen((snapshot) {
          if (snapshot.totalBytes > 0) {
            onProgress(snapshot.bytesTransferred / snapshot.totalBytes);
          }
        });
      }

      await task;
      final url = await ref.getDownloadURL();

      return AttachmentModel(
        fileName: fileName,
        fileUrl: url,
        fileSize: bytes.length,
        uploadedAt: DateTime.now(),
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al subir "$fileName": $e');
    }
  }

  /// Sube múltiples PDFs con progreso global.
  /// [onFileProgress] recibe (fileIndex, 0.0..1.0)
  Future<List<AttachmentModel>> uploadMultiple({
    required List<Map<String, dynamic>> files, // {name, bytes}
    required String experienceId,
    void Function(int fileIndex, double progress)? onFileProgress,
  }) async {
    final results = <AttachmentModel>[];
    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      final attachment = await uploadPdf(
        bytes: file['bytes'] as Uint8List,
        fileName: file['name'] as String,
        experienceId: experienceId,
        onProgress: (p) => onFileProgress?.call(i, p),
      );
      results.add(attachment);
    }
    return results;
  }

  /// Elimina un archivo de Storage por URL.
  Future<void> deleteFile(String fileUrl) async {
    try {
      await _storage.refFromURL(fileUrl).delete();
    } catch (_) {
      // Si el archivo no existe, ignorar el error
    }
  }

  // ─────────────────────────────────────────────────────────
  // REGLAS DE STORAGE SUGERIDAS:
  //
  // rules_version = '2';
  // service firebase.storage {
  //   match /b/{bucket}/o {
  //     match /attachments/{allPaths=**} {
  //       allow read, write: if request.auth != null;
  //     }
  //   }
  // }
  // ─────────────────────────────────────────────────────────
}
