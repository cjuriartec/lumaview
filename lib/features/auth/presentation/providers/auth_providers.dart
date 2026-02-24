import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lumaview/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:lumaview/features/auth/domain/repository_contracts/auth_repository.dart';
import 'package:lumaview/features/auth/domain/use_cases/sign_in_with_google.dart';

final googleSignInProvider = Provider<GoogleSignIn>(
  (ref) => GoogleSignIn.instance,
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.read(googleSignInProvider)),
);

final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogle>(
  (ref) => SignInWithGoogle(ref.read(authRepositoryProvider)),
);
