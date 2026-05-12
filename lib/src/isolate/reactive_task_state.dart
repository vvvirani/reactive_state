/// Reactive state used by [ReactiveIsolateTask].
///
/// Stores:
/// - Loading state
/// - Task result
/// - Task error
///
class ReactiveTaskState<T> {
  /// Whether isolate task is currently executing.
  final bool isLoading;

  /// Latest successful task result.
  final T? data;

  /// Latest task error.
  final Object? error;

  const ReactiveTaskState({
    this.isLoading = false,
    this.data,
    this.error,
  });

  /// Whether task contains data.
  bool get hasData => data != null;

  /// Whether task contains an error.
  bool get hasError => error != null;

  /// Creates a modified copy of current state.
  ///
  /// Supports clearing nullable values using sentinel values.
  ReactiveTaskState<T> copyWith({
    bool? isLoading,
    Object? error = _sentinel,
    Object? data = _sentinel,
  }) {
    return ReactiveTaskState<T>(
      isLoading: isLoading ?? this.isLoading,
      error: error == _sentinel ? this.error : error,
      data: data == _sentinel ? this.data : data as T?,
    );
  }

  @override
  String toString() {
    return 'ReactiveTaskState('
        'isLoading: $isLoading, '
        'hasData: $hasData, '
        'hasError: $hasError, '
        'data: $data, '
        'error: $error'
        ')';
  }
}

/// Internal sentinel used to differentiate:
/// - explicit null
/// - unchanged value
const Object _sentinel = Object();
