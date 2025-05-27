// lib/core/error/failures.dart
import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure([this.message = 'Une erreur est survenue']);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'Une erreur serveur est survenue'])
    : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'Une erreur de cache est survenue'])
    : super(message);
}

class DataParsingFailure extends Failure {
  const DataParsingFailure([
    String message = 'Erreur lors du parsing des données',
  ]) : super(message);
}
