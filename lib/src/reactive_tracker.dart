import 'reactive_base.dart';

/// ---------------------------------------------------------------------------
/// Reactive dependency tracker
/// ---------------------------------------------------------------------------

/// Tracks accessed [ReactiveBase] instances during widget builds.
///
/// Used internally by `Watch` to automatically detect
/// reactive dependencies without requiring manual registration.
///
/// Workflow:
/// 1. [start] begins dependency tracking.
/// 2. Reactive values call [record] when accessed.
/// 3. [stop] returns all tracked dependencies.
class ReactiveTracker {
  ReactiveTracker._();

  /// Stores all tracked reactive dependencies.
  static final Set<ReactiveBase> _tracking = {};

  /// Indicates whether tracking is currently active.
  static bool _isTracking = false;

  /// Starts dependency tracking.
  ///
  /// Clears previously tracked dependencies.
  static void start() {
    _tracking.clear();
    _isTracking = true;
  }

  /// Stops dependency tracking.
  ///
  /// Returns all tracked reactive dependencies.
  static Set<ReactiveBase> stop() {
    _isTracking = false;

    return Set<ReactiveBase>.of(_tracking);
  }

  /// Records a reactive dependency.
  ///
  /// Called internally by reactive value getters
  /// when dependency tracking is active.
  static void record(ReactiveBase reactive) {
    if (_isTracking) {
      _tracking.add(reactive);
    }
  }
}
