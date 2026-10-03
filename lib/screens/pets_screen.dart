import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/saved.dart';
import '../state/pets_store.dart';
import '../theme.dart';
import '../widgets/page_width.dart';
import '../widgets/pet_editor.dart';

class PetsScreen extends StatelessWidget {
  const PetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pets = context.watch<PetsStore>().pets;
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: pets.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => PetEditor.show(context),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add pet', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
      body: SafeArea(
        bottom: false,
        child: PageWidth(
          max: 960,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
            children: [
              Text('My pets', style: theme.textTheme.headlineMedium),
              Text(
                pets.isEmpty ? 'Keep your crew in one place' : '${pets.length} furry, feathery or scaly friend${pets.length == 1 ? '' : 's'}',
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: .6)),
              ),
              const SizedBox(height: 20),
              if (pets.isEmpty)
                _Empty(onAdd: () => PetEditor.show(context))
              else
                LayoutBuilder(
                  builder: (context, box) {
                    final columns = box.maxWidth > 700 ? 3 : (box.maxWidth > 420 ? 2 : 1);
                    return Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        for (final p in pets)
                          SizedBox(
                            width: (box.maxWidth - 14 * (columns - 1)) / columns,
                            child: _PetCard(pet: p),
                          ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard({required this.pet});
  final Pet pet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final store = context.read<PetsStore>();
    final details = [if (pet.breed.isNotEmpty) pet.breed, if (pet.age != null) pet.age!].join(' · ');

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => PetEditor.show(context, pet: pet),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: honey.withValues(alpha: .25), borderRadius: BorderRadius.circular(20)),
                child: Text(pet.species.emoji, style: const TextStyle(fontSize: 34)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(pet.name, style: nameStyle(context, size: 24), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(details.isEmpty ? pet.species.label : details, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurface.withValues(alpha: .65))),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz_rounded),
                onSelected: (v) {
                  if (v == 'edit') PetEditor.show(context, pet: pet);
                  if (v == 'remove') {
                    final removed = store.remove(pet.id);
                    if (removed == null) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Removed ${pet.name}'),
                        action: SnackBarAction(label: 'Undo', onPressed: () => store.restore(removed)),
                      ),
                    );
                  }
                },
                itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Edit')), PopupMenuItem(value: 'remove', child: Text('Remove'))],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: theme.colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(28)),
      child: Column(
        children: [
          const Text('🐶 🐱 🐰', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 16),
          Text('Add your first pet', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('Give them one of your saved names, and keep their breed and birthday handy.', textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 20),
          FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add_rounded), label: const Text('Add a pet')),
        ],
      ),
    );
  }
}
