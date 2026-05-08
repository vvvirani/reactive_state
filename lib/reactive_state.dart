/// A lightweight auto-tracking reactive state management library for Flutter.
///
/// Provides:
/// - Reactive state containers
/// - Automatic widget rebuild tracking
/// - Lightweight dependency injection
/// - Page-based pagination
/// - Cursor-based pagination
///
/// ---------------------------------------------------------------------------
/// Basic Usage
/// ---------------------------------------------------------------------------
///
/// ```dart
/// import 'package:reactive_state/reactive_state.dart';
///
/// final Reactive<int> counter = Reactive<int>(0);
/// final Reactive<String> name = Reactive<String>('Flutter');
/// final Reactive<bool> isDark = Reactive<bool>(false);
///
/// Watch(
///   builder: () => Column(
///     children: [
///       Text('${counter.value}'),
///       Text(name.value),
///       Switch(
///         value: isDark.value,
///         onChanged: (v) => isDark.value = v,
///       ),
///     ],
///   ),
/// )
/// ```
///
/// ---------------------------------------------------------------------------
/// Dependency Injection
/// ---------------------------------------------------------------------------
///
/// ```dart
/// ReactiveInjector.singleton<ApiService>(() => ApiService());
///
/// final ApiService api = ReactiveInjector.find<ApiService>();
/// ```
///
/// ---------------------------------------------------------------------------
/// Pagination
/// ---------------------------------------------------------------------------
///
/// ```dart
/// final ReactivePagination<User> pagination = ReactivePagination<User>(
///   perPage: 20,
///   fetcher: (page, limit) async {
///     return api.fetchUsers(page, limit);
///   },
/// );
/// ```
///
/// ---------------------------------------------------------------------------
/// Features
/// ---------------------------------------------------------------------------
///
/// ✔ Automatic dependency tracking
/// ✔ Minimal boilerplate
/// ✔ Lightweight and fast
/// ✔ Reactive widget rebuilding
/// ✔ Cursor & page pagination
/// ✔ Simple dependency injection
library;

export 'src/reactive.dart';
export 'src/reactive_base.dart';
export 'src/watch.dart';

export 'src/pagination/pagination.dart';

export 'src/injection/reactive_injector.dart';
