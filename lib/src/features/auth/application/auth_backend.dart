import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/firebase/firebase_guard.dart';
import '../domain/auth_defaults.dart';

class AuthSession {
  const AuthSession({required this.isAnonymous, this.email});

  final bool isAnonymous;
  final String? email;
}

class AuthBackendException implements Exception {
  AuthBackendException(this.code);

  final String code;
}

abstract class AuthBackend {
  Stream<AuthSession?> get authStateChanges;
  AuthSession? get currentUser;

  Future<void> signInAnonymously();
  Future<void> signInWithEmailAndPassword(String email, String password);
  Future<void> createUserWithEmailAndPassword(String email, String password);
  Future<void> signInWithGoogle();
  Future<void> signOut();
  void dispose();
}

class FirebaseAuthBackend implements AuthBackend {
  FirebaseAuthBackend(this._auth, {GoogleSignIn? googleSignIn})
    : _googleSignIn = googleSignIn ?? _createDefaultGoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  @override
  Stream<AuthSession?> get authStateChanges =>
      _auth.authStateChanges().map(_mapUser);

  @override
  AuthSession? get currentUser => _mapUser(_auth.currentUser);

  @override
  Future<void> createUserWithEmailAndPassword(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signInAnonymously() => _auth.signInAnonymously();

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      provider.setCustomParameters({'prompt': 'select_account'});
      await _auth.signInWithPopup(provider);
      return;
    }

    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw AuthBackendException('sign-in-cancelled');
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await _auth.signInWithCredential(credential);
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignored: GoogleSignIn sign-out best effort only.
    }
  }

  @override
  void dispose() {}

  AuthSession? _mapUser(User? user) {
    if (user == null) return null;
    return AuthSession(isAnonymous: user.isAnonymous, email: user.email);
  }
}

GoogleSignIn _createDefaultGoogleSignIn() {
  if (kIsWeb) {
    debugPrint(
      'Initializing GoogleSignIn for web with clientId=$_webGoogleClientId',
    );
    return GoogleSignIn(clientId: _webGoogleClientId);
  }
  return GoogleSignIn();
}

const _webGoogleClientId =
    '884701979120-9konorg79jmm2i2t2uas5mu0liv9084d.apps.googleusercontent.com';

class LocalAuthBackend implements AuthBackend {
  LocalAuthBackend({
    this.defaultEmail = AuthDefaults.defaultEmail,
    this.defaultPassword = AuthDefaults.defaultPassword,
  }) {
    _initialization = _loadUsers();
  }

  static const _prefsKey = 'local_auth_users';
  final Map<String, String> _users = {};
  final _controller = StreamController<AuthSession?>.broadcast();
  AuthSession? _current;
  SharedPreferences? _prefs;
  late final Future<void> _initialization;

  final String defaultEmail;
  final String defaultPassword;

  Future<void> _loadUsers() async {
    _prefs = await SharedPreferences.getInstance();
    final raw = _prefs!.getString(_prefsKey);
    if (raw != null) {
      final decoded = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      decoded.forEach((key, value) {
        _users[key] = value as String;
      });
    }
    if (!_users.containsKey(defaultEmail)) {
      _users[defaultEmail] = defaultPassword;
      await _saveUsers();
    }
    _controller.add(_current);
  }

  Future<void> _saveUsers() async {
    if (_prefs == null) return;
    await _prefs!.setString(_prefsKey, jsonEncode(_users));
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
    await _initialization;
    if (_users.containsKey(email)) {
      throw AuthBackendException('email-already-in-use');
    }
    _users[email] = password;
    await _saveUsers();
    _current = AuthSession(isAnonymous: false, email: email);
    _controller.add(_current);
  }

  @override
  Future<void> signInAnonymously() async {
    await _initialization;
    _current = const AuthSession(isAnonymous: true, email: null);
    _controller.add(_current);
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _initialization;
    if (!_users.containsKey(email)) {
      throw AuthBackendException('user-not-found');
    }
    if (_users[email] != password) {
      throw AuthBackendException('wrong-password');
    }
    _current = AuthSession(isAnonymous: false, email: email);
    _controller.add(_current);
  }

  @override
  Future<void> signOut() async {
    await _initialization;
    _current = null;
    _controller.add(_current);
  }

  @override
  Future<void> signInWithGoogle() {
    return signInWithEmailAndPassword(defaultEmail, defaultPassword);
  }

  @override
  void dispose() {
    _controller.close();
  }
}

final authBackendProvider = Provider<AuthBackend>((ref) {
  if (isFirebaseConfigured) {
    return FirebaseAuthBackend(FirebaseAuth.instance);
  }
  final backend = LocalAuthBackend();
  ref.onDispose(backend.dispose);
  return backend;
});
