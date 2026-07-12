import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/logger.dart';

class AIService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  
  // Custom API key. Developers/users can set this.
  static String? apiKey;

  static Future<String> getAIResponse(String prompt) async {
    final key = apiKey;
    if (key == null || key.trim().isEmpty) {
      AppLogger.info('Gemini API key is not set. Falling back to Local Health Expert Engine.');
      return _getLocalFallbackResponse(prompt);
    }

    try {
      final url = Uri.parse('$_baseUrl?key=$key');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text': 'You are a helpful, professional, and empathetic AI clinical assistant named FastCure AI. '
                      'Help the user with symptom checking, medicine information, health tips, or medical FAQs. '
                      'Give concise, clear answers in markdown bullet points. '
                      'Always include a professional disclaimer: "Disclaimer: This is for educational purposes. Consult a doctor for diagnostic help."\n\n'
                      'User Query: $prompt'
                }
              ]
            }
          ]
        }),
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String text = data['candidates'][0]['content']['parts'][0]['text'];
        return text;
      } else {
        AppLogger.error('Gemini API error. Status: ${response.statusCode}');
        return _getLocalFallbackResponse(prompt);
      }
    } catch (e) {
      AppLogger.error('Gemini API connection error: $e');
      return _getLocalFallbackResponse(prompt);
    }
  }

  static String _getLocalFallbackResponse(String prompt) {
    final query = prompt.toLowerCase();

    // 1. Symptom Checker
    if (query.contains('symptom') || query.contains('fever') || query.contains('pain') || query.contains('cough') || query.contains('headache')) {
      return '### 🩺 FastCure Symptom Checker (Offline Mode)\n\n'
          '*   **Mild Fever / Headache**: Ensure adequate hydration, rest, and consider over-the-counter antipyretics (e.g. Paracetamol). Monitor temperature hourly.\n'
          '*   **Chest Pain / Pressure**: ⚠️ **Warning!** If chest pain is crushing, radiates to your arm, or is accompanied by shortness of breath, please call emergency services immediately.\n'
          '*   **Dry Cough**: Drink warm tea, use saline gargles, and keep your room humidified.\n\n'
          '*Disclaimer: This suggestion is for informational purposes only and does not replace diagnostic evaluations. Please consult a qualified practitioner.*';
    }

    // 2. Medicine Info
    if (query.contains('medicine') || query.contains('paracetamol') || query.contains('amoxicillin') || query.contains('drug') || query.contains('dose')) {
      return '### 💊 FastCure Medicine Information (Offline Mode)\n\n'
          '*   **Paracetamol (650mg)**: Used to manage fever and moderate body pain. Standard adult dosage is 1 tablet every 6 hours (Max 4g/day to prevent hepatotoxicity).\n'
          '*   **Amoxicillin (500mg)**: Broad-spectrum penicillin antibiotic used for bacterial respiratory, urinary, and ear infections. Finish full prescription course to prevent antibiotic resistance.\n'
          '*   **Atorvastatin (20mg)**: Cardiovascular HMG-CoA reductase inhibitor (Statin) taken at bedtime to lower LDL cholesterol and mitigate cardiac risks.\n\n'
          '*Disclaimer: Consult your doctor or clinical pharmacist before starting any new drugs.*';
    }

    // 3. Health Tips
    if (query.contains('tip') || query.contains('healthy') || query.contains('exercise') || query.contains('diet')) {
      return '### 🥗 FastCure Health Tips (Offline Mode)\n\n'
          '*   **Hydration**: Drink at least 2.5 - 3 liters of purified water daily to optimize kidney filtration and metabolic rates.\n'
          '*   **Daily Cardio**: Engage in at least 30 minutes of moderate aerobic activity (e.g. brisk walking) 5 times a week to improve heart function.\n'
          '*   **Sleep Quality**: Aim for 7-8 hours of sleep. Keep screen devices away at least 1 hour before bedtime to stimulate melatonin production.\n\n'
          '*Disclaimer: General guidelines. Tailor exercises according to personal clinical clearance.*';
    }

    // 4. FAQ Chatbot general fallback
    return '### 🤖 FastCure Health FAQ Bot (Offline Mode)\n\n'
        'Hello! I can help you check symptoms, look up medicine dosages, give daily health tips, and answer clinical questions.\n\n'
        '**Quick Prompts to try:**\n'
        '*   *Check symptoms for fever & headache*\n'
        '*   *What is the dosage of Paracetamol?*\n'
        '*   *Give me daily healthy living tips*\n\n'
        '*Disclaimer: Chat answers are educational. Always verify with clinicians for definitive diagnostic plans.*';
  }
}
