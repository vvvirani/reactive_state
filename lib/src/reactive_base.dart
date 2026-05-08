/// Reactive state management utilities.
library;

///
/// ---------------------------------------------------------------------------
/// Base reactive listener container
/// ---------------------------------------------------------------------------

/// Internal base class for reactive state objects.
///
/// Provides a lightweight listener system used to:
/// - register listeners
/// - remove listeners
/// - notify subscribers when state changes
///
/// This class intentionally avoids generics so it can be
/// shared across all reactive implementations.
abstract class ReactiveBase {
  /// Registered listeners.
  final List<void Function()> _listeners = [];

  /// Adds a new listener.
  ///
  /// The listener will be called whenever [notify] is triggered.
  void addListener(void Function() cb) {
    _listeners.add(cb);
  }

  /// Removes a previously registered listener.
  void removeListener(void Function() cb) {
    _listeners.remove(cb);
  }

  /// Notifies all registered listeners.
  ///
  /// A copied listener list is used to prevent
  /// concurrent modification issues while iterating.
  void notify() {
    for (final Function() cb in List.of(_listeners)) {
      cb();
    }
  }
}
