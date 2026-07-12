import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/ai_service.dart';
import '../../data/models/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isWriting = false;

  List<ChatMessage> get messages => _messages;
  bool get isWriting => _isWriting;

  ChatProvider() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? encoded = prefs.getString('fastcure_chat_history');
      if (encoded != null) {
        final List<dynamic> decoded = jsonDecode(encoded);
        _messages.clear();
        _messages.addAll(decoded.map((m) => ChatMessage.fromMap(Map<String, dynamic>.from(m))));
      } else {
        _addGreeting();
      }
    } catch (e) {
      _addGreeting();
    }
    notifyListeners();
  }

  void _addGreeting() {
    _messages.add(
      ChatMessage(
        text: 'Hello! I am your FastCure AI clinical assistant. How can I help you today?\n\n'
            'You can check symptoms, request medicine details, or ask clinical FAQs.',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_messages.map((m) => m.toMap()).toList());
      await prefs.setString('fastcure_chat_history', encoded);
    } catch (_) {}
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMsg);
    _isWriting = true;
    notifyListeners();
    await _saveHistory();

    try {
      final responseText = await AIService.getAIResponse(text);
      final aiMsg = ChatMessage(
        text: responseText,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(aiMsg);
    } catch (e) {
      _messages.add(
        ChatMessage(
          text: 'An error occurred while connecting to the clinic server. Please check your connection.',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } finally {
      _isWriting = false;
      notifyListeners();
      await _saveHistory();
    }
  }

  Future<void> clearChat() async {
    _messages.clear();
    _addGreeting();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('fastcure_chat_history');
  }
}
