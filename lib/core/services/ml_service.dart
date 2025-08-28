// lib/core/services/ml_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lym_nutrition/data/models/recipe_feedback_model.dart';
import 'package:lym_nutrition/domain/entities/user_profile.dart';

class MLService {
  static const String _feedbackKey = 'recipe_feedback_data';
  static const String _userPreferencesKey = 'user_ml_preferences';

  // Store user feedback
  static Future<void> storeFeedback(RecipeFeedbackModel feedback) async {
    final prefs = await SharedPreferences.getInstance();

    // Get existing feedback
    List<RecipeFeedbackModel> existingFeedback = await getFeedbackHistory();

    // Add new feedback
    existingFeedback.add(feedback);

    // Keep only last 100 feedback entries to avoid storage bloat
    if (existingFeedback.length > 100) {
      existingFeedback =
          existingFeedback.sublist(existingFeedback.length - 100);
    }

    // Store updated feedback
    final feedbackJson = existingFeedback.map((f) => f.toJson()).toList();
    await prefs.setString(_feedbackKey, json.encode(feedbackJson));

    // Update user preferences based on new feedback
    await _updateUserPreferences(feedback);

    print(
        '🤖 ML: Stored feedback - Rating: ${feedback.rating}, Type: ${feedback.feedbackType}');
  }

  // Get all feedback history
  static Future<List<RecipeFeedbackModel>> getFeedbackHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final feedbackJson = prefs.getString(_feedbackKey);

    if (feedbackJson == null) return [];

