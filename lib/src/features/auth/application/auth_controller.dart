import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_backend.dart';

class AuthState {
  const AuthState({
    required this.isAuthenticated,
    this.email,
    this.isLoading = false,
    this.errorMessage,
  });

  final bool isAuthenticated;
  final String? email;
  final bool isLoading;
  final String? errorMessage;

  const AuthState.signedOut()
    : isAuthenticated = false,
      email = null,
      isLoading = false,
      errorMessage = null;

  AuthState copyWith({
    bool? isAuthenticated,
    String? email,
    bool? isLoading,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthController extends Notifier<AuthState> {
  StreamSubscription<AuthSession?>? _authSubscription;

  AuthBackend get _backend => ref.read(authBackendProvider);

  @override
  AuthState build() {
    _authSubscription ??= _backend.authStateChanges.listen((session) {
      state = state.copyWith(
        isAuthenticated: session != null,
        email: _userEmail(session),
        isLoading: false,
        errorMessage: null,
      );
    });
    ref.onDispose(() => _authSubscription?.cancel());
    final session = _backend.currentUser;
    return AuthState(
      isAuthenticated: session != null,
      email: _userEmail(session),
    );
  }

  Future<void> loginDemo() => _runAuthMutation(_backend.signInAnonymously);

  Future<void> loginWithEmail(String email, String password) {
    return _runAuthMutation(
      () => _backend.signInWithEmailAndPassword(email, password),
    );
  }

  Future<void> registerWithEmail(String email, String password) {
    return _runAuthMutation(
      () => _backend.createUserWithEmailAndPassword(email, password),
    );
  }

  Future<void> loginWithGoogle() {
    return _runAuthMutation(_backend.signInWithGoogle);
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await _backend.signOut();
    state = state.copyWith(isLoading: false);
  }

  Future<void> _runAuthMutation(Future<void> Function() mutation) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await mutation();
      state = state.copyWith(isLoading: false, errorMessage: null);
    } on AuthBackendException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _messageForCode(e.code),
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _messageForCode(e.code),
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erreur inconnue, réessayez.',
      );
    }
  }

  String? _userEmail(AuthSession? session) {
    if (session == null) return null;
    if (session.isAnonymous) return 'invité';
    return session.email;
  }

  String _messageForCode(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'user-not-found':
      case 'wrong-password':
        return 'Combinaison email/mot de passe incorrecte.';
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cet email.';
      case 'weak-password':
        return 'Mot de passe trop faible (6 caractères min).';
      case 'sign-in-cancelled':
        return 'Connexion annulée.';
      default:
        return 'Erreur d’authentification ($code).';
    }
  }
}

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
