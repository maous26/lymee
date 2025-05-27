// A base UseCase class and NoParams for clean architecture
import 'package:dartz/dartz.dart';
import 'package:lym_nutrition/core/error/failures.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams {}
