import 'package:flutter/material.dart';
import 'package:namify/main.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    String currentName = appState.currentWord.asPascalCase;
    Set<String> favorites = appState.favorites;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            currentName,
            semanticsLabel: currentName,
            style: const TextStyle(
              fontSize: 32,
              fontFamily: "Space Mono",
              //color: Colors.lime,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    appState.toggleFavoriteItem(currentName);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                ),
                label: const Text(
                  "Like",
                  style: TextStyle(
                    fontFamily: "Space Mono",
                    fontSize: 15,
                  ),
                ),
                icon: Icon(
                  favorites.contains(currentName)
                      ? Icons.favorite
                      : Icons.favorite_border,
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    appState.generateNewName();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                ),
                child: const Text(
                  "Next Name",
                  style: TextStyle(fontFamily: "Space Mono", fontSize: 15),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
