import 'package:flutter/material.dart';
import '../services/translation_service.dart';

class TranslationProvider extends ChangeNotifier {
  String _currentLanguageCode = 'en'; 
  String get currentLanguageCode => _currentLanguageCode;

  final TranslationService _translator = TranslationService();

  void setLanguage(String languageCode) {
    print('TranslationProvider: Setting language to $languageCode');
    _currentLanguageCode = languageCode;
    notifyListeners();
    print('TranslationProvider: Language changed to $languageCode');
  }

  Future<String> translate(String text) async {
    print(
      'TranslationProvider: Requested translation for "$text" to $_currentLanguageCode',
    );

    if (_currentLanguageCode == 'en') {
      print('TranslationProvider: Skipping translation (already English)');
      return text;
    }

    try {
      final result = await _translator.translate(
        text: text,
        sourceLang: 'en',
        targetLang: _currentLanguageCode,
      );
      print('TranslationProvider: Successfully translated "$text"');
      return result;
    } catch (e) {
      print('TranslationProvider: Translation failed for "$text": $e');
      return text;
    }
  }

  Future<List<String>> translateList(List<String> texts) async {
    print('TranslationProvider: Translating list of ${texts.length} items');
    final results = <String>[];
    for (final text in texts) {
      results.add(await translate(text));
    }
    print('TranslationProvider: Completed list translation');
    return results;
  }
}
