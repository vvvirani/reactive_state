/// Represents the state of paginated data.
///
/// [T] is the item type.
///
/// Stores:
/// - Loaded items
/// - Current page
/// - Loading states
/// - Pagination availability
/// - Error information
class PaginationState<T> {
  /// List of loaded items.
  final List<T> items;

  /// Current page index.
  final int page;

  /// Indicates whether the initial page is loading.
  final bool isLoading;

  /// Indicates whether more data is currently loading.
  final bool isMoreLoading;

  /// Indicates whether more data can be loaded.
  final bool hasMore;

  /// Optional error message.
  final String? error;

  PaginationState({
    List<T>? items,
    this.page = 0,
    this.isLoading = false,
    this.isMoreLoading = false,
    this.hasMore = true,
    this.error,
  }) : items = items ?? <T>[];

  /// Total number of fetched items.
  int get totalFetched => items.length;

  /// Returns `true` when no items exist
  /// and the initial load is not in progress.
  bool get isEmpty => items.isEmpty && !isLoading;

  /// Returns `true` if any loading operation is active.
  bool get isBusy => isLoading || isMoreLoading;

  /// Creates a new state by overriding selected fields.
  ///
  /// Use [clearError] to explicitly remove the current error.
  PaginationState<T> copyWith({
    List<T>? items,
    int? page,
    bool? isLoading,
    bool? isMoreLoading,
    bool? hasMore,
    String? error,
    bool clearError = false,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : error ?? this.error,
    );
  }
}

/// ---------------------------------------------------------------------------
/// Cursor-based pagination state
/// ---------------------------------------------------------------------------

/// Pagination state that supports cursor-based pagination.
///
/// [T] is the item type.
/// [C] is the cursor type.
///
/// Extends [PaginationState] by adding a pagination cursor.
class CursorPaginationState<T, C> extends PaginationState<T> {
  /// Cursor used to fetch the next page.
  final C? cursor;

  CursorPaginationState({
    super.items,
    super.page = 0,
    super.isLoading = false,
    super.isMoreLoading = false,
    super.hasMore = true,
    super.error,
    this.cursor,
  });

  /// Creates a new cursor pagination state
  /// by overriding selected fields.
  @override
  CursorPaginationState<T, C> copyWith({
    List<T>? items,
    int? page,
    bool? isLoading,
    bool? isMoreLoading,
    bool? hasMore,
    String? error,
    bool clearError = false,
    C? cursor,
  }) {
    return CursorPaginationState<T, C>(
      items: items ?? this.items,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      isMoreLoading: isMoreLoading ?? this.isMoreLoading,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : error ?? this.error,
      cursor: cursor ?? this.cursor,
    );
  }
}
