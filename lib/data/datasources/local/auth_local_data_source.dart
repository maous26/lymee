// lib/data/datasources/local/auth_local_data_source.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/error/exceptions.dart';
import '../../models/user_model.dart';

abstract class AuthLocalDataSource {
  /// Get cached user data
  Future<UserModel?> getCachedUser();

  /// Cache user data
  Future<void> cacheUser(UserModel user);

  /// Clear cached user data
  Future<void> clearCachedUser();

  /// Check if user is locally stored as authenticated
  Future<bool> isUserCached();

  /// Get all registered users (email -> user map)
  Future<Map<String, Map<String, dynamic>>> getRegisteredUsers();

  /// Get a single registered user by email
  Future<Map<String, dynamic>?> getRegisteredUser(String email);

  /// Create or update a registered user
  Future<void> upsertRegisteredUser(String email, Map<String, dynamic> data);

  /// Remove a registered user by email
  Future<void> removeRegisteredUser(String email);

  /// Set remember me preference
  Future<void> setRememberMe(bool value);

  /// Get remember me preference
  Future<bool> getRememberMe();
}

const String cachedUserKey = 'CACHED_USER';
const String registeredUsersKey = 'REGISTERED_USERS';
const String rememberMeKey = 'REMEMBER_ME';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonString = sharedPreferences.getString(cachedUserKey);
      if (jsonString != null) {
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
        return UserModel.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final jsonString = json.encode(user.toJson());
      await sharedPreferences.setString(cachedUserKey, jsonString);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> clearCachedUser() async {
    try {
      await sharedPreferences.remove(cachedUserKey);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<bool> isUserCached() async {
    try {
      return sharedPreferences.containsKey(cachedUserKey);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<Map<String, Map<String, dynamic>>> getRegisteredUsers() async {
    try {
      final jsonString = sharedPreferences.getString(registeredUsersKey);
      if (jsonString == null) return {};
      final decoded = json.decode(jsonString) as Map<String, dynamic>;
      // Ensure deep map typing
      return decoded.map((key, value) => MapEntry(
            key,
            (value as Map).map((k, v) => MapEntry(k as String, v)),
          ));
    } catch (_) {
      throw CacheException();
    }
  }

  @override
  Future<Map<String, dynamic>?> getRegisteredUser(String email) async {
    final users = await getRegisteredUsers();
    return users[email.toLowerCase()];
  }

  @override
  Future<void> upsertRegisteredUser(
      String email, Map<String, dynamic> data) async {
    try {
      final users = await getRegisteredUsers();
      users[email.toLowerCase()] = data;
      final jsonString = json.encode(users);
      await sharedPreferences.setString(registeredUsersKey, jsonString);
    } catch (_) {
      throw CacheException();
    }
  }

  @override
  Future<void> removeRegisteredUser(String email) async {
    try {
      final users = await getRegisteredUsers();
      users.remove(email.toLowerCase());
      final jsonString = json.encode(users);
      await sharedPreferences.setString(registeredUsersKey, jsonString);
    } catch (_) {
      throw CacheException();
    }
  }

  @override
  Future<void> setRememberMe(bool value) async {
    try {
      await sharedPreferences.setBool(rememberMeKey, value);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<bool> getRememberMe() async {
    try {
      return sharedPreferences.getBool(rememberMeKey) ?? false;
    } catch (e) {
      throw CacheException();
    }
  }
}
