import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SpeechService extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _lastWords = '';
  VoidCallback? _onDhikrDetected;

  bool get isListening => _isListening;
  String get lastWords => _lastWords;

  Future<bool> initialize() async {
    try {
      final status = await Permission.microphone.request();
      if (!status.isGranted) return false;

      return await _speech.initialize(
        onError: (val) {
          _isListening = false;
          notifyListeners();
        },
        onStatus: (val) {
          if (val == 'done' || val == 'notListening') {
            _isListening = false;
            notifyListeners();
          }
        },
      );
    } catch (_) {
      return false;
    }
  }

  Future<void> startListening({
    required VoidCallback onDhikrDetected,
    String? expectedPhrase,
  }) async {
    _onDhikrDetected = onDhikrDetected;
    bool available = await initialize();
    if (!available) return;

    _isListening = true;
    _lastWords = '';
    notifyListeners();

    try {
      await _speech.listen(
        onResult: (val) {
          _lastWords = val.recognizedWords;
          notifyListeners();

          if (val.finalResult) {
            _processSpeechResult(val.recognizedWords, expectedPhrase);
          }
        },
        localeId: 'ar_SA', // Listen specifically in Arabic
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
      );
    } catch (_) {
      _isListening = false;
      notifyListeners();
    }
  }

  void _processSpeechResult(String recognizedText, String? expectedPhrase) {
    final text = recognizedText.trim();
    if (text.isEmpty) return;

    // List of common islamic phrases to match if no specific phrase is expected
    final commonPhrases = [
      'سبحان الله',
      'الحمد لله',
      'الله أكبر',
      'استغفر الله',
      'أستغفر الله',
      'لا إله إلا الله',
      'يا رب',
      'اللهم صل',
    ];

    bool matched = false;

    if (expectedPhrase != null && expectedPhrase.isNotEmpty) {
      // Clean up string comparison for Arabic diacritics
      final cleanExpected = _cleanArabic(expectedPhrase);
      final cleanRecognized = _cleanArabic(text);

      if (cleanRecognized.contains(cleanExpected) || 
          cleanExpected.contains(cleanRecognized)) {
        matched = true;
      }
    }

    // Fallback to match general tasbeeh keywords
    if (!matched) {
      final cleanRecognized = _cleanArabic(text);
      for (var phrase in commonPhrases) {
        if (cleanRecognized.contains(_cleanArabic(phrase))) {
          matched = true;
          break;
        }
      }
    }

    // Always increment on any recognizable vocal attempt if speaking
    if (matched || text.length >= 4) {
      _onDhikrDetected?.call();
    }
  }

  // Help normalize Arabic letters to make matching resilient
  String _cleanArabic(String text) {
    return text
        .replaceAll(RegExp(r'[\u064B-\u0652]'), '') // Remove Harakat (diacritics)
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ة', 'ه')
        .replaceAll('ى', 'ي')
        .toLowerCase();
  }

  Future<void> stopListening() async {
    await _speech.stop();
    _isListening = false;
    notifyListeners();
  }
}
