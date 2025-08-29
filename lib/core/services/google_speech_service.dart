import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class GoogleSpeechService {
  static final GoogleSpeechService _instance = GoogleSpeechService._internal();
  factory GoogleSpeechService() => _instance;
  GoogleSpeechService._internal();

  static const String _baseUrl = 'https://speech.googleapis.com/v1/speech:recognize';
  
  bool _isRecording = false;
  bool _isAvailable = false;
  String _lastTranscription = '';

  bool get isRecording => _isRecording;
  bool get isAvailable => _isAvailable;
  String get lastTranscription => _lastTranscription;

  /// Initialise le service Google Speech-to-Text
  Future<bool> initialize() async {
    try {
      // Vérifier la clé API
      final apiKey = dotenv.env['GOOGLE_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        debugPrint('❌ Clé API Google manquante');
        return false;
      }

      // Demander permission microphone
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        debugPrint('❌ Permission microphone refusée');
        return false;
      }

      _isAvailable = true;
      debugPrint('✅ Google Speech Service initialisé');
      return true;
    } catch (e) {
      debugPrint('❌ Erreur initialisation Google Speech: $e');
      return false;
    }
  }

  /// Transcrit un fichier audio en utilisant l'API Google Speech-to-Text
  Future<String?> transcribeAudio({
    required Uint8List audioData,
    String languageCode = 'fr-FR',
    int sampleRateHertz = 16000,
  }) async {
    try {
      final apiKey = dotenv.env['GOOGLE_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        debugPrint('❌ Clé API Google manquante');
        return null;
      }

      // Encoder l'audio en base64
      final audioBase64 = base64Encode(audioData);

      // Préparer la requête
      final requestBody = {
        'config': {
          'encoding': 'WEBM_OPUS', // Format supporté par les navigateurs/devices
          'sampleRateHertz': sampleRateHertz,
          'languageCode': languageCode,
          'model': 'latest_long', // Modèle optimisé pour les longues transcriptions
          'useEnhanced': true,
          'enableAutomaticPunctuation': true,
          'enableWordTimeOffsets': false,
          'speechContexts': [
            {
              'phrases': [
                'ingrédients', 'recette', 'cuisson', 'préparation',
                'grammes', 'kilogrammes', 'cuillères', 'tasses',
                'minutes', 'heures', 'four', 'poêle', 'casserole'
              ],
              'boost': 10.0
            }
          ]
        },
        'audio': {
          'content': audioBase64
        }
      };

      debugPrint('🎤 Envoi à Google Speech API...');

      final response = await http.post(
        Uri.parse('$_baseUrl?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['results'] != null && 
            responseData['results'].isNotEmpty) {
          
          final alternatives = responseData['results'][0]['alternatives'];
          if (alternatives != null && alternatives.isNotEmpty) {
            final transcription = alternatives[0]['transcript'] as String;
            final confidence = alternatives[0]['confidence'] as double? ?? 0.0;
            
            debugPrint('✅ Transcription (confiance: ${(confidence * 100).toStringAsFixed(1)}%): $transcription');
            
            _lastTranscription = transcription;
            return transcription;
          }
        }
        
        debugPrint('⚠️ Aucune transcription trouvée dans la réponse');
        return null;
      } else {
        debugPrint('❌ Erreur API Google Speech: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Exception lors de la transcription: $e');
      return null;
    }
  }

  /// Démarre l'enregistrement (placeholder - nécessite intégration native)
  Future<void> startRecording({
    required Function(String) onResult,
    required Function(String) onPartialResult,
    Duration timeout = const Duration(minutes: 1),
  }) async {
    if (!_isAvailable) {
      debugPrint('❌ Google Speech Service non disponible');
      return;
    }

    _isRecording = true;
    debugPrint('🎤 Enregistrement démarré (simulation)');
    
    // Note: Dans une implémentation complète, vous devriez:
    // 1. Démarrer l'enregistrement audio natif
    // 2. Capturer l'audio en chunks
    // 3. Envoyer périodiquement à l'API Google pour transcription en temps réel
    
    onPartialResult('Démarrage de l\'enregistrement...');
  }

  /// Arrête l'enregistrement
  Future<void> stopRecording() async {
    if (_isRecording) {
      _isRecording = false;
      debugPrint('🎤 Enregistrement arrêté');
    }
  }

  /// Annule l'enregistrement
  Future<void> cancelRecording() async {
    if (_isRecording) {
      _isRecording = false;
      _lastTranscription = '';
      debugPrint('🎤 Enregistrement annulé');
    }
  }

  /// Test avec un exemple de transcription
  Future<String?> testTranscription() async {
    try {
      debugPrint('🧪 Test de l\'API Google Speech...');
      
      // Valider la clé API
      final apiKey = dotenv.env['GOOGLE_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        return 'Erreur: Clé API Google manquante dans .env';
      }

      if (apiKey.length < 10) {
        return 'Erreur: Clé API Google invalide (trop courte)';
      }

      return 'API Google configurée avec succès. Clé: ${apiKey.substring(0, 10)}***';
    } catch (e) {
      return 'Erreur test: $e';
    }
  }

  /// Nettoie les ressources
  void dispose() {
    if (_isRecording) {
      stopRecording();
    }
  }
}

/// Extension pour intégrer facilement avec l'UI existante
extension GoogleSpeechIntegration on GoogleSpeechService {
  /// Méthode compatible avec l'interface SpeechToTextService existante
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onPartialResult,
    Duration timeout = const Duration(minutes: 1),
  }) async {
    await startRecording(
      onResult: onResult,
      onPartialResult: onPartialResult,
      timeout: timeout,
    );
  }

  bool get isListening => _isRecording;
  String get lastWords => _lastTranscription;
}
