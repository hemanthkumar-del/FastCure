import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static void info(String message) {
    if (kDebugMode) {
      print('ℹ️ [FastCure INFO]: $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      print('⚠️ [FastCure WARNING]: $message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('❌ [FastCure ERROR]: $message');
      if (error != null) {
        print('Details: $error');
      }
      if (stackTrace != null) {
        print(stackTrace);
      }
    }
  }
}
