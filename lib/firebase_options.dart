// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDdLYoGlJA9FES9q9AIABeKVBMbpH7Wmjk',
    appId: '1:283692545969:web:e0e5b5bc1ebff38ab32f90',
    messagingSenderId: '283692545969',
    projectId: 'health-companion-database',
    authDomain: 'health-companion-database.firebaseapp.com',
    storageBucket: 'health-companion-database.appspot.com',
    measurementId: 'G-X7L9XPKWE2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDTnREEkGnLw4asPPZeReDfZtMY0FYKHVs',
    appId: '1:283692545969:android:ca8f9bf597e98c02b32f90',
    messagingSenderId: '283692545969',
    projectId: 'health-companion-database',
    storageBucket: 'health-companion-database.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA_nRdgiLpzFgSk9INU5ECvAYT6VNJhfSg',
    appId: '1:283692545969:ios:19be2dcefc007cacb32f90',
    messagingSenderId: '283692545969',
    projectId: 'health-companion-database',
    storageBucket: 'health-companion-database.appspot.com',
    iosBundleId: 'com.example.healthCompanionApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA_nRdgiLpzFgSk9INU5ECvAYT6VNJhfSg',
    appId: '1:283692545969:ios:19be2dcefc007cacb32f90',
    messagingSenderId: '283692545969',
    projectId: 'health-companion-database',
    storageBucket: 'health-companion-database.appspot.com',
    iosBundleId: 'com.example.healthCompanionApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDdLYoGlJA9FES9q9AIABeKVBMbpH7Wmjk',
    appId: '1:283692545969:web:69ba5005b4c34949b32f90',
    messagingSenderId: '283692545969',
    projectId: 'health-companion-database',
    authDomain: 'health-companion-database.firebaseapp.com',
    storageBucket: 'health-companion-database.appspot.com',
    measurementId: 'G-CFDHJBQJJ3',
  );

}