import 'package:flutter/widgets.dart';

/// Responsive behaviour for Home.
///
/// The rule that matters: widening the window must not promote tier 2
/// or tier 3 content into the first screenful. A tablet user asks the
/// same question as a phone user and deserves the same answer in the
/// same place. Extra width buys larger type and a second column of
/// secondary content, never a reordering.
enum HomeLayout {
  /// Phones. Single column, everything in queue order.
  compact,

  /// Large phones in landscape and small tablets. Single column,
  /// constrained to a comfortable measure and centred.
  medium,

  /// Tablets and desktop web. Tier 1 stays in a fixed left column;
  /// tier 2 and 3 flow into a second column beside it.
  expanded;

  factory HomeLayout.of(BuildContext context) =>
      HomeLayout.forWidth(MediaQuery.sizeOf(context).width);

  factory HomeLayout.forWidth(double width) {
    if (width < 600) return HomeLayout.compact;
    if (width < 900) return HomeLayout.medium;
    return HomeLayout.expanded;
  }

  /// Maximum width of the primary column.
  ///
  /// Capped even on very wide windows: a prayer card 1200 logical
  /// pixels wide is a banner, and the countdown ends up further from
  /// the prayer name than it is from the edge of the screen.
  double get primaryColumnWidth => switch (this) {
        HomeLayout.compact => double.infinity,
        HomeLayout.medium => 560,
        HomeLayout.expanded => 420,
      };

  /// Horizontal page padding.
  double get gutter => switch (this) {
        HomeLayout.compact => 16,
        HomeLayout.medium => 24,
        HomeLayout.expanded => 32,
      };

  /// Whether tier 2 and 3 render beside tier 1 rather than beneath it.
  bool get isTwoColumn => this == HomeLayout.expanded;

  /// Vertical gap between sections.
  double get sectionSpacing => this == HomeLayout.compact ? 12 : 16;
}
