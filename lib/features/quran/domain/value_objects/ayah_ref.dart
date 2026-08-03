/// A pointer to one ayah. Validated at construction.
///
/// Pure Dart. Nothing in domain/ imports Flutter or Riverpod.
class AyahRef implements Comparable<AyahRef> {
  AyahRef(this.surah, this.number) {
    if (surah < 1 || surah > 114) {
      throw ArgumentError.value(surah, 'surah', 'must be 1-114');
    }
    if (number < 1) {
      throw ArgumentError.value(number, 'number', 'must be >= 1');
    }
  }

  /// Parses the canonical `2:255` form. Returns null rather than throwing,
  /// because this is used on untrusted deep-link input.
  static AyahRef? tryParse(String input) {
    final parts = input.split(':');
    if (parts.length != 2) return null;
    final s = int.tryParse(parts[0]);
    final a = int.tryParse(parts[1]);
    if (s == null || a == null) return null;
    if (s < 1 || s > 114 || a < 1) return null;
    return AyahRef(s, a);
  }

  final int surah;
  final int number;

  @override
  int compareTo(AyahRef other) => surah != other.surah
      ? surah.compareTo(other.surah)
      : number.compareTo(other.number);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyahRef && other.surah == surah && other.number == number;

  @override
  int get hashCode => Object.hash(surah, number);

  @override
  String toString() => '$surah:$number';
}

/// An inclusive span of ayat.
///
/// Value equality is mandatory: this is a Riverpod family parameter, and
/// without `==` the family caches a new entry on every rebuild.
class AyahRange {
  const AyahRange(this.start, this.end);

  AyahRange.surah(int surah, int ayahCount)
      : start = AyahRef(surah, 1),
        end = AyahRef(surah, ayahCount);

  final AyahRef start;
  final AyahRef end;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyahRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() => '$start-$end';
}
