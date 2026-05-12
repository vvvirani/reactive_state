import 'dart:async';

/// Async search callback used by [ReactiveSearch].
///
/// [T] is the search result item type.
///
/// Receives the search query and returns
/// a list of matching results.
///
/// Example:
/// ```dart
/// final SearchFetcher<User> fetcher = (query) async {
///   return api.searchUsers(query);
/// };
/// ```
typedef SearchFetcher<T> = Future<List<T>> Function(String query);

// ── Search State ─────────────────────────────────────────────────────────────

/// Represents the current state of a search operation.
///
/// Stores:
/// - search results
/// - current query
/// - loading state
/// - idle state
/// - error information
///
/// [T] is the search result item type.
class SearchState<T> {
  /// Current search results.
  final List<T> results;

  /// Current search query.
  final String query;

  /// Indicates whether a search request is in progress.
  final bool isLoading;

  /// Indicates whether no search has been performed yet.
  ///
  /// Typically `true` before the first search.
  final bool isIdle;

  /// Optional error message.
  final String? error;

  SearchState({
    List<T>? results,
    this.query = '',
    this.isLoading = false,
    this.isIdle = true,
    this.error,
  }) : results = results ?? [];

  /// Returns `true` when:
  /// - there are no results
  /// - not loading
  /// - not idle
  ///
  /// Useful for showing empty search states.
  bool get isEmpty => results.isEmpty && !isLoading && !isIdle;

  /// Returns `true` if search results exist.
  bool get hasResults => results.isNotEmpty;

  /// Returns `true` if an error exists.
  bool get hasError => error != null;

  /// Creates a new search state by overriding selected fields.
  ///
  /// Use [clearError] to explicitly remove the current error.
  SearchState<T> copyWith({
    List<T>? results,
    String? query,
    bool? isLoading,
    bool? isIdle,
    String? error,
    bool clearError = false,
  }) {
    return SearchState<T>(
      results: results ?? this.results,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      isIdle: isIdle ?? this.isIdle,
      error: clearError ? null : error ?? this.error,
    );
  }
}
