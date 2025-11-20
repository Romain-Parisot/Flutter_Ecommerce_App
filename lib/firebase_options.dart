import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return _web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _android;
      case TargetPlatform.iOS:
        return _ios;
      case TargetPlatform.macOS:
        return _macos;
      case TargetPlatform.windows:
        return _windows;
      case TargetPlatform.linux:
        return _linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions _web = FirebaseOptions(
    apiKey: 'AIzaSyCeRADrXEyLq-eH4cHEFIxTqRuEqoWiQ_4',
    appId: '1:884701979120:web:0bc0f607802dffada6bd35',
    messagingSenderId: '884701979120',
    projectId: 'flutter-25984',
    authDomain: 'flutter-25984.firebaseapp.com',
    storageBucket: 'flutter-25984.firebasestorage.app',
    measurementId: 'G-6RVXN7VKPZ',
  );

  static const FirebaseOptions _android = FirebaseOptions(
    apiKey: 'AIzaSyAoqJeWbby3h-c0W4wVhDVfjPmA5LbdixI',
    appId: '1:884701979120:android:65be2eb9c81fb65ea6bd35',
    messagingSenderId: '884701979120',
    projectId: 'flutter-25984',
    storageBucket: 'flutter-25984.firebasestorage.app',
  );

  static const FirebaseOptions _ios = FirebaseOptions(
    apiKey: 'AIzaSyCvPU2afJudIRLZ9C-kC-pv9dSLNRvrqKo',
    appId: '1:884701979120:ios:37062906a8a8df7ea6bd35',
    messagingSenderId: '884701979120',
    projectId: 'flutter-25984',
    storageBucket: 'flutter-25984.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication3',
  );

  static const FirebaseOptions _macos = FirebaseOptions(
    apiKey: 'AIzaSyCvPU2afJudIRLZ9C-kC-pv9dSLNRvrqKo',
    appId: '1:884701979120:ios:37062906a8a8df7ea6bd35',
    messagingSenderId: '884701979120',
    projectId: 'flutter-25984',
    storageBucket: 'flutter-25984.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication3',
  );

  static const FirebaseOptions _windows = FirebaseOptions(
    apiKey: 'AIzaSyCeRADrXEyLq-eH4cHEFIxTqRuEqoWiQ_4',
    appId: '1:884701979120:web:d348516c3a2f71b3a6bd35',
    messagingSenderId: '884701979120',
    projectId: 'flutter-25984',
    storageBucket: 'flutter-25984.firebasestorage.app',
    authDomain: 'flutter-25984.firebaseapp.com',
    measurementId: 'G-TSQDSHL1ZN',
  );

  static const FirebaseOptions _linux = FirebaseOptions(
    apiKey: 'AIzaSyCeRADrXEyLq-eH4cHEFIxTqRuEqoWiQ_4',
    appId: '1:884701979120:web:d348516c3a2f71b3a6bd35',
    messagingSenderId: '884701979120',
    projectId: 'flutter-25984',
    storageBucket: 'flutter-25984.firebasestorage.app',
    authDomain: 'flutter-25984.firebaseapp.com',
    measurementId: 'G-TSQDSHL1ZN',
  );
}
