import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:quran_one/core/theme/theme.dart';

/// Four destinations. No More tab, no drawer on phones.
///
/// A More tab is where features go to be forgotten; if something deserves a
/// destination it gets one, and if it does not it lives inside a screen.
class RootShell extends StatelessWidget {
  const RootShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  static const _destinations = [
    (icon: Symbols.home_rounded, label: 'Home'),
    (icon: Symbols.book_2_rounded, label: 'Read'),
    (icon: Symbols.mosque_rounded, label: 'Prayer'),
    (icon: Symbols.school_rounded, label: 'Learn'),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final useRail = width >= 600;

    if (useRail) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: shell.currentIndex,
              onDestinationSelected: _go,
              extended: width >= 840,
              labelType: width >= 840
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              destinations: [
                for (final d in _destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.icon, fill: 1),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: shell),
          ],
        ),
      );
    }

    return Scaffold(
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: context.semantic.divider),
          ),
        ),
        child: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: _go,
          destinations: [
            for (final d in _destinations)
              NavigationDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.icon, fill: 1),
                label: d.label,
              ),
          ],
        ),
      ),
    );
  }

  /// Tapping the active destination pops that branch to its root, which is
  /// what every user expects and most apps get wrong.
  void _go(int index) => shell.goBranch(
        index,
        initialLocation: index == shell.currentIndex,
      );
}
