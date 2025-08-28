// lib/presentation/widgets/workout_rating_widget.dart
import 'package:flutter/material.dart';
import 'package:lym_nutrition/core/services/ml_service.dart';
import 'package:lym_nutrition/data/models/recipe_feedback_model.dart';

class WorkoutRatingWidget extends StatefulWidget {
  final String workoutId;
  final String workoutContent;
  final String workoutType;
  final int duration;
  final int intensity;
  final VoidCallback? onRated;

  const WorkoutRatingWidget({
    Key? key,
    required this.workoutId,
    required this.workoutContent,
    required this.workoutType,
    required this.duration,
    required this.intensity,
    this.onRated,
  }) : super(key: key);

  @override
  State<WorkoutRatingWidget> createState() => _WorkoutRatingWidgetState();
}

class _WorkoutRatingWidgetState extends State<WorkoutRatingWidget> {
  int _rating = 0;
  bool _isRated = false;
  bool _isSubmitting = false;
  String _comment = '';
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une note'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Créer un feedback adapté pour les séances de sport
      final feedback = RecipeFeedbackModel(
        id: widget.workoutId,
        recipeId: widget.workoutId, // Utilise le workoutId comme recipeId
        recipeContent: widget.workoutContent,
        rating: _rating,
        comment: _comment,
        feedbackType: 'workout', // Type spécifique pour les séances
        tags: _extractWorkoutTags(),
        createdAt: DateTime.now(),
        userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
        userContext: {
          'workout_type': widget.workoutType,
          'duration': widget.duration,
          'intensity': widget.intensity,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      // Sauvegarder dans le service ML
      await MLService.storeFeedback(feedback);

      setState(() {
        _isRated = true;
        _isSubmitting = false;
      });

      // Callback optionnel
      if (widget.onRated != null) {
        widget.onRated!();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Merci pour votre évaluation ! (${_rating}/5)'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      print(
          '🏋️ ML: Workout feedback saved - Rating: $_rating, Type: ${widget.workoutType}');
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sauvegarde: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }

      print('❌ ML: Error saving workout feedback: $e');
    }
  }

  List<String> _extractWorkoutTags() {
    List<String> tags = [];

    // Tags basés sur le type de séance
    tags.add(widget.workoutType.toLowerCase());

    // Tags basés sur la durée
    if (widget.duration <= 15) {
      tags.add('courte');
    } else if (widget.duration <= 45) {
      tags.add('moyenne');
    } else {
      tags.add('longue');
    }

    // Tags basés sur l'intensité
    switch (widget.intensity) {
      case 0:
        tags.add('faible_intensite');
        break;
      case 1:
        tags.add('intensite_moderee');
        break;
      case 2:
        tags.add('haute_intensite');
        break;
      case 3:
        tags.add('intensite_extreme');
        break;
    }

    // Tags basés sur le contenu
    final content = widget.workoutContent.toLowerCase();
    if (content.contains('cardio') || content.contains('course')) {
      tags.add('cardio');
    }
    if (content.contains('musculation') || content.contains('poids')) {
      tags.add('musculation');
    }
    if (content.contains('étirement') || content.contains('stretching')) {
      tags.add('stretching');
    }
    if (content.contains('hiit') || content.contains('interval')) {
      tags.add('hiit');
    }
    if (content.contains('yoga') || content.contains('meditation')) {
      tags.add('yoga');
    }
    if (content.contains('natation') || content.contains('piscine')) {
      tags.add('natation');
    }

    return tags;
  }

  @override
  Widget build(BuildContext context) {
    if (_isRated) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Merci pour votre évaluation de cette séance !',
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
              ),
            ),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                );
              }),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_outlined, color: Colors.blue),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Évaluez cette séance pour améliorer l\'IA',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Informations sur la séance
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.fitness_center, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${widget.workoutType} • ${widget.duration} min',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department,
                        size: 16, color: Colors.orange),
                    const SizedBox(width: 2),
                    Text(
                      [
                        'Faible',
                        'Modérée',
                        'Élevée',
                        'Extrême'
                      ][widget.intensity],
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Notation par étoiles
          const Text(
            'Quelle note donnez-vous à cette séance ?',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _rating = index + 1;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 28,
                  ),
                ),
              );
            }),
          ),

          if (_rating > 0) ...[
            const SizedBox(height: 12),

            // Commentaire optionnel
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Commentaire optionnel...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              maxLines: 2,
              onChanged: (value) => _comment = value,
            ),

            const SizedBox(height: 12),

            // Bouton de soumission
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Évaluer cette séance'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
