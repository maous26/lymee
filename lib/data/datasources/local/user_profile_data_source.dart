// lib/data/datasources/local/user_profile_data_source.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lym_nutrition/core/error/exceptions.dart';
import 'package:lym_nutrition/domain/entities/user_profile.dart';

abstract class UserProfileDataSource {
  /// Récupère le profil de l'utilisateur
  ///
  /// Retourne un [UserProfile]
  ///
  /// Lance [CacheException] si aucun profil n'est disponible
  Future<UserProfile> getUserProfile();

  /// Vérifie si le profil de l'utilisateur existe
  ///
  /// Retourne un [bool]
  Future<bool> hasUserProfile();

  /// Sauvegarde le profil de l'utilisateur
  ///
  /// Retourne [true] si la sauvegarde a réussi
  Future<bool> saveUserProfile(UserProfile userProfile);

  /// Vérifie si l'utilisateur a terminé l'onboarding
  Future<bool> hasCompletedOnboarding();

  /// Réinitialise le profil utilisateur et le statut d'onboarding
  Future<bool> resetUserProfile();
}

class UserProfileDataSourceImpl implements UserProfileDataSource {
  final SharedPreferences sharedPreferences;
  static const String USER_PROFILE_KEY = 'USER_PROFILE';
  static const String HAS_COMPLETED_ONBOARDING_KEY = 'HAS_COMPLETED_ONBOARDING';

  UserProfileDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserProfile> getUserProfile() async {
    try {
      final String? jsonString = sharedPreferences.getString(USER_PROFILE_KEY);

      if (jsonString == null) {
        throw CacheException('Aucun profil utilisateur disponible');
      }

      Map<String, dynamic> profileJson = jsonDecode(jsonString);
      return UserProfile.fromJson(profileJson);
    } catch (e) {
      if (e is CacheException) {
        rethrow;
      }
      throw CacheException(
          'Erreur lors de la récupération du profil: ${e.toString()}');
    }
  }

  @override
  Future<bool> hasUserProfile() async {
    return sharedPreferences.containsKey(USER_PROFILE_KEY);
  }

  @override
  Future<bool> saveUserProfile(UserProfile userProfile) async {
    try {
      final String jsonString = jsonEncode(userProfile.toJson());
      final result =
          await sharedPreferences.setString(USER_PROFILE_KEY, jsonString);

      // Marquer l'onboarding comme terminé
      await sharedPreferences.setBool(HAS_COMPLETED_ONBOARDING_KEY, true);

      return result;
    } catch (e) {
      throw CacheException(
          'Erreur lors de la sauvegarde du profil: ${e.toString()}');
    }
  }

  /// Vérifie si l'utilisateur a terminé l'onboarding
  @override
  Future<bool> hasCompletedOnboarding() async {
    // TESTING MODE: Always return false to reset onboarding on each app launch
    // This forces the onboarding to restart every time for testing purposes
    // TODO: Remove this when moving to production
    return false;

    // Original implementation (commented out for testing):
    // return sharedPreferences.getBool(HAS_COMPLETED_ONBOARDING_KEY) ?? false;
  }

  /// Réinitialise le profil utilisateur et le statut d'onboarding
  @override
  Future<bool> resetUserProfile() async {
    try {
      await sharedPreferences.remove(USER_PROFILE_KEY);
      await sharedPreferences.remove(HAS_COMPLETED_ONBOARDING_KEY);
      return true;
    } catch (e) {
      throw CacheException(
          'Erreur lors de la réinitialisation du profil: ${e.toString()}');
    }
  }
}
