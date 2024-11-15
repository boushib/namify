import 'package:flutter/material.dart';
import 'package:namify/main.dart';
import 'package:provider/provider.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key, required this.title});
  final String title;

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    Set<String> favorites = Provider.of<AppState>(context).favorites;

    if (favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "No favorites yet!",
                style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                "Navigate to the home page and favorite some names",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            child: Text(
              "You have ${favorites.length} favorite${favorites.length == 1 ? '' : 's'}! (Tap to Remove)",
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const Divider(
            color: Color.fromARGB(40, 255, 255, 255),
            thickness: 1,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              children: favorites.map(
                (name) {
                  return ListTile(
                    hoverColor: const Color.fromARGB(10, 255, 255, 255),
                    dense: true,
                    contentPadding: const EdgeInsets.all(0),
                    leading: Icon(
                      Icons.favorite,
                      color: Theme.of(context).primaryColor,
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    onTap: () {
                      Provider.of<AppState>(
                        context,
                        listen: false,
                      ).removeFavoriteItem(name);
                    },
                  );
                },
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
