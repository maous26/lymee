// Debug utility to refresh CIQUAL data
// Add this to your app and call it when needed

import 'package:flutter/material.dart';
import 'package:lym_nutrition/injection_container.dart' as di;
import 'package:lym_nutrition/data/datasources/local/ciqual_local_data_source.dart';

class CiqualCacheManager {
  static Future<void> refreshCache(BuildContext context) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Actualisation des données...'),
            ],
          ),
        ),
      );

      // Get the data source
      final ciqualDataSource = di.sl<CiqualLocalDataSource>();

      // Clear the cache
      await ciqualDataSource.clearCache();

      // Force re-initialization
      await ciqualDataSource.initializeDatabase();

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Données CIQUAL actualisées avec succès!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      // Close loading dialog if open
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur lors de l\'actualisation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
