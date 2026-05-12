import 'dart:async';
import 'dart:isolate';

import 'package:reactive_flutter/src/isolate/reactive_task_state.dart';
import 'package:reactive_flutter/src/reactive.dart';

export 'reactive_task_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ReactiveIsolateTask
// ─────────────────────────────────────────────────────────────────────────────

/// A lightweight reactive wrapper around `Isolate.run`.
///
/// Features:
/// - Reactive loading state
/// - Reactive data updates
/// - Reactive error handling
/// - Generic reusable task execution
/// - Background isolate execution
///
/// Useful for:
/// - Heavy calculations
/// - JSON parsing
/// - File processing
/// - Data transformation
/// - CPU intensive work
///
/// Example:
/// ```dart
/// final ReactiveIsolateTask<int> task = ReactiveIsolateTask<int>();
///
/// await task.run<int>(
///   ReactiveTaskPayload(
///     input: 1000000,
///     callback: heavySumOperation,
///   ),
/// );
/// ```
///
/// Important:
/// The callback must be:
/// - top-level function
/// - static function
///
/// Avoid:
/// - closures capturing state
/// - BuildContext
/// - controllers
/// - services
/// - reactive objects
/// - Flutter bindings
class ReactiveIsolateTask<T> extends Reactive<ReactiveTaskState<T>> {
  ReactiveIsolateTask() : super(ReactiveTaskState<T>());

  /// Whether task is currently executing.
  bool get isLoading => value.isLoading;

  /// Latest successful result.
  T? get data => value.data;

  /// Latest task error.
  Object? get error => value.error;

  // ───────────────────────────────────────────────────────────────────────────
  // Run
  // ───────────────────────────────────────────────────────────────────────────

  /// Executes a task inside a background isolate.
  ///
  /// Errors are captured internally and stored in reactive state.
  ///
  /// Does NOT throw.
  Future<void> run<I>(
    ReactiveTaskPayload<I, T> payload,
  ) async {
    _update((s) => s.copyWith(isLoading: true, error: null));

    try {
      final T result = await _runIsolateTask(payload);

      _update((s) => s.copyWith(isLoading: false, data: result));
    } catch (e) {
      _update((s) => s.copyWith(isLoading: false, error: e));
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Run Or Throw
  // ───────────────────────────────────────────────────────────────────────────

  /// Executes a task inside a background isolate.
  ///
  /// Errors are rethrown to caller.
  Future<T> runOrThrow<I>(
    ReactiveTaskPayload<I, T> payload,
  ) async {
    _update((s) => s.copyWith(isLoading: true, error: null));

    try {
      final T result = await _runIsolateTask(payload);

      _update((s) => s.copyWith(isLoading: false, data: result));

      return result;
    } catch (e) {
      _update((s) => s.copyWith(isLoading: false, error: e));

      rethrow;
    }
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Reset
  // ───────────────────────────────────────────────────────────────────────────

  /// Clears:
  /// - loading state
  /// - data
  /// - error
  void reset() {
    value = ReactiveTaskState<T>();
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Internal
  // ───────────────────────────────────────────────────────────────────────────

  void _update(ReactiveTaskState<T> Function(ReactiveTaskState<T>) updater) {
    value = updater(value);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payload
// ─────────────────────────────────────────────────────────────────────────────

/// Defines isolate task input and callback.
class ReactiveTaskPayload<I, O> {
  /// Input passed into callback.
  final I input;

  /// Task callback executed inside isolate.
  ///
  /// Must be:
  /// - top-level function
  /// - static function
  final FutureOr<O> Function(I input) callback;

  const ReactiveTaskPayload({required this.input, required this.callback});
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal Isolate Execution
// ─────────────────────────────────────────────────────────────────────────────

FutureOr<R> _executeTask<I, R>(ReactiveTaskPayload<I, R> payload) {
  return payload.callback(payload.input);
}

Future<R> _runIsolateTask<I, R>(ReactiveTaskPayload<I, R> payload) {
  return Isolate.run<R>(() => _executeTask(payload));
}
