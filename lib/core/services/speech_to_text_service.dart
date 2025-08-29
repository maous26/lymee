import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SpeechToTextService {
  static final SpeechToTextService _instance = SpeechToTextService._internal();
  factory SpeechToTextService() => _instance;
  SpeechToTextService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isAvailable = false;
  String _lastWords = '';

  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;
  String get lastWords => _lastWords;

  /// Initialise le service de reconnaissance vocale
  Future<bool> initialize() async {
    try {
      // Demander permission microphone
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        debugPrint('❌ Permission microphone refusée');
        return false;
      }

      // Initialiser speech-to-text
      _isAvailable = await _speech.initialize(
        onStatus: (status) {
          debugPrint('🎤 Speech status: $status');
          _isListening = status == 'listening';
        },
        onError: (error) {
          debugPrint('❌ Speech error: $error');
          _isListening = false;
        },
      );

      debugPrint('🎤 Speech-to-text available: $_isAvailable');
      return _isAvailable;
    } catch (e) {
      debugPrint('❌ Erreur initialisation speech: $e');
      return false;
    }
  }

  /// Démarre l'écoute avec un callback pour les mots en temps réel
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onPartialResult,
    Duration timeout = const Duration(minutes: 1),
  }) async {
    if (!_isAvailable) {
      debugPrint('❌ Speech-to-text non disponible');
      return;
    }

    if (_isListening) {
      debugPrint('⚠️ Déjà en écoute');
      return;
    }

    try {
      await _speech.listen(
        onResult: (result) {
          _lastWords = result.recognizedWords;
          if (result.finalResult) {
            onResult(_lastWords);
          } else {
            onPartialResult(_lastWords);
          }
        },
        listenFor: timeout,
        pauseFor: const Duration(seconds: 3),
        localeId: 'fr_FR', // Français
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.confirmation,
        ),
      );

      _isListening = true;
      debugPrint('🎤 Écoute démarrée');
    } catch (e) {
      debugPrint('❌ Erreur démarrage écoute: $e');
      _isListening = false;
    }
  }

  /// Arrête l'écoute
  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      debugPrint('🎤 Écoute arrêtée');
    }
  }

  /// Annule l'écoute
  Future<void> cancelListening() async {
    if (_isListening) {
      await _speech.cancel();
      _isListening = false;
      _lastWords = '';
      debugPrint('🎤 Écoute annulée');
    }
  }

  /// Vérifie les langues disponibles
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (!_isAvailable) return [];
    return await _speech.locales();
  }

  /// Nettoie les ressources
  void dispose() {
    if (_isListening) {
      _speech.stop();
    }
  }
}
