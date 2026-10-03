import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:namify/data/names.dart';
import 'package:namify/models/pet_name.dart';
import 'package:namify/models/saved.dart';
import 'package:namify/services/storage.dart';
import 'package:namify/state/deck_store.dart';
import 'package:namify/state/favorites_store.dart';
import 'package:namify/state/pets_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Storage> storageWith(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  return Storage.open();
}

void main() {
  group('catalog', () {
    test('has unique, well-formed names', () {
      final names = catalog.map((n) => n.name).toList();
      expect(names.toSet().length, names.length, reason: 'duplicate names');
      expect(catalog.length, greaterThan(200));
      for (final n in catalog) {
        expect(n.name.trim(), isNotEmpty);
        expect(n.meaning.trim(), isNotEmpty);
      }
    });

    test('every litter theme has enough names', () {
      for (final names in litterThemes.values) {
        expect(names.length, greaterThanOrEqualTo(8));
      }
    });
  });

  group('deck', () {
    test('only deals names that match the filters', () async {
      final deck = DeckStore(await storageWith({}), random: Random(1));
      deck.filters = const Filters(species: Species.cat, gender: Gender.female, styles: {NameStyle.mythic});
      for (var i = 0; i < 10 && deck.current != null; i++) {
        final n = deck.current!;
        expect(n.style, NameStyle.mythic);
        expect(n.suits(Species.cat), isTrue);
        expect(n.gender, isNot(Gender.male));
        deck.decide(Verdict.skip);
      }
    });

    test('first letter and length filters', () async {
      final deck = DeckStore(await storageWith({}), random: Random(2));
      deck.filters = const Filters(letter: 'B', maxLength: 6, styles: {NameStyle.food});
      expect(deck.current, isNotNull);
      expect(deck.current!.name.startsWith('B'), isTrue);
      expect(deck.current!.name.length, lessThanOrEqualTo(6));
    });

    test('counts and undoes decisions', () async {
      final deck = DeckStore(await storageWith({}), random: Random(3));
      final first = deck.current!;
      deck.decide(Verdict.like);
      deck.decide(Verdict.skip);
      expect(deck.seen, 2);
      expect(deck.liked, 1);
      deck.undo();
      final undone = deck.undo();
      expect(undone!.$1, first);
      expect(undone.$2, Verdict.like);
      expect(deck.current, first);
      expect((deck.seen, deck.liked), (0, 0));
    });

    test('filters survive a restart', () async {
      final storage = await storageWith({});
      DeckStore(storage).filters = const Filters(species: Species.rabbit, styles: {NameStyle.cute}, letter: 'B');
      final again = DeckStore(storage);
      expect(again.filters.species, Species.rabbit);
      expect(again.filters.styles, {NameStyle.cute});
      expect(again.filters.letter, 'B');
    });

    test('inventive style invents names forever', () async {
      final deck = DeckStore(await storageWith({}), random: Random(4));
      deck.filters = const Filters(styles: {NameStyle.inventive});
      for (var i = 0; i < 30; i++) {
        expect(deck.current?.style, NameStyle.inventive);
        deck.decide(Verdict.skip);
      }
    });
  });

  group('favorites', () {
    test('carries over names saved by the first version', () async {
      final store = FavoritesStore(await storageWith({'favorites': ['FuzzyBear', 'LuckyStar']}));
      expect(store.items.map((f) => f.name), containsAll(['FuzzyBear', 'LuckyStar']));
    });

    test('add, note, remove and undo', () async {
      final storage = await storageWith({});
      final store = FavoritesStore(storage);
      final luna = catalog.firstWhere((n) => n.name == 'Luna');
      store.add(luna);
      store.setNote('Luna', '  For the grey kitten  ');
      final removed = store.remove('Luna')!;
      expect(store.contains('Luna'), isFalse);
      store.restore(removed);
      // Saved and read back
      final again = FavoritesStore(storage);
      expect(again.items.single.note, 'For the grey kitten');
      expect(again.items.single.style, NameStyle.mythic);
    });
  });

  test('pets are saved and their age is readable', () async {
    final storage = await storageWith({});
    final pets = PetsStore(storage);
    final now = DateTime.now();
    pets.save(Pet(id: '1', name: 'Biscuit', species: Species.dog, birthday: DateTime(now.year - 3, now.month, 1)));
    final again = PetsStore(storage);
    expect(again.pets.single.name, 'Biscuit');
    expect(again.pets.single.age, '3 years');
  });
}