    try {
      final List<dynamic> feedbackList = json.decode(feedbackJson);
      return feedbackList
          .map((json) => RecipeFeedbackModel.fromJson(json))
          .toList();
    } catch (e) {
      print('❌ ML: Error loading feedback history: $e');
      return [];
    }
  }

  // Get user ML preferences (learned patterns)
  static Future<Map<String, dynamic>> getUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final preferencesJson = prefs.getString(_userPreferencesKey);

    if (preferencesJson == null) {
      return _getDefaultPreferences();
    }

    try {
      return Map<String, dynamic>.from(json.decode(preferencesJson));
    } catch (e) {
      print('❌ ML: Error loading user preferences: $e');
      return _getDefaultPreferences();
    }
  }

  // Generate ML-enhanced recipe recommendations
  static Future<Map<String, dynamic>> generateRecipePromptEnhancements(
      UserProfile userProfile) async {
    final feedback = await getFeedbackHistory();

    if (feedback.isEmpty) {
      print('🤖 ML: No feedback history, using default preferences');
      return _getBasicPreferences(userProfile);
    }

    // Analyze feedback patterns
    final analysis = _analyzeFeedbackPatterns(feedback, userProfile);

    print(
        '🤖 ML: Generated recommendations based on ${feedback.length} feedback entries');

    return {
      'preferred_ingredients': analysis['preferred_ingredients'],
      'avoided_ingredients': analysis['avoided_ingredients'],
      'preferred_cooking_methods': analysis['preferred_cooking_methods'],
      'optimal_complexity': analysis['optimal_complexity'],
      'preferred_cooking_time': analysis['preferred_cooking_time'],
      'dietary_patterns': analysis['dietary_patterns'],
      'flavor_preferences': analysis['flavor_preferences'],
      'ml_confidence_score': analysis['confidence_score'],
    };
  }

  // Analyze feedback patterns using simple ML algorithms
  static Map<String, dynamic> _analyzeFeedbackPatterns(
      List<RecipeFeedbackModel> feedback, UserProfile userProfile) {
    Map<String, double> ingredientScores = {};
    List<int> complexityRatings = [];
    List<int> timeRatings = [];
    Map<String, int> tagCounts = {};

    // Analyze each feedback entry
    for (var fb in feedback) {
      final features = fb.toMLFeatures();
      final rating = fb.rating.toDouble();
      final weight = _calculateFeedbackWeight(fb, DateTime.now());

      // Weight ratings by recency (newer feedback has more weight)
      final weightedRating = rating * weight;

      // Analyze tags/ingredients
      for (String tag in fb.tags) {
        ingredientScores[tag] = (ingredientScores[tag] ?? 0) + weightedRating;
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }

      // Analyze complexity preferences
      if (features['recipe_complexity'] != null) {
        complexityRatings.add((rating * features['recipe_complexity']).round());
      }

      // Analyze time preferences
      if (features['cooking_time'] != null && features['cooking_time'] > 0) {
        timeRatings.add((rating * features['cooking_time']).round());
      }
    }

    // Calculate preferences
    final preferredIngredients = ingredientScores.entries
        .where((e) => e.value >= 3.5 && tagCounts[e.key]! >= 2)
        .map((e) => e.key)
        .toList()
      ..sort((a, b) => ingredientScores[b]!.compareTo(ingredientScores[a]!));

    final avoidedIngredients = ingredientScores.entries
        .where((e) => e.value <= 2.5 && tagCounts[e.key]! >= 2)
        .map((e) => e.key)
        .toList();

    // Calculate optimal complexity and time
    final avgComplexity = complexityRatings.isNotEmpty
        ? complexityRatings.reduce((a, b) => a + b) / complexityRatings.length
        : 2.0;

    final avgTime = timeRatings.isNotEmpty
        ? timeRatings.reduce((a, b) => a + b) / timeRatings.length
        : 30.0;

    // Calculate confidence score
    final confidenceScore = min(1.0, feedback.length / 20.0);

    return {
      'preferred_ingredients': preferredIngredients.take(5).toList(),
      'avoided_ingredients': avoidedIngredients.take(3).toList(),
      'preferred_cooking_methods': _getPreferredCookingMethods(feedback),
      'optimal_complexity': avgComplexity.round().clamp(1, 5),
      'preferred_cooking_time': avgTime.round(),
      'dietary_patterns': _extractDietaryPatterns(feedback),
      'flavor_preferences': _extractFlavorPreferences(feedback),
      'confidence_score': confidenceScore,
    };
  }

  // Calculate feedback weight based on recency
  static double _calculateFeedbackWeight(
      RecipeFeedbackModel feedback, DateTime now) {
    final daysSince = now.difference(feedback.createdAt).inDays;

    // Exponential decay: newer feedback has more weight
    if (daysSince <= 7) return 1.0; // Last week: full weight
    if (daysSince <= 30) return 0.8; // Last month: 80% weight
    if (daysSince <= 90) return 0.6; // Last 3 months: 60% weight
    return 0.4; // Older: 40% weight
  }

  // Extract preferred cooking methods
  static List<String> _getPreferredCookingMethods(
      List<RecipeFeedbackModel> feedback) {
    Map<String, double> methodScores = {};

    for (var fb in feedback) {
      final rating = fb.rating.toDouble();
      final cookingMethods = ['grilled', 'baked', 'sauteed', 'boiled'];

      for (String method in cookingMethods) {
        if (fb.tags.contains(method)) {
          methodScores[method] = (methodScores[method] ?? 0) + rating;
        }
      }
    }

    return methodScores.entries
        .where((e) => e.value >= 3.5)
        .map((e) => e.key)
        .toList()
      ..sort((a, b) => methodScores[b]!.compareTo(methodScores[a]!));
  }

  // Extract dietary patterns
  static Map<String, dynamic> _extractDietaryPatterns(
      List<RecipeFeedbackModel> feedback) {
    Map<String, int> dietaryTags = {
      'vegetarian': 0,
      'vegan': 0,
      'meat': 0,
      'fish': 0,
      'dairy': 0,
    };

    Map<String, double> dietaryRatings = {
      'vegetarian': 0,
      'vegan': 0,
      'meat': 0,
      'fish': 0,
      'dairy': 0,
    };

    for (var fb in feedback) {
      for (String tag in dietaryTags.keys) {
        if (fb.tags.contains(tag)) {
          dietaryTags[tag] = dietaryTags[tag]! + 1;
          dietaryRatings[tag] = dietaryRatings[tag]! + fb.rating;
        }
      }
    }

    // Calculate average ratings
    Map<String, double> avgRatings = {};
    for (String tag in dietaryTags.keys) {
      if (dietaryTags[tag]! > 0) {
        avgRatings[tag] = dietaryRatings[tag]! / dietaryTags[tag]!;
      }
    }

    return avgRatings;
  }

  // Extract flavor preferences
  static List<String> _extractFlavorPreferences(
      List<RecipeFeedbackModel> feedback) {
    // Simple keyword analysis for flavor preferences
    Map<String, double> flavorScores = {};

    final flavorKeywords = {
      'épicé': ['épice', 'piment', 'curry', 'paprika'],
      'sucré': ['sucré', 'miel', 'sucre', 'caramel'],
      'salé': ['salé', 'sel', 'soja', 'anchois'],
      'umami': ['champignon', 'parmesan', 'tomate', 'bouillon'],
      'frais': ['citron', 'herbes', 'menthe', 'basilic'],
    };

    for (var fb in feedback) {
      final content = fb.recipeContent.toLowerCase();
      final rating = fb.rating.toDouble();

      for (var entry in flavorKeywords.entries) {
        final flavor = entry.key;
        final keywords = entry.value;

        for (String keyword in keywords) {
          if (content.contains(keyword)) {
            flavorScores[flavor] = (flavorScores[flavor] ?? 0) + rating;
            break; // Only count once per recipe
          }
        }
      }
    }

    return flavorScores.entries
        .where((e) => e.value >= 3.5)
        .map((e) => e.key)
        .toList()
      ..sort((a, b) => flavorScores[b]!.compareTo(flavorScores[a]!));
  }

  // Update user preferences based on new feedback
  static Future<void> _updateUserPreferences(
      RecipeFeedbackModel feedback) async {
    final currentPrefs = await getUserPreferences();

    // Update preference counters
    currentPrefs['total_feedback'] = (currentPrefs['total_feedback'] ?? 0) + 1;
    currentPrefs['avg_rating'] = _calculateRunningAverage(
      currentPrefs['avg_rating'] ?? 3.0,
      currentPrefs['total_feedback'],
      feedback.rating.toDouble(),
    );

    // Store updated preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userPreferencesKey, json.encode(currentPrefs));
  }

  // Calculate running average
  static double _calculateRunningAverage(
      double currentAvg, int count, double newValue) {
    return ((currentAvg * (count - 1)) + newValue) / count;
  }

  // Get default preferences for new users
  static Map<String, dynamic> _getDefaultPreferences() {
    return {
      'total_feedback': 0,
      'avg_rating': 3.0,
      'preferred_ingredients': <String>[],
      'avoided_ingredients': <String>[],
      'optimal_complexity': 2,
      'preferred_cooking_time': 30,
    };
  }

  // Get basic preferences based on user profile
  static Map<String, dynamic> _getBasicPreferences(UserProfile userProfile) {
    List<String> basicPreferences = [];

    // Based on dietary preferences
    if (userProfile.dietaryPreferences.isVegetarian) {
      basicPreferences.addAll(['vegetables', 'vegetarian']);
    }
    if (userProfile.dietaryPreferences.isVegan) {
      basicPreferences.addAll(['vegetables', 'vegan']);
    }
    if (userProfile.dietaryPreferences.isGlutenFree) {
      basicPreferences.add('gluten_free');
    }

    // Based on activity level
    if (userProfile.activityLevel == ActivityLevel.veryActive ||
        userProfile.activityLevel == ActivityLevel.extremelyActive) {
      basicPreferences.addAll(['meat', 'protein']);
    }

    return {
      'preferred_ingredients': basicPreferences,
      'avoided_ingredients': <String>[],
      'preferred_cooking_methods': <String>[],
      'optimal_complexity': 2,
      'preferred_cooking_time': 30,
      'dietary_patterns': {},
      'flavor_preferences': <String>[],
      'ml_confidence_score': 0.0,
    };
  }

  // Clear all ML data (for testing/reset)
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_feedbackKey);
    await prefs.remove(_userPreferencesKey);
    print('🤖 ML: All ML data cleared');
  }

  // Get ML statistics for debugging
  static Future<Map<String, dynamic>> getMLStatistics() async {
    final feedback = await getFeedbackHistory();

    if (feedback.isEmpty) {
      return {
        'total_feedback': 0,
        'avg_rating': 0.0,
        'data_points': 0,
        'confidence': 0.0,
      };
    }

    final avgRating =
        feedback.map((f) => f.rating).reduce((a, b) => a + b) / feedback.length;
    final confidence = min(1.0, feedback.length / 20.0);

    return {
      'total_feedback': feedback.length,
      'avg_rating': avgRating.toStringAsFixed(1),
      'data_points': feedback.length,
      'confidence': (confidence * 100).toStringAsFixed(0) + '%',
      'last_feedback':
          feedback.isNotEmpty ? feedback.last.createdAt.toString() : 'None',
    };
  }
}
