import 'package:reactive_flutter/src/reactive.dart';

import 'pagination_result.dart';
import 'pagination_state.dart';

/// Fetch function used for cursor-based pagination.
///
/// [T] is the item type.
/// [C] is the cursor type.
///
/// Parameters:
/// - [perPage] → number of items to fetch.
/// - [cursor] → cursor for the next page.
///
/// Returns a [PaginationResult] containing:
/// - fetched items
/// - next cursor
typedef CursorFetcher<T, C> = Future<PaginationResult<T, C>> Function(
    int perPage, C? cursor);

/// ---------------------------------------------------------------------------
/// Reactive cursor pagination
/// ---------------------------------------------------------------------------

/// Reactive pagination controller that supports cursor-based pagination.
///
/// [T] is the item type.
/// [C] is the cursor type.
///
/// Features:
/// - Initial loading
/// - Load more pagination
/// - Refresh support
/// - Error handling
/// - Reactive state updates
///
/// Example:
/// ```dart
/// final ReactiveCursorPagination<User, String> pagination = ReactiveCursorPagination<User, String>(
///   perPage: 20,
///   fetcher: (limit, cursor) async {
///     return api.fetchUsers(limit, cursor);
///   },
/// );
/// ```
class ReactiveCursorPagination<T, C>
    extends Reactive<CursorPaginationState<T, C>> {
  ReactiveCursorPagination({
    required this.perPage,
    required CursorFetcher<T, C> fetcher,
  })  : _fetcher = fetcher,
        super(CursorPaginationState());

  /// Number of items fetched per request.
  final int perPage;

  /// Fetch callback responsible for loading data.
  final CursorFetcher<T, C> _fetcher;

  /// Current pagination state.
  CursorPaginationState<T, C> get state => value;

  /// Loaded items.
  List<T> get items => value.items;

  /// Current cursor value.
  C? get cursor => value.cursor;

  /// Returns `true` during the initial load.
  bool get isLoading => value.isLoading;

  /// Returns `true` while loading additional pages.
  bool get isMoreLoading => value.isMoreLoading;

  /// Returns `true` if more data is available.
  bool get hasMore => value.hasMore;

  /// Current error message, if any.
  String? get error => value.error;

  /// Total number of fetched items.
  int get totalFetched => value.totalFetched;

  /// Returns `true` if no items exist.
  bool get isEmpty => value.isEmpty;

  /// Initializes pagination.
  ///
  /// Resets existing state and loads the first page.
  Future<void> init() async {
    if (state.isBusy) return;

    _reset();

    await _fetch();
  }

  /// Refreshes pagination data.
  ///
  /// Clears current items and reloads from the beginning.
  Future<void> refresh() async {
    if (state.isBusy) return;

    _reset();

    await _fetch();
  }

  /// Loads the next page.
  ///
  /// Does nothing if:
  /// - A request is already in progress
  /// - No more data is available
  Future<void> fetchMore() async {
    if (state.isBusy || !state.hasMore) return;

    await _fetch();
  }

  /// Resets pagination state to its initial value.
  void _reset() {
    value = CursorPaginationState<T, C>();
  }

  /// Updates the current state.
  void _update(
    CursorPaginationState<T, C> Function(CursorPaginationState<T, C>) updater,
  ) {
    value = updater(value);
  }

  /// Internal fetch handler.
  ///
  /// Handles:
  /// - loading state
  /// - data fetching
  /// - pagination updates
  /// - error handling
  Future<void> _fetch() async {
    final bool isFirst = value.page == 0;

    _update((s) {
      return s.copyWith(
        isLoading: isFirst,
        isMoreLoading: !isFirst,
        clearError: true,
      );
    });

    try {
      final PaginationResult<T, C> result = await _fetcher(
        perPage,
        value.cursor,
      );

      _update((s) {
        return s.copyWith(
          items: [...s.items, ...result.items],
          page: s.page + 1,
          hasMore: result.items.length >= perPage,
          isLoading: false,
          isMoreLoading: false,
          cursor: result.nextCursor,
        );
      });
    } catch (e) {
      _update((s) {
        return s.copyWith(
          isLoading: false,
          isMoreLoading: false,
          error: e.toString(),
        );
      });
    }
  }
}
