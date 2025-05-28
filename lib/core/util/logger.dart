// lib/core/util/logger.dart
class Logger {
  static const String _tag = 'LYM';
  static bool _isEnabled = true;
  
  static void enable() {
    _isEnabled = true;
  }
  
  static void disable() {
    _isEnabled = false;
  }
  
  static void d(String message) {
    if (_isEnabled) {
      print('[$_tag] 💙 $message');
    }
  }
  
  static void i(String message) {
    if (_isEnabled) {
      print('[$_tag] 💚 $message');
    }
  }
  
  static void w(String message) {
    if (_isEnabled) {
      print('[$_tag] 💛 $message');
    }
  }
  
  static void e(String message, [Object? error, StackTrace? stackTrace]) {
    if (_isEnabled) {
      print('[$_tag] ❤️ $message');
      if (error != null) {
        print('[$_tag] ❤️ Error: $error');
      }
      if (stackTrace != null) {
        print('[$_tag] ❤️ StackTrace: $stackTrace');
      }
    }
  }
}
