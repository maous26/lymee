// lib/presentation/widgets/recipe_rating_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lym_nutrition/core/services/ml_service.dart';
import 'package:lym_nutrition/data/models/recipe_feedback_model.dart';
import 'package:lym_nutrition/presentation/bloc/user_profile/user_profile_bloc.dart';
import 'package:lym_nutrition/presentation/bloc/user_profile/user_profile_state.dart';
import 'package:lym_nutrition/domain/entities/user_profile.dart';

class RecipeRatingWidget extends StatefulWidget {
  final String recipeId;
  final String recipeContent;
  final VoidCallback? onRated;

  const RecipeRatingWidget({
    Key? key,
    required this.recipeId,
    required this.recipeContent,
    this.onRated,
  }) : super(key: key);

  @override
  State<RecipeRatingWidget> createState() => _RecipeRatingWidgetState();
}

class _RecipeRatingWidgetState extends State<RecipeRatingWidget>
    with TickerProviderStateMixin {
  int _currentRating = 0;
  int _hoverRating = 0;
  String _selectedFeedbackType = 'taste';
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;
  bool _isExpanded = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final Map<String, IconData> _feedbackTypeIcons = {
    'taste': Icons.restaurant,
    'difficulty': Icons.build,
    'time': Icons.access_time,
    'nutrition': Icons.local_dining,
  };

  final Map<String, String> _feedbackTypeLabels = {
    'taste': 'Goût',
    'difficulty': 'Difficulté',
    'time': 'Temps',
    'nutrition': 'Nutrition',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildStarRating(),
              if (_currentRating > 0) ...[
                const SizedBox(height: 20),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  child:
                      _isExpanded ? _buildExpandedForm() : _buildQuickActions(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.psychology,
            color: Theme.of(context).primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notez cette recette',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Aidez Lymee à mieux vous connaître',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
              ),
            ],
          ),
        ),
        if (!_isExpanded && _currentRating > 0)
          TextButton(
            onPressed: () => setState(() => _isExpanded = true),
            child: const Text('Plus d\'options'),
          ),
      ],
    );
  }

  Widget _buildStarRating() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 4,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...List.generate(5, (index) {
              final starIndex = index + 1;
              final isSelected = starIndex <= _currentRating;
              final isHovered = starIndex <= _hoverRating;

              return GestureDetector(
                onTap: () => _setRating(starIndex),
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hoverRating = starIndex),
                  onExit: (_) => setState(() => _hoverRating = 0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      isSelected || isHovered ? Icons.star : Icons.star_border,
                      color: isSelected || isHovered
                          ? _getStarColor(starIndex)
                          : Theme.of(context).hintColor,
                      size: 32,
                    ),
                  ),
                ),
              );
            }),
            if (_currentRating > 0)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 180),
                child: Text(
                  _getRatingText(_currentRating),
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _getStarColor(_currentRating),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isSubmitting ? null : () => _submitFeedback(false),
            icon: _isSubmitting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(_isSubmitting ? 'Envoi...' : 'Noter'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: () => setState(() => _isExpanded = true),
          child: const Text('Détails'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedForm() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type d\'évaluation',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            _buildFeedbackTypeSelector(),
            const SizedBox(height: 16),
            Text(
              'Commentaire (optionnel)',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Que pensez-vous de cette recette ?',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.all(12),
              ),
              maxLines: 3,
              maxLength: 200,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _isSubmitting ? null : () => _submitFeedback(true),
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    label: Text(
                        _isSubmitting ? 'Envoi...' : 'Envoyer l\'évaluation'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () => setState(() => _isExpanded = false),
                  child: const Text('Réduire'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackTypeSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _feedbackTypeIcons.entries.map((entry) {
        final type = entry.key;
        final icon = entry.value;
        final label = _feedbackTypeLabels[type]!;
        final isSelected = _selectedFeedbackType == type;

        return FilterChip(
          selected: isSelected,
          onSelected: (selected) {
            setState(() => _selectedFeedbackType = type);
          },
          avatar: Icon(
            icon,
            size: 18,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).primaryColor,
          ),
          label: Text(label),
          selectedColor: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
        );
      }).toList(),
    );
  }

  void _setRating(int rating) {
    setState(() {
      _currentRating = rating;
      _hoverRating = 0;
    });

    // Trigger animation when rating is set
    if (_isExpanded) {
      _animationController.forward();
    }
  }

  Color _getStarColor(int rating) {
    switch (rating) {
      case 1:
      case 2:
        return Colors.red;
      case 3:
        return Colors.orange;
      case 4:
      case 5:
        return Colors.green;
      default:
        return Theme.of(context).hintColor;
    }
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'Très décevant';
      case 2:
        return 'Pas terrible';
      case 3:
        return 'Correct';
      case 4:
        return 'Très bon';
      case 5:
        return 'Excellent !';
      default:
        return '';
    }
  }

  Future<void> _submitFeedback(bool withDetails) async {
    if (_currentRating == 0) return;

    setState(() => _isSubmitting = true);

    try {
      // Get user profile
      final userProfileBloc = context.read<UserProfileBloc>();
      UserProfile? userProfile;

      if (userProfileBloc.state is UserProfileLoaded) {
        userProfile = (userProfileBloc.state as UserProfileLoaded).userProfile;
      }

      // Create feedback model
      final feedback = RecipeFeedbackModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userProfile?.userId ?? 'anonymous',
        recipeId: widget.recipeId,
        recipeContent: widget.recipeContent,
        rating: _currentRating,
        feedbackType: _selectedFeedbackType,
        userContext: userProfile?.toMLContext() ?? {},
        tags: RecipeFeedbackModel.extractTags(widget.recipeContent),
        createdAt: DateTime.now(),
        comment: withDetails && _commentController.text.isNotEmpty
            ? _commentController.text
            : null,
      );

      // Store feedback using ML service
      await MLService.storeFeedback(feedback);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Merci pour votre retour ! Note: ${_currentRating}/5'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }

      // Call callback
      widget.onRated?.call();
    } catch (e) {
      print('❌ Error submitting feedback: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Erreur lors de l\'envoi'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

// Extension to convert UserProfile to ML context
extension UserProfileMLExtension on UserProfile {
  Map<String, dynamic> toMLContext() {
    return {
      'age': age,
      'weight': weightKg,
      'height': heightCm,
      'activityLevel': activityLevel.toString(),
      'weightGoal': weightGoal.toString(),
      'isVegetarian': dietaryPreferences.isVegetarian,
      'isVegan': dietaryPreferences.isVegan,
      'isGlutenFree': dietaryPreferences.isGlutenFree,
      'isLactoseFree': dietaryPreferences.isLactoseFree,
      'allergies': dietaryPreferences.allergies,
      'bmr': calculateBMR(),
      'dailyCalories': calculateDailyCalories(),
    };
  }
}
