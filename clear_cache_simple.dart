// Simple cache clearing script without Flutter dependencies
// Run with: dart clear_cache_simple.dart

import 'dart:io';

void main() async {
  print('🔄 Recherche du cache CIQUAL...');

  // Common SharedPreferences locations on macOS
  final possiblePaths = [
    '${Platform.environment['HOME']}/Library/Preferences/',
    '${Platform.environment['HOME']}/Library/Application Support/',
  ];

  // Look for your app's preference files
  for (final path in possiblePaths) {
    final dir = Directory(path);
    if (await dir.exists()) {
      await for (final entity in dir.list()) {
        if (entity is File && entity.path.contains('lym_nutrition')) {
          print('📁 Trouvé: ${entity.path}');
          // You could delete the file here if needed
        }
      }
    }
  }

  print('');
  print('📱 Pour effacer le cache CIQUAL de votre app:');
  print('1. Ouvrez l\'app LYM Nutrition');
  print('2. Allez sur l\'écran de recherche d\'aliments');
  print('3. Appuyez sur le bouton de rafraîchissement (🔄) en haut à droite');
  print('4. Attendez que l\'actualisation soit terminée');
  print('');
  print('✅ Vos nouvelles données CIQUAL seront alors chargées!');
}
