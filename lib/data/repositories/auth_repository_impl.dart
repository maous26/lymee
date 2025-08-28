// lib/data/repositories/auth_repository_impl.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart' as failures;
import '../../core/network/network_info.dart';
import '../../core/services/remember_me_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  // Stream controller for auth state changes
  final StreamController<User?> _authStateController =
      StreamController<User?>.broadcast();

  // Persisted local user database (email -> user json)
  Map<String, Map<String, dynamic>> _localUsers = {};
  User? _currentUser;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Stream<User?> get authStateChanges => _authStateController.stream;

  @override
  Future<Either<failures.Failure, User?>> getCurrentUser() async {
    try {
      // Check if remember me is enabled
      final rememberMe = await localDataSource.getRememberMe();
      if (!rememberMe) {
        // If remember me is false, user should not be auto-logged in
        return const Right(null);
      }

      // Load local users cache in memory
      _localUsers = await localDataSource.getRegisteredUsers();
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null) {
        _currentUser = cachedUser.toEntity();
        return Right(_currentUser);
      }
      return const Right(null);
    } on CacheException {
      return Left(failures.CacheFailure());
    }
  }

  @override
  Future<Either<failures.Failure, bool>> isAuthenticated() async {
    try {
      final isUserCached = await localDataSource.isUserCached();
      return Right(isUserCached);
    } on CacheException {
      return Left(failures.CacheFailure());
    }
  }

  @override
  Future<Either<failures.Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(failures.NetworkFailure());
      }

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Refresh local users
      _localUsers = await localDataSource.getRegisteredUsers();
      final hashedPassword = _hashPassword(password);
      final userKey = email.toLowerCase();
      if (!_localUsers.containsKey(userKey)) {
        return Left(
            failures.ServerFailure('Aucun utilisateur trouvé avec cet email.'));
      }

      final userData = _localUsers[userKey]!;
      if (userData['password'] != hashedPassword) {
        return Left(failures.ServerFailure('Mot de passe incorrect.'));
      }

      // Create user model
      final userModel = UserModel(
        id: userData['id'],
        email: email,
        displayName: userData['displayName'],
        photoURL: userData['photoURL'],
        isEmailVerified: userData['isEmailVerified'] ?? false,
        createdAt: DateTime.parse(userData['createdAt']),
        lastLoginAt: DateTime.now(),
      );

      // Update last login time
      _localUsers[userKey]!['lastLoginAt'] = DateTime.now().toIso8601String();
      await localDataSource.upsertRegisteredUser(
          userKey, _localUsers[userKey]!);

      // Get remember me preference from the service
      final rememberMeService = RememberMeService();
      final rememberMe = rememberMeService.rememberMe;

      // Set remember me preference
      await localDataSource.setRememberMe(rememberMe);

      // Cache user locally only if remember me is true
      if (rememberMe) {
        await localDataSource.cacheUser(userModel);
      } else {
        // Clear cached user if remember me is false
        await localDataSource.clearCachedUser();
      }

      final user = userModel.toEntity();
      _currentUser = user;
      _authStateController.add(user);

      return Right(user);
    } on ServerException {
      return Left(failures.ServerFailure());
    } on CacheException {
      return Left(failures.CacheFailure());
    } catch (e) {
      return Left(failures.ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<failures.Failure, User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(failures.NetworkFailure());
      }

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final userKey = email.toLowerCase();
      _localUsers = await localDataSource.getRegisteredUsers();
      // Check if user already exists
      if (_localUsers.containsKey(userKey)) {
        return Left(
            failures.ServerFailure('Un compte avec cet email existe déjà.'));
      }

      // Create new user
      final userId = _generateUserId();
      final hashedPassword = _hashPassword(password);
      final now = DateTime.now();

      _localUsers[userKey] = {
        'id': userId,
        'email': email,
        'password': hashedPassword,
        'displayName': displayName,
        'photoURL': null,
        'isEmailVerified': false,
        'createdAt': now.toIso8601String(),
        'lastLoginAt': now.toIso8601String(),
      };
      await localDataSource.upsertRegisteredUser(
          userKey, _localUsers[userKey]!);

      final userModel = UserModel(
        id: userId,
        email: email,
        displayName: displayName,
        photoURL: null,
        isEmailVerified: false,
        createdAt: now,
        lastLoginAt: now,
      );

      // Set remember me to true by default for new signups
      await localDataSource.setRememberMe(true);

      // Cache user locally
      await localDataSource.cacheUser(userModel);

      final user = userModel.toEntity();
      _currentUser = user;
      _authStateController.add(user);

      return Right(user);
    } on ServerException {
      return Left(failures.ServerFailure());
    } on CacheException {
      return Left(failures.CacheFailure());
    } catch (e) {
      return Left(failures.ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<failures.Failure, void>> signOut() async {
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Clear remember me preference
      await localDataSource.setRememberMe(false);

      // Reset the remember me service
      final rememberMeService = RememberMeService();
      rememberMeService.reset();

      // Clear cached user
      await localDataSource.clearCachedUser();

      _currentUser = null;
      _authStateController.add(null);

      return const Right(null);
    } on CacheException {
      return Left(failures.CacheFailure());
    } catch (e) {
      return Left(failures.ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<failures.Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(failures.NetworkFailure());
      }

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final userKey = email.toLowerCase();
      _localUsers = await localDataSource.getRegisteredUsers();
      if (!_localUsers.containsKey(userKey)) {
        return Left(
            failures.ServerFailure('Aucun utilisateur trouvé avec cet email.'));
      }

      // In a real app, this would trigger an email
      print('Password reset email sent to $email');

      return const Right(null);
    } on ServerException {
      return Left(failures.ServerFailure());
    } catch (e) {
      return Left(failures.ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<failures.Failure, void>> sendEmailVerification() async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(failures.NetworkFailure());
      }

      if (_currentUser == null) {
        return Left(failures.ServerFailure('Aucun utilisateur connecté.'));
      }

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, this would trigger an email
      print('Email verification sent to ${_currentUser!.email}');

      return const Right(null);
    } on ServerException {
      return Left(failures.ServerFailure());
    } catch (e) {
      return Left(failures.ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<failures.Failure, bool>> isEmailVerified() async {
    try {
      if (_currentUser == null) {
        return const Right(false);
      }

      return Right(_currentUser!.isEmailVerified);
    } catch (e) {
      return Left(failures.ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<failures.Failure, User>> refreshUser() async {
    try {
      if (_currentUser == null) {
        return Left(failures.ServerFailure('Aucun utilisateur connecté.'));
      }

      // In a real app, this would fetch fresh user data from server
      final userKey = _currentUser!.email.toLowerCase();
      _localUsers = await localDataSource.getRegisteredUsers();
      if (_localUsers.containsKey(userKey)) {
        final userData = _localUsers[userKey]!;

        final userModel = UserModel(
          id: userData['id'],
          email: _currentUser!.email,
          displayName: userData['displayName'],
          photoURL: userData['photoURL'],
          isEmailVerified: userData['isEmailVerified'] ?? false,
          createdAt: DateTime.parse(userData['createdAt']),
          lastLoginAt: userData['lastLoginAt'] != null
              ? DateTime.parse(userData['lastLoginAt'])
              : null,
        );

        await localDataSource.cacheUser(userModel);

        final user = userModel.toEntity();
        _currentUser = user;
        _authStateController.add(user);

        return Right(user);
      }

      return Left(failures.ServerFailure('Utilisateur non trouvé.'));
    } on CacheException {
      return Left(failures.CacheFailure());
    } catch (e) {
      return Left(failures.ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<failures.Failure, void>> deleteAccount() async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(failures.NetworkFailure());
      }

      if (_currentUser == null) {
        return Left(failures.ServerFailure('Aucun utilisateur connecté.'));
      }

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final userKey = _currentUser!.email.toLowerCase();
      await localDataSource.removeRegisteredUser(userKey);
      await localDataSource.clearCachedUser();

      _currentUser = null;
      _authStateController.add(null);

      return const Right(null);
    } on ServerException {
      return Left(failures.ServerFailure());
    } on CacheException {
      return Left(failures.CacheFailure());
    } catch (e) {
      return Left(failures.ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<failures.Failure, User>> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(failures.NetworkFailure());
      }

      if (_currentUser == null) {
        return Left(failures.ServerFailure('Aucun utilisateur connecté.'));
      }

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final userKey = _currentUser!.email.toLowerCase();
      _localUsers = await localDataSource.getRegisteredUsers();
      if (_localUsers.containsKey(userKey)) {
        if (displayName != null) {
          _localUsers[userKey]!['displayName'] = displayName;
        }
        if (photoURL != null) {
          _localUsers[userKey]!['photoURL'] = photoURL;
        }

        final userData = _localUsers[userKey]!;
        final userModel = UserModel(
          id: userData['id'],
          email: _currentUser!.email,
          displayName: userData['displayName'],
          photoURL: userData['photoURL'],
          isEmailVerified: userData['isEmailVerified'] ?? false,
          createdAt: DateTime.parse(userData['createdAt']),
          lastLoginAt: userData['lastLoginAt'] != null
              ? DateTime.parse(userData['lastLoginAt'])
              : null,
        );

        await localDataSource.upsertRegisteredUser(userKey, userData);
        await localDataSource.cacheUser(userModel);

        final user = userModel.toEntity();
        _currentUser = user;
        _authStateController.add(user);

        return Right(user);
      }

      return Left(failures.ServerFailure('Utilisateur non trouvé.'));
    } on ServerException {
      return Left(failures.ServerFailure());
    } on CacheException {
      return Left(failures.CacheFailure());
    } catch (e) {
      return Left(failures.ServerFailure(e.toString()));
    }
  }

  // Helper methods
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  String _generateUserId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomNumber = random.nextInt(1000000);
    return '${timestamp}_$randomNumber';
  }

  void dispose() {
    _authStateController.close();
  }
}
