// lib/presentation/screens/ml_admin_screen.dart
import 'package:flutter/material.dart';
import 'package:lym_nutrition/core/services/ml_service.dart';
import 'package:lym_nutrition/data/models/recipe_feedback_model.dart';

class MLAdminScreen extends StatefulWidget {
  const MLAdminScreen({Key? key}) : super(key: key);

  @override
  State<MLAdminScreen> createState() => _MLAdminScreenState();
}

class _MLAdminScreenState extends State<MLAdminScreen> {
  Map<String, dynamic>? _mlStats;
  List<RecipeFeedbackModel>? _feedbackHistory;
  Map<String, dynamic>? _userPreferences;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMLData();
  }

  Future<void> _loadMLData() async {
    setState(() => _isLoading = true);

    try {
      final stats = await MLService.getMLStatistics();
      final feedback = await MLService.getFeedbackHistory();
      final preferences = await MLService.getUserPreferences();

      setState(() {
        _mlStats = stats;
        _feedbackHistory = feedback;
        _userPreferences = preferences;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading ML data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration ML'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMLData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsCard(),
                  const SizedBox(height: 16),
                  _buildPreferencesCard(),
                  const SizedBox(height: 16),
                  _buildFeedbackHistoryCard(),
                  const SizedBox(height: 16),
                  _buildActionsCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsCard() {
    if (_mlStats == null) return Container();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Statistiques ML',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatRow(
                'Total Feedback', _mlStats!['total_feedback'].toString()),
            _buildStatRow('Note Moyenne', _mlStats!['avg_rating'].toString()),
            _buildStatRow(
                'Points de Données', _mlStats!['data_points'].toString()),
            _buildStatRow('Confiance ML', _mlStats!['confidence'].toString()),
            _buildStatRow(
                'Dernier Feedback', _mlStats!['last_feedback'].toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard() {
    if (_userPreferences == null) return Container();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.psychology, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Préférences Apprises',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._userPreferences!.entries
                .map(
                    (entry) => _buildStatRow(entry.key, entry.value.toString()))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackHistoryCard() {
    if (_feedbackHistory == null || _feedbackHistory!.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(Icons.feedback, color: Theme.of(context).primaryColor),
              const SizedBox(height: 8),
              const Text('Aucun feedback disponible'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Historique des Feedback (${_feedbackHistory!.length})',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: _feedbackHistory!.length,
                itemBuilder: (context, index) {
                  final feedback = _feedbackHistory![index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getStarColor(feedback.rating),
                        child: Text(
                          feedback.rating.toString(),
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        feedback.recipeId.length > 30
                            ? '${feedback.recipeId.substring(0, 30)}...'
                            : feedback.recipeId,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Type: ${feedback.feedbackType}'),
                          Text('Tags: ${feedback.tags.take(3).join(', ')}'),
                          Text(
                              'Date: ${feedback.createdAt.toString().split(' ')[0]}'),
                        ],
                      ),
                      trailing: feedback.comment != null
                          ? const Icon(Icons.comment, size: 16)
                          : null,
                      onTap: () => _showFeedbackDetails(feedback),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Actions Administration',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _clearAllData,
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Effacer toutes les données'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _exportData,
                    icon: const Icon(Icons.download),
                    label: const Text('Exporter les données'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
        return Colors.grey;
    }
  }

  void _showFeedbackDetails(RecipeFeedbackModel feedback) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Détails du Feedback',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              _buildDetailRow('ID', feedback.id),
              _buildDetailRow('Recette', feedback.recipeId),
              _buildDetailRow('Note', '${feedback.rating}/5'),
              _buildDetailRow('Type', feedback.feedbackType),
              _buildDetailRow('Tags', feedback.tags.join(', ')),
              _buildDetailRow('Date', feedback.createdAt.toString()),
              if (feedback.comment != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Commentaire:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(feedback.comment!),
              ],
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Fermer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text(
          'Êtes-vous sûr de vouloir effacer toutes les données ML ? '
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Effacer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await MLService.clearAllData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Toutes les données ML ont été effacées'),
          backgroundColor: Colors.green,
        ),
      );
      _loadMLData();
    }
  }

  Future<void> _exportData() async {
    try {
      final feedback = await MLService.getFeedbackHistory();
      final preferences = await MLService.getUserPreferences();

      final exportData = {
        'feedback': feedback.map((f) => f.toJson()).toList(),
        'preferences': preferences,
        'exported_at': DateTime.now().toIso8601String(),
      };

      // Pour une vraie app, ici on sauvegarderait dans un fichier
      print('Export ML Data: ${exportData.toString()}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Données exportées dans les logs'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur d\'exportation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
