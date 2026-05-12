/// Defines automatic log/data clearing intervals.
///
/// Used to determine when stored data should be removed automatically.
enum ClearPolicy {
  /// Never clear stored data automatically.
  never,

  /// Clear data every day.
  daily,

  /// Clear data every week.
  weekly,

  /// Clear data every month.
  monthly,

  /// Clear data every 3 months.
  every3Months,

  /// Clear data every 6 months.
  every6Months,
}

/// Extension helpers for [ClearPolicy].
extension ClearPolicyX on ClearPolicy {
  /// Human-readable display name.
  ///
  /// Example:
  /// ```dart
  /// policy.displayName
  /// ```
  String get displayName {
    return switch (this) {
      ClearPolicy.never => 'Never',
      ClearPolicy.daily => 'Daily',
      ClearPolicy.weekly => 'Weekly',
      ClearPolicy.monthly => 'Monthly',
      ClearPolicy.every3Months => 'Every 3 months',
      ClearPolicy.every6Months => 'Every 6 months',
    };
  }

  /// Duration associated with the clear policy.
  ///
  /// Returns `null` for [ClearPolicy.never].
  ///
  /// Example:
  /// ```dart
  /// final Duration? duration = policy.duration;
  /// ```
  Duration? get duration {
    return switch (this) {
      ClearPolicy.never => null,
      ClearPolicy.daily => const Duration(days: 1),
      ClearPolicy.weekly => const Duration(days: 7),
      ClearPolicy.monthly => const Duration(days: 30),
      ClearPolicy.every3Months => const Duration(days: 90),
      ClearPolicy.every6Months => const Duration(days: 180),
    };
  }
}
