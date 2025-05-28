import 'package:equatable/equatable.dart';

// lib/core/error/exceptions.dart
class ServerException implements Exception {
  final String message;
  
  ServerException([this.message = 'Une erreur serveur est survenue']);
}

class CacheException implements Exception {
  final String message;
  
  CacheException([this.message = 'Une erreur de cache est survenue']);
}

class DataParsingException implements Exception {
  final String message;
  
  DataParsingException([this.message = 'Erreur lors du parsing des données']);
}

// lib/core/error/failures.dart

abstract class Failure extends Equatable {
  final String message;
  
  const Failure([this.message = 'Une erreur est survenue']);
  
  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Une erreur serveur est survenue']) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Une erreur de cache est survenue']) : super(message);
}

class DataParsingFailure extends Failure {
  const DataParsingFailure([String message = 'Erreur lors du parsing des données']) : super(message);
}