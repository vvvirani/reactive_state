/// Creates a new instance of type [T].
typedef Factory<T> = T Function();

/// ---------------------------------------------------------------------------
/// Internal registration model
/// ---------------------------------------------------------------------------

/// Stores dependency configuration for a registered type.
///
/// [factory] is used to create the instance.
/// [singleton] determines whether the same instance should be reused.
/// [_instance] holds the cached singleton instance.
class _Registration<T extends Object> {
  final Factory<T> factory;
  final bool singleton;

  /// Cached singleton instance.
  T? _instance;

  _Registration({required this.factory, required this.singleton});

  /// Returns an instance of [T].
  ///
  /// - If registered as singleton, the same instance is reused.
  /// - If registered as transient, a new instance is created each time.
  T getInstance() {
    if (singleton) {
      return _instance ??= factory();
    }

    return factory();
  }
}

/// ---------------------------------------------------------------------------
/// Internal dependency container
/// ---------------------------------------------------------------------------

/// Internal service locator implementation.
///
/// Manages dependency registration, retrieval,
/// lifecycle handling, and cleanup.
class _ReactiveInjector {
  _ReactiveInjector._();

  /// Singleton instance of the injector.
  static final _ReactiveInjector _instance = _ReactiveInjector._();

  /// Stores all registered dependencies by type.
  final Map<Type, _Registration<Object>> _registry = {};

  /// Registers a singleton dependency.
  ///
  /// The same instance will be returned every time.
  void _singleton<T extends Object>(Factory<T> factory) {
    _registry[T] = _Registration<Object>(
      factory: factory as Factory<Object>,
      singleton: true,
    );
  }

  /// Registers a transient dependency.
  ///
  /// A new instance will be created on every request.
  void _transient<T extends Object>(Factory<T> factory) {
    _registry[T] = _Registration<Object>(
      factory: factory as Factory<Object>,
      singleton: false,
    );
  }

  /// Returns the registered dependency of type [T].
  ///
  /// Throws an exception if:
  /// - The type is not registered.
  /// - The resolved type does not match [T].
  T _get<T extends Object>() {
    final reg = _registry[T];

    if (reg == null) {
      throw Exception('$T is not registered.');
    }

    final value = reg.getInstance();

    if (value is! T) {
      throw Exception('Type mismatch for $T.');
    }

    return value;
  }

  /// Returns `true` if type [T] is registered.
  bool _isRegistered<T extends Object>() {
    return _registry.containsKey(T);
  }

  /// Clears the cached singleton instance for type [T].
  ///
  /// The next call to [find] will recreate the instance.
  void _reset<T extends Object>() {
    _registry[T]?._instance = null;
  }

  /// Removes the registered dependency of type [T].
  void _unregister<T extends Object>() {
    _registry.remove(T);
  }

  /// Removes all registered dependencies.
  void _clear() {
    _registry.clear();
  }
}

/// ---------------------------------------------------------------------------
/// Public API
/// ---------------------------------------------------------------------------

/// Lightweight dependency injection and service locator utility.
///
/// Supports:
/// - Singleton registration
/// - Transient registration
/// - Dependency lookup
/// - Reset/unregister operations
///
/// Example:
/// ```dart
/// ReactiveInjector.singleton<ApiService>(() => ApiService());
///
/// final ApiService api = ReactiveInjector.find<ApiService>();
/// ```
class ReactiveInjector {
  ReactiveInjector._();

  static final _i = _ReactiveInjector._instance;

  /// Registers a singleton dependency.
  ///
  /// The same instance is reused for every lookup.
  static void singleton<T extends Object>(Factory<T> factory) {
    _i._singleton<T>(factory);
  }

  /// Registers a transient dependency.
  ///
  /// A new instance is created every time it is requested.
  static void transient<T extends Object>(Factory<T> factory) {
    _i._transient<T>(factory);
  }

  /// Finds and returns the registered dependency of type [T].
  static T find<T extends Object>() {
    return _i._get<T>();
  }

  /// Returns `true` if type [T] is registered.
  static bool isRegistered<T extends Object>() {
    return _i._isRegistered<T>();
  }

  /// Resets the singleton instance of type [T].
  ///
  /// The dependency registration remains intact.
  static void reset<T extends Object>() {
    _i._reset<T>();
  }

  /// Removes the registered dependency of type [T].
  static void unregister<T extends Object>() {
    _i._unregister<T>();
  }

  /// Removes all registered dependencies.
  static void clear() {
    _i._clear();
  }
}
