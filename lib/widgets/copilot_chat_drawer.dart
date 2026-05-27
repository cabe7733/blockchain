import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/experience_provider.dart';
import '../theme/app_theme.dart';

class CopilotChatDrawer extends StatefulWidget {
  const CopilotChatDrawer({super.key});

  @override
  State<CopilotChatDrawer> createState() => _CopilotChatDrawerState();
}

class _CopilotChatDrawerState extends State<CopilotChatDrawer> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  static const List<String> _suggestions = [
    '¿Qué industrias usan más Blockchain?',
    '¿Cuáles son los retos comunes en Logística?',
    'Comparar proyectos en Finanzas',
    '¿Hay fallos reportados con Ethereum?',
  ];

  @override
  void initState() {
    super.initState();
    // Inicializar sesión RAG al abrir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExperienceProvider>().initCopilotSession();
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _sendMessage([String? text]) async {
    final message = text ?? _msgCtrl.text.trim();
    if (message.isEmpty) return;

    if (text == null) {
      _msgCtrl.clear();
    }

    final provider = context.read<ExperienceProvider>();
    await provider.sendCopilotMessage(message);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExperienceProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Ejecuta scroll al final si la IA empieza a responder
    if (provider.isAiResponding) {
      _scrollToBottom();
    }

    return Drawer(
      width: MediaQuery.of(context).size.width > 450 ? 420 : double.infinity,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : AppTheme.white,
          border: Border(
            left: BorderSide(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, provider, isDark),
              const Divider(height: 1),
              Expanded(
                child: !provider.isAiEnabled
                    ? _buildDisabledState(isDark)
                    : _buildChatBody(provider, isDark),
              ),
              const Divider(height: 1),
              if (provider.isAiEnabled) _buildInputField(provider, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ExperienceProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome, color: AppTheme.primaryBlue, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Copilot de Blockchain',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: provider.isAiEnabled ? AppTheme.successGreen : Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          if (provider.isAiEnabled)
                            BoxShadow(
                              color: AppTheme.successGreen.withValues(alpha: 0.5),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      provider.isAiEnabled ? 'Activo (RAG)' : 'Deshabilitado',
                      style: const TextStyle(fontSize: 11, color: AppTheme.textGray),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (provider.isAiEnabled)
            IconButton(
              icon: const Icon(Icons.refresh, size: 20, color: AppTheme.textGray),
              tooltip: 'Reiniciar Chat',
              onPressed: provider.isAiResponding ? null : () => provider.clearChat(),
            ),
          IconButton(
            icon: const Icon(Icons.close, size: 20, color: AppTheme.textGray),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDisabledState(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 64, color: AppTheme.textGray.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text(
            'IA no inicializada',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Para usar el Copilot, inicia la aplicación pasando tu clave API con --dart-define:\n\n'
            'flutter run -d chrome --dart-define=GEMINI_API_KEY=tu_api_key',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppTheme.textGray, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBody(ExperienceProvider provider, bool isDark) {
    final messages = provider.chatMessages;

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length + (provider.isAiResponding ? 1 : 0) + (messages.length <= 1 ? 1 : 0),
      itemBuilder: (context, index) {
        // Mostrar sugerencias si solo está el mensaje de bienvenida y estamos en el index final
        if (messages.length <= 1 && index == messages.length) {
          return _buildSuggestionsGrid(isDark);
        }

        // Mostrar burbuja de IA pensando al final
        if (provider.isAiResponding && index == messages.length + (messages.length <= 1 ? 1 : 0)) {
          return _buildAiThinkingBubble(isDark);
        }

        if (index >= messages.length) return const SizedBox();

        final msg = messages[index];
        final isUser = msg['sender'] == 'user';

        return _buildMessageBubble(msg['text'] ?? '', isUser, isDark);
      },
    );
  }

  Widget _buildSuggestionsGrid(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preguntas sugeridas:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.textGray : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.2,
            ),
            itemCount: _suggestions.length,
            itemBuilder: (context, idx) {
              final suggestion = _suggestions[idx];
              return InkWell(
                onTap: () => _sendMessage(suggestion),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      suggestion,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.blue[300] : AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser, bool isDark) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: isUser ? AppTheme.buttonGradient : null,
          color: isUser
              ? null
              : isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFF1F5F9),
          border: isUser
              ? null
              : Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  width: 1,
                ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isUser ? 0.1 : 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _buildParsedText(text, isUser, isDark),
      ),
    );
  }

  Widget _buildAiThinkingBubble(bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.zero,
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, color: Colors.amber, size: 14),
            const SizedBox(width: 8),
            Text(
              'Pensando',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: isDark ? AppTheme.textGray : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 4),
            const _AnimatedDots(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(ExperienceProvider provider, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: isDark ? const Color(0xFF0F172A) : AppTheme.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              enabled: !provider.isAiResponding,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: const TextStyle(fontSize: 14),
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'Pregunta sobre experiencias blockchain...',
                hintStyle: const TextStyle(color: AppTheme.textGray, fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.buttonGradient,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: AppTheme.white, size: 18),
              onPressed: provider.isAiResponding ? null : () => _sendMessage(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParsedText(String text, bool isUser, bool isDark) {
    final Color textColor = isUser
        ? AppTheme.white
        : isDark
            ? AppTheme.white
            : const Color(0xFF1E293B);

    if (isUser) {
      return Text(
        text,
        style: TextStyle(color: textColor, fontSize: 13, height: 1.4),
      );
    }

    final List<TextSpan> spans = [];
    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      var line = lines[i];

      bool isBullet = false;
      if (line.startsWith('- ') || line.startsWith('* ')) {
        isBullet = true;
        line = '•  ${line.substring(2)}';
      }

      final regex = RegExp(r'\*\*(.*?)\*\*');
      int currentPos = 0;
      final List<TextSpan> lineSpans = [];

      final matches = regex.allMatches(line);
      for (final match in matches) {
        if (match.start > currentPos) {
          lineSpans.add(TextSpan(
            text: line.substring(currentPos, match.start),
            style: const TextStyle(fontWeight: FontWeight.normal),
          ));
        }
        lineSpans.add(TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ));
        currentPos = match.end;
      }

      if (currentPos < line.length) {
        lineSpans.add(TextSpan(
          text: line.substring(currentPos),
          style: const TextStyle(fontWeight: FontWeight.normal),
        ));
      }

      if (i < lines.length - 1) {
        lineSpans.add(const TextSpan(text: '\n'));
      }

      spans.add(TextSpan(
        children: lineSpans,
        style: TextStyle(
          height: isBullet ? 1.6 : 1.4,
          fontSize: 13,
        ),
      ));
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: TextStyle(color: textColor),
      ),
    );
  }
}

class _AnimatedDots extends StatefulWidget {
  const _AnimatedDots();

  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.15;
            final value = ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
            final opacity = value < 0.5 ? value * 2 : (1 - value) * 2;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.5),
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: opacity * 0.7),
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
