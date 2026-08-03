import 'package:flutter/foundation.dart';
import 'package:quran_one/features/quran/domain/value_objects/ayah_ref.dart';

/// A single unified type over the three annotation kinds.
///
/// Users do not remember whether they bookmarked, highlighted or noted
/// a verse. Presenting three tabs forces them to guess, and they guess
/// wrong about half the time. The three types exist because they have
/// different data shapes and different merge rules; that is a data
/// layer concern and it must not surface as three tabs.
sealed class Mark {
  const Mark({
    required this.id,
    required this.ref,
    required this.createdAt,
  });

  final String id;
  final AyahRef ref;
  final DateTime createdAt;

  /// Text shown when searching marks. Notes search their body, the
  /// others fall back to the verse itself, resolved by the caller.
  String? get searchableText => null;
}

/// A place kept. No range, no colour, no text.
class BookmarkMark extends Mark {
  const BookmarkMark({
    required super.id,
    required super.ref,
    required super.createdAt,
    this.isFavorite = false,
  });

  /// A favourite is a flag on a bookmark, not a separate entity. See
  /// SyncEntity.notAnEntity.
  final bool isFavorite;
}

/// A span of a verse, coloured.
class HighlightMark extends Mark {
  const HighlightMark({
    required super.id,
    required super.ref,
    required super.createdAt,
    required this.colourId,
    required this.start,
    required this.end,
  });

  /// One of the five palette highlights. Never a raw colour value:
  /// the stored mark has to survive a theme change and an AMOLED
  /// switch.
  final String colourId;

  final int start;
  final int end;

  /// Matches the sync entity id format.
  String get entityId => '${ref.surah}:$start:$end:$colourId';
}

/// A highlight with something written on it, or a standalone comment.
class NoteMark extends Mark {
  const NoteMark({
    required super.id,
    required super.ref,
    required super.createdAt,
    required this.body,
    this.start,
    this.end,
  });

  final String body;
  final int? start;
  final int? end;

  @override
  String? get searchableText => body;
}

/// Filter chips, not tabs. Chips are additive and preserve the default
/// of showing everything, which is what the user wants nearly always.
enum MarkFilter { all, notes, highlights, favourites }

/// Marks sort by position in the mushaf by default, not by date.
///
/// People look for a mark by where it is in the Quran, not by when they
/// made it. Date sort exists and almost nobody will use it.
enum MarkSort { mushafOrder, recent }

@immutable
class MarkQuery {
  const MarkQuery({
    this.filter = MarkFilter.all,
    this.sort = MarkSort.mushafOrder,
    this.search,
  });

  final MarkFilter filter;
  final MarkSort sort;
  final String? search;

  bool matches(Mark mark) {
    final passesFilter = switch (filter) {
      MarkFilter.all => true,
      MarkFilter.notes => mark is NoteMark,
      MarkFilter.highlights => mark is HighlightMark,
      MarkFilter.favourites => mark is BookmarkMark && mark.isFavorite,
    };
    if (!passesFilter) return false;

    final term = search?.trim();
    if (term == null || term.isEmpty) return true;
    final text = mark.searchableText;
    return text != null && text.toLowerCase().contains(term.toLowerCase());
  }
}

int compareMarks(Mark a, Mark b, MarkSort sort) => switch (sort) {
      MarkSort.mushafOrder => a.ref.surah != b.ref.surah
          ? a.ref.surah.compareTo(b.ref.surah)
          : a.ref.number.compareTo(b.ref.number),
      MarkSort.recent => b.createdAt.compareTo(a.createdAt),
    };
