// Generated manually based on android/app/google-services.json for project cinemarques1
// This mimics the file normally created by FlutterFire CLI.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Configuração web do Firebase não foi definida. Este app está configurado apenas para Android.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'Configuração Firebase não está disponível para esta plataforma. Suportado apenas em Android.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBoxjN9LQoXS1L6iWFy91q2H7cBdtmyU5E',
    appId: '1:921066712758:android:8f705850da1fcdd7948017',
    messagingSenderId: '921066712758',
    projectId: 'cinemarques2',
    storageBucket: 'cinemarques2.firebasestorage.app',
  );
}
