import '../models/pet_name.dart';
import '../models/saved.dart';
import 'storage.dart';

/// Builds with `--dart-define=DEMO=true` start with sample names, pets and stats (for screenshots)
const demoMode = bool.fromEnvironment('DEMO');

Future<void> seedDemoData(Storage storage) async {
  if (!demoMode || storage.readBool('demo.seeded')) return;
  final now = DateTime.now();
  DateTime ago(int days) => now.subtract(Duration(days: days));
  Favorite fav(String name, String meaning, NameStyle style, int days, [String note = '']) => Favorite(name: name, meaning: meaning, style: style, addedAt: ago(days), note: note);

  await storage.writeList('favorites.v2', [
    fav('Biscuit', 'Crunchy, golden and impossible to resist', NameStyle.food, 0, 'Grandma’s favorite'),
    fav('Luna', 'Roman goddess of the moon', NameStyle.mythic, 1),
    fav('Clover', 'Lucky, green and rare with four leaves', NameStyle.nature, 2),
    fav('Captain Fluff', 'Commander of the couch', NameStyle.funny, 3),
    fav('Nova', 'A star that suddenly shines brighter', NameStyle.cosmic, 4),
    fav('Mochi', 'A squishy Japanese rice-cake treat', NameStyle.food, 5),
    fav('Duchess', 'Elegant and a bit aloof', NameStyle.fancy, 6),
  ].map((f) => f.toJson()).toList());
  await storage.writeList('pets', [
    Pet(id: '1', name: 'Biscuit', species: Species.dog, breed: 'Golden Retriever', birthday: ago(800)),
    Pet(id: '2', name: 'Luna', species: Species.cat, breed: 'British Shorthair', birthday: ago(400)),
    Pet(id: '3', name: 'Clover', species: Species.rabbit, breed: 'Holland Lop', birthday: ago(150)),
  ].map((p) => p.toJson()).toList());
  await storage.writeInt('stats.seen', 148);
  await storage.writeInt('stats.liked', 37);
  await storage.writeBool('demo.seeded', true);
}
