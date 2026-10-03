import 'package:flutter/foundation.dart';

import '../models/pet_name.dart';
import '../models/saved.dart';
import '../services/storage.dart';

class FavoritesStore extends ChangeNotifier {
  FavoritesStore(this._storage) {
    _items = _storage.readList('favorites.v2').map(Favorite.fromJson).whereType<Favorite>().toList();
    // Carry over favorites from the first version of the app (a plain list of names)
    if (_items.isEmpty) {
      final legacy = _legacy();
      if (legacy.isNotEmpty) {
        _items = legacy.map((n) => Favorite(name: n, addedAt: DateTime.now())).toList();
        _save();
      }
    }
  }

  final Storage _storage;
  late List<Favorite> _items;

  List<String> _legacy() {
    try {
      return _storage.readStringList('favorites');
    } catch (_) {
      return const [];
    }
  }

  /// Newest first
  List<Favorite> get items => List.unmodifiable(_items);
  int get count => _items.length;

  bool contains(String name) => _items.any((f) => f.name == name);

  void add(PetName n) {
    if (contains(n.name)) return;
    _items.insert(0, Favorite(name: n.name, addedAt: DateTime.now(), meaning: n.meaning, style: n.style));
    _changed();
  }

  void addName(String name, {String meaning = ''}) {
    if (contains(name)) return;
    _items.insert(0, Favorite(name: name, addedAt: DateTime.now(), meaning: meaning));
    _changed();
  }

  void toggle(PetName n) => contains(n.name) ? remove(n.name) : add(n);

  /// Removes a favorite and returns it with its position, so it can be undone
  (Favorite, int)? remove(String name) {
    final i = _items.indexWhere((f) => f.name == name);
    if (i < 0) return null;
    final removed = _items.removeAt(i);
    _changed();
    return (removed, i);
  }

  void restore((Favorite, int) entry) {
    final (fav, i) = entry;
    if (contains(fav.name)) return;
    _items.insert(i.clamp(0, _items.length), fav);
    _changed();
  }

  void setNote(String name, String note) {
    final f = _items.where((f) => f.name == name).firstOrNull;
    if (f == null) return;
    f.note = note.trim();
    _changed();
  }

  void clear() {
    _items = [];
    _changed();
  }

  void _changed() {
    notifyListeners();
    _save();
  }

  Future<void> _save() => _storage.writeList('favorites.v2', _items.map((f) => f.toJson()).toList());
}
