import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:lym_nutrition/domain/entities/user_profile.dart';
import 'package:lym_nutrition/domain/entities/food_item.dart';
import 'package:lym_nutrition/domain/entities/user_dietary_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lym_nutrition/core/services/ml_service.dart';

class NutritionChatService {
  final http.Client _client;
  UserProfile? _currentUserProfile;
  List<FoodItem>? _recentFoodHistory;
  String? _lastProvider; // 'perplexity' | 'openai' | 'simulation'
  String? _lastModel;

  NutritionChatService({http.Client? client})
      : _client = client ?? http.Client();

  // Diagnostics getters
  String get lastProvider => _lastProvider ?? 'unknown';
  String get lastModel => _lastModel ?? '';

  void updateUserContext(UserProfile? profile, List<FoodItem>? recentHistory) {
    _currentUserProfile = profile;
    _recentFoodHistory = recentHistory;
  }

  // OpenAI fallback removed in Perplexity-only refactor

  // Perplexity Deep Research (preferred when key is present)
  String? get _pplxKey => dotenv.env['PERPLEXITY_API_KEY']?.trim();
  String? get _openaiKey => dotenv.env['OPENAI_API_KEY']?.trim();
  String get _pplxBaseUrl => (dotenv.env['PERPLEXITY_BASE_URL']?.trim() ??
      'https://api.perplexity.ai');
  String get _pplxModel =>
      (dotenv.env['PERPLEXITY_MODEL']?.trim() ?? 'gpt-4o-mini');
  String get _openaiBaseUrl => 'https://api.openai.com/v1';
  String get _openaiModel =>
      (dotenv.env['OPENAI_MODEL']?.trim() ?? 'gpt-4o-mini');

  // Use OpenAI GPT first, then Perplexity if available
  bool get _useOpenAI => _openaiKey != null && _openaiKey!.isNotEmpty;
  bool get _usePerplexity => _pplxKey != null && _pplxKey!.isNotEmpty;
  // Méthode pour recharger le prompt depuis .env
  Future<void> reloadPromptFromEnv() async {
    try {
      await dotenv.load(fileName: ".env");
      print('🔄 Prompt coach rechargé depuis .env');
    } catch (e) {
      print('⚠️ Erreur rechargement .env: $e');
    }
  }

  String get _systemPrompt {
    final basePrompt = dotenv.env['COACH_SYSTEM_PROMPT']?.trim() ??
        '''
    **Your Identity:** You are Lymee, a personalized AI nutrition coach. Your persona is encouraging, scientific, and expert. Your goal is to provide safe, effective, and highly personalized nutritional advice.

    **Core Directives:**
    1.  **Never Ask for Existing Data:** The user's profile is provided below. All necessary data (goals, activity level, allergies, preferences, biometrics) is included. NEVER ask for this information again. Use it directly to tailor every response.
    2.  **Strict Domain Adherence:** Only answer questions related to nutrition, food, hydration, calories, macronutrients, and healthy eating habits. If asked about workouts or topics outside this scope, politely decline and steer the conversation back to nutrition. For workout requests, say: "Pour créer des séances personnalisées, rendez-vous dans l'onglet Journal et cliquez sur 'Générer une séance'."
    3.  **Safety and Scientific Rigor:** Base all advice on established nutritional science. Avoid fad diets or extreme recommendations. Prioritize user safety and well-being. If a user's request seems unhealthy (e.g., extremely low calories), gently correct them with a safer, more balanced alternative.
    4.  **Recipe Protocol:** When providing meal or recipe suggestions, ALWAYS follow this detailed format:
        - **Title:** Clear and appealing.
        - **Total Time:** "Préparation: X min | Cuisson: Y min"
        - **Ingredients:** Use a bulleted list with precise quantities (e.g., "- 150g de blanc de poulet").
        - **Instructions:** Provide numbered, step-by-step directions. Keep them brief and clear.
        - **Nutrition Estimate:** Provide a breakdown: "Calories: ~X kcal | Protéines: Yg | Glucides: Zg | Lipides: Wg".

    **Response Style:**
    -   **Tone:** Be positive, supportive, and clear. Avoid overly technical jargon.
    -   **Formatting:** Use Markdown for clarity. Embolden key terms (**-15g de protéines**). Use bullet points for lists.
    -   **Conciseness:** Get straight to the point. Deliver actionable advice without unnecessary conversational filler.
    -   **Closing:** Always end your responses with a question to encourage conversation, such as "Souhaitez-vous plus de détails ?" or "Est-ce que cela vous convient ?".
    ''';

    // Style concis par défaut pour éviter les réponses trop longues
    final brevity =
        '\n\nSTYLE DE RÉPONSE:\n- Réponds en français, de façon concise.\n- Utilise des puces courtes (max 6 à 8 lignes).\n- Mets en gras les éléments clés (par ex. **aliment – 30g prot**).\n- Donne les nombres utiles (kcal, g de protéines) sans paragraphes longs.\n- Termine par: “Souhaitez-vous plus de détails ?”.';

    // Charts instruction removed (rollback)

    // Add user context if available
    if (_currentUserProfile != null) {
      final profile = _currentUserProfile!;
      final weightGoalText = _getWeightGoalText(profile.weightGoal);
      final activityLevelText = _getActivityLevelText(profile.activityLevel);
      final budgetText =
          _getBudgetText(profile.mealPlanningPreferences.weeklyBudget);
      final cookingLevelText =
          _getCookingLevelText(profile.mealPlanningPreferences.cookingLevel);

      final contextInfo =
          '''\n\nPROFIL UTILISATEUR (utilise ces données, ne les demande pas):
- Nom: ${profile.name ?? 'Utilisateur'}
- Objectif: $weightGoalText
- Niveau d'activité: $activityLevelText
- Âge: ${profile.age} ans, ${profile.gender == Gender.male ? 'Homme' : profile.gender == Gender.female ? 'Femme' : 'Autre'}
- Poids: ${profile.weightKg}kg, Taille: ${profile.heightCm}cm
- Besoins caloriques quotidiens: ${profile.calculateDailyCalories().round()} kcal
- Allergies/Restrictions: ${profile.dietaryPreferences.allergies.isNotEmpty ? profile.dietaryPreferences.allergies.join(', ') : 'Aucune'}
- Préférences: ${_getDietaryPreferencesText(profile.dietaryPreferences)}
- Budget hebdomadaire: $budgetText
- Niveau de cuisine: $cookingLevelText
- Temps de cuisine en semaine: ${_getCookingTimeText(profile.mealPlanningPreferences.weekdayCookingTime)}
- Temps de cuisine weekend: ${_getCookingTimeText(profile.mealPlanningPreferences.weekendCookingTime)}''';

      if (_recentFoodHistory != null && _recentFoodHistory!.isNotEmpty) {
        final recentFoods =
            _recentFoodHistory!.take(5).map((f) => f.name).join(', ');
        return basePrompt +
            contextInfo +
            '\n- Aliments consommés récemment: $recentFoods\n\nRappel: Tu as déjà toutes ces informations, ne les redemande pas à l\'utilisateur.';
      }

      return basePrompt +
          brevity +
          contextInfo +
          '\n\nRappel: Tu as déjà toutes ces informations, ne les redemande pas à l\'utilisateur.';
    }

    return basePrompt + brevity;
  }

  String get _workoutSystemPrompt {
    return '''Tu es un coach sportif expert. Génère des séances d'entraînement détaillées et personnalisées.

Tes séances doivent inclure :
- Échauffement (5-10 minutes)
- Corps de séance avec exercices précis (répétitions, séries, temps de repos)
- Retour au calme/étirements (5-10 minutes)
- Conseils techniques et sécurité
- Adaptations selon le niveau

Format attendu :
🏋️ **ÉCHAUFFEMENT** (X min)
- Exercice 1 : description précise
- Exercice 2 : description précise

💪 **CORPS DE SÉANCE** (X min)
**Exercice 1 :** Nom de l'exercice
- X séries de X répétitions
- Repos : X secondes entre séries
- Technique : conseils précis

🧘 **RETOUR AU CALME** (X min)
- Étirements spécifiques

💡 **CONSEILS**
- Points clés de sécurité
- Adaptations possibles

Sois précis, motivant et professionnel.''';
  }

  /// Enrichit les prompts avec les données d'apprentissage automatique
  Future<String> _enrichPromptWithML(String basePrompt,
      {bool isWorkout = false}) async {
    if (_currentUserProfile == null) return basePrompt;

    try {
      // Obtenir les recommandations ML
      final mlEnhancements = await MLService.generateRecipePromptEnhancements(
          _currentUserProfile!);
      final confidence = mlEnhancements['ml_confidence_score'] ?? 0.0;

      // Si on n'a pas assez de données ML, utiliser le prompt de base
      if (confidence < 0.1) {
        print(
            '🤖 ML: Pas assez de données ML (confidence: ${(confidence * 100).toStringAsFixed(0)}%)');
        return basePrompt;
      }

      print(
          '🤖 ML: Enrichissement du prompt avec ML (confidence: ${(confidence * 100).toStringAsFixed(0)}%)');

      // Construire l'enrichissement ML
      String mlContext =
          '\n\n🤖 **DONNÉES D\'APPRENTISSAGE PERSONNALISÉES** (Confidence: ${(confidence * 100).toStringAsFixed(0)}%)\n';

      // Préférences alimentaires apprises
      final preferredIngredients =
          mlEnhancements['preferred_ingredients'] as List<dynamic>? ?? [];
      final avoidedIngredients =
          mlEnhancements['avoided_ingredients'] as List<dynamic>? ?? [];
      final flavorPreferences =
          mlEnhancements['flavor_preferences'] as List<dynamic>? ?? [];

      if (preferredIngredients.isNotEmpty) {
        mlContext +=
            '✅ **INGRÉDIENTS PRÉFÉRÉS** (notes élevées): ${preferredIngredients.join(', ')}\n';
      }

      if (avoidedIngredients.isNotEmpty) {
        mlContext +=
            '❌ **INGRÉDIENTS À ÉVITER** (notes faibles): ${avoidedIngredients.join(', ')}\n';
      }

      if (flavorPreferences.isNotEmpty) {
        mlContext += '🎯 **GOÛTS PRÉFÉRÉS**: ${flavorPreferences.join(', ')}\n';
      }

      // Paramètres optimaux
      final optimalComplexity = mlEnhancements['optimal_complexity'] ?? 2;
      final preferredTime = mlEnhancements['preferred_cooking_time'] ?? 30;

      mlContext +=
          '⏱️ **TEMPS DE PRÉPARATION OPTIMAL**: ~${preferredTime} minutes\n';
      mlContext +=
          '🎯 **COMPLEXITÉ PRÉFÉRÉE**: ${_getComplexityLabel(optimalComplexity)}\n';

      // Méthodes de cuisson préférées
      final cookingMethods =
          mlEnhancements['preferred_cooking_methods'] as List<dynamic>? ?? [];
      if (cookingMethods.isNotEmpty) {
        mlContext +=
            '🍳 **MÉTHODES DE CUISSON PRÉFÉRÉES**: ${cookingMethods.join(', ')}\n';
      }

      // Patterns alimentaires
      final dietaryPatterns =
          mlEnhancements['dietary_patterns'] as Map<String, dynamic>? ?? {};
      if (dietaryPatterns.isNotEmpty) {
        final topPatterns = dietaryPatterns.entries
            .where((e) => e.value >= 3.5)
            .map((e) => e.key)
            .take(3)
            .join(', ');
        if (topPatterns.isNotEmpty) {
          mlContext += '🥗 **TYPES D\'ALIMENTS APPRÉCIÉS**: $topPatterns\n';
        }
      }

      // Instructions spécifiques
      mlContext += '\n💡 **INSTRUCTIONS ML**:\n';
      mlContext +=
          '- PRIORISE les ingrédients et goûts préférés de l\'utilisateur\n';
      mlContext += '- ÉVITE absolument les ingrédients mal notés\n';
      mlContext +=
          '- RESPECTE le temps de préparation et la complexité optimaux\n';
      mlContext += '- ADAPTE selon les patterns alimentaires détectés\n';
      mlContext +=
          '- UTILISE les méthodes de cuisson préférées quand possible\n\n';

      return basePrompt + mlContext;
    } catch (e) {
      print('❌ ML: Erreur lors de l\'enrichissement du prompt: $e');
      return basePrompt;
    }
  }

  String _getComplexityLabel(int complexity) {
    switch (complexity) {
      case 1:
        return 'Très simple';
      case 2:
        return 'Simple';
      case 3:
        return 'Modérée';
      case 4:
        return 'Complexe';
      case 5:
        return 'Très complexe';
      default:
        return 'Modérée';
    }
  }

