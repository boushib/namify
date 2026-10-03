import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_shell.dart';
import 'screens/onboarding_screen.dart';
import 'services/storage.dart';
import 'state/deck_store.dart';
import 'state/favorites_store.dart';
import 'state/pets_store.dart';
import 'state/settings_store.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await Storage.open();
  runApp(WhiskrApp(storage: storage));
}

class WhiskrApp extends StatelessWidget {
  const WhiskrApp({super.key, required this.storage});
  final Storage storage;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsStore(storage)),
        ChangeNotifierProvider(create: (_) => FavoritesStore(storage)),
        ChangeNotifierProvider(create: (_) => PetsStore(storage)),
        ChangeNotifierProvider(create: (_) => DeckStore(storage)),
      ],
      child: Builder(
        builder: (context) {
          final settings = context.watch<SettingsStore>();
          return MaterialApp(
            title: 'Whiskr',
            debugShowCheckedModeBanner: false,
            theme: buildTheme(Brightness.light),
            darkTheme: buildTheme(Brightness.dark),
            themeMode: settings.themeMode,
            home: AnimatedSwitcher(duration: const Duration(milliseconds: 400), child: settings.onboarded ? const AppShell() : const OnboardingScreen()),
          );
        },
      ),
    );
  }
}
