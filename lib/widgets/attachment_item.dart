import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/attachment_model.dart';
import '../theme/app_theme.dart';

class AttachmentItem extends StatelessWidget {
  final AttachmentModel attachment;
  final bool compact;

  const AttachmentItem({
    super.key,
    required this.attachment,
    this.compact = false,
  });

  Future<void> _openPdf() async {
    final uri = Uri.parse(attachment.fileUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return InkWell(
        onTap: _openPdf,
        borderRadius: BorderRadius.circular(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.picture_as_pdf,
                color: Color(0xFFEF4444), size: 14),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                attachment.fileName,
                style: const TextStyle(
                  color: AppTheme.primaryBlue,
                  fontSize: 11,
                  decoration: TextDecoration.underline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF0F172A)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey.shade700
                : Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.picture_as_pdf,
              color: Color(0xFFEF4444), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.fileName,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  attachment.formattedSize,
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textGray),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: _openPdf,
            icon: const Icon(Icons.open_in_new, size: 14),
            label: const Text('Ver PDF'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryBlue,
              textStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            ),
          ),
        ],
      ),
    );
  }
}
