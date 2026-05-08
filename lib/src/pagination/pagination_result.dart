/// Represents a paginated response.
///
/// [T] is the item type.
/// [C] is the cursor type used for pagination.
///
/// Example:
/// ```dart
/// PaginationResult<User, String>(
///   items: users,
///   nextCursor: 'next_page_token',
/// );
/// ```
class PaginationResult<T, C> {
  /// List of fetched items for the current page.
  final List<T> items;

  /// Cursor used to fetch the next page.
  ///
  /// Will be `null` if there are no more pages available.
  final C? nextCursor;

  const PaginationResult({required this.items, this.nextCursor});
}
