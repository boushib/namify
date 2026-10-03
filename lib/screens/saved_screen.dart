import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/saved.dart';
import '../state/favorites_store.dart';
import '../state/pets_store.dart';
import '../theme.dart';
import '../widgets/page_width.dart';
import '../widgets/name_card.dart';
import '../widgets/name_sheet.dart';
import 'discover_screen.dart';

enum _Sort { newest, az }

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key, required this.onDiscover});
  final VoidCallback onDiscover;

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  String _query = '';
  _Sort _sort = _Sort.newest;

  void _remove(Favorite f) {
    final store = context.read<FavoritesStore>();
    final removed = store.remove(f.name);
    if (removed == null) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('Removed ${f.name}'),
          action: SnackBarAction(label: 'Undo', onPressed: () => store.restore(removed)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FavoritesStore>();
    final pets = context.watch<PetsStore>();
    final theme = Theme.of(context);
    var items = store.items.where((f) => f.name.toLowerCase().contains(_query.toLowerCase())).toList();
    if (_sort == _Sort.az) items.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: PageWidth(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Saved names', style: theme.textTheme.headlineMedium),
                      Text(
                        store.count == 0 ? 'Names you like show up here' : '${store.count} name${store.count == 1 ? '' : 's'} on your shortlist',
                        style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: .6)),
                      ),
                      const SizedBox(height: 18),
                      const _TodayCard(),
                      if (store.count > 0) ...[
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                onChanged: (v) => setState(() => _query = v),
                                decoration: const InputDecoration(hintText: 'Search your names', prefixIcon: Icon(Icons.search_rounded), isDense: true),
                              ),
                            ),
                            const SizedBox(width: 10),
                            SegmentedButton<_Sort>(
                              segments: const [
                                ButtonSegment(value: _Sort.newest, icon: Icon(Icons.schedule_rounded), tooltip: 'Newest first'),
                                ButtonSegment(value: _Sort.az, icon: Icon(Icons.sort_by_alpha_rounded), tooltip: 'A to Z'),
                              ],
                              selected: {_sort},
                              showSelectedIcon: false,
                              onSelectionChanged: (s) => setState(() => _sort = s.first),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              if (store.count == 0)
                SliverFillRemaining(hasScrollBody: false, child: _Empty(onDiscover: widget.onDiscover))
              else if (items.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Text('No saved names match “$_query”', textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final f = items[i];
                      final n = NameSheet.lookup(f.name, meaning: f.meaning, style: f.style);
                      final owner = pets.byName(f.name);
                      return Dismissible(
                        key: ValueKey(f.name),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _remove(f),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 24),
                          decoration: BoxDecoration(color: theme.colorScheme.errorContainer, borderRadius: BorderRadius.circular(20)),
                          child: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.onErrorContainer),
                        ),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: .4)),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                            onTap: () => NameSheet.show(context, n),
                            leading: Container(
                              width: 52,
                              height: 52,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(color: styleColor(n.style, theme.brightness), borderRadius: BorderRadius.circular(16)),
                              child: Text(n.style.emoji, style: const TextStyle(fontSize: 24)),
                            ),
                            title: Text(f.name, style: nameStyle(context, size: 21)),
                            subtitle: Text(
                              owner != null ? '${owner.species.emoji} ${owner.name}’s name' : (f.note.isNotEmpty ? '“${f.note}”' : n.meaning),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              tooltip: 'Remove',
                              icon: Icon(Icons.favorite_rounded, color: theme.colorScheme.primary),
                              onPressed: () => _remove(f),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard();

  @override
  Widget build(BuildContext context) {
    final n = nameOfTheDay();
    final theme = Theme.of(context);
    final saved = context.watch<FavoritesStore>().contains(n.name);
    return Material(
      color: theme.colorScheme.primary,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => NameSheet.show(context, n),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NAME OF THE DAY',
                      style: theme.textTheme.labelMedium?.copyWith(color: Colors.white.withValues(alpha: .8), letterSpacing: 1.4, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(n.name, style: nameStyle(context, size: 32).copyWith(color: Colors.white)),
                    const SizedBox(height: 4),
                    Text(
                      n.meaning,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: .85)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 30,
                backgroundColor: honey,
                child: Text(n.style.emoji, style: const TextStyle(fontSize: 28)),
              ),
              if (saved)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(Icons.favorite_rounded, color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onDiscover});
  final VoidCallback onDiscover;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💜', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('No saved names yet', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Swipe right on names you love and they’ll wait for you here.', textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 20),
          FilledButton(onPressed: onDiscover, child: const Text('Start discovering')),
        ],
      ),
    );
  }
}
