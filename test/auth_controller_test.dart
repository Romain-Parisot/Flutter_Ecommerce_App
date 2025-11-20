import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_3/src/features/auth/application/auth_backend.dart';
import 'package:flutter_application_3/src/features/auth/application/auth_controller.dart';

class _FakeAuthBackend implements AuthBackend {
  _FakeAuthBackend();

  final _controller = StreamController<AuthSession?>.broadcast();
  AuthSession? _current;
  String? nextErrorCode;

  void _emit(AuthSession? session) {
    _current = session;
    _controller.add(session);
  }

  @override
  Stream<AuthSession?> get authStateChanges => _controller.stream;

  @override
  AuthSession? get currentUser => _current;

  @override
  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    if (nextErrorCode != null) {
      final code = nextErrorCode!;
      nextErrorCode = null;
      throw AuthBackendException(code);
    }
    _emit(AuthSession(isAnonymous: false, email: email));
  }

  @override
  Future<void> signInAnonymously() async {
    _emit(const AuthSession(isAnonymous: true));
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    if (nextErrorCode != null) {
      final code = nextErrorCode!;
      nextErrorCode = null;
      throw AuthBackendException(code);
    }
    _emit(AuthSession(isAnonymous: false, email: email));
  }

  @override
  Future<void> signInWithGoogle() async {
    _emit(
      const AuthSession(isAnonymous: false, email: 'google@shopflutter.app'),
    );
  }

  @override
  Future<void> signOut() async {
    _emit(null);
  }

  @override
  void dispose() {
    _controller.close();
  }
}

void main() {
  test('loginWithEmail updates auth state on success', () async {
    final backend = _FakeAuthBackend();
    final container = ProviderContainer(
      overrides: [authBackendProvider.overrideWithValue(backend)],
    );
    addTearDown(() {
      backend.dispose();
      container.dispose();
    });

    final controller = container.read(authControllerProvider.notifier);

    await controller.loginWithEmail('client@shopflutter.app', 'secret');
    await Future<void>.delayed(Duration.zero);

    final state = container.read(authControllerProvider);
    expect(state.isAuthenticated, isTrue);
    expect(state.email, 'client@shopflutter.app');
    expect(state.errorMessage, isNull);
    expect(state.isLoading, isFalse);
  });

  test('loginWithEmail surfaces friendly error message', () async {
    final backend = _FakeAuthBackend()..nextErrorCode = 'wrong-password';
    final container = ProviderContainer(
      overrides: [authBackendProvider.overrideWithValue(backend)],
    );
    addTearDown(() {
      backend.dispose();
      container.dispose();
    });

    final controller = container.read(authControllerProvider.notifier);

    await controller.loginWithEmail('client@shopflutter.app', 'bad');
    await Future<void>.delayed(Duration.zero);

    final state = container.read(authControllerProvider);
    expect(state.isAuthenticated, isFalse);
    expect(state.errorMessage, 'Combinaison email/mot de passe incorrecte.');
    expect(state.isLoading, isFalse);
  });
}
