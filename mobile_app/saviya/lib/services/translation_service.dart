import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  final String apiUrl = "https://libretranslate.de/translate";

  Future<String> translate({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    print(
      'TranslationService: Translating "$text" from $sourceLang to $targetLang',
    );

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "q": text,
          "source": sourceLang,
          "target": targetLang,
          "format": "text",
        }),
      );

      print(
        'TranslationService: Response status code: ${response.statusCode}',
      );
      print('TranslationService: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final translatedText = jsonDecode(response.body)["translatedText"];
        print(
          'TranslationService: Successfully translated to: "$translatedText"',
        );
        return translatedText;
      } else {
        print(
          'TranslationService: Failed with status ${response.statusCode}',
        );
        throw Exception("Translation failed: ${response.body}");
      }
    } catch (e) {
      print('TranslationService: Error occurred: $e');
      throw Exception("Translation error: $e");
    }
  }
}
