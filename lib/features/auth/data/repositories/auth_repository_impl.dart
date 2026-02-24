import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lumaview/config/env/env_config.dart';
import 'package:lumaview/features/auth/domain/entities/auth_user.dart';
import 'package:lumaview/features/auth/domain/repository_contracts/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._googleSignIn);

  final GoogleSignIn _googleSignIn;

  @override
  Future<AppUser> signInWithGoogle() async {
    if (kIsWeb) {
      throw Exception(
        'Google Sign-In en web se maneja desde la capa de presentación.',
      );
    }

    String? clientId;
    String? serverClientId;

    if (defaultTargetPlatform == TargetPlatform.android) {
      clientId = Env.config.androidClientId;
      serverClientId = Env.config.serverClientId;
    }

    await _googleSignIn.initialize(
      clientId: clientId,
      serverClientId: serverClientId,
    );

    if (!_googleSignIn.supportsAuthenticate()) {
      throw Exception('Google Sign-In no soportado en esta plataforma');
    }

    try {
      await _googleSignIn.authenticate(scopeHint: <String>['email']);

      final account = await _googleSignIn.attemptLightweightAuthentication(
        reportAllExceptions: true,
      );
      if (account == null) {
        throw Exception('No se pudo obtener la cuenta de Google');
      }

      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw Exception('Google no devolvió un ID token válido');
      }

      final supabase = Supabase.instance.client;
      final authResponse = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      final supaUser = authResponse.user ?? supabase.auth.currentUser;
      if (supaUser == null) {
        throw Exception('No se pudo obtener el usuario desde Supabase');
      }

      return AppUser(
        id: supaUser.id,
        email: supaUser.email ?? account.email,
        name:
            (supaUser.userMetadata?['name'] as String?) ?? account.displayName,
        avatarUrl:
            (supaUser.userMetadata?['picture'] as String?) ?? account.photoUrl,
      );
    } finally {}
  }
}
