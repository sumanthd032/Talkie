import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:talkie/secrets.dart';

class CombinedService {
  final List<Map<String, String>> messages = [];
  final FlutterTts flutterTts = FlutterTts();

  CombinedService() {
    flutterTts.setCompletionHandler(() {
      // Handle completion if needed
    });
  }

  Future<String> generateTextGemini(String prompt, String character) async {
    final String systemPrompt = character.isEmpty
        ? "You are a helpful assistant. Respond to the user's queries in a simple and clear language, tries to answer in one or two sentence if not required. Speak in the user's language for each query, no need of english translation if language is other than english.For simple questions give simple answer"
        : "You are $character. You never break character. Even if the user asks you a question that is not related to your persona, you will find a way to answer it with an appropriate twist. Speak in the same language of the user during each query,no need of english translation if language is other than english,  use simple and clear language. Do not speak emojis or symbols.for simple questions give simple answer, dont forgot your character";

    messages.add({'role': 'user', 'content': prompt});

    try {
      final response = await http.post(
        Uri.parse(gemini), // Using the gemini variable from secrets.dart
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': '$systemPrompt\n${messages.map((message) => "${message['role']}: ${message['content']}").join('\n')}'}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        String aiResponse = decodedResponse['candidates'][0]['content']['parts'][0]['text'];

      

        messages.add({'role': 'assistant', 'content': aiResponse});
        return aiResponse;
      } else {
        return 'Error generating response: ${response.statusCode}';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

 
  Future<String> generateImageHuggingFace(String prompt) async {
    messages.add({'role': 'user', 'content': prompt});

    final String huggingFaceApiKey = hugFace; // Using the hugFace variable from secrets.dart
    final String huggingFaceModel = 'stabilityai/stable-diffusion-2-1';

    try {
      final response = await http.post(
        Uri.parse('https://api-inference.huggingface.co/models/$huggingFaceModel'),
        headers: {
          'Authorization': 'Bearer $huggingFaceApiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'inputs': prompt}),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        if (decodedResponse is List && decodedResponse.isNotEmpty) {
          if (decodedResponse[0] is String) {
            String imageData = decodedResponse[0];
            String imageUrl = 'data:image/png;base64,$imageData';

            messages.add({'role': 'assistant', 'content': imageUrl});
            return imageUrl;
          } else {
            return "Image data format error.";
          }
        } else {
          return "Image response structure error.";
        }
      } else {
        return 'Hugging Face API Error: ${response.statusCode}, ${response.body}';
      }
    } catch (e) {
      return 'Hugging Face API Exception: $e';
    }
  }

  Future<String> isImagePrompt(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse(gemini), // Using the gemini variable from secrets.dart
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': "Is the following prompt a request for an image? answer only yes or no. $prompt"}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        final answer =
            decodedResponse['candidates'][0]['content']['parts'][0]['text'];
        return answer;
      } else {
        return 'no';
      }
    } catch (e) {
      return 'no';
    }
  }

  Future<void> speakResponse(String text) async {
    await flutterTts.speak(text);
  }

  Future<String> detectLanguage(String text) async {
    // Conceptual Code. Replace with your language detection logic.
    try {
      final response = await http.post(
        Uri.parse(gemini), // Using the gemini variable from secrets.dart
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': "What is the language of this text? answer with the language name. $text"}
              ]
            }
          ]
        }),
      );
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        final language =
            decodedResponse['candidates'][0]['content']['parts'][0]['text'];
        return language;
      } else {
        return 'en';
      }
    } catch (e) {
      return 'en';
    }
  }
}