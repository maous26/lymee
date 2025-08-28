import 'package:flutter/material.dart';
import 'package:lym_nutrition/presentation/themes/enhanced_theme.dart';
// charts removed rollback; no extra imports
import 'package:lym_nutrition/presentation/screens/chat/nutrition_chat_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/user_profile/user_profile_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/user_profile/user_profile_state.dart';
import 'package:lym_nutrition/presentation/bloc/food_history/food_history_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/food_history/food_history_state.dart';
import 'package:lym_nutrition/presentation/bloc/food_history/food_history_event.dart';
import 'package:lym_nutrition/domain/entities/user_profile.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<_Message> _messages = <_Message>[];
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;
  final NutritionChatService _service = NutritionChatService();
  bool _showSuggestions = true;

  List<String> get _suggestionQuestions {
    final userProfileState = context.read<UserProfileBloc>().state;

    if (userProfileState is UserProfileLoaded) {
      final profile = userProfileState.userProfile;
      final hasAllergies = profile.dietaryPreferences.allergies.isNotEmpty;
      final isVegetarian = profile.dietaryPreferences.isVegetarian ||
          profile.dietaryPreferences.isVegan;

      List<String> questions = [
        "Suggère-moi un repas adapté à mes objectifs",
        "Quelle recette de ${profile.mealPlanningPreferences.weekdayCookingTime == CookingTime.minimal ? '15 min' : '30 min'} pour ce soir?",
        "Comment optimiser mes macros aujourd'hui?",
        "Quels aliments pour ${profile.weightGoal == WeightGoal.gain ? 'prendre du muscle' : 'mes objectifs'}?",
      ];

      if (isVegetarian) {
        questions.add("Recette végétarienne riche en protéines");
      } else {
        questions.add("Recette équilibrée avec viande ou poisson");
      }

      if (hasAllergies) {
        questions.add(
            "Alternatives sans ${profile.dietaryPreferences.allergies.first}");
      }

      questions.addAll([
        "Plan de repas pour la semaine",
        "Snacks sains pour mon niveau d'activité",
      ]);

      return questions;
    }

    // Default questions if profile not loaded
    return [
      "Suggère-moi un repas sain pour ce soir",
      "Quelle recette rapide pour le déjeuner?",
      "Comment atteindre mes objectifs nutritionnels?",
      "Quels aliments pour plus de protéines?",
      "Donne-moi une recette végétarienne facile",
      "Comment améliorer mon hydratation?",
      "Suggère un menu de la semaine",
      "Quels snacks sains entre les repas?",
    ];
  }

  @override
  void initState() {
    super.initState();
    // Load food history when screen opens
    context.read<FoodHistoryBloc>().add(GetFoodHistoryItemsEvent());

    // Délai pour s'assurer que les blocs sont prêts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateUserContext();
      _initializeGreeting();
    });
  }

  void _initializeGreeting() {
    final userProfileState = context.read<UserProfileBloc>().state;

    if (userProfileState is UserProfileLoaded) {
      final profile = userProfileState.userProfile;
      final name = profile.name ?? 'là';
      final goalText = _getGoalMessage(profile.weightGoal);
      final caloriesNeeded = profile.calculateDailyCalories().round();

      // Assurez-vous que le service a le contexte utilisateur
      _service.updateUserContext(profile, null);

      final greeting =
          "Bonjour $name 👋 Je suis Lymee, votre coach nutrition personnalisé.\n\n"
          "Je vois que votre objectif est: $goalText. "
          "Vos besoins caloriques quotidiens sont d'environ $caloriesNeeded kcal. "
          "Comment puis-je vous aider aujourd'hui?";

      setState(() {
        _messages.add(_Message(role: 'assistant', text: greeting));
      });
    } else {
      // Si le profil n'est pas chargé, utilisez le message du service
      setState(() {
        _messages.add(_Message(
            role: 'assistant',
            text:
                "Bonjour 👋 Je suis Lymee, votre coach nutrition personnalisé. Comment puis-je vous aider aujourd'hui?"));
      });
    }
  }

  String _getGoalMessage(WeightGoal goal) {
    switch (goal) {
      case WeightGoal.lose:
        return 'perdre du poids';
      case WeightGoal.maintain:
        return 'maintenir votre poids actuel';
      case WeightGoal.gain:
        return 'prendre de la masse';
      case WeightGoal.healthyEating:
        return 'manger plus sainement';
    }
  }

  void _updateUserContext() {
    final userProfileState = context.read<UserProfileBloc>().state;
    final historyState = context.read<FoodHistoryBloc>().state;

    if (userProfileState is UserProfileLoaded) {
      final recentHistory = historyState is FoodHistoryLoadSuccess
          ? historyState.historyItems.take(10).toList()
          : null;
      _service.updateUserContext(userProfileState.userProfile, recentHistory);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send([String? predefinedText]) async {
    final text = predefinedText ?? _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
      _showSuggestions = false;
      _messages.add(_Message(role: 'user', text: text));
      _controller.clear();
    });

    try {
      final history =
          _messages.map((m) => {'role': m.role, 'content': m.text}).toList();
      bool streamed = false;
      await for (final chunk in _service.streamAnswer(history)) {
        streamed = true;
        if ((chunk.trim()).isEmpty) {
          // Skip empty chunks to avoid rendering blank bubbles
          continue;
        }
        if (_messages.isNotEmpty &&
            _messages.last.role == 'assistant' &&
            _messages.last.streamingBuffer != null) {
          setState(() => _messages.last.append(chunk));
        } else {
          setState(() => _messages.add(
              _Message(role: 'assistant', text: '', streamingBuffer: chunk)));
        }
      }
      if (!streamed) {
        final reply = await _service.getAnswer(history);
        final safe = reply.trim().isEmpty
            ? "Désolé, je n'ai pas pu formuler une réponse. Reformule ta question nutritionnelle."
            : reply;
        setState(() => _messages.add(_Message(role: 'assistant', text: safe)));
      } else {
        setState(() {
          final last = _messages.last;
          final finished = last.finish();
          _messages[_messages.length - 1] = (finished.text.trim().isEmpty)
              ? _Message(
                  role: 'assistant',
                  text:
                      "Désolé, je n'ai pas pu formuler une réponse. Reformule ta question nutritionnelle.")
              : finished;
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(_Message(role: 'assistant', text: 'Erreur: $e'));
      });
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lymee'),
        backgroundColor: EnhancedTheme.primaryTeal,
        foregroundColor: EnhancedTheme.neutralWhite,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                final isUser = m.role == 'user';
                final bubbleColor = isUser
                    ? EnhancedTheme.primaryTeal
                    : EnhancedTheme.neutralGray100;
                final textColor = isUser
                    ? EnhancedTheme.neutralWhite
                    : EnhancedTheme.neutralGray900;
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: EnhancedTheme.shadowLight,
                    ),
                    child: _buildMessageContent(m, textColor),
                  ),
                );
              },
            ),
          ),

          // Predefined questions bubbles
          if (_showSuggestions && _messages.length == 1)
            Container(
              height: 100,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _suggestionQuestions.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(
                        _suggestionQuestions[index],
                        style: const TextStyle(fontSize: 12),
                      ),
                      onPressed: () => _send(_suggestionQuestions[index]),
                      backgroundColor: EnhancedTheme.neutralGray100,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  );
                },
              ),
            ),

          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: EnhancedTheme.neutralWhite,
                boxShadow: EnhancedTheme.shadowLight,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Posez une question nutrition...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isSending ? null : () => _send(),
                    icon: Icon(Icons.send,
                        color: _isSending
                            ? EnhancedTheme.neutralGray300
                            : EnhancedTheme.primaryTeal),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _Message {
  final String role;
  final String text;
  final String? streamingBuffer;
  _Message({required this.role, required this.text, this.streamingBuffer});

  void append(String chunk) {
    if (streamingBuffer != null) {
      // ignore: invalid_use_of_visible_for_testing_member
      (this as dynamic).streamingBuffer = streamingBuffer! + chunk;
    }
  }

  _Message finish() => _Message(role: role, text: streamingBuffer ?? text);
}

// Extension method to build message content
extension _MessageBuilder on _ChatbotScreenState {
  Widget _buildMessageContent(_Message message, Color textColor) {
    final text = message.text;

    // Check if message contains a recipe format
    if (message.role == 'assistant' && _looksLikeRecipe(text)) {
      return _buildRecipeCard(text, textColor);
    }

    // Charts disabled (rollback): render as plain text only
    return SelectionArea(
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 14),
      ),
    );
  }

  Widget _buildRecipeCard(String text, Color textColor) {
    final sections = _parseRecipeSections(text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sections['title'] != null)
          Text(
            sections['title']!,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (sections['time'] != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time, size: 16, color: textColor),
              const SizedBox(width: 4),
              Text(
                sections['time']!,
                style: TextStyle(color: textColor, fontSize: 12),
              ),
            ],
          ),
        ],
        if (sections['ingredients'] != null) ...[
          const SizedBox(height: 12),
          Text(
            'Ingrédients:',
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sections['ingredients']!,
            style: TextStyle(color: textColor, fontSize: 13),
          ),
        ],
        if (sections['instructions'] != null) ...[
          const SizedBox(height: 12),
          Text(
            'Instructions:',
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sections['instructions']!,
            style: TextStyle(color: textColor, fontSize: 13),
          ),
        ],
        if (sections['nutrition'] != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Valeurs nutritionnelles:',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sections['nutrition']!,
                  style: TextStyle(color: textColor, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
        if (sections['other'] != null)
          Text(
            sections['other']!,
            style: TextStyle(color: textColor, fontSize: 13),
          ),
      ],
    );
  }

  bool _looksLikeRecipe(String text) {
    return text.contains('Ingrédients:') ||
        text.contains('Instructions:') ||
        text.contains('Temps de préparation:') ||
        text.contains('Valeurs nutritionnelles:');
  }

  Map<String, String> _parseRecipeSections(String text) {
    final sections = <String, String>{};

    // Extract title (usually the first line if it's a recipe)
    final lines = text.split('\n');
    if (lines.isNotEmpty && !lines[0].contains(':')) {
      sections['title'] = lines[0].trim();
    }

    // Extract time info
    final timeMatch =
        RegExp(r'Temps.*?:.*?(?=\n|$)', multiLine: true).firstMatch(text);
    if (timeMatch != null) {
      sections['time'] = timeMatch.group(0)!.trim();
    }

    // Extract ingredients
    final ingredientsMatch = RegExp(
            r'Ingrédients\s*:(.*?)(?=Instructions:|Valeurs nutritionnelles:|$)',
            dotAll: true)
        .firstMatch(text);
    if (ingredientsMatch != null) {
      sections['ingredients'] = ingredientsMatch.group(1)!.trim();
    }

    // Extract instructions
    final instructionsMatch = RegExp(
            r'Instructions\s*:(.*?)(?=Valeurs nutritionnelles:|$)',
            dotAll: true)
        .firstMatch(text);
    if (instructionsMatch != null) {
      sections['instructions'] = instructionsMatch.group(1)!.trim();
    }

    // Extract nutrition
    final nutritionMatch =
        RegExp(r'Valeurs nutritionnelles\s*:(.*?)$', dotAll: true)
            .firstMatch(text);
    if (nutritionMatch != null) {
      sections['nutrition'] = nutritionMatch.group(1)!.trim();
    }

    // Any other content
    if (sections.isEmpty) {
      sections['other'] = text;
    }

    return sections;
  }
}
