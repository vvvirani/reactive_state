import 'reactive_base.dart';
import 'reactive_tracker.dart';

/// ---------------------------------------------------------------------------
/// Reactive state container
/// ---------------------------------------------------------------------------

/// A lightweight reactive state holder.
///
/// Stores a value of type [T] and automatically notifies listeners
/// when the value changes.
///
/// Any `Watch` widget that accesses [value] during its build
/// will automatically subscribe to updates.
///
/// Example:
/// ```dart
/// final Reactive<int> counter = Reactive<int>(0);
/// final Reactive<String> name = Reactive<String>('Flutter');
/// final Reactive<bool> isDark = Reactive<bool>(false);
///
/// // Update values
/// counter.value = counter.value + 1;
/// name.value = 'Dart';
/// isDark.value = !isDark.value;
/// ```
class Reactive<T> extends ReactiveBase {
  /// Internal stored value.
  T _value;

  Reactive(this._value);

  /// Returns the current value.
  ///
  /// If accessed during dependency tracking,
  /// this reactive instance will automatically
  /// register itself as a dependency.
  T get value {
    ReactiveTracker.record(this);

    return _value;
  }

  /// Updates the current value.
  ///
  /// Listeners are notified only if the new value
  /// is different from the current value.
  set value(T newValue) {
    if (_value == newValue) return;

    _value = newValue;

    notify();
  }

  /// Updates the value without notifying listeners.
  ///
  /// Useful for silent internal state changes.
  void setSilent(T newValue) {
    _value = newValue;
  }

  @override
  String toString() => 'Reactive<$T>($_value)';
}
