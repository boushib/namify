import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/names.dart';
import '../state/favorites_store.dart';
import '../theme.dart';

/// Name a whole litter at once from a theme
class LitterScreen extends StatefulWidget {
  const LitterScreen({super.key});

  @override
  State<LitterScreen> createState() => _LitterScreenState();
}

class _LitterScreenState extends State<LitterScreen> {
  String _theme = litterThemes.keys.first;
  int _count = 4;
  List<String> _names = [];
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _shuffle();
  }

  void _shuffle() => setState(() => _names = ([...litterThemes[_theme]!]..shuffle(_random)).take(_count).toList());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final favorites = context.watch<FavoritesStore>();
    final allSaved = _names.every(favorites.contains);

    return Scaffold(
      appBar: AppBar(title: const Text('Name a litter')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
        children: [
          Text('Pick a theme and how many little ones you have. We’ll find names that belong together.', style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurface.withValues(alpha: .7))),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in litterThemes.keys)
                ChoiceChip(
                  label: Text(t),
                  selected: _theme == t,
                  onSelected: (_) {
                    _theme = t;
                    _shuffle();
                  },
                ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Text('How many?', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const Spacer(),
              IconButton.outlined(
                onPressed: _count > 2
                    ? () {
                        _count--;
                        _shuffle();
                      }
                    : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              SizedBox(
                width: 48,
                child: Text('$_count', textAlign: TextAlign.center, style: nameStyle(context, size: 26)),
              ),
              IconButton.outlined(
                onPressed: _count < 8
                    ? () {
                        _count++;
                        _shuffle();
                      }
                    : null,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 22),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Column(
              key: ValueKey(_names.join()),
              children: [
                for (var i = 0; i < _names.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                        leading: CircleAvatar(
                          backgroundColor: honey.withValues(alpha: .3),
                          child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.w800)),
                        ),
                        title: Text(_names[i], style: nameStyle(context, size: 22)),
                        trailing: IconButton(
                          icon: Icon(favorites.contains(_names[i]) ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: scheme.primary),
                          onPressed: () =>
                              favorites.contains(_names[i]) ? favorites.remove(_names[i]) : favorites.addName(_names[i], meaning: 'From the ${_theme.substring(_theme.indexOf(' ') + 1)} litter set'),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(onPressed: _shuffle, icon: const Icon(Icons.shuffle_rounded), label: const Text('Shuffle')),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: allSaved
                      ? null
                      : () {
                          for (final n in _names) {
                            favorites.addName(n, meaning: 'From the ${_theme.substring(_theme.indexOf(' ') + 1)} litter set');
                          }
                          HapticFeedback.mediumImpact();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved ${_names.length} names')));
                        },
                  icon: Icon(allSaved ? Icons.check_rounded : Icons.favorite_rounded),
                  label: Text(allSaved ? 'All saved' : 'Save all'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
