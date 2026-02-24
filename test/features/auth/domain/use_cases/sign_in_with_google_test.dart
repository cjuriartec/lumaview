import 'package:flutter_test/flutter_test.dart';
import 'package:lumaview/features/auth/domain/entities/auth_user.dart';
import 'package:lumaview/features/auth/domain/repository_contracts/auth_repository.dart';
import 'package:lumaview/features/auth/domain/use_cases/sign_in_with_google.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository repository;
  late SignInWithGoogle useCase;

  setUp(() {
    repository = _MockAuthRepository();
    useCase = SignInWithGoogle(repository);
  });

  test(
    'should delegate to repository and return AppUser on success',
    () async {
      final user = AppUser(
        id: '123',
        email: 'test@example.com',
        name: 'Test User',
        avatarUrl: 'https://example.com/avatar.png',
      );

      when(() => repository.signInWithGoogle()).thenAnswer(
        (_) async => user,
      );

      final result = await useCase();

      expect(result, user);
      verify(() => repository.signInWithGoogle()).called(1);
      verifyNoMoreInteractions(repository);
    },
  );
}

