import 'package:cloud_firestore/cloud_firestore.dart';
import 'attachment_model.dart';

class ExperienceModel {
  final String id;
  final String companyName;
  final String industry;
  final String summary;
  final DateTime registrationDate;
  final String createdBy;        // UID del autor
  final String createdByName;    // Nombre del autor
  final String createdByCompany; // Empresa del autor
  final List<AttachmentModel> attachments;
  final DateTime createdAt;
  final List<String> tags;
  final List<String> keyChallenges;
  final List<String> keyBenefits;
  final String? link;

  ExperienceModel({
    required this.id,
    required this.companyName,
    required this.industry,
    required this.summary,
    required this.registrationDate,
    required this.createdBy,
    required this.createdByName,
    required this.createdByCompany,
    required this.attachments,
    required this.createdAt,
    this.tags = const [],
    this.keyChallenges = const [],
    this.keyBenefits = const [],
    this.link,
  });

  int get totalAttachments => attachments.length;

  factory ExperienceModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExperienceModel(
      id: doc.id,
      companyName: data['companyName'] as String? ?? '',
      industry: data['industry'] as String? ?? '',
      summary: data['summary'] as String? ?? '',
      registrationDate: data['registrationDate'] is Timestamp
          ? (data['registrationDate'] as Timestamp).toDate()
          : DateTime.now(),
      createdBy: data['createdBy'] as String? ?? '',
      createdByName: data['createdByName'] as String? ?? '',
      createdByCompany: data['createdByCompany'] as String? ?? '',
      attachments: data['attachments'] != null
          ? (data['attachments'] as List<dynamic>)
              .map((a) => AttachmentModel.fromMap(a as Map<String, dynamic>))
              .toList()
          : [],
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      tags: data['tags'] != null ? List<String>.from(data['tags'] as List) : [],
      keyChallenges: data['keyChallenges'] != null
          ? List<String>.from(data['keyChallenges'] as List)
          : [],
      keyBenefits: data['keyBenefits'] != null
          ? List<String>.from(data['keyBenefits'] as List)
          : [],
      link: data['link'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'industry': industry,
      'summary': summary,
      'registrationDate': Timestamp.fromDate(registrationDate),
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdByCompany': createdByCompany,
      'attachments': attachments.map((a) => a.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'tags': tags,
      'keyChallenges': keyChallenges,
      'keyBenefits': keyBenefits,
      if (link != null) 'link': link,
    };
  }
}
