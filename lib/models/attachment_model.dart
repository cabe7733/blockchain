import 'package:cloud_firestore/cloud_firestore.dart';

class AttachmentModel {
  final String fileName;
  final String fileUrl;
  final int fileSize; // en bytes
  final DateTime uploadedAt;

  AttachmentModel({
    required this.fileName,
    required this.fileUrl,
    required this.fileSize,
    required this.uploadedAt,
  });

  /// Retorna el tamaño formateado (KB / MB)
  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  factory AttachmentModel.fromMap(Map<String, dynamic> map) {
    return AttachmentModel(
      fileName: map['fileName'] as String? ?? '',
      fileUrl: map['fileUrl'] as String? ?? '',
      fileSize: (map['fileSize'] as num?)?.toInt() ?? 0,
      uploadedAt: map['uploadedAt'] is Timestamp
          ? (map['uploadedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileSize': fileSize,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
    };
  }
}
