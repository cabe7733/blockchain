import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/experience_model.dart';
import '../providers/auth_provider.dart';
import '../providers/experience_provider.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/gradient_button.dart';

class AddExperienceScreen extends StatefulWidget {
  final ExperienceModel? experienceToEdit;

  const AddExperienceScreen({super.key, this.experienceToEdit});

  @override
  State<AddExperienceScreen> createState() => _AddExperienceScreenState();
}

class _AddExperienceScreenState extends State<AddExperienceScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _companyCtrl    = TextEditingController();
  final _summaryCtrl    = TextEditingController();
  final _linkCtrl       = TextEditingController();
  final _storageService = StorageService();

  String? _selectedIndustry;
  // Lista de archivos: {name, bytes, progress (0.0-1.0), uploaded}
  final List<Map<String, dynamic>> _files = [];
  bool   _isSaving      = false;
  String _statusMessage = '';
  bool   _isEditMode    = false;

  final List<String> _tags = [];
  final List<String> _keyChallenges = [];
  final List<String> _keyBenefits = [];
  bool _isAnalyzing = false;

  static const List<String> _industries = [
    'Finanzas', 'Logística', 'Salud', 'Retail',
    'Manufactura', 'Gobierno', 'Educación', 'Otro',
  ];

  @override
  void initState() {
    super.initState();
    final exp = widget.experienceToEdit;
    if (exp != null) {
      _isEditMode = true;
      _companyCtrl.text = exp.companyName;
      _summaryCtrl.text = exp.summary;
      _linkCtrl.text = exp.link ?? '';
      _selectedIndustry = exp.industry;
      _tags.addAll(exp.tags);
      _keyChallenges.addAll(exp.keyChallenges);
      _keyBenefits.addAll(exp.keyBenefits);
    }
  }

  @override
  void dispose() {
    _companyCtrl.dispose();
    _summaryCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
        withData: true,
      );
      if (result == null) return;

      for (final file in result.files) {
        if (file.bytes == null) continue;
        if (file.bytes!.length > StorageService.maxFileSizeBytes) {
          _showSnackBar(
              'El archivo "${file.name}" supera 10 MB y no se añadirá',
              isError: true);
          continue;
        }
        final exists = _files.any((f) => f['name'] == file.name);
        if (!exists) {
          setState(() => _files.add({
            'name': file.name,
            'bytes': file.bytes as Uint8List,
            'progress': 0.0,
          }));
        }
      }
    } catch (e) {
      _showSnackBar('Error al seleccionar archivos: $e', isError: true);
    }
  }

  void _removeFile(int index) => setState(() => _files.removeAt(index));

  Future<void> _analyzeWithAI() async {
    final summaryText = _summaryCtrl.text.trim();
    if (summaryText.length < 50) {
      _showSnackBar('El resumen debe tener al menos 50 caracteres para ser analizado.', isError: true);
      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final expProvider = context.read<ExperienceProvider>();
      if (!expProvider.isAiEnabled) {
        _showSnackBar('El servicio de IA no está habilitado.', isError: true);
        return;
      }

      final insights = await expProvider.aiService.extractInsights(summaryText);
      
      setState(() {
        _tags.clear();
        _tags.addAll(insights['tags'] ?? []);
        
        _keyChallenges.clear();
        _keyChallenges.addAll(insights['challenges'] ?? []);
        
        _keyBenefits.clear();
        _keyBenefits.addAll(insights['benefits'] ?? []);
      });

      _showSnackBar('Insights y etiquetas extraídos exitosamente.', isError: false);
    } catch (e) {
      _showSnackBar('Error al analizar con IA: $e', isError: true);
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final authProvider = context.read<AuthProvider>();
      final expProvider  = context.read<ExperienceProvider>();
      final user         = authProvider.userModel;
      final linkValue = _linkCtrl.text.trim();

      if (_isEditMode) {
        final exp = widget.experienceToEdit!;
        setState(() { _isSaving = true; _statusMessage = 'Actualizando registro...'; });

        final updateData = <String, dynamic>{
          'companyName': _companyCtrl.text.trim(),
          'industry': _selectedIndustry!,
          'summary': _summaryCtrl.text.trim(),
          'tags': _tags,
          'keyChallenges': _keyChallenges,
          'keyBenefits': _keyBenefits,
        };
        if (linkValue.isNotEmpty) {
          updateData['link'] = linkValue;
        } else {
          updateData['link'] = FieldValue.delete();
        }

        await expProvider.updateExperience(exp.id, updateData);

        if (mounted) {
          _showSnackBar('Experiencia actualizada exitosamente', isError: false);
          await Future.delayed(const Duration(milliseconds: 600));
          if (mounted) Navigator.pop(context);
        }
        return;
      }

      setState(() { _isSaving = true; _statusMessage = 'Creando registro...'; });

      final now = DateTime.now();

      // 1. Crear documento base
      final newExp = ExperienceModel(
        id: '',
        companyName: _companyCtrl.text.trim(),
        industry: _selectedIndustry!,
        summary: _summaryCtrl.text.trim(),
        registrationDate: now,
        createdBy: user?.uid ?? '',
        createdByName: user?.name ?? '',
        createdByCompany: user?.company ?? '',
        attachments: [],
        createdAt: now,
        tags: _tags,
        keyChallenges: _keyChallenges,
        keyBenefits: _keyBenefits,
        link: linkValue.isNotEmpty ? linkValue : null,
      );
      final docId = await expProvider.addExperience(newExp);

      // 2. Subir archivos PDF
      if (_files.isNotEmpty) {
        final attachmentMaps = <Map<String, dynamic>>[];

        for (int i = 0; i < _files.length; i++) {
          setState(() => _statusMessage =
              'Subiendo archivo ${i + 1}/${_files.length}: ${_files[i]['name']}');

          final att = await _storageService.uploadPdf(
            bytes: _files[i]['bytes'] as Uint8List,
            fileName: _files[i]['name'] as String,
            experienceId: docId,
            onProgress: (p) => setState(() => _files[i]['progress'] = p),
          );
          setState(() => _files[i]['progress'] = 1.0);
          attachmentMaps.add(att.toMap());
        }

        // 3. Actualizar con attachments
        await expProvider.updateExperience(docId, {'attachments': attachmentMaps});
      }

      if (mounted) {
        _showSnackBar('Experiencia guardada exitosamente', isError: false);
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar('Error al guardar: $e', isError: true);
      setState(() { _isSaving = false; _statusMessage = ''; });
    }
  }

  void _showSnackBar(String msg, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppTheme.errorRed : AppTheme.successGreen,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final isMobile = sw < 768;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 16 : sw * 0.15,
                    vertical: 20,
                  ),
                  child: _buildForm(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.white),
          ),
          Text(_isEditMode ? 'Editar Experiencia' : 'Nueva Experiencia',
              style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E293B)
            : AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Información de la Experiencia',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Los campos con * son obligatorios',
                style:
                    TextStyle(fontSize: 13, color: AppTheme.textGray)),
            const SizedBox(height: 24),

            // Empresa
            _label('Nombre de la Empresa *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _companyCtrl,
              validator: (v) => Validators.required(v, 'El nombre de empresa'),
              decoration: const InputDecoration(
                hintText: 'Ej: Banco Nacional S.A.',
                prefixIcon: Icon(Icons.business_outlined,
                    color: AppTheme.primaryBlue),
              ),
            ),
            const SizedBox(height: 18),

            // Industria
            _label('Industria / Sector *'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedIndustry,
              validator: (v) => v == null ? 'Selecciona un sector' : null,
              decoration: const InputDecoration(
                hintText: 'Selecciona un sector',
                prefixIcon: Icon(Icons.category_outlined,
                    color: AppTheme.primaryBlue),
              ),
              items: _industries
                  .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedIndustry = v),
            ),
            const SizedBox(height: 18),

            // Link de Referencia (opcional)
            _label('Link de Referencia'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _linkCtrl,
              keyboardType: TextInputType.url,
              validator: Validators.url,
              decoration: const InputDecoration(
                hintText: 'https://ejemplo.com/articulo',
                prefixIcon: Icon(Icons.link_outlined,
                    color: AppTheme.primaryBlue),
              ),
            ),
            const SizedBox(height: 18),

            // Resumen con contador
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _label('Resumen de la Experiencia *'),
                ValueListenableBuilder(
                  valueListenable: _summaryCtrl,
                  builder: (_, val, __) {
                    final count = (val as TextEditingValue).text.trim().length;
                    return Text(
                      '$count / mín. 50',
                      style: TextStyle(
                        fontSize: 12,
                        color: count >= 50
                            ? AppTheme.successGreen
                            : AppTheme.textGray,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _summaryCtrl,
              maxLines: 6,
              validator: Validators.summary,
              decoration: const InputDecoration(
                hintText: 'Describe la implementación, retos, soluciones '
                    'y lecciones aprendidas (mínimo 50 caracteres)...',
              ),
            ),
            if (context.watch<ExperienceProvider>().isAiEnabled) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _isAnalyzing || _isSaving ? null : _analyzeWithAI,
                  icon: _isAnalyzing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.primaryBlue,
                          ),
                        )
                      : const Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
                  label: Text(
                    _isAnalyzing ? 'Analizando con IA...' : 'Analizar e Instalar Insights con IA',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                  ),
                ),
              ),
            ],
            if (_tags.isNotEmpty || _keyChallenges.isNotEmpty || _keyBenefits.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Insights Generados por IA',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? AppTheme.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    
                    // Tags / Etiquetas
                    if (_tags.isNotEmpty) ...[
                      const Text(
                        'Etiquetas Sugeridas:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textGray),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _tags.map((tag) {
                          return Chip(
                            label: Text(tag, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                            backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            deleteIcon: const Icon(Icons.close, size: 14, color: AppTheme.primaryBlue),
                            onDeleted: () => setState(() => _tags.remove(tag)),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // Retos
                    if (_keyChallenges.isNotEmpty) ...[
                      const Text(
                        'Retos Clave Identificados:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textGray),
                      ),
                      const SizedBox(height: 6),
                      ..._keyChallenges.map((challenge) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 4, right: 8),
                              child: Icon(Icons.error_outline_rounded, color: Colors.orange, size: 14),
                            ),
                            Expanded(
                              child: Text(
                                challenge,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(height: 12),
                    ],
                    
                    // Beneficios
                    if (_keyBenefits.isNotEmpty) ...[
                      const Text(
                        'Beneficios y Lecciones:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textGray),
                      ),
                      const SizedBox(height: 6),
                      ..._keyBenefits.map((benefit) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 4, right: 8),
                              child: Icon(Icons.check_circle_outline, color: AppTheme.successGreen, size: 14),
                            ),
                            Expanded(
                              child: Text(
                                benefit,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),

            // Adjuntos
            const Divider(),
            const SizedBox(height: 16),
            _label('Archivos PDF Adjuntos'),
            const SizedBox(height: 4),
            const Text(
                'Solo .pdf · Máximo 10 MB por archivo · Múltiples archivos',
                style: TextStyle(fontSize: 12, color: AppTheme.textGray)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _isSaving ? null : _pickFiles,
              icon: const Icon(Icons.attach_file, size: 18),
              label: const Text('Adjuntar PDF'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryBlue,
                side: const BorderSide(
                    color: AppTheme.primaryBlue, width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
              ),
            ),

            // Lista de archivos con barra de progreso
            if (_files.isNotEmpty) ...[
              const SizedBox(height: 14),
              ..._files.asMap().entries.map((entry) {
                final i   = entry.key;
                final f   = entry.value;
                final progress = (f['progress'] as double?) ?? 0.0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.picture_as_pdf,
                              color: Color(0xFFEF4444), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              f['name'] as String,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!_isSaving)
                            IconButton(
                              onPressed: () => _removeFile(i),
                              icon: const Icon(Icons.close,
                                  color: AppTheme.textGray, size: 18),
                              constraints: const BoxConstraints(
                                  minWidth: 28, minHeight: 28),
                              padding: EdgeInsets.zero,
                            ),
                        ],
                      ),
                      // Barra de progreso por archivo
                      if (_isSaving && progress < 1.0) ...[
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress == 0.0 ? null : progress,
                            backgroundColor: const Color(0xFFE2E8F0),
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(
                                    AppTheme.primaryBlue),
                            minHeight: 5,
                          ),
                        ),
                      ],
                      if (_isSaving && progress >= 1.0) ...[
                        const SizedBox(height: 4),
                        const Row(
                          children: [
                            Icon(Icons.check_circle,
                                color: AppTheme.successGreen, size: 14),
                            SizedBox(width: 4),
                            Text('Subido',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.successGreen)),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              }),
            ],

            // Mensaje de estado durante guardado
            if (_isSaving && _statusMessage.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                _statusMessage,
                style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w500),
              ),
            ],

            const SizedBox(height: 28),

            // Botón guardar
            GradientButton(
              label: _isEditMode ? 'Actualizar Experiencia' : 'Guardar Experiencia',
              onPressed: _isSaving ? null : _save,
              isLoading: _isSaving,
              width: double.infinity,
              height: 54,
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600),
      );
}
