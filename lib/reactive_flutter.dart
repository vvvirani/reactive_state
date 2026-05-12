/// A lightweight auto-tracking reactive state management library for Flutter.
///
/// `reactive_flutter` provides a minimal and powerful reactive architecture
/// with automatic dependency tracking, reactive UI rebuilding, isolate helpers,
/// pagination utilities, dependency injection, reactive search, and logging.
///
/// ---------------------------------------------------------------------------
/// Features
/// ---------------------------------------------------------------------------
///
/// ✔ Automatic dependency tracking
/// ✔ Minimal boilerplate
/// ✔ Lightweight and fast
/// ✔ Reactive widget rebuilding
/// ✔ Page & cursor pagination
/// ✔ Reactive search with debounce
/// ✔ File-based reactive logger
/// ✔ Background isolate tasks
/// ✔ Simple dependency injection
/// ✔ No code generation
/// ✔ No BuildContext required for state access
///
/// ---------------------------------------------------------------------------
/// Basic Reactive Example
/// ---------------------------------------------------------------------------
///
/// ```dart
/// import 'package:reactive_flutter/reactive_flutter.dart';
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
/// ReactiveInjector.singleton<ApiService>(
///   () => ApiService(),
/// );
///
/// final ApiService api = ReactiveInjector.find<ApiService>();
/// ```
///
/// ---------------------------------------------------------------------------
/// Page Pagination
/// ---------------------------------------------------------------------------
///
/// ```dart
/// final ReactivePagination<User> pagination =
///     ReactivePagination<User>(
///   perPage: 20,
///   fetcher: (page, limit) async {
///     return api.fetchUsers(page, limit);
///   },
/// );
/// ```
///
/// ---------------------------------------------------------------------------
/// Reactive Search
/// ---------------------------------------------------------------------------
///
/// ```dart
/// final ReactiveSearch<User> search =
///     ReactiveSearch<User>(
///   fetcher: (query) async {
///     return api.searchUsers(query);
///   },
/// );
///
/// TextField(
///   onChanged: search.onChanged,
/// )
/// ```
///
/// ---------------------------------------------------------------------------
/// Reactive Logger
/// ---------------------------------------------------------------------------
///
/// ```dart
/// final ReactiveLogger logger = ReactiveLogger(
///   clearPolicy: ClearPolicy.weekly,
/// );
///
/// await logger.init();
///
/// logger.info('Application started');
/// logger.error('Something failed');
/// ```
///
/// ---------------------------------------------------------------------------
/// Reactive Isolate Tasks
/// ---------------------------------------------------------------------------
///
/// ```dart
/// final ReactiveIsolateTask<int> task =
///     ReactiveIsolateTask<int>();
///
/// await task.run<int>(
///   ReactiveTaskPayload(
///     input: 1000000,
///     callback: heavyCalculation,
///   ),
/// );
///
/// int heavyCalculation(int total) {
///   int sum = 0;
///
///   for (int i = 0; i < total; i++) {
///     sum += i;
///   }
///
///   return sum;
/// }
/// ```
///
/// ---------------------------------------------------------------------------
/// Included Modules
/// ---------------------------------------------------------------------------
///
/// - Reactive state containers
/// - Watch auto-tracking widgets
/// - Dependency injection
/// - Page pagination
/// - Cursor pagination
/// - Reactive search
/// - Reactive file logger
/// - Reactive isolate tasks
library;

export 'src/reactive.dart';
export 'src/reactive_base.dart';

export 'src/ui/ui.dart';

export 'src/pagination/pagination.dart';

export 'src/injection/reactive_injector.dart';

export 'src/search/reactive_search.dart';

export 'src/log/log.dart';

export 'src/isolate/reactive_isolate_task.dart';
