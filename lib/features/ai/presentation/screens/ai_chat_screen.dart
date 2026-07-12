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

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _waveformTimer?.cancel();
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
      // Stopped dictating
      setState(() {
        _isListening = false;
      });
      _waveformTimer?.cancel();
      // Insert mock medical speech recognition
      _submitMessage(provider, "I have been experiencing a mild fever and headache for 2 days, what could it be?");
    } else {
      // Started dictating
      setState(() {
        _isListening = true;
      });
      // Waveform bouncing effect timer
      _waveformTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
        setState(() {
          _waveformScale = 0.6 + (0.8 * (0.5 - (0.5 * (timer.tick % 3))));
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ChatProvider>(context);
    final messages = provider.messages;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.assistant_rounded),
            SizedBox(width: 8),
            Text('AI Health Assistant'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Clear History',
            onPressed: () => provider.clearChat(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Suggestions Quick Actions Row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  _buildQuickActionChip(provider, '🔍 Check Symptoms', 'Check symptoms for headache and mild fever'),
                  const SizedBox(width: 8),
                  _buildQuickActionChip(provider, '💊 Medicine Info', 'Explain Amoxicillin dosage instructions'),
                  const SizedBox(width: 8),
                  _buildQuickActionChip(provider, '🥗 Health Tips', 'Give me cardiovascular health tips'),
                  const SizedBox(width: 8),
                  _buildQuickActionChip(provider, '❓ FAQ Chatbot', 'Hello, show FAQ options'),
                ],
              ),
            ),
          ),

          // Message Thread
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return _buildMessageBubble(msg, theme);
              },
            ),
          ),

          // Writing typing bubble indicator
          if (provider.isWriting) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI clinical assistant is typing...',
                    style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],

          // Voice dictation waveform popup
          if (_isListening) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: theme.colorScheme.primaryContainer.withOpacity(0.2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('Listening voice...', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 24,
                    height: 24 * _waveformScale,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Bottom Send bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Ask doctor chatbot...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                    ),
                    onSubmitted: (val) => _submitMessage(provider, val),
                  ),
                ),
                const SizedBox(width: 8),
                // Voice input button
                IconButton.filledTonal(
                  onPressed: () => _toggleListening(provider),
                  icon: Icon(_isListening ? Icons.stop_rounded : Icons.mic_rounded),
                  color: _isListening ? theme.colorScheme.error : null,
                ),
                const SizedBox(width: 4),
                IconButton.filled(
                  onPressed: () => _submitMessage(provider, _textController.text),
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionChip(ChatProvider provider, String label, String query) {
    return ActionChip(
      label: Text(label),
      onPressed: () => _submitMessage(provider, query),
    );
  }

  Widget _buildMessageBubble(dynamic msg, ThemeData theme) {
    final isUser = msg.isUser;
    final alignment = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isUser ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5);
    final textColor = isUser ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            constraints: const BoxConstraints(maxWidth: 280),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0),
                bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
              ),
            ),
            child: Text(
              msg.text,
              style: TextStyle(color: textColor, height: 1.3),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            DateFormat('hh:mm a').format(msg.timestamp),
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 10, color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }
}
