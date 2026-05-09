import 'package:reactive_flutter/src/reactive.dart';

import 'pagination_state.dart';

/// Fetch function used for page-based pagination.
///
/// [T] is the item type.
///
/// Parameters:
/// - [page] → current page number.
/// - [perPage] → number of items per request.
///
/// Returns a list of fetched items.
typedef PageFetcher<T> = Future<List<T>> Function(int page, int perPage);

/// ---------------------------------------------------------------------------
/// Reactive page-based pagination
/// ---------------------------------------------------------------------------

/// Reactive pagination controller for page-based APIs.
///
/// [T] is the item type.
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
/// final ReactivePagination<User> pagination = ReactivePagination<User>(
///   perPage: 20,
///   fetcher: (page, limit) async {
///     return api.fetchUsers(page, limit);
///   },
/// );
/// ```
class ReactivePagination<T> extends Reactive<PaginationState<T>> {
  ReactivePagination({required this.perPage, required PageFetcher<T> fetcher})
      : _fetcher = fetcher,
        super(PaginationState());

  /// Number of items fetched per request.
  final int perPage;

  /// Fetch callback responsible for loading data.
  final PageFetcher<T> _fetcher;

  /// Current pagination state.
  PaginationState<T> get state => value;

  /// Loaded items.
  List<T> get items => value.items;

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
    value = PaginationState<T>();
  }

  /// Updates the current state.
  void _update(PaginationState<T> Function(PaginationState<T>) updater) {
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
      final int nextPage = value.page + 1;

      final List<T> result = await _fetcher(nextPage, perPage);

      _update((s) {
        return s.copyWith(
          items: [...s.items, ...result],
          page: nextPage,
          hasMore: result.length >= perPage,
          isLoading: false,
          isMoreLoading: false,
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
