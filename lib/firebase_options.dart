import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions hanya dikonfigurasi untuk web.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC7FFylzeEBJAIjH9RQNUAw2gtKoWNTb6s',
    appId: '1:484720162270:web:b606c110a79ae32b08594f',
    messagingSenderId: '484720162270',
    projectId: 'tugas-firebase-fiko',
    authDomain: 'tugas-firebase-fiko.firebaseapp.com',
    storageBucket: 'tugas-firebase-fiko.firebasestorage.app',
  );
}
