// File generated manually for Medhavi (মেধাবী) targeting project: studyhub-bd-39887
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
    apiKey: 'AIzaSyBafnOXFDaFoJRuotF0SP891zlssw17f3o',
    appId: '1:556026049349:web:c2fc35007a97b9c33ac42c',
    messagingSenderId: '556026049349',
    projectId: 'studyhub-bd-39887',
    authDomain: 'studyhub-bd-39887.firebaseapp.com',
    storageBucket: 'studyhub-bd-39887.firebasestorage.app',
    measurementId: 'G-26RC4QGLD6',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBafnOXFDaFoJRuotF0SP891zlssw17f3o',
    appId: '1:556026049349:android:c2fc35007a97b9c33ac42c',
    messagingSenderId: '556026049349',
    projectId: 'studyhub-bd-39887',
    storageBucket: 'studyhub-bd-39887.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBafnOXFDaFoJRuotF0SP891zlssw17f3o',
    appId: '1:556026049349:ios:c2fc35007a97b9c33ac42c',
    messagingSenderId: '556026049349',
    projectId: 'studyhub-bd-39887',
    storageBucket: 'studyhub-bd-39887.firebasestorage.app',
    iosBundleId: 'bd.medhavi.medhaviMobile',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBafnOXFDaFoJRuotF0SP891zlssw17f3o',
    appId: '1:556026049349:ios:c2fc35007a97b9c33ac42c',
    messagingSenderId: '556026049349',
    projectId: 'studyhub-bd-39887',
    storageBucket: 'studyhub-bd-39887.firebasestorage.app',
    iosBundleId: 'bd.medhavi.medhaviMobile',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBafnOXFDaFoJRuotF0SP891zlssw17f3o',
    appId: '1:556026049349:web:c2fc35007a97b9c33ac42c',
    messagingSenderId: '556026049349',
    projectId: 'studyhub-bd-39887',
    authDomain: 'studyhub-bd-39887.firebaseapp.com',
    storageBucket: 'studyhub-bd-39887.firebasestorage.app',
    measurementId: 'G-26RC4QGLD6',
  );
}
