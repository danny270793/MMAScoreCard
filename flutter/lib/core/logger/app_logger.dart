import 'package:flutter/foundation.dart';

/// Debug-only console logger (same shape as Wallet's `AppLogger`).
abstract class AppLogger {
  static void debug(String message) {
    if (!kDebugMode) return;
    _log('DEBUG', message);
  }

  static void info(String message) {
    if (!kDebugMode) return;
    _log('INFO ', message);
  }

  static void warn(String message) {
    if (!kDebugMode) return;
    _log('WARN ', message);
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (!kDebugMode) return;
    _log('ERROR', message);
    if (error != null) debugPrint('         error: $error');
    if (stackTrace != null) debugPrint('    stacktrace: $stackTrace');
  }

  static void _log(String level, String message) {
    final time = DateTime.now().toIso8601String();
    debugPrint('[$time][$level][${_callerPath()}] $message');
  }

  static String _callerPath() {
    // Frame 0: _callerPath  Frame 1: _log  Frame 2: debug/info/warn/error  Frame 3: actual caller
    final frame = StackTrace.current.toString().split('\n').elementAtOrNull(3);
    if (frame == null) return '?';
    final match = RegExp(r'\(package:[^/]+/(.+\.dart):\d+:\d+\)')
        .firstMatch(frame);
    return match?.group(1) ?? '?';
  }
}
