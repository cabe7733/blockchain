import 'package:flutter/material.dart' show debugPrint;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/experience_model.dart';

/// Utilidad para generar y descargar reportes PDF.
class PdfGenerator {
  PdfGenerator._();

  // ── Colores del reporte ────────────────────────────────────
  static const _blue   = PdfColor.fromInt(0xFF2563EB);
  static const _violet = PdfColor.fromInt(0xFF7C3AED);
  static const _dark   = PdfColor.fromInt(0xFF1F2937);
  static const _gray   = PdfColor.fromInt(0xFF6B7280);
  static const _light  = PdfColor.fromInt(0xFFF9FAFB);
  static const _white  = PdfColors.white;

  /// Genera un PDF con el listado de experiencias y lo descarga.
  static Future<void> generateReport(
    List<ExperienceModel> experiences,
  ) async {
    try {
      final doc = pw.Document();
      final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
      final dateFormatter = DateFormat('dd/MM/yyyy');

      // Dividir en páginas de 15 filas
      const rowsPerPage = 15;
      final pages = <List<ExperienceModel>>[];
      for (int i = 0; i < experiences.length; i += rowsPerPage) {
        pages.add(experiences.sublist(
          i,
          (i + rowsPerPage).clamp(0, experiences.length),
        ));
      }

      if (pages.isEmpty) pages.add([]);

      for (int pageIdx = 0; pageIdx < pages.length; pageIdx++) {
        final pageData = pages[pageIdx];
        doc.addPage(
          pw.Page(
            pageTheme: pw.PageTheme(
              pageFormat: PdfPageFormat.a4.landscape,
              margin: const pw.EdgeInsets.all(24),
            ),
            build: (ctx) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // ── Encabezado ─────────────────────────────
                _buildHeader(dateStr, experiences.length),
                pw.SizedBox(height: 16),
                // ── Tabla ──────────────────────────────────
                _buildTable(pageData, dateFormatter),
                pw.Spacer(),
                // ── Pie de página ─────────────────────────
                _buildFooter(pageIdx + 1, pages.length),
              ],
            ),
          ),
        );
      }

      await Printing.sharePdf(
        bytes: await doc.save(),
        filename:
            'blockchain_experiencias_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      debugPrint('Error al generar PDF: $e');
      rethrow;
    }
  }

  /// Genera el PDF detallado de una única experiencia.
  static Future<void> generateDetailReport(ExperienceModel exp) async {
    try {
      final doc = pw.Document();
      final dateStr = DateFormat('dd/MM/yyyy').format(exp.registrationDate);

      doc.addPage(
        pw.Page(
          pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(32),
          ),
          build: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(
                  DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()), 1),
              pw.SizedBox(height: 20),
              _detailRow('Empresa', exp.companyName),
              _detailRow('Industria', exp.industry),
              _detailRow('Fecha de Registro', dateStr),
              _detailRow('Registrado por',
                  '${exp.createdByName} — ${exp.createdByCompany}'),
              if (exp.link != null && exp.link!.isNotEmpty) ...[
                _detailRow('Link de Referencia', exp.link!),
              ],
              pw.SizedBox(height: 12),
              pw.Text('Resumen:',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                      color: _dark)),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: _light,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Text(exp.summary,
                    style: const pw.TextStyle(fontSize: 11, color: _dark)),
              ),
              if (exp.attachments.isNotEmpty) ...[
                pw.SizedBox(height: 16),
                pw.Text('Archivos Adjuntos (${exp.attachments.length}):',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                        color: _dark)),
                pw.SizedBox(height: 6),
                ...exp.attachments.map((a) => pw.Text('• ${a.fileName}',
                    style: const pw.TextStyle(fontSize: 10, color: _gray))),
              ],
              pw.Spacer(),
              _buildFooter(1, 1),
            ],
          ),
        ),
      );

      await Printing.sharePdf(
        bytes: await doc.save(),
        filename: 'experiencia_${exp.companyName.replaceAll(' ', '_')}.pdf',
      );
    } catch (e) {
      debugPrint('Error al generar PDF de detalle: $e');
      rethrow;
    }
  }

  // ── Widgets internos del PDF ───────────────────────────────

  static pw.Widget _buildHeader(String dateStr, int count) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        gradient: pw.LinearGradient(
          colors: [_blue, _violet],
          begin: pw.Alignment.centerLeft,
          end: pw.Alignment.centerRight,
        ),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Blockchain en la Empresa',
                  style: pw.TextStyle(
                      color: _white,
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text('Registro de Experiencias y Aprendizajes',
                  style: const pw.TextStyle(color: _white, fontSize: 11)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Generado: $dateStr',
                  style: const pw.TextStyle(color: _white, fontSize: 10)),
              pw.SizedBox(height: 4),
              pw.Text('Total: $count registro${count != 1 ? 's' : ''}',
                  style: pw.TextStyle(
                      color: _white,
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTable(
      List<ExperienceModel> rows, DateFormat fmt) {
    const headers = [
      'Empresa',
      'Industria',
      'Fecha',
      'Registrado por',
      'Resumen',
      'Adjuntos',
    ];

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2.0),
        1: const pw.FlexColumnWidth(1.2),
        2: const pw.FlexColumnWidth(1.0),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(3.5),
        5: const pw.FlexColumnWidth(0.7),
      },
      children: [
        // Fila de encabezado
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _blue),
          children: headers
              .map(
                (h) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8, vertical: 6),
                  child: pw.Text(h,
                      style: pw.TextStyle(
                          color: _white,
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10)),
                ),
              )
              .toList(),
        ),
        // Filas de datos
        ...rows.asMap().entries.map((entry) {
          final i = entry.key;
          final exp = entry.value;
          final bg = i.isEven ? _white : _light;
          final summary = exp.summary.length > 120
              ? '${exp.summary.substring(0, 117)}...'
              : exp.summary;

          return pw.TableRow(
            decoration: pw.BoxDecoration(color: bg),
            children: [
              _cell(exp.companyName),
              _cell(exp.industry),
              _cell(fmt.format(exp.registrationDate)),
              _cell('${exp.createdByName}\n${exp.createdByCompany}'),
              _cell(summary),
              _cell('${exp.attachments.length}',
                  align: pw.TextAlign.center),
            ],
          );
        }),
      ],
    );
  }

  static pw.Widget _cell(String text,
      {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding:
          const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 9, color: _dark),
        textAlign: align,
      ),
    );
  }

  static pw.Widget _detailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 140,
            child: pw.Text('$label:',
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                    color: _blue)),
          ),
          pw.Expanded(
            child: pw.Text(value,
                style: const pw.TextStyle(fontSize: 11, color: _dark)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(int page, int total) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Blockchain en la Empresa — Confidencial',
              style: const pw.TextStyle(fontSize: 8, color: _gray)),
          pw.Text('Página $page de $total',
              style: const pw.TextStyle(fontSize: 8, color: _gray)),
        ],
      ),
    );
  }
}
