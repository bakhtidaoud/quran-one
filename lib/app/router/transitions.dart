import 'package:flutter/material.dart';
import 'package:quran_one/core/theme/extensions/q_shape_motion.dart';

/// Route transitions built from motion tokens, never from raw values.
///
/// Coding rule 11 bans literal Duration and Curves outside token files. It
/// exists because a codebase with 40 hand-picked durations has no motion
/// system, it has 40 opinions.
class QSharedAxisPage<T> extends CustomTransitionPage<T> {
  QSharedAxisPage({required super.child, super.key})
      : super(
          transitionDuration: QMotion.pageEnter,
          reverseTransitionDuration: QMotion.pageExit,
          transitionsBuilder: _sharedAxis,
        );

  static Widget _sharedAxis(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondary,
    Widget child,
  ) {
    // Directional, so the motion reverses under RTL. A right-to-left
    // reader watching pages slide in from the left is being told, subtly
    // and constantly, that the app was not built for them.
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final begin = Offset(isRtl ? -0.2 : 0.2, 0);

    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: QEasing.standard),
      child: SlideTransition(
        position: Tween(begin: begin, end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: QEasing.standard),
        ),
        child: child,
      ),
    );
  }
}

/// A modal sheet expressed as a route.
///
/// Costs a little ceremony over showModalBottomSheet and buys correct
/// browser back behaviour on web plus a deep-linkable action sheet.
class QModalSheetPage<T> extends CustomTransitionPage<T> {
  QModalSheetPage({required super.child, super.key})
      : super(
          opaque: false,
          barrierDismissible: true,
          barrierColor: const Color(0x66000000),
          transitionDuration: QMotion.sheetEnter,
          transitionsBuilder: (context, animation, _, child) => SlideTransition(
            position: Tween(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: QEasing.standard),
            ),
            child: child,
          ),
        );
}

class QFullScreenPage<T> extends CustomTransitionPage<T> {
  QFullScreenPage({required super.child, super.key})
      : super(
          transitionDuration: QMotion.pageEnter,
          transitionsBuilder: (context, animation, _, child) => FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: QEasing.standard),
            child: child,
          ),
        );
}
