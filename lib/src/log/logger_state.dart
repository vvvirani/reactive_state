/// Represents the current state of the logger.
///
/// Stores:
/// - initialization status
/// - total log count
/// - last clear timestamp
class LoggerState {
  /// Indicates whether the logger is initialized and ready.
  final bool isReady;

  /// Total number of stored logs.
  final int totalLogs;

  /// Timestamp of the last clear operation.
  ///
  /// Will be `null` if logs have never been cleared.
  final DateTime? lastCleared;

  const LoggerState({
    this.isReady = false,
    this.totalLogs = 0,
    this.lastCleared,
  });

  /// Creates a new logger state by overriding selected fields.
  LoggerState copyWith({
    bool? isReady,
    int? totalLogs,
    DateTime? lastCleared,
  }) {
    return LoggerState(
      isReady: isReady ?? this.isReady,
      totalLogs: totalLogs ?? this.totalLogs,
      lastCleared: lastCleared ?? this.lastCleared,
    );
  }
}
