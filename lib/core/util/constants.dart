// lib/core/util/constants.dart
class Constants {
  // Chemins d'assets
  static const String lottiePath = 'assets/animations';
  static const String imagePath = 'assets/images';
  static const String iconPath = 'assets/icons';
  static const String dataPath = 'assets/data';
  
  // Fichiers de données
  static const String ciqualDataFile = 'common_ciqual.json';
  
  // Clés de préférences partagées
  static const String keyLastSync = 'LAST_SYNC';
  static const String keyUserProfile = 'USER_PROFILE';
  static const String keyThemeMode = 'THEME_MODE';
  
  // Constantes réseau
  static const int timeoutDuration = 10000; // 10 secondes
  static const int maxRetries = 3;
  
  // Constantes d'interface utilisateur
  static const int searchDebounceTime = 300; // millisecondes
  static const int minimumSearchLength = 2;
  
  // Constantes de pagination
  static const int pageSize = 20;
  
  // Valeurs nutritionnelles par défaut
  static const double defaultDailyCalories = 2000;
  static const double defaultDailyProtein = 50;
  static const double defaultDailyCarbs = 275;
  static const double defaultDailyFat = 78;
  static const double defaultDailyFiber = 25;
  static const double defaultDailySugar = 50;
}