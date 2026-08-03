import 'package:flutter/foundation.dart';

/// Cursor pagination, matching `apps.core.pagination.CursorPagination` on
/// the Django side.
///
/// Offsets are wrong for this data. Bookmarks and hifz cards are written
/// while the user is scrolling, so page two of an offset query silently
/// repeats or skips rows. A cursor is stable under insertion.
@immutable
class Paginated<T> {
  const Paginated({
    required this.items,
    this.cursor,
    this.isLoadingMore = false,
  });

  const Paginated.empty()
      : items = const [],
        cursor = null,
        isLoadingMore = false;

  final List<T> items;
  final String? cursor;
  final bool isLoadingMore;

  bool get hasMore => cursor != null;
  bool get isEmpty => items.isEmpty;

  Paginated<T> append(List<T> next, String? nextCursor) => Paginated(
        items: [...items, ...next],
        cursor: nextCursor,
      );

  Paginated<T> loadingMore() => Paginated(
        items: items,
        cursor: cursor,
        isLoadingMore: true,
      );

  /// Keeps what is already loaded after a failed page.
  ///
  /// Most implementations throw here, which replaces a working list with an
  /// error screen because page four timed out.
  Paginated<T> settle() => Paginated(items: items, cursor: cursor);

  Paginated<T> removeWhere(bool Function(T) test) => Paginated(
        items: items.where((e) => !test(e)).toList(),
        cursor: cursor,
      );

  @override
  bool operator ==(Object other) =>
      other is Paginated<T> &&
      other.cursor == cursor &&
      other.isLoadingMore == isLoadingMore &&
      listEquals(other.items, items);

  @override
  int get hashCode => Object.hash(cursor, isLoadingMore, Object.hashAll(items));
}

/// One page as returned by the API.
@immutable
class Page<T> {
  const Page({required this.items, this.next});

  final List<T> items;
  final String? next;
}
