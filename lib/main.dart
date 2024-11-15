import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:namify/components/nav_item.dart';
import 'package:namify/screens/favorites.dart';
import 'package:namify/screens/home.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => AppState(),
        child: Builder(builder: (context) {
          String theme = Provider.of<AppState>(context).theme;
          return MaterialApp(
            title: 'Flutter Demo',
            theme: theme == "dark" ? getDarkTheme() : getLightTheme(),
            home: const AppWrapper(title: 'Namify'),
            debugShowCheckedModeBanner: false,
          );
        }));
  }
}

class AppState extends ChangeNotifier {
  var currentWord = WordPair.random();
  Set<String> favorites = {};
  String theme = "dark";

  AppState() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedFavorites = prefs.getStringList("favorites");
    final String? savedTheme = prefs.getString("theme");

    if (savedFavorites != null) {
      favorites = Set<String>.from(savedFavorites);
      notifyListeners();
    }

    if (savedTheme != null) {
      theme = savedTheme;
      notifyListeners();
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("favorites", favorites.toList());
  }

  Future<void> _toggleTheme() async {
    theme = theme == "dark" ? "light" : "dark";
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("theme", theme);
  }

  void generateNewName() {
    currentWord = WordPair.random();
  }

  void toggleFavoriteItem(String name) {
    if (favorites.contains(name)) {
      favorites.remove(name);
    } else {
      favorites.add(name);
    }
    notifyListeners();
    _saveFavorites();
  }

  void removeFavoriteItem(String name) {
    favorites.remove(name);
    notifyListeners();
    _saveFavorites();
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key, required this.title});
  final String title;

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  int _selectedPageIndex = 0;

  void updatePageIndex(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget selectedPage;

    switch (_selectedPageIndex) {
      case 0:
        selectedPage = const HomePage(title: "HomePage");
        break;
      case 1:
        selectedPage = const FavoritesPage(title: "Favorites");
        break;
      default:
        throw UnimplementedError("Page not found");
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        title: Text(widget.title),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.menu),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              Provider.of<AppState>(context, listen: false)._toggleTheme();
            },
            icon: Icon(
              Provider.of<AppState>(context).theme == "dark"
                  ? Icons.dark_mode
                  : Icons.light_mode,
              color: Colors.white,
            ),
          )
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: ListView(
            padding: const EdgeInsets.all(0),
            children: [
              Container(
                color: Theme.of(context).primaryColor,
                child: const SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 24),
                    child: Text(
                      "Namify",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              NavigationItem(
                icon: Icons.home,
                title: "Home",
                isSelected: _selectedPageIndex == 0,
                onTap: () {
                  setState(() {
                    _selectedPageIndex = 0;
                  });
                },
              ),
              NavigationItem(
                icon: Icons.favorite,
                title: "Favorites",
                isSelected: _selectedPageIndex == 1,
                onTap: () {
                  setState(() {
                    _selectedPageIndex = 1;
                  });
                },
              ),
              NavigationItem(
                icon: Icons.pets,
                title: "Profile",
                isSelected: _selectedPageIndex == 2,
                onTap: () {
                  //
                },
              ),
              NavigationItem(
                icon: Icons.settings,
                title: "Settings",
                isSelected: _selectedPageIndex == 3,
                onTap: () {
                  //
                },
              ),
              NavigationItem(
                icon: Icons.bug_report,
                title: "Report a Bug",
                isSelected: _selectedPageIndex == 4,
                onTap: () {
                  //
                },
              ),
              NavigationItem(
                icon: Icons.help,
                title: "Support",
                isSelected: _selectedPageIndex == 5,
                onTap: () {
                  //
                },
              ),
            ],
          ),
        ),
      ),
      body: selectedPage,
    );
  }
}

ThemeData getDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    primaryColor: const Color(0xFFF95F32),
    scaffoldBackgroundColor: const Color(0xFF161B28),
    textTheme: const TextTheme(
      bodySmall: TextStyle(
        fontFamily: "Space Mono",
        fontSize: 16,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontFamily: "Space Mono",
        fontSize: 24,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontFamily: "Space Mono",
        fontSize: 36,
        color: Colors.white,
      ),
    ),
  );
}

ThemeData getLightTheme() {
  return ThemeData(
    useMaterial3: true,
    primaryColor: const Color(0xFFF95F32),
    scaffoldBackgroundColor: const Color(0xFFFFFFFF),
    textTheme: const TextTheme(
      bodySmall: TextStyle(
        fontFamily: "Space Mono",
        fontSize: 16,
        color: Colors.black,
      ),
      bodyMedium: TextStyle(
        fontFamily: "Space Mono",
        fontSize: 24,
        color: Colors.black,
      ),
      bodyLarge: TextStyle(
        fontFamily: "Space Mono",
        fontSize: 36,
        color: Colors.black,
      ),
    ),
  );
}
