import 'package:flutter/foundation.dart';

import '../models/saved.dart';
import '../services/storage.dart';

class PetsStore extends ChangeNotifier {
  PetsStore(this._storage) {
    _pets = _storage.readList('pets').map(Pet.fromJson).whereType<Pet>().toList();
  }

  final Storage _storage;
  late List<Pet> _pets;

  List<Pet> get pets => List.unmodifiable(_pets);

  Pet? byName(String name) => _pets.where((p) => p.name == name).firstOrNull;

  void save(Pet pet) {
    final i = _pets.indexWhere((p) => p.id == pet.id);
    if (i < 0) {
      _pets.add(pet);
    } else {
      _pets[i] = pet;
    }
    _changed();
  }

  (Pet, int)? remove(String id) {
    final i = _pets.indexWhere((p) => p.id == id);
    if (i < 0) return null;
    final removed = _pets.removeAt(i);
    _changed();
    return (removed, i);
  }

  void restore((Pet, int) entry) {
    final (pet, i) = entry;
    _pets.insert(i.clamp(0, _pets.length), pet);
    _changed();
  }

  void clear() {
    _pets = [];
    _changed();
  }

  void _changed() {
    notifyListeners();
    _storage.writeList('pets', _pets.map((p) => p.toJson()).toList());
  }
}
