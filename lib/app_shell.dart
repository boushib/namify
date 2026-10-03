import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/discover_screen.dart';
import 'screens/more_screen.dart';
import 'screens/pets_screen.dart';
import 'screens/saved_screen.dart';
import 'state/favorites_store.dart';

/// Bottom navigation on phones, a side rail on wide screens
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final saved = context.select<FavoritesStore, int>((f) => f.count);
    final pages = [const DiscoverScreen(), SavedScreen(onDiscover: () => setState(() => _tab = 0)), const PetsScreen(), const MoreScreen()];
    final destinations = [
      (Icons.style_outlined, Icons.style_rounded, 'Discover'),
      (Icons.favorite_border_rounded, Icons.favorite_rounded, 'Saved'),
      (Icons.pets_outlined, Icons.pets_rounded, 'Pets'),
      (Icons.more_horiz_rounded, Icons.more_horiz_rounded, 'More'),
    ];
    Widget icon(int i, bool on) {
      final widget = Icon(on ? destinations[i].$2 : destinations[i].$1);
      return i == 1 && saved > 0 ? Badge(label: Text('$saved'), backgroundColor: Theme.of(context).colorScheme.primary, textColor: Theme.of(context).colorScheme.onPrimary, child: widget) : widget;
    }

    final body = IndexedStack(index: _tab, children: pages);
    final wide = MediaQuery.sizeOf(context).width >= 840;

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _tab,
              onDestinationSelected: (i) => setState(() => _tab = i),
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.pets_rounded, color: Colors.white, size: 22),
                ),
              ),
              destinations: [for (var i = 0; i < 4; i++) NavigationRailDestination(icon: icon(i, false), selectedIcon: icon(i, true), label: Text(destinations[i].$3))],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [for (var i = 0; i < 4; i++) NavigationDestination(icon: icon(i, false), selectedIcon: icon(i, true), label: destinations[i].$3)],
      ),
    );
  }
}
