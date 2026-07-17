import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> with SingleTickerProviderStateMixin {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  bool _isListening = false;
  double _waveformScale = 1.0;
  Timer? _waveformTimer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _waveformTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _submitMessage(ChatProvider provider, String text) {
    if (text.trim().isEmpty) return;
    provider.sendMessage(text.trim());
    _textController.clear();
    _scrollToBottom();
  }

  void _toggleListening(ChatProvider provider) {
    if (_isListening) {
      setState(() {
        _isListening = false;
      });
      _waveformTimer?.cancel();
      _submitMessage(provider, "I have been experiencing a mild fever and headache for 2 days, what could it be?");
    } else {
      setState(() {
        _isListening = true;
      });
      _waveformTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
        setState(() {
          _waveformScale = 0.6 + (0.8 * (0.5 - (0.5 * (timer.tick % 3))));
        });
      });
    }
  }

  bool _isEmergency(String text) {
    final lower = text.toLowerCase();
    return lower.contains('chest pain') ||
        lower.contains('breathing') ||
        lower.contains('shortness of breath') ||
        lower.contains('heart attack') ||
        lower.contains('stroke') ||
        lower.contains('unconscious') ||
        lower.contains('heavy bleeding') ||
        lower.contains('difficulty breathing') ||
        lower.contains('choking');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = Provider.of<ChatProvider>(context);
    final messages = provider.messages;

    // Detect if user has entered any potentially life-threatening messages
    final hasEmergency = messages.any((msg) => msg.isUser && _isEmergency(msg.text));

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.assistant_rounded, color: Color(0xFF2563EB), size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              'FastCure AI',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            color: Colors.grey[500],
            tooltip: 'Clear History',
            onPressed: () => provider.clearChat(),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Pinned Safety Disclaimer Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF2563EB)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'FastCure AI provides general health information and is not a substitute for professional medical advice, diagnosis, or treatment.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[300] : const Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Emergency Banner Warning if life-threatening keywords detected
            if (hasEmergency)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: const Color(0xFFFEE2E2),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 20, color: Color(0xFFB91C1C)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'WARNING: Potentially life-threatening symptoms described. Please seek emergency medical care immediately or call emergency services (e.g. 911).',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF991B1B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Message Thread or Welcome screen
            Expanded(
              child: messages.length <= 1
                  ? _buildWelcomeScreen(provider, theme, isDark)
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16.0),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        return _buildMessageBubble(msg, theme, isDark);
                      },
                    ),
            ),

            // Generative loading indicator
            if (provider.isWriting)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF2563EB)),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'AI clinical assistant is typing...',
                      style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),

            // Voice dictation waveform mockup panel
            if (_isListening)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                color: const Color(0xFF2563EB).withOpacity(0.08),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.mic_rounded, color: Color(0xFF2563EB)),
                    const SizedBox(width: 8),
                    Text(
                      'Listening to clinical description...',
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF2563EB)),
                    ),
                    const SizedBox(width: 16),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 24,
                      height: 24 * _waveformScale,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),

            // Input Send bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _textController,
                      style: theme.textTheme.bodyLarge,
                      decoration: InputDecoration(
                        hintText: 'Describe symptoms or ask health questions...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.0),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.0),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.0),
                          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                        ),
                        fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        filled: true,
                      ),
                      onFieldSubmitted: (val) => _submitMessage(provider, val),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: () => _toggleListening(provider),
                    icon: Icon(_isListening ? Icons.stop_rounded : Icons.mic_rounded),
                    color: _isListening ? Colors.red : const Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 4),
                  IconButton.filled(
                    onPressed: () => _submitMessage(provider, _textController.text),
                    icon: const Icon(Icons.send_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen(ChatProvider provider, ThemeData theme, bool isDark) {
    final suggestedPrompts = [
      {'label': 'Symptom Checker', 'icon': Icons.health_and_safety_rounded, 'query': 'Help me check symptoms for a health concern.'},
      {'label': 'Medicine Info', 'icon': Icons.medical_services_rounded, 'query': 'Provide info on common medications.'},
      {'label': 'Prescription Guide', 'icon': Icons.description_rounded, 'query': 'Explain dosage instructions for a prescription.'},
      {'label': 'Diet Suggestions', 'icon': Icons.restaurant_rounded, 'query': 'Give me healthy diet suggestions.'},
      {'label': 'BMI Calculator', 'icon': Icons.calculate_rounded, 'query': 'Help me calculate my Body Mass Index (BMI).'},
      {'label': 'Heart Health', 'icon': Icons.favorite_rounded, 'query': 'What are some tips for a healthy heart?'},
      {'label': 'Emergency Help', 'icon': Icons.warning_rounded, 'query': 'Show guidance on what to do in case of a medical emergency.'},
      {'label': 'Book Appointment', 'icon': Icons.calendar_month_rounded, 'query': 'Help me book a clinic appointment.'},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          Text(
            "Hello! I'm FastCure AI.",
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            "How can I help you today?",
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Text(
            'Suggested Topics',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: suggestedPrompts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.1,
            ),
            itemBuilder: (context, index) {
              final item = suggestedPrompts[index];
              return Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _submitMessage(provider, item['query'] as String),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item['icon'] as IconData, color: const Color(0xFF2563EB), size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item['label'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        ),
                      ],
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

  Widget _buildMessageBubble(dynamic msg, ThemeData theme, bool isDark) {
    final isUser = msg.isUser;
    final alignment = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    final bubbleColor = isUser
        ? const Color(0xFF2563EB)
        : (isDark ? const Color(0xFF1E293B) : Colors.white);

    final textColor = isUser
        ? Colors.white
        : (isDark ? Colors.white : const Color(0xFF0F172A));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 290),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(0),
                bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.1 : 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              border: isUser
                  ? null
                  : Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
            ),
            child: Text(
              msg.text,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              DateFormat('hh:mm a').format(msg.timestamp),
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, color: Colors.grey[500]),
            ),
          ),
        ],
      ),
    );
  }
}
