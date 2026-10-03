import 'pet_name.dart';

/// A name you liked, with your own note.
class Favorite {
  Favorite({required this.name, required this.addedAt, this.meaning = '', this.note = '', this.style});

  final String name;
  final DateTime addedAt;
  final String meaning;
  final NameStyle? style;
  String note;

  Map<String, dynamic> toJson() => {'name': name, 'addedAt': addedAt.toIso8601String(), 'meaning': meaning, 'note': note, 'style': style?.name};

  static Favorite? fromJson(Object? json) {
    if (json is! Map || json['name'] is! String) return null;
    return Favorite(
      name: json['name'] as String,
      addedAt: DateTime.tryParse('${json['addedAt']}') ?? DateTime.now(),
      meaning: json['meaning'] is String ? json['meaning'] as String : '',
      note: json['note'] is String ? json['note'] as String : '',
      style: NameStyle.values.where((s) => s.name == json['style']).firstOrNull,
    );
  }
}

/// One of your pets.
class Pet {
  Pet({required this.id, required this.name, required this.species, this.breed = '', this.birthday});

  final String id;
  String name;
  Species species;
  String breed;
  DateTime? birthday;

  /// "2 years", "5 months" or "3 weeks"
  String? get age {
    final b = birthday;
    if (b == null) return null;
    final now = DateTime.now();
    var months = (now.year - b.year) * 12 + now.month - b.month - (now.day < b.day ? 1 : 0);
    if (months >= 24) return '${months ~/ 12} years';
    if (months >= 12) return months == 12 ? '1 year' : '$months months';
    if (months >= 1) return '$months month${months == 1 ? '' : 's'}';
    final weeks = now.difference(b).inDays ~/ 7;
    return weeks <= 1 ? 'Newborn' : '$weeks weeks';
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'species': species.name, 'breed': breed, 'birthday': birthday?.toIso8601String()};

  static Pet? fromJson(Object? json) {
    if (json is! Map || json['id'] is! String || json['name'] is! String) return null;
    return Pet(
      id: json['id'] as String,
      name: json['name'] as String,
      species: Species.values.where((s) => s.name == json['species']).firstOrNull ?? Species.dog,
      breed: json['breed'] is String ? json['breed'] as String : '',
      birthday: DateTime.tryParse('${json['birthday']}'),
    );
  }
}
