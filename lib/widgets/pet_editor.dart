import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pet_name.dart';
import '../models/saved.dart';
import '../state/favorites_store.dart';
import '../state/pets_store.dart';

/// Add a pet or edit one; saved names are offered as one-tap suggestions
class PetEditor extends StatefulWidget {
  const PetEditor({super.key, this.pet, this.name});

  final Pet? pet;
  final String? name;

  static Future<void> show(BuildContext context, {Pet? pet, String? name}) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: PetEditor(pet: pet, name: name),
    ),
  );

  @override
  State<PetEditor> createState() => _PetEditorState();
}

class _PetEditorState extends State<PetEditor> {
  late final _name = TextEditingController(text: widget.pet?.name ?? widget.name ?? '');
  late final _breed = TextEditingController(text: widget.pet?.breed ?? '');
  late Species _species = widget.pet?.species ?? Species.dog;
  late DateTime? _birthday = widget.pet?.birthday;

  @override
  void dispose() {
    _name.dispose();
    _breed.dispose();
    super.dispose();
  }

  Future<void> _pickBirthday() async {
    final now = DateTime.now();
    final picked = await showDatePicker(context: context, initialDate: _birthday ?? now, firstDate: DateTime(now.year - 40), lastDate: now, helpText: 'Birthday or adoption day');
    if (picked != null) setState(() => _birthday = picked);
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    final pets = context.read<PetsStore>();
    pets.save(Pet(id: widget.pet?.id ?? DateTime.now().microsecondsSinceEpoch.toString(), name: name, species: _species, breed: _breed.text.trim(), birthday: _birthday));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.pet == null ? 'Welcome, $name! ${_species.emoji}' : 'Saved $name')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suggestions = context.read<FavoritesStore>().items.take(8).map((f) => f.name).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.pet == null ? 'New pet' : 'Edit ${widget.pet!.name}', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 20),
          TextField(
            controller: _name,
            autofocus: widget.pet == null && widget.name == null,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Name'),
            onChanged: (_) => setState(() {}),
          ),
          if (suggestions.isNotEmpty && widget.pet == null) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final s in suggestions)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(avatar: const Icon(Icons.favorite_rounded, size: 16), label: Text(s), onPressed: () => setState(() => _name.text = s)),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text('Species', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final s in Species.values) ChoiceChip(label: Text('${s.emoji} ${s.label}'), selected: _species == s, onSelected: (_) => setState(() => _species = s))],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _breed,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Breed (optional)'),
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: _pickBirthday,
            icon: const Icon(Icons.cake_rounded, size: 20),
            label: Text(_birthday == null ? 'Add birthday (optional)' : 'Birthday: ${MaterialLocalizations.of(context).formatMediumDate(_birthday!)}'),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _name.text.trim().isEmpty ? null : _save, child: Text(widget.pet == null ? 'Add pet' : 'Save changes')),
        ],
      ),
    );
  }
}