  /// Méthode spécialisée pour générer des séances de sport
  Future<String> generateWorkoutSession(
      String type, int duration, int intensity, int level) async {
    final intensityLabels = ['Faible', 'Modérée', 'Élevée', 'Extrême'];
    final intensityLabel = intensityLabels[intensity];
    final levelLabels = ['Débutant', 'Intermédiaire', 'Avancé', 'Expert'];
    final levelLabel = levelLabels[level];

    // Construire le contexte utilisateur
    String userContext = '';
    if (_currentUserProfile != null) {
      final profile = _currentUserProfile!;
      final age = profile.age;
      final weight = profile.weightKg;
      final height = profile.heightCm;
      final gender = profile.gender == Gender.male
          ? 'Homme'
          : profile.gender == Gender.female
              ? 'Femme'
              : 'Autre';
      final goal = _getWeightGoalText(profile.weightGoal);
      final activityLevel = _getActivityLevelText(profile.activityLevel);

      userContext = '''

PROFIL UTILISATEUR:
- Âge: $age ans, $gender
- Poids: ${weight}kg, Taille: ${height}cm
- Objectif: $goal
- Niveau d'activité habituel: $activityLevel
- Besoins caloriques quotidiens: ${profile.calculateDailyCalories().round()} kcal''';
    }

    final basePrompt =
        '''Tu es un coach sportif expert. Génère une séance détaillée de $type adaptée au profil utilisateur.

PARAMÈTRES DE LA SÉANCE:
- Sport: $type
- Durée totale: $duration minutes
- Intensité: $intensityLabel
- Niveau technique: $levelLabel$userContext

STRUCTURE REQUISE:
🏃‍♂️ **ÉCHAUFFEMENT (5-8 min)**
[Exercices d'échauffement spécifiques au sport]

💪 **CORPS DE SÉANCE (${duration - 10} min)**
[Programme principal avec exercices détaillés, séries, répétitions/temps]

🧘‍♂️ **RETOUR AU CALME (5 min)**
[Étirements et récupération]

⚡ **CONSEILS & SÉCURITÉ**
[Conseils techniques et de sécurité]

📊 **ESTIMATION CALORIES**
[Estimation calories brûlées personnalisée selon le profil]

INSTRUCTIONS IMPORTANTES:
- Adapte TOUS les exercices au niveau technique ($levelLabel)
- Tiens compte de l'âge et du poids pour les charges et répétitions
- Personnalise les conseils selon l'objectif (perte/prise/maintien de poids)
- Ajuste les temps de repos selon le niveau d'activité habituel
- Propose des variantes/progressions selon le niveau
- Calcule les calories en fonction du profil physique (âge, poids, genre)
- Donne des conseils de sécurité spécifiques au niveau et à l'âge

Sois très précis et totalement personnalisé.''';

    // Enrichir le prompt avec les données ML
    final prompt = await _enrichPromptWithML(basePrompt, isWorkout: true);

    // S'assurer que le profil utilisateur est chargé
    await _ensureUserProfileLoaded();

    final messages = [
      {'role': 'user', 'content': prompt}
    ];

    // Try OpenAI first
    if (_useOpenAI) {
      print('🤖 [Workout Generation] Provider=OpenAI, Model=$_openaiModel');
      final response = await _postOpenAIWorkout(messages);
      if (response != null && response.trim().isNotEmpty) {
        await _saveWorkoutSessionText(response, type: type, duration: duration);
        return response;
      }
    }

    // Fallback to Perplexity
    if (_usePerplexity) {
      print('[Workout Generation] Provider=Perplexity, Model=$_pplxModel');
      final response = await _postPerplexity(
          _pplxModel, _withSystem(messages, useWorkoutPrompt: true));
      if (response != null && response.trim().isNotEmpty) {
        await _saveWorkoutSessionText(response, type: type, duration: duration);
        return response;
      }
    }

    return 'Erreur lors de la génération de la séance. Veuillez réessayer.';
  }

