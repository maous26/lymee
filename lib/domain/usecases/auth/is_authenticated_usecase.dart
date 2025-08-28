// lib/domain/usecases/auth/is_authenticated_usecase.dart
import 'package:dartz/dartz.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/auth_repository.dart';

class IsAuthenticatedUseCase implements UseCase<bool, NoParams> {
  final AuthRepository repository;

  IsAuthenticatedUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.isAuthenticated();
  }
}
