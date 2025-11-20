// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_3/src/app.dart';
import 'package:flutter_application_3/src/features/auth/application/auth_backend.dart';

class _StubAuthBackend implements AuthBackend {
  final _controller = StreamController<AuthSession?>.broadcast();

  @override
  Stream<AuthSession?> get authStateChanges => _controller.stream;

  @override
  AuthSession? get currentUser => null;

  @override
  Future<void> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {}

  @override
  void dispose() {
    _controller.close();
  }

  @override
  Future<void> signInAnonymously() async {}

  @override
  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> signInWithGoogle() async {}
}

void main() {
  final stubBackend = _StubAuthBackend();

  testWidgets('Login screen renders brand title', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authBackendProvider.overrideWithValue(stubBackend)],
        child: const ShopApp(),
      ),
    );

    expect(find.text('ShopFlutter Bois de Chauffage'), findsOneWidget);
    expect(find.textContaining('Connexion'), findsWidgets);
  });
}
