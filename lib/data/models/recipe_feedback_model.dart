// lib/data/models/recipe_feedback_model.dart

class RecipeFeedbackModel {
  final String id;
  final String userId;
  final String recipeId;
  final String recipeContent;
  final int rating; // 1-5 stars
  final String feedbackType; // 'taste', 'difficulty', 'time', 'nutrition'
  final Map<String, dynamic> userContext; // Profile data at time of feedback
  final List<String> tags; // extracted tags from recipe
  final DateTime createdAt;
  final String? comment; // optional user comment

  RecipeFeedbackModel({
    required this.id,
    required this.userId,
    required this.recipeId,
    required this.recipeContent,
    required this.rating,
    required this.feedbackType,
    required this.userContext,
    required this.tags,
    required this.createdAt,
    this.comment,
  });

  // Convert to ML features for training
  Map<String, dynamic> toMLFeatures() {
    return {
      'rating': rating,
      'user_age': userContext['age'] ?? 0,
      'user_weight': userContext['weight'] ?? 0,
      'user_height': userContext['height'] ?? 0,
      'user_activity_level': userContext['activityLevel'] ?? 'moderate',
      'user_goal': userContext['weightGoal'] ?? 'maintain',
      'recipe_calories': _extractCalories(),
      'recipe_protein': _extractProtein(),
      'recipe_carbs': _extractCarbs(),
      'recipe_fat': _extractFat(),
      'recipe_complexity': _extractComplexity(),
      'cooking_time': _extractCookingTime(),
      'ingredient_count': _extractIngredientCount(),
      'has_meat': tags.contains('meat') ? 1 : 0,
      'has_vegetables': tags.contains('vegetables') ? 1 : 0,
      'has_dairy': tags.contains('dairy') ? 1 : 0,
      'is_vegetarian': tags.contains('vegetarian') ? 1 : 0,
      'is_vegan': tags.contains('vegan') ? 1 : 0,
      'difficulty_level': _extractDifficulty(),
      'feedback_type': feedbackType,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  // Extract nutritional info from recipe content
  double _extractCalories() {
    final regex = RegExp(r'(\d+)\s*(?:kcal|calories)', caseSensitive: false);
    final match = regex.firstMatch(recipeContent);
    return match != null ? double.tryParse(match.group(1)!) ?? 0 : 0;
  }

  double _extractProtein() {
    final regex = RegExp(r'(\d+(?:\.\d+)?)\s*g?\s*(?:de\s+)?protéines?',
        caseSensitive: false);
    final match = regex.firstMatch(recipeContent);
    return match != null ? double.tryParse(match.group(1)!) ?? 0 : 0;
  }

  double _extractCarbs() {
    final regex = RegExp(r'(\d+(?:\.\d+)?)\s*g?\s*(?:de\s+)?glucides?',
        caseSensitive: false);
    final match = regex.firstMatch(recipeContent);
    return match != null ? double.tryParse(match.group(1)!) ?? 0 : 0;
  }

  double _extractFat() {
    final regex = RegExp(r'(\d+(?:\.\d+)?)\s*g?\s*(?:de\s+)?lipides?',
        caseSensitive: false);
    final match = regex.firstMatch(recipeContent);
    return match != null ? double.tryParse(match.group(1)!) ?? 0 : 0;
  }

  int _extractComplexity() {
    int complexity = 1;

    // Count preparation steps
    final steps = recipeContent
        .split('\n')
        .where((line) =>
            line.trim().startsWith(RegExp(r'\d+\.')) ||
            line.toLowerCase().contains('étape'))
        .length;

    if (steps > 5) complexity += 1;
    if (steps > 10) complexity += 1;

    // Check for complex techniques
    final complexTerms = [
      'réduction',
      'émulsion',
      'caramélisation',
      'brunoise',
      'julienne'
    ];
    for (String term in complexTerms) {
      if (recipeContent.toLowerCase().contains(term)) {
        complexity += 1;
        break;
      }
    }

    return complexity.clamp(1, 5);
  }

  int _extractCookingTime() {
    final regex = RegExp(r'(\d+)\s*(?:min|minutes?)', caseSensitive: false);
    final match = regex.firstMatch(recipeContent);
    return match != null ? int.tryParse(match.group(1)!) ?? 0 : 0;
  }

  int _extractIngredientCount() {
    // Count bullet points or numbered lists
    final bulletPoints = recipeContent
        .split('\n')
        .where((line) =>
            line.trim().startsWith('•') ||
            line.trim().startsWith('-') ||
            line.trim().startsWith(RegExp(r'\d+\.')))
        .length;

    return bulletPoints;
  }

  String _extractDifficulty() {
    if (recipeContent.toLowerCase().contains('facile') ||
        recipeContent.toLowerCase().contains('simple')) {
      return 'easy';
    } else if (recipeContent.toLowerCase().contains('difficile') ||
        recipeContent.toLowerCase().contains('complexe')) {
      return 'hard';
    }
    return 'medium';
  }

  // Auto-tag extraction from recipe content
  static List<String> extractTags(String content) {
    List<String> tags = [];

    // Dietary tags
    if (content.toLowerCase().contains('végétarien')) tags.add('vegetarian');
    if (content.toLowerCase().contains('végan')) tags.add('vegan');
    if (content.toLowerCase().contains('sans gluten')) tags.add('gluten_free');

    // Ingredient category tags
    if (content
        .toLowerCase()
        .contains(RegExp(r'\b(?:poulet|bœuf|porc|agneau|viande)\b')))
      tags.add('meat');
    if (content
        .toLowerCase()
        .contains(RegExp(r'\b(?:poisson|saumon|thon|cabillaud)\b')))
      tags.add('fish');
    if (content
        .toLowerCase()
        .contains(RegExp(r'\b(?:légumes?|tomate|carotte|courgette)\b')))
      tags.add('vegetables');
    if (content
        .toLowerCase()
        .contains(RegExp(r'\b(?:fromage|lait|yaourt|crème)\b')))
      tags.add('dairy');
    if (content
        .toLowerCase()
        .contains(RegExp(r'\b(?:riz|pâtes|pain|céréales)\b')))
      tags.add('grains');

    // Cooking method tags
    if (content
        .toLowerCase()
        .contains(RegExp(r'\b(?:grillé|griller|barbecue)\b')))
      tags.add('grilled');
    if (content.toLowerCase().contains(RegExp(r'\b(?:cuit au four|rôti)\b')))
      tags.add('baked');
    if (content.toLowerCase().contains(RegExp(r'\b(?:sauté|poêlé)\b')))
      tags.add('sauteed');
    if (content.toLowerCase().contains(RegExp(r'\b(?:bouilli|mijoté)\b')))
      tags.add('boiled');

    return tags;
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'recipeId': recipeId,
      'recipeContent': recipeContent,
      'rating': rating,
      'feedbackType': feedbackType,
      'userContext': userContext,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'comment': comment,
    };
  }

  factory RecipeFeedbackModel.fromJson(Map<String, dynamic> json) {
    return RecipeFeedbackModel(
      id: json['id'],
      userId: json['userId'],
      recipeId: json['recipeId'],
      recipeContent: json['recipeContent'],
      rating: json['rating'],
      feedbackType: json['feedbackType'],
      userContext: Map<String, dynamic>.from(json['userContext']),
      tags: List<String>.from(json['tags']),
      createdAt: DateTime.parse(json['createdAt']),
      comment: json['comment'],
    );
  }

  @override
  String toString() {
    return 'RecipeFeedbackModel(id: $id, rating: $rating, feedbackType: $feedbackType, tags: $tags)';
  }
}
