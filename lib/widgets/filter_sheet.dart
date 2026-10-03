import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pet_name.dart';
import '../state/deck_store.dart';

/// Gender, style, first letter and length filters for the deck
class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet(context: context, isScrollControlled: true, showDragHandle: true, useSafeArea: true, builder: (_) => const FilterSheet());

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late Filters _f = context.read<DeckStore>().filters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = _preview();
    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 10),
      child: Text(text, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
    );

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .8,
      maxChildSize: .95,
      builder: (context, scroll) => Column(
        children: [
          Expanded(
            child: ListView(
              controller: scroll,
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              children: [
                Row(
                  children: [
                    Text('Filters', style: theme.textTheme.headlineMedium),
                    const Spacer(),
                    if (!_f.isEmpty) TextButton(onPressed: () => setState(() => _f = const Filters()), child: const Text('Clear all')),
                  ],
                ),
                heading('Gender'),
                SegmentedButton<Gender?>(
                  segments: const [
                    ButtonSegment(value: null, label: Text('Any')),
                    ButtonSegment(value: Gender.male, label: Text('Boy')),
                    ButtonSegment(value: Gender.female, label: Text('Girl')),
                  ],
                  selected: {_f.gender},
                  onSelectionChanged: (s) => setState(() => _f = _f.copyWith(gender: () => s.first)),
                  showSelectedIcon: false,
                ),
                heading('Style'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: NameStyle.values.map((s) {
                    final on = _f.styles.contains(s);
                    return FilterChip(
                      label: Text('${s.emoji} ${s.label}'),
                      selected: on,
                      onSelected: (v) => setState(() => _f = _f.copyWith(styles: v ? {..._f.styles, s} : ({..._f.styles}..remove(s)))),
                    );
                  }).toList(),
                ),
                heading('Starts with'),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ChoiceChip(
                      label: const Text('Any'),
                      selected: _f.letter == null,
                      onSelected: (_) => setState(() => _f = _f.copyWith(letter: () => null)),
                    ),
                    for (final l in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split(''))
                      ChoiceChip(
                        label: Text(l),
                        selected: _f.letter == l,
                        onSelected: (v) => setState(() => _f = _f.copyWith(letter: () => v ? l : null)),
                      ),
                  ],
                ),
                heading(_f.maxLength == null ? 'Length: any' : 'Up to ${_f.maxLength} letters'),
                Slider(
                  min: 3,
                  max: 13,
                  divisions: 10,
                  value: (_f.maxLength ?? 13).toDouble(),
                  label: _f.maxLength == null ? 'Any' : '${_f.maxLength}',
                  onChanged: (v) => setState(() => _f = _f.copyWith(maxLength: () => v >= 13 ? null : v.round())),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    context.read<DeckStore>().filters = _f;
                    Navigator.pop(context);
                  },
                  child: Text(count == 0 && !_f.styles.contains(NameStyle.inventive) ? 'No names match' : 'Show ${count > 0 ? '$count ' : ''}names'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // How many catalog names the draft filters would show
  int _preview() {
    final store = context.read<DeckStore>();
    final saved = store.filters;
    if (identical(saved, _f)) return store.matchCount;
    return countMatches(_f);
  }
}
