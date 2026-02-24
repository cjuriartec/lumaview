import 'package:lumaview/features/auth/domain/entities/auth_user.dart';

abstract class AuthRepository {
  Future<AppUser> signInWithGoogle();
}
