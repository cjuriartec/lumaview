import 'package:lumaview/features/auth/domain/entities/auth_user.dart';
import 'package:lumaview/features/auth/domain/repository_contracts/auth_repository.dart';

class SignInWithGoogle {
  const SignInWithGoogle(this._repository);

  final AuthRepository _repository;

  Future<AppUser> call() {
    return _repository.signInWithGoogle();
  }
}
