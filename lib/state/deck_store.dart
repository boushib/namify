import 'dart:math';

import 'package:english_words/english_words.dart';
import 'package:flutter/foundation.dart';

import '../data/names.dart';
import '../models/pet_name.dart';
import '../services/storage.dart';

/// What the deck shows. Empty sets and nulls mean "any".
@immutable
class Filters {
  const Filters({this.species, this.gender, this.styles = const {}, this.letter, this.maxLength});

  final Species? species;
  final Gender? gender;
  final Set<NameStyle> styles;
  final String? letter;
  final int? maxLength;

  bool get isEmpty => species == null && gender == null && styles.isEmpty && letter == null && maxLength == null;

  /// Filters set in the filters sheet (species has its own chips)
  int get extraCount => [gender != null, styles.isNotEmpty, letter != null, maxLength != null].where((b) => b).length;

  int get activeCount => [species != null, gender != null, styles.isNotEmpty, letter != null, maxLength != null].where((b) => b).length;

  bool matches(PetName n) {
    if (species != null && !n.suits(species!)) return false;
    if (gender != null && n.gender != Gender.neutral && n.gender != gender) return false;
    if (styles.isNotEmpty && !styles.contains(n.style)) return false;
    if (letter != null && !n.name.toUpperCase().startsWith(letter!)) return false;
    if (maxLength != null && n.name.replaceAll(' ', '').length > maxLength!) return false;
    return true;
  }

  // Stored as a one-item list so it fits the list helpers in Storage
  List<Object?> toJson() => [
    {'species': species?.name, 'gender': gender?.name, 'styles': styles.map((s) => s.name).toList(), 'letter': letter, 'maxLength': maxLength},
  ];

  static Filters fromJson(List<Object?> json) {
    final m = json.isNotEmpty && json.first is Map ? json.first as Map : const {};
    final styles = m['styles'] is List ? (m['styles'] as List) : const [];
    return Filters(
      species: Species.values.where((s) => s.name == m['species']).firstOrNull,
      gender: Gender.values.where((g) => g.name == m['gender']).firstOrNull,
      styles: NameStyle.values.where((s) => styles.contains(s.name)).toSet(),
      letter: m['letter'] is String ? m['letter'] as String : null,
      maxLength: m['maxLength'] is int ? m['maxLength'] as int : null,
    );
  }

  Filters copyWith({Species? Function()? species, Gender? Function()? gender, Set<NameStyle>? styles, String? Function()? letter, int? Function()? maxLength}) => Filters(
    species: species != null ? species() : this.species,
    gender: gender != null ? gender() : this.gender,
    styles: styles ?? this.styles,
    letter: letter != null ? letter() : this.letter,
    maxLength: maxLength != null ? maxLength() : this.maxLength,
  );
}

/// How many catalog names a set of filters lets through
int countMatches(Filters f) => catalog.where((n) => n.style != NameStyle.inventive && f.matches(n)).length;

enum Verdict { like, skip }

/// The stack of name cards on the Discover tab
class DeckStore extends ChangeNotifier {
  DeckStore(this._storage, {Random? random}) : _random = random ?? Random() {
    _seen = _storage.readInt('stats.seen');
    _liked = _storage.readInt('stats.liked');
    _filters = Filters.fromJson(_storage.readList('filters'));
    _refill();
  }

  final Storage _storage;
  final Random _random;
  Filters _filters = const Filters();
  final List<PetName> _queue = [];
  final List<(PetName, Verdict)> _history = [];
  int _seen = 0;
  int _liked = 0;

  Filters get filters => _filters;
  int get seen => _seen;
  int get liked => _liked;
  bool get canUndo => _history.isNotEmpty;

  /// The top card and the one behind it (null when nothing matches)
  PetName? get current => _queue.isEmpty ? null : _queue.first;
  PetName? get next => _queue.length < 2 ? null : _queue[1];

  /// How many catalog names match the filters
  int get matchCount => countMatches(_filters);

  set filters(Filters f) {
    _filters = f;
    _storage.writeList('filters', f.toJson());
    _queue.clear();
    _refill();
    notifyListeners();
  }

  void decide(Verdict verdict) {
    final top = current;
    if (top == null) return;
    _queue.removeAt(0);
    _history.add((top, verdict));
    if (_history.length > 30) _history.removeAt(0);
    _seen++;
    if (verdict == Verdict.like) _liked++;
    _storage.writeInt('stats.seen', _seen);
    _storage.writeInt('stats.liked', _liked);
    _refill();
    notifyListeners();
  }

  /// Puts the last card back on top and returns how it was judged
  (PetName, Verdict)? undo() {
    if (_history.isEmpty) return null;
    final last = _history.removeLast();
    _queue.insert(0, last.$1);
    _seen = max(0, _seen - 1);
    if (last.$2 == Verdict.like) _liked = max(0, _liked - 1);
    notifyListeners();
    return last;
  }

  void resetStats() {
    _seen = 0;
    _liked = 0;
    _storage.writeInt('stats.seen', 0);
    _storage.writeInt('stats.liked', 0);
    notifyListeners();
  }

  // Keeps a few cards ready: a shuffled pass through the matching names, plus invented
  // two-word names when "Inventive" is wanted (or nothing narrows the style)
  void _refill() {
    if (_queue.length >= 3) return;
    final pool = catalog.where((n) => n.style != NameStyle.inventive && _filters.matches(n)).toList()..shuffle(_random);
    final recent = _history.reversed.take(12).map((h) => h.$1.name).toSet();
    final inventive = _filters.styles.isEmpty || _filters.styles.contains(NameStyle.inventive);
    final onlyInventive = _filters.styles.length == 1 && inventive;
    for (final n in onlyInventive ? const <PetName>[] : pool) {
      if (_queue.length >= 12) break;
      if (recent.contains(n.name) || _queue.contains(n)) continue;
      _queue.add(n);
      if (inventive && _random.nextInt(5) == 0) _addInvented();
    }
    while (inventive && _queue.length < 6) {
      if (!_addInvented()) break;
    }
  }

  bool _addInvented() {
    for (var tries = 0; tries < 20; tries++) {
      final name = generateWordPairs(random: _random).first.asPascalCase;
      final n = PetName(name: name, gender: Gender.neutral, style: NameStyle.inventive, meaning: 'A one-of-a-kind name, invented just now');
      if (_filters.matches(n) && !_queue.contains(n)) {
        _queue.add(n);
        return true;
      }
    }
    return false;
  }
}
