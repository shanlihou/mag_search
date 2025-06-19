// lib/logger.dart

import 'package:talker_flutter/talker_flutter.dart';

class Log {
  // Private constructor to prevent multiple instances
  Log._privateConstructor();

  // Singleton instance of the logger
  static final Log _instance = Log._privateConstructor();

  Talker? _loggerInstance;

  // Create a logger instance
  Talker get _logger {
    _loggerInstance ??= TalkerFlutter.init();

    return _loggerInstance!;
  }

  Talker get logger => _logger;

  // Getter to access the singleton logger instance
  static Log get instance => _instance;

  // Add methods to log messages with different levels

  void v(String message) => _logger.verbose(message);

  void d(String message) => _logger.debug(message);

  void i(String message) => _logger.info(message);

  void w(String message) => _logger.warning(message);

  void e(String message) => _logger.error(message);
}