  /// Version spécialisée d'OpenAI pour les séances de sport
  Future<String?> _postOpenAIWorkout(List<Map<String, String>> messages) async {
    try {
      final uri = Uri.parse('$_openaiBaseUrl/chat/completions');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_openaiKey',
      };

      final body = {
        'model': _openaiModel,
        'messages': _withSystem(messages, useWorkoutPrompt: true)
            .map((m) => {'role': m['role'], 'content': m['content']})
            .toList(),
        'temperature': 0.7,
        'max_tokens': 1500, // Plus de tokens pour les séances détaillées
        'presence_penalty': 0.0,
        'frequency_penalty': 0.0,
      };

      final resp =
          await _client.post(uri, headers: headers, body: jsonEncode(body));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final content = data['choices']?[0]?['message']?['content'];
        if (content != null) {
          return content.toString().trim();
        }
      } else {
        print('OpenAI Workout API Error: ${resp.statusCode} - ${resp.body}');
      }
    } catch (e) {
      print('OpenAI Workout API Exception: $e');
    }
    return null;
  }

  /// S'assurer que le profil utilisateur est chargé pour la personnalisation
  Future<void> _ensureUserProfileLoaded() async {
    if (_currentUserProfile == null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final profileJson = prefs.getString('user_profile');
        if (profileJson != null) {
          final profileData = jsonDecode(profileJson);
          _currentUserProfile = UserProfile.fromJson(profileData);
          print('✅ Profil utilisateur chargé pour génération personnalisée');
        }
      } catch (e) {
        print('⚠️ Impossible de charger le profil utilisateur: $e');
      }
    }
  }

  String _getWeightGoalText(WeightGoal goal) {
    switch (goal) {
      case WeightGoal.lose:
        return 'Perte de poids';
      case WeightGoal.maintain:
        return 'Maintien du poids';
      case WeightGoal.gain:
        return 'Prise de masse';
      case WeightGoal.healthyEating:
        return 'Alimentation saine';
    }
  }

  String _getActivityLevelText(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return 'Sédentaire';
      case ActivityLevel.lightlyActive:
        return 'Légèrement actif';
      case ActivityLevel.moderatelyActive:
        return 'Modérément actif';
      case ActivityLevel.veryActive:
        return 'Très actif';
      case ActivityLevel.extremelyActive:
        return 'Extrêmement actif';
    }
  }

  String _getBudgetText(FoodBudget budget) {
    switch (budget) {
      case FoodBudget.tight:
        return '< 50€/semaine';
      case FoodBudget.moderate:
        return '50-100€/semaine';
      case FoodBudget.comfortable:
        return '100-150€/semaine';
      case FoodBudget.generous:
        return '> 150€/semaine';
    }
  }

  String _getCookingLevelText(CookingLevel level) {
    switch (level) {
      case CookingLevel.beginner:
        return 'Débutant';
      case CookingLevel.intermediate:
        return 'Intermédiaire';
      case CookingLevel.advanced:
        return 'Avancé';
      case CookingLevel.expert:
        return 'Expert';
    }
  }

  String _getCookingTimeText(CookingTime time) {
    switch (time) {
      case CookingTime.minimal:
        return '< 15 min';
      case CookingTime.short:
        return '15-30 min';
      case CookingTime.moderate:
        return '30-60 min';
      case CookingTime.long:
        return '> 60 min';
    }
  }

  String _getDietaryPreferencesText(UserDietaryPreferences prefs) {
    List<String> preferences = [];
    if (prefs.isVegetarian) preferences.add('Végétarien');
    if (prefs.isVegan) preferences.add('Végétalien');
    if (prefs.isHalal) preferences.add('Halal');
    if (prefs.isKosher) preferences.add('Casher');
    if (prefs.isGlutenFree) preferences.add('Sans gluten');
    if (prefs.isLactoseFree) preferences.add('Sans lactose');
    return preferences.isNotEmpty ? preferences.join(', ') : 'Aucune';
  }

  List<Map<String, String>> _withSystem(List<Map<String, String>> messages,
      {bool useWorkoutPrompt = false}) {
    // Évite d'empiler plusieurs prompts système
    final hasSystem = messages.isNotEmpty && messages.first['role'] == 'system';
    if (hasSystem) return messages;

    final promptToUse = useWorkoutPrompt ? _workoutSystemPrompt : _systemPrompt;
    return [
      {'role': 'system', 'content': promptToUse},
      ...messages,
    ];
  }

  // Ensure messages alternate user/assistant and start with a user message (Perplexity requirement)
  List<Map<String, String>> _normalizeMessages(
      List<Map<String, String>> messages) {
    // Drop any leading non-user messages
    int startIndex = 0;
    while (startIndex < messages.length &&
        messages[startIndex]['role'] != 'user') {
      startIndex++;
    }

    final normalized = <Map<String, String>>[];
    String? lastRole;
    for (int i = startIndex; i < messages.length; i++) {
      final role = messages[i]['role'] ?? 'user';
      final content = (messages[i]['content'] ?? '').trim();
      if (content.isEmpty) continue;
      if (normalized.isNotEmpty && lastRole == role) {
        // Merge consecutive messages of same role
        normalized.last = {
          'role': role,
          'content': (normalized.last['content'] ?? '') + '\n' + content,
        };
      } else {
        normalized.add({'role': role, 'content': content});
        lastRole = role;
      }
    }

    return normalized.isNotEmpty ? normalized : messages;
  }

  Future<String> getAnswer(List<Map<String, String>> messages) async {
    print('🎯 getAnswer called with ${messages.length} messages');

    final last =
        (messages.isNotEmpty ? messages.last['content'] : '')?.toLowerCase() ??
            '';

    final bool wantsWorkout = _isSportIntent(last);

    // Si c'est explicitement une demande de génération de séance (depuis le Journal),
    // on bypass le domain guard pour permettre la génération
    final isWorkoutGeneration = last.contains('génère une séance') ||
        last.contains('coach sportif expert');

    final bool inDomain = _isNutritionDomain(last) ||
        _isFollowUp(last) ||
        _hasNutritionContext(messages);
    if (!isWorkoutGeneration && !inDomain) {
      return "Je réponds aux sujets nutrition et sport: repas, recettes, calories, macros, hydratation et séances d'entraînement. Reformule ta question dans ce domaine.";
    }

    // Try OpenAI first (better for detailed workout generation)
    if (_useOpenAI) {
      print('🤖 [AI Coach] Provider=OpenAI, Model=$_openaiModel');
      final openaiResponse = await _postOpenAI(messages);
      if (openaiResponse != null && openaiResponse.trim().isNotEmpty) {
        if (wantsWorkout) {
          unawaited(_saveWorkoutSessionText(openaiResponse));
        }
        return openaiResponse;
      }
    }

    // Fallback to Perplexity if OpenAI fails or unavailable
    if (_usePerplexity) {
      print('[AI Coach] Provider=Perplexity, Model=$_pplxModel');
      // If the user requests a workout, override with a precise workout prompt
      final convo = wantsWorkout
          ? _withSystem([
              {
                'role': 'user',
                'content': _buildWorkoutPrompt(
                    _currentUserProfile, messages.last['content'] ?? '')
              }
            ])
          : _normalizeMessages(messages);
      // Primary attempt with configured model
      final primary = await _postPerplexity(_pplxModel, convo);
      if (primary != null && primary.trim().isNotEmpty) {
        if (wantsWorkout) {
          unawaited(_saveWorkoutSessionText(primary));
        }
        return primary;
      }
      // Retry with a lighter model for resiliency
      final retry = await _postPerplexity('sonar', convo);
      if (retry != null && retry.trim().isNotEmpty) {
        if (wantsWorkout) {
          unawaited(_saveWorkoutSessionText(retry));
        }
        return retry;
      }
      return _fallbackAnswer(messages.last['content'] ?? '');
    }

    // No API keys: simulation fallback (nutrition only, no auto workouts)
    _lastProvider = 'simulation';
    _lastModel = 'local';
    // ignore: avoid_print
    print('[AI Coach] Provider=Simulation');
    if (wantsWorkout) {
      return "Pour créer des séances personnalisées, configurez votre clé OpenAI et rendez-vous dans l'onglet Journal pour cliquer sur 'Générer une séance'.";
    }
    return _getSimulatedResponse(messages.last['content'] ?? '');
  }

  String? _extractAssistantText(Map<String, dynamic> data) {
    try {
      final choices = data['choices'] as List?;
      if (choices == null || choices.isEmpty) return null;
      final choice = choices.first as Map<String, dynamic>;
      final msg = choice['message'];
      if (msg is Map && msg['content'] != null) {
        final c = msg['content'];
        if (c is String) return c;
        if (c is List) {
          final parts = <String>[];
          for (final item in c) {
            if (item is Map && item['type'] == 'text' && item['text'] != null) {
              parts.add(item['text'].toString());
            } else if (item is String) {
              parts.add(item);
            }
          }
          return parts.join('\n');
        }
      }
      // Some providers may return `text`
      if (choice['text'] != null) return choice['text'].toString();
      return null;
    } catch (_) {
      return null;
    }
  }

  String _fallbackAnswer(String userMessage) {
    // Simple helpful defaults if provider returns empty
    final lower = userMessage.toLowerCase();
    if (lower.contains('proté') || lower.contains('protein')) {
      return 'Aliments riches en protéines (par portion):\n'
          '- Poulet (150g): ~35g\n- Thon/saumon (150g): 30g\n- Oeufs (2): 12g\n- Yaourt grec (200g): 18g\n- Tofu (150g): 18g\n- Lentilles cuites (200g): 16g';
    }
    return "Voici quelques idées adaptées à vos objectifs: misez sur des protéines de qualité, des légumes variés et des féculents complets. Je peux aussi proposer une recette si vous le souhaitez.";
  }

  // Gustar and external fallbacks removed: Sonar-only generation in planner

  // All Gustar-related helpers removed

  bool _isNutritionDomain(String msg) {
    if (msg.isEmpty) return true;
    final allow = [
      'repas',
      'recette',
      'nutrition',
      'calorie',
      'kcal',
      'macro',
      'proté',
      'protein',
      'glucide',
      'lipide',
      'graisse',
      'sucre',
      'sucré',
      'dessert',
      'goûter',
      'gouter',
      'collation',
      'manger',
      'boire',
      'soir',
      'hydratation',
      'eau',
      'snack',
      'déjeuner',
      'dîner',
      'petit-déjeuner',
      'petit dejeuner',
      'ingrédient',
      'aliment',
      'food',
      // sport / workout scope
      'sport',
      'séance',
      'seance',
      'entrain',
      'entraîn',
      'workout',
      'fitness',
      'musculation',
      'cardio',
      'hiit',
      'courir',
      'course',
      'marche',
      'yoga'
    ];
    final deny = [
      'politique',
      'news',
      'bourse',
      'crypto',
      'météo',
      'meteo',
      'voyage',
      'film',
      'musique'
    ];
    if (deny.any((d) => msg.contains(d))) return false;
    return allow.any((a) => msg.contains(a));
  }

  bool _isSportIntent(String msg) {
    if (msg.isEmpty) return false;
    final intents = [
      'sport',
      'séance',
      'seance',
      'entrain',
      'entraîn',
      'workout',
      'fitness',
      'musculation',
      'cardio',
      'hiit',
      'yoga',
      'course',
      'courir',
      'marche'
    ];
    return intents.any((w) => msg.contains(w));
  }

  // Consider short confirmations or follow-ups as valid continuation
  bool _isFollowUp(String msg) {
    if (msg.isEmpty) return false;
    final m = msg.trim();
    if (m.length <= 3) {
      // e.g., "oui", "ok", "non"
      return ['oui', 'ok', 'non', 'yes', 'no'].contains(m);
    }
    final followUps = [
      'continue',
      'plus',
      'davantage',
      'détails',
      'details',
      'développe',
      'developpe',
      'exemple',
      'exemples',
      'en savoir',
      'dis m\'en',
      'svp',
    ];
    return followUps.any((w) => m.contains(w));
  }

  // If the latest message isn't explicitly in-domain, allow if recent user
  // messages (context) were in-domain – supports follow-up like "oui".
  bool _hasNutritionContext(List<Map<String, String>> messages) {
    int checked = 0;
    for (var i = messages.length - 2; i >= 0 && checked < 3; i--) {
      final role = messages[i]['role'] ?? '';
      if (role == 'user') {
        checked++;
        final txt = (messages[i]['content'] ?? '').toLowerCase();
        if (_isNutritionDomain(txt) || _isSportIntent(txt)) return true;
      }
    }
    return false;
  }

  String _buildWorkoutPrompt(UserProfile? profile, String userQuery) {
    final p = profile;
    final goal = p != null ? _getWeightGoalText(p.weightGoal) : 'santé';
    final activity = p != null ? _getActivityLevelText(p.activityLevel) : 'N/A';
    final calories = p?.calculateDailyCalories().round();

    return [
      "Tu es un coach sportif. Ignore la nutrition sauf court rappel hydratation.",
      "L'utilisateur demande: $userQuery",
      if (p != null)
        "Profil: objectif=$goal, activité=$activity, poids=${p.weightKg}kg, taille=${p.heightCm}cm, kcal=${calories}.",
      "Génère une séance POUR AUJOURD'HUI au format clair:",
      "- Titre avec durée totale",
      "- Échauffement (5 min)",
      "- Bloc principal en séries/tempo – préciser intensité RPE",
      "- Alternatives débutant/intermédiaire si utile",
      "- Retour au calme (5 min)",
      "- Conseils rapides: hydratation et récupération",
      "Pas de texte long. Puces courtes."
    ].join('\n');
  }

  // Public helper to persist a workout content manually from UI
  Future<void> saveWorkoutContent(String content,
      {DateTime? day, String? type, int? duration}) async {
    await _saveWorkoutSessionText(content,
        day: day, type: type, duration: duration);
  }

  Future<void> _saveWorkoutSessionText(String content,
      {DateTime? day, String? type, int? duration}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dateKey =
          (day ?? DateTime.now()).toIso8601String().split('T').first;
      final journalKey = 'journal_' + dateKey;
      Map<String, dynamic> journal;
      final raw = prefs.getString(journalKey);
      if (raw != null && raw.isNotEmpty) {
        final parsed = jsonDecode(raw);
        journal = parsed is Map<String, dynamic>
            ? parsed
            : Map<String, dynamic>.from(parsed as Map);
      } else {
        journal = {
          'calories': 0,
          'protein': 0,
          'carbs': 0,
          'fat': 0,
          'meals': <Map<String, dynamic>>[],
          'sports': <Map<String, dynamic>>[],
        };
      }
      // Persist to backend (best effort) and keep summary locally
      final summary = _extractWorkoutSummary(content);

      // Override extracted values with provided parameters if available
      if (type != null) summary['type'] = type;
      if (duration != null) summary['duration'] = duration;

      final persisted = await _persistWorkoutToBackend(content, day: day);
      final List<dynamic> sports = (journal['sports'] as List?) ?? [];

      // Check for duplicates before adding, but allow AI-generated content to replace manual entries
      final existingEntry = sports.firstWhere(
        (entry) =>
            entry['type'] == summary['type'] &&
            entry['duration'] ==
                summary['duration'] && // Must be EXACT same duration
            entry['createdAt'] != null &&
            _isRecentEntry(entry['createdAt'], minutes: 5),
        orElse: () => null,
      );

      if (existingEntry != null) {
        // Allow replacement if new content is much longer (AI-generated replacing manual)
        final existingText = existingEntry['text']?.toString() ?? '';
        final isReplacingManualWithAI =
            existingText.length < 100 && content.length > 500;

        if (isReplacingManualWithAI) {
          print(
              '🔄 Replacing manual workout with AI-generated content: ${summary['type']} - ${summary['duration']}min');
          // Remove the old entry
          sports.removeWhere((entry) =>
              entry['type'] == summary['type'] &&
              entry['duration'] ==
                  summary['duration'] && // Must be EXACT same duration
              entry['createdAt'] != null &&
              _isRecentEntry(entry['createdAt'], minutes: 5));
        } else {
          print(
              '⚠️ Skipped duplicate workout: ${summary['type']} - ${summary['duration']}min (created recently)');
          return; // Don't save duplicate
        }
      }

      final entry = {
        'id': persisted['id'],
        'type': summary['type'],
        'duration': summary['duration'],
        'calories': summary['calories'],
        'createdAt': DateTime.now().toIso8601String(),
        'text': content, // Always save the full content locally
      };
      sports.add(entry);
      journal['sports'] = sports;
      await prefs.setString(journalKey, jsonEncode(journal));

      // Maintain journal index for quick listing
      final indexRaw = prefs.getString('journal_index');
      final Set<String> index = indexRaw != null
          ? (Set<String>.from(jsonDecode(indexRaw)))
          : <String>{};
      index.add(journalKey);
      await prefs.setString('journal_index', jsonEncode(index.toList()));
    } catch (e) {
      // ignore: avoid_print
      print('[AI Coach] Failed to save workout session: ' + e.toString());
    }
  }

  Map<String, dynamic> _extractWorkoutSummary(String content) {
    String header = '';

    // Look for header in first few lines (either with ** or ###)
    final lines = content.split('\n');
    for (int i = 0; i < lines.length && i < 5; i++) {
      final line = lines[i].trim();
      if (line.startsWith('**') && line.endsWith('**')) {
        header = line.replaceAll('*', '').trim();
        break;
      } else if (line.startsWith('###') || line.startsWith('##')) {
        header = line.replaceAll('#', '').trim();
        break;
      }
    }

    String type = 'Séance';
    int duration = 30; // default duration

    // If we have a header, extract type and duration from it
    if (header.isNotEmpty) {
      if (header.contains('–')) {
        final parts = header.split('–');
        type = parts[0].trim();
        if (parts.length > 1) {
          final durMatch = RegExp(r'(\d{1,3})\s*min').firstMatch(parts[1]);
          if (durMatch != null) {
            duration = int.parse(durMatch.group(1)!);
          }
        }
      } else if (header.contains('-')) {
        final parts = header.split('-');
        type = parts[0].trim();
        if (parts.length > 1) {
          final durMatch = RegExp(r'(\d{1,3})\s*min').firstMatch(parts[1]);
          if (durMatch != null) {
            duration = int.parse(durMatch.group(1)!);
          }
        }
      }
    }

    final lowerAll = content.toLowerCase();
    final typeMap = {
      'course': 'Course à pied',
      'running': 'Course à pied',
      'marche': 'Marche',
      'hiit': 'HIIT',
      'yoga': 'Yoga',
      'muscu': 'Musculation',
      'musculation': 'Musculation',
      'renforcement': 'Musculation',
      'cyclisme': 'Cyclisme',
      'vélo': 'Cyclisme',
      'velo': 'Cyclisme',
      'natation': 'Natation',
      'cardio': 'Cardio',
    };

    // If type is still generic, try to detect from content
    if (type == 'Séance') {
      for (final k in typeMap.keys) {
        if (lowerAll.contains(k)) {
          type = typeMap[k]!;
          break;
        }
      }
    }

    // If duration is still default and no header found, search in content
    if (duration == 30 && header.isEmpty) {
      final durMatch = RegExp(r'(\d{1,3})\s*min').firstMatch(content);
      if (durMatch != null) {
        duration = int.parse(durMatch.group(1)!);
      }
    }

    print('🔍 Workout summary extracted:');
    print('  - Header: $header');
    print('  - Type: $type');
    print('  - Duration: $duration min');

    int intensity = 1;
    if (lowerAll.contains('faible')) intensity = 0;
    if (lowerAll.contains('modérée') || lowerAll.contains('modere'))
      intensity = 1;
    if (lowerAll.contains('élevée') || lowerAll.contains('elevee'))
      intensity = 2;
    if (lowerAll.contains('extrême') || lowerAll.contains('extreme'))
      intensity = 3;

    final weight = _currentUserProfile?.weightKg ?? 70;
    double baseMets;
    switch (type) {
      case 'Course à pied':
        baseMets = 8.5;
        break;
      case 'Cyclisme':
        baseMets = 8.0;
        break;
      case 'Natation':
        baseMets = 8.0;
        break;
      case 'Musculation':
        baseMets = 6.0;
        break;
      case 'Yoga':
        baseMets = 3.0;
        break;
      case 'Marche':
        baseMets = 3.5;
        break;
      case 'HIIT':
        baseMets = 10.0;
        break;
      default:
        baseMets = 6.0;
    }
    final intensityFactor = [0.8, 1.0, 1.2, 1.35][intensity];
    final mets = baseMets * intensityFactor;
    final calories = ((mets * 3.5 * weight) / 200.0 * duration).round();

    return {
      'type': type,
      'duration': duration,
      'calories': calories,
      'intensity': intensity,
    };
  }

  Future<Map<String, dynamic>> _persistWorkoutToBackend(String content,
      {DateTime? day}) async {
    final base = dotenv.env['WORKOUTS_BASE_URL']?.trim() ??
        dotenv.env['BACKEND_BASE_URL']?.trim();
    if (base == null || base.isEmpty) {
      return {
        'id': 'local_' + DateTime.now().millisecondsSinceEpoch.toString()
      };
    }
    try {
      final uri = Uri.parse(base + '/workouts');
      final body = {
        'date': (day ?? DateTime.now()).toIso8601String(),
        'userId': _currentUserProfile?.userId ?? 'unknown',
        'content': content,
      };
      final resp = await _client.post(uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body));
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final json = jsonDecode(resp.body) as Map<String, dynamic>;
        return {'id': (json['id'] ?? json['workoutId'] ?? '').toString()};
      }
    } catch (_) {}
    return {'id': 'local_' + DateTime.now().millisecondsSinceEpoch.toString()};
  }

  Future<String?> getWorkoutContentById(String id) async {
    final base = dotenv.env['WORKOUTS_BASE_URL']?.trim() ??
        dotenv.env['BACKEND_BASE_URL']?.trim();
    if (base == null || base.isEmpty) return null;
    try {
      final uri = Uri.parse(base + '/workouts/' + id);
      final resp = await _client.get(uri);
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final json = jsonDecode(resp.body) as Map<String, dynamic>;
        return (json['content'] ?? json['text'] ?? '').toString();
      }
    } catch (_) {}
    return null;
  }

  // Optional SSE via proxy (recommended simple backend). Returns a token stream.
  // Expects a proxy URL in CHAT_PROXY_URL that accepts {messages} and streams SSE with lines starting with "data: ".
  Stream<String> streamAnswer(List<Map<String, String>> messages) async* {
    final proxy = dotenv.env['CHAT_PROXY_URL'];
    if (proxy == null || proxy.isEmpty) {
      // Fallback: emit the full answer from getAnswer
      final full = await getAnswer(messages);
      yield full;
      return;
    }

    final req = http.Request('POST', Uri.parse(proxy));
    req.headers['Content-Type'] = 'application/json';
    final convo = _normalizeMessages(messages);
    final last =
        (convo.isNotEmpty ? convo.last['content'] : '')?.toLowerCase() ?? '';
    if (_isSportIntent(last)) {
      // Override with explicit workout prompt to force a training plan answer
      final prompt = _buildWorkoutPrompt(_currentUserProfile,
          convo.isNotEmpty ? convo.last['content'] ?? '' : '');
      req.body = jsonEncode({
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          {'role': 'user', 'content': prompt}
        ]
      });
    } else {
      req.body = jsonEncode({'messages': _withSystem(convo)});
    }
    final resp = await _client.send(req);
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      final body = await resp.stream.bytesToString();
      yield 'Erreur ${resp.statusCode}: $body';
      return;
    }

    // Parse Server-Sent Events (SSE)
    final stream =
        resp.stream.transform(utf8.decoder).transform(const LineSplitter());
    final lastMsg =
        (messages.isNotEmpty ? messages.last['content'] : '')?.toLowerCase() ??
            '';
    final wantsWorkout = _isSportIntent(lastMsg);
    final buffer = StringBuffer();
    await for (final line in stream) {
      if (line.startsWith('data: ')) {
        final data = line.substring(6).trim();
        if (data == '[DONE]') break;
        buffer.write(data);
        yield data;
      }
    }
    if (wantsWorkout) {
      final text = buffer.toString();
      if (text.trim().isNotEmpty) {
        unawaited(_saveWorkoutSessionText(text));
      }
    }
  }

  String _getSimulatedResponse(String userMessage) {
    if (_currentUserProfile == null) {
      return "Je suis votre coach nutrition personnalisé. Pour vous donner des conseils adaptés, j'ai besoin que vous complétiez votre profil nutritionnel.";
    }

    final profile = _currentUserProfile!;
    final lowerMessage = userMessage.toLowerCase();

    // Réponses basées sur le profil pour les questions courantes
    if (lowerMessage.contains('repas') ||
        lowerMessage.contains('manger') ||
        lowerMessage.contains('recette')) {
      return _getMealSuggestion(profile);
    }

    if (lowerMessage.contains('objectif') || lowerMessage.contains('but')) {
      return _getGoalAdvice(profile);
    }

    if (lowerMessage.contains('calori') || lowerMessage.contains('macro')) {
      return _getNutritionalInfo(profile);
    }

    if (lowerMessage.contains('protéine')) {
      return _getProteinAdvice(profile);
    }

    // Séance de sport / entraînement - redirection vers Journal
    if (lowerMessage.contains('sport') ||
        lowerMessage.contains('séance') ||
        lowerMessage.contains('seance') ||
        lowerMessage.contains('entrain') ||
        lowerMessage.contains('workout') ||
        lowerMessage.contains('musculation') ||
        lowerMessage.contains('cardio')) {
      return "Pour créer des séances personnalisées, rendez-vous dans l'onglet Journal et cliquez sur 'Générer une séance'. Là, vous pourrez choisir le type de sport, la durée et l'intensité pour avoir une séance adaptée à vos besoins.";
    }

    // Réponse par défaut personnalisée
    return "Basé sur votre profil (${_getWeightGoalText(profile.weightGoal)}, ${profile.calculateDailyCalories().round()} kcal/jour), "
        "je peux vous aider avec des recettes adaptées, des conseils nutritionnels, ou l'optimisation de vos macros. "
        "Que souhaitez-vous savoir?";
  }

  String _getMealSuggestion(UserProfile profile) {
    final calories = profile.calculateDailyCalories().round();
    final mealCalories = (calories / 3).round();
    final cookingTime = profile.mealPlanningPreferences.weekdayCookingTime ==
            CookingTime.minimal
        ? "15 minutes"
        : "30 minutes";

    if (profile.weightGoal == WeightGoal.lose) {
      return """Voici une suggestion de repas léger (~$mealCalories kcal) pour votre objectif de perte de poids:

**Salade de Poulet Grillé aux Légumes**
⏱️ Temps de préparation: $cookingTime

Ingrédients:
- 150g de blanc de poulet
- 200g de légumes verts mélangés
- 1 tomate moyenne
- 1/2 concombre
- 1 cuillère à soupe d'huile d'olive
- Jus de citron, herbes

Instructions:
1. Griller le poulet avec des épices (10 min)
2. Couper les légumes en morceaux
3. Mélanger avec l'huile d'olive et le citron
4. Ajouter le poulet coupé en tranches

Valeurs nutritionnelles:
Calories: ${mealCalories} kcal
Protéines: 35g | Glucides: 15g | Lipides: 12g""";
    }

    return """Suggestion de repas équilibré (~$mealCalories kcal) adapté à vos besoins:

**Bol de Quinoa aux Légumes et Saumon**
⏱️ Temps: $cookingTime

Ingrédients:
- 80g de quinoa cuit
- 150g de saumon
- Légumes de saison
- 1 cuillère à soupe d'huile d'olive

Valeurs nutritionnelles:
Calories: $mealCalories kcal
Protéines: 30g | Glucides: 40g | Lipides: 18g""";
  }

  String _getGoalAdvice(UserProfile profile) {
    final goal = _getWeightGoalText(profile.weightGoal);
    final calories = profile.calculateDailyCalories().round();

    switch (profile.weightGoal) {
      case WeightGoal.lose:
        return "Pour votre objectif de $goal, je recommande:\n"
            "• Déficit calorique modéré: visez $calories kcal/jour\n"
            "• Privilégiez les protéines maigres et légumes\n"
            "• Hydratation: minimum 2L d'eau/jour\n"
            "• Activité physique régulière";
      case WeightGoal.gain:
        return "Pour votre objectif de $goal:\n"
            "• Surplus calorique: $calories kcal/jour\n"
            "• Protéines: ${(profile.weightKg * 2).round()}g/jour\n"
            "• Repas fréquents (5-6 fois/jour)\n"
            "• Entraînement en résistance";
      default:
        return "Pour $goal avec $calories kcal/jour:\n"
            "• Équilibre entre tous les groupes alimentaires\n"
            "• Variété dans vos repas\n"
            "• Écoute de vos signaux de faim/satiété";
    }
  }

  String _getNutritionalInfo(UserProfile profile) {
    final calories = profile.calculateDailyCalories().round();
    final protein = (profile.weightKg * 1.6).round();
    final carbs = ((calories * 0.45) / 4).round();
    final fats = ((calories * 0.30) / 9).round();

    return "Vos besoins nutritionnels quotidiens personnalisés:\n"
        "• Calories: $calories kcal\n"
        "• Protéines: $protein g (${(protein * 4 * 100 / calories).round()}%)\n"
        "• Glucides: $carbs g (${(carbs * 4 * 100 / calories).round()}%)\n"
        "• Lipides: $fats g (${(fats * 9 * 100 / calories).round()}%)\n"
        "• Fibres: 25-30g\n"
        "• Eau: ${(profile.weightKg * 30).round()}ml minimum";
  }

  String _getProteinAdvice(UserProfile profile) {
    final proteinNeeds = (profile.weightKg * 1.6).round();
    final isVegetarian = profile.dietaryPreferences.isVegetarian ||
        profile.dietaryPreferences.isVegan;

    if (isVegetarian) {
      return "Pour atteindre vos ${proteinNeeds}g de protéines/jour (végétarien):\n"
          "• Légumineuses: lentilles, pois chiches (20-25g/100g)\n"
          "• Tofu/tempeh (15-20g/100g)\n"
          "• Quinoa (14g/100g cuit)\n"
          "• Graines et noix\n"
          "• Oeufs (si non vegan): 6g/oeuf";
    }

    return "Pour vos ${proteinNeeds}g de protéines quotidiennes:\n"
        "• Viandes maigres: poulet, dinde (25-30g/100g)\n"
        "• Poissons: saumon, thon (20-25g/100g)\n"
        "• Oeufs: 6g par oeuf\n"
        "• Produits laitiers: yaourt grec, fromage blanc\n"
        "• Légumineuses en complément";
  }

  // Removed _getWorkoutPlan - no more auto-generated workouts

  Future<String?> _postOpenAI(List<Map<String, String>> messages) async {
    try {
      final uri = Uri.parse('$_openaiBaseUrl/chat/completions');
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_openaiKey',
      };

      // Déterminer si c'est une génération de séance
      final lastMessage =
          messages.isNotEmpty ? messages.last['content'] ?? '' : '';
      final isWorkoutGeneration =
          lastMessage.toLowerCase().contains('coach sportif expert') ||
              lastMessage.toLowerCase().contains('génère une séance');

      final body = {
        'model': _openaiModel,
        'messages': _withSystem(messages, useWorkoutPrompt: isWorkoutGeneration)
            .map((m) => {'role': m['role'], 'content': m['content']})
            .toList(),
        'temperature': 0.7,
        'max_tokens': 1000,
        'presence_penalty': 0.0,
        'frequency_penalty': 0.0,
      };

      final resp =
          await _client.post(uri, headers: headers, body: jsonEncode(body));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        final content = data['choices']?[0]?['message']?['content'];
        if (content != null) {
          return content.toString().trim();
        }
      } else {
        print('OpenAI API Error: ${resp.statusCode} - ${resp.body}');
      }
    } catch (e) {
      print('OpenAI API Exception: $e');
    }
    return null;
  }

  Future<String?> _postPerplexity(
      String model, List<Map<String, String>> convo) async {
    try {
      final uri = Uri.parse('$_pplxBaseUrl/chat/completions');
      final body = {
        'model': model,
        'messages': _withSystem(convo)
            .map((m) => {'role': m['role'], 'content': m['content']})
            .toList(),
        'temperature': 0.1,
        'top_p': 0.85,
        'return_images': false,
        'max_output_tokens': 400,
      };
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $_pplxKey',
      };
      final resp =
          await _client.post(uri, headers: headers, body: jsonEncode(body));
      _lastProvider = 'perplexity';
      _lastModel = model;
      // ignore: avoid_print
      print('[AI Coach] Provider=Perplexity, Model=' +
          model +
          ', Status=' +
          resp.statusCode.toString());
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        // ignore: avoid_print
        print('[AI Coach] Perplexity error: ' + resp.body);
        return null;
      }
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final content = _extractAssistantText(data);
      if (content != null && content.trim().isNotEmpty) return content;
      // Some responses include tool-style blocks or missing message; fallback to `citations` summary
      final choices = data['choices'] as List?;
      if (choices != null && choices.isNotEmpty) {
        final msg = (choices.first as Map<String, dynamic>)['message'];
        if (msg is Map &&
            msg['role'] == 'assistant' &&
            (msg['content'] == null || msg['content'] == '')) {
          return 'Réponse reçue mais sans texte exploitable. Réessaie avec une question plus précise (ex: "Top 10 aliments riches en protéines avec grammes par portion").';
        }
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('[AI Coach] Perplexity request exception: ' + e.toString());
      return null;
    }
  }

  // Helper method to check if an entry was created recently
  bool _isRecentEntry(String createdAtString, {int minutes = 5}) {
    try {
      final createdAt = DateTime.parse(createdAtString);
      final now = DateTime.now();
      final difference = now.difference(createdAt);
      return difference.inMinutes <= minutes;
    } catch (e) {
      return false;
    }
  }
}
