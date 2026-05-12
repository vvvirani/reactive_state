// ── ReactiveSearch ────────────────────────────────────────────────────────────

import 'dart:async';

import 'package:reactive_flutter/src/reactive.dart';
import 'package:reactive_flutter/src/search/search_state.dart';

export 'search_state.dart';

/// Reactive search controller with:
/// - debounce support
/// - async fetching
/// - stale response protection
/// - loading/error handling
/// - automatic reactive updates
///
/// [T] is the search result item type.
///
/// Example:
/// ```dart
/// final ReactiveSearch<User> search = ReactiveSearch<User>(
///   fetcher: (query) async {
///     return api.searchUsers(query);
///   },
/// );
/// ```
class ReactiveSearch<T> extends Reactive<SearchState<T>> {
  ReactiveSearch({
    this.debounceMs = 500,
    this.minLength = 1,
    required SearchFetcher<T> fetcher,
  })  : _fetcher = fetcher,
        super(SearchState<T>());

  /// Debounce duration in milliseconds.
  ///
  /// Prevents triggering searches too frequently
  /// while the user is typing.
  final int debounceMs;

  /// Minimum query length required before searching.
  final int minLength;

  /// Async fetch callback used to perform searches.
  final SearchFetcher<T> _fetcher;

  /// Internal debounce timer.
  Timer? _debounce;

  /// Stores the latest searched query.
  ///
  /// Used to prevent stale async responses.
  String _lastSearched = '';

  // ── Shorthand getters ─────────────────────────────────────────────────────

  /// Current search state.
  SearchState<T> get state => value;

  /// Current search results.
  List<T> get results => value.results;

  /// Current query text.
  String get query => value.query;

  /// Returns `true` while searching.
  bool get isLoading => value.isLoading;

  /// Returns `true` when no active search exists.
  bool get isIdle => value.isIdle;

  /// Returns `true` when no results are available.
  bool get isEmpty => value.isEmpty;

  /// Returns `true` if results exist.
  bool get hasResults => value.hasResults;

  /// Current error message, if any.
  String? get error => value.error;

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Called when the search input changes.
  ///
  /// Typically used inside:
  ///
  /// ```dart
  /// TextField(
  ///   onChanged: search.onChanged,
  /// )
  /// ```
  ///
  /// Features:
  /// - debounce support
  /// - minimum length validation
  /// - duplicate query prevention
  /// - automatic state updates
  void onChanged(String query) {
    _debounce?.cancel();

    value = state.copyWith(query: query);

    // Query below minimum length → reset to idle state.
    if (query.trim().length < minLength) {
      value = SearchState<T>(query: query);
      _lastSearched = '';
      return;
    }

    // Prevent duplicate searches.
    if (query.trim() == _lastSearched) return;

    // Start debounce timer.
    _debounce = Timer(Duration(milliseconds: debounceMs), () {
      _search(query.trim());
    });
  }

  /// Executes a search immediately without debounce.
  ///
  /// Useful for:
  /// - search buttons
  /// - keyboard submit actions
  /// - manual refresh
  Future<void> search(String query) async {
    _debounce?.cancel();

    if (query.trim().length < minLength) return;

    await _search(query.trim());
  }

  /// Clears the current query and results.
  ///
  /// Resets the search state back to idle.
  void clear() {
    _debounce?.cancel();

    _lastSearched = '';

    value = SearchState<T>();
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  /// Internal async search handler.
  ///
  /// Handles:
  /// - loading state
  /// - async fetching
  /// - stale response protection
  /// - error handling
  Future<void> _search(String query) async {
    _lastSearched = query;

    value = state.copyWith(
      isLoading: true,
      isIdle: false,
      clearError: true,
    );

    try {
      final List<T> results = await _fetcher(query);

      // Ignore stale responses if query changed mid-request.
      if (query != _lastSearched) return;

      value = state.copyWith(
        results: results,
        isLoading: false,
      );
    } catch (e) {
      // Ignore stale errors.
      if (query != _lastSearched) return;

      value = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Disposes internal resources.
  ///
  /// Cancels any active debounce timer.
  void dispose() {
    _debounce?.cancel();
  }
}
