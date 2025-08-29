import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImageGenerationService {
  static final ImageGenerationService _instance =
      ImageGenerationService._internal();
  factory ImageGenerationService() => _instance;
  ImageGenerationService._internal();

  static const String _baseUrl = 'https://api.openai.com/v1/images/generations';

  /// Génère une image à partir d'une description de recette
  Future<String?> generateRecipeImage({
    required String recipeName,
    required String ingredients,
    required String description,
  }) async {
    try {
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        debugPrint('❌ Clé API OpenAI manquante');
        return null;
      }

      // Construire le prompt optimisé pour la génération d'images de recettes
      final prompt =
          _buildRecipeImagePrompt(recipeName, ingredients, description);

      debugPrint('🎨 Génération image pour: $recipeName');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'dall-e-3',
          'prompt': prompt,
          'n': 1,
          'size': '1024x1024',
          'quality': 'standard',
          'style': 'natural',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final imageUrl = data['data'][0]['url'] as String;

        debugPrint('✅ Image générée: $imageUrl');
        return imageUrl;
      } else {
        debugPrint('❌ Erreur génération image: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Exception génération image: $e');
      return null;
    }
  }

  /// Construit un prompt optimisé pour la génération d'images de recettes
  String _buildRecipeImagePrompt(
      String recipeName, String ingredients, String description) {
    return '''
Create a professional, appetizing food photography image of "$recipeName".

Key ingredients: $ingredients

Description: $description

Style requirements:
- High-quality food photography
- Natural lighting, preferably soft daylight
- Clean, minimalist presentation
- Focus on the finished dish
- Attractive plating and composition
- Warm, inviting colors
- Professional restaurant-quality presentation
- Shot from a slightly elevated angle (45 degrees)
- Clean white or neutral background
- No text or watermarks

The image should look like it belongs in a premium cookbook or food magazine, showcasing the dish in its most appetizing form.
'''
        .trim();
  }

  /// Génère une image alternative avec un style différent
  Future<String?> generateAlternativeImage({
    required String recipeName,
    required String ingredients,
    String style = 'rustic',
  }) async {
    try {
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        debugPrint('❌ Clé API OpenAI manquante');
        return null;
      }

      final prompt = _buildAlternativePrompt(recipeName, ingredients, style);

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'dall-e-3',
          'prompt': prompt,
          'n': 1,
          'size': '1024x1024',
          'quality': 'standard',
          'style': style == 'artistic' ? 'vivid' : 'natural',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'][0]['url'] as String;
      }
      return null;
    } catch (e) {
      debugPrint('❌ Exception génération image alternative: $e');
      return null;
    }
  }

  String _buildAlternativePrompt(
      String recipeName, String ingredients, String style) {
    final styleDescriptions = {
      'rustic': 'rustic, homestyle cooking, wooden table, natural textures',
      'elegant':
          'elegant fine dining, sophisticated plating, luxury restaurant',
      'casual': 'casual dining, comfort food, cozy kitchen atmosphere',
      'artistic':
          'artistic food styling, creative presentation, modern gastronomy',
    };

    final styleDesc = styleDescriptions[style] ?? styleDescriptions['rustic']!;

    return '''
Food photography of "$recipeName" with $styleDesc style.

Ingredients: $ingredients

Create a beautiful, appetizing image that captures the essence of this dish in a $style setting.
Professional food photography, natural lighting, no text overlays.
'''
        .trim();
  }
}
