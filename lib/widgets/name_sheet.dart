import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/names.dart';
import '../models/pet_name.dart';
import '../state/favorites_store.dart';
import '../state/pets_store.dart';
import '../theme.dart';
import 'name_card.dart';
import 'pet_editor.dart';

/// Everything about one name: meaning, tags, similar names, your note and actions
class NameSheet extends StatefulWidget {
  const NameSheet({super.key, required this.name});

  final PetName name;

  static Future<void> show(BuildContext context, PetName name) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => NameSheet(name: name),
  );

  /// Looks a saved name up in the catalog; invented or litter names get a simple entry
  static PetName lookup(String name, {String meaning = '', NameStyle? style}) =>
      catalog.where((n) => n.name == name).firstOrNull ?? PetName(name: name, gender: Gender.neutral, style: style ?? NameStyle.inventive, meaning: meaning.isEmpty ? 'A name you picked' : meaning);

  @override
  State<NameSheet> createState() => _NameSheetState();
}

class _NameSheetState extends State<NameSheet> {
  late final _note = TextEditingController(text: context.read<FavoritesStore>().items.where((f) => f.name == widget.name.name).firstOrNull?.note ?? '');

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  List<PetName> _similar() {
    final n = widget.name;
    final same = catalog.where((c) => c.name != n.name && c.style == n.style).toList();
    same.sort((a, b) => (a.name[0] == n.name[0] ? 0 : 1).compareTo(b.name[0] == n.name[0] ? 0 : 1));
    return same.take(8).toList();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.name;
    final favorites = context.watch<FavoritesStore>();
    final saved = favorites.contains(n.name);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bg = styleColor(n.style, theme.brightness);
    final owner = context.watch<PetsStore>().byName(n.name);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .85,
      maxChildSize: .95,
      builder: (context, scroll) => ListView(
        controller: scroll,
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(28)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(n.style.emoji, style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 10),
                Text(n.name, style: nameStyle(context, size: 44)),
                const SizedBox(height: 8),
                Text(n.meaning, style: theme.textTheme.titleMedium?.copyWith(color: scheme.onSurface.withValues(alpha: .75))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Fact(label: 'Style', value: n.style.label),
              _Fact(label: 'For', value: n.gender == Gender.neutral ? 'Anyone' : n.gender.label),
              _Fact(label: 'Letters', value: '${n.name.replaceAll(RegExp(r'[^A-Za-z]'), '').length}'),
              _Fact(label: 'Syllables', value: '${_syllables(n.name)}'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            n.species.isEmpty ? 'Suits any pet' : 'Great for: ${n.species.map((s) => '${s.emoji} ${s.label}').join('   ')}',
            style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurface.withValues(alpha: .75)),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(onPressed: () => favorites.toggle(n), icon: Icon(saved ? Icons.favorite_rounded : Icons.favorite_border_rounded), label: Text(saved ? 'Saved' : 'Save name')),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: n.name));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Copied “${n.name}”')));
                },
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('Copy'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: owner != null ? null : () => PetEditor.show(context, name: n.name),
            icon: Icon(owner != null ? Icons.pets_rounded : Icons.add_rounded, size: 20),
            label: Text(owner != null ? '${owner.species.emoji} ${owner.name} has this name' : 'Give this name to a pet'),
          ),
          if (saved) ...[
            const SizedBox(height: 24),
            Text('Your note', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            TextField(
              controller: _note,
              maxLines: 3,
              minLines: 2,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Why you love it, who suggested it…'),
              onChanged: (v) => favorites.setNote(n.name, v),
            ),
          ],
          const SizedBox(height: 28),
          Text('More ${n.style.label.toLowerCase()} names', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in _similar())
                ActionChip(
                  avatar: favorites.contains(s.name) ? Icon(Icons.favorite_rounded, size: 16, color: scheme.primary) : null,
                  label: Text(s.name),
                  onPressed: () {
                    Navigator.pop(context);
                    NameSheet.show(context, s);
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  int _syllables(String name) {
    final words = name.toLowerCase().replaceAll(RegExp(r'[^a-z ]'), '').split(' ').where((w) => w.isNotEmpty);
    var total = 0;
    for (final w in words) {
      var count = RegExp(r'[aeiouy]+').allMatches(w).length;
      if (w.endsWith('e') && !w.endsWith('le') && count > 1) count--;
      total += count < 1 ? 1 : count;
    }
    return total;
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: .5)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: .6))),
          ],
        ),
      ),
    );
  }
}
