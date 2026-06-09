import 'package:flutter/foundation.dart';

class AppConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8081';
    }

    return 'http://10.0.2.2:8081';
  }
}