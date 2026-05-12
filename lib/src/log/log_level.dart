/// Defines available log severity levels.
///
/// Used to categorize logs based on importance and severity.
enum LogLevel {
  /// Debug-level logs.
  ///
  /// Typically used for development and troubleshooting.
  debug,

  /// Informational logs.
  ///
  /// Used for general application events.
  info,

  /// Warning logs.
  ///
  /// Indicates unexpected situations that are not fatal.
  warning,

  /// Error logs.
  ///
  /// Represents failures or recoverable issues.
  error,

  /// Fatal logs.
  ///
  /// Represents critical failures that may crash the application.
  fatal,
}

/// Extension helpers for [LogLevel].
extension LogLevelX on LogLevel {
  /// Uppercase display name for the log level.
  ///
  /// Example:
  /// ```dart
  /// level.displayName
  /// ```
  String get displayName {
    return switch (this) {
      LogLevel.debug => 'DEBUG',
      LogLevel.info => 'INFO',
      LogLevel.warning => 'WARNING',
      LogLevel.error => 'ERROR',
      LogLevel.fatal => 'FATAL',
    };
  }

  /// Emoji representation of the log level.
  ///
  /// Useful for console logs or visual debugging.
  ///
  /// Example:
  /// ```dart
  /// level.emoji
  /// ```
  String get emoji {
    return switch (this) {
      LogLevel.debug => '🔍',
      LogLevel.info => 'ℹ️',
      LogLevel.warning => '⚠️',
      LogLevel.error => '🔴',
      LogLevel.fatal => '💀',
    };
  }

  /// Detects a [LogLevel] from a raw log line.
  ///
  /// Returns:
  /// - matching [LogLevel] if found
  /// - `null` if no level is detected
  ///
  /// Example:
  /// ```dart
  /// final LogLevel? level =
  ///     LogLevelX.fromLine('[ERROR] Something failed');
  /// ```
  static LogLevel? fromLine(String line) {
    for (final LogLevel level in LogLevel.values) {
      if (line.contains('[${level.displayName}]')) {
        return level;
      }
    }
    return null;
  }
}
