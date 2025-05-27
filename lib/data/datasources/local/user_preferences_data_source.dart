// lib/data/datasources/local/user_preferences_data_source.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lym_nutrition/core/error/exceptions.dart';
import 'package:lym_nutrition/domain/entities/user_dietary_preferences.dart';

abstract class UserPreferencesDataSource {
  /// Récupère les préférences alimentaires de l'utilisateur
  ///
  /// Retourne un [UserDietaryPreferences]
  Future<UserDietaryPreferences> getDietaryPreferences();

  /// Sauvegarde les préférences alimentaires de l'utilisateur
  Future<void> saveDietaryPreferences(UserDietaryPreferences preferences);
}

class UserPreferencesDataSourceImpl implements UserPreferencesDataSource {
  final SharedPreferences sharedPreferences;
  static const String dietaryPreferencesKey = 'USER_DIETARY_PREFERENCES';

  UserPreferencesDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserDietaryPreferences> getDietaryPreferences() async {
    try {
      final String? jsonString = sharedPreferences.getString(
        dietaryPreferencesKey,
      );

      if (jsonString == null) {
        return UserDietaryPreferences();
      }

      Map<String, dynamic> preferences = jsonDecode(jsonString);
      return UserDietaryPreferences.fromJson(preferences);
    } catch (e) {
      throw CacheException(e.toString());
    }
  }

  @override
  Future<void> saveDietaryPreferences(
    UserDietaryPreferences preferences,
  ) async {
    try {
      await sharedPreferences.setString(
        dietaryPreferencesKey,
        jsonEncode(preferences.toJson()),
      );
    } catch (e) {
      throw CacheException(e.toString());
    }
  }
}
