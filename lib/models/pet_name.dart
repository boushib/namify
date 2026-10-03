/// Kinds of pets a name suits.
enum Species {
  dog('Dog', '🐶'),
  cat('Cat', '🐱'),
  rabbit('Rabbit', '🐰'),
  bird('Bird', '🐦'),
  small('Small pet', '🐹'),
  fish('Fish', '🐠'),
  reptile('Reptile', '🦎'),
  horse('Horse', '🐴');

  const Species(this.label, this.emoji);
  final String label;
  final String emoji;
}

enum Gender {
  male('Boy'),
  female('Girl'),
  neutral('Any');

  const Gender(this.label);
  final String label;
}

/// The feel of a name.
enum NameStyle {
  cute('Cute', '🧸'),
  classic('Classic', '🎩'),
  funny('Funny', '😂'),
  food('Food', '🧁'),
  nature('Nature', '🌿'),
  mythic('Mythic', '🐉'),
  cosmic('Cosmic', '🪐'),
  tough('Tough', '💪'),
  fancy('Fancy', '💎'),
  inventive('Inventive', '✨');

  const NameStyle(this.label, this.emoji);
  final String label;
  final String emoji;
}

class PetName {
  const PetName({required this.name, required this.gender, required this.style, required this.meaning, this.species = const {}});

  final String name;
  final Gender gender;
  final NameStyle style;
  final String meaning;

  /// Empty means the name suits any pet.
  final Set<Species> species;

  bool suits(Species s) => species.isEmpty || species.contains(s);

  @override
  bool operator ==(Object other) => other is PetName && other.name == name;

  @override
  int get hashCode => name.hashCode;
}
