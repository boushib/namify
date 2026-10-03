import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/pet_name.dart';
import '../state/deck_store.dart';
import '../state/favorites_store.dart';
import '../state/pets_store.dart';
import '../state/settings_store.dart';
import '../theme.dart';
import '../widgets/page_width.dart';
import '../widgets/name_card.dart';
import 'litter_screen.dart';

const _issues = 'https://github.com/boushib/namify/issues';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  Future<void> _open(BuildContext context, String url) async {
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Couldn’t open the link')));
  }

  Future<void> _reset(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Start over?'),
        content: const Text('This removes your saved names, pets and stats from this device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Reset')),
        ],
      ),
    );
    if (yes != true || !context.mounted) return;
    context.read<FavoritesStore>().clear();
    context.read<PetsStore>().clear();
    context.read<DeckStore>().resetStats();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Everything was reset')));
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsStore>();
    final deck = context.watch<DeckStore>();
    final favorites = context.watch<FavoritesStore>();
    final pets = context.watch<PetsStore>();
    final theme = Theme.of(context);
    final rate = deck.seen == 0 ? 0 : (deck.liked / deck.seen * 100).round();

    // Which styles you save most
    final byStyle = <NameStyle, int>{};
    for (final f in favorites.items) {
      final s = f.style;
      if (s != null) byStyle[s] = (byStyle[s] ?? 0) + 1;
    }
    final top = byStyle.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final most = top.isEmpty ? 1 : top.first.value;

    Widget section(String title, List<Widget> children) => Padding(
      padding: const EdgeInsets.only(top: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              title.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 1.3, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface.withValues(alpha: .55)),
            ),
          ),
          Card(child: Column(children: children)),
        ],
      ),
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: PageWidth(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              Text('More', style: theme.textTheme.headlineMedium),
              const SizedBox(height: 18),
              Row(
                children: [
                  _Stat(value: '${deck.seen}', label: 'Names seen'),
                  const SizedBox(width: 10),
                  _Stat(value: '${favorites.count}', label: 'Saved'),
                  const SizedBox(width: 10),
                  _Stat(value: '$rate%', label: 'Like rate'),
                  const SizedBox(width: 10),
                  _Stat(value: '${pets.pets.length}', label: 'Pets'),
                ],
              ),
              if (top.isNotEmpty)
                section('Your taste', [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                    child: Column(
                      children: [
                        for (final e in top.take(4))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 110,
                                  child: Text('${e.key.emoji}  ${e.key.label}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                ),
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(99),
                                    child: LinearProgressIndicator(value: e.value / most, minHeight: 10, color: theme.colorScheme.primary, backgroundColor: styleColor(e.key, theme.brightness)),
                                  ),
                                ),
                                SizedBox(
                                  width: 36,
                                  child: Text(
                                    '${e.value}',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ]),
              section('Appearance', [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.brightness_auto_rounded), label: Text('Auto')),
                        ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_rounded), label: Text('Light')),
                        ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_rounded), label: Text('Dark')),
                      ],
                      selected: {settings.themeMode},
                      onSelectionChanged: (s) => settings.themeMode = s.first,
                      showSelectedIcon: false,
                    ),
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  value: settings.haptics,
                  onChanged: (v) => settings.haptics = v,
                  secondary: const Icon(Icons.vibration_rounded),
                  title: const Text('Haptics'),
                  subtitle: const Text('A little buzz when you like a name'),
                ),
              ]),
              section('Tools', [
                ListTile(
                  leading: const Icon(Icons.auto_awesome_rounded),
                  title: const Text('Name a litter'),
                  subtitle: const Text('Themed names for several pets at once'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LitterScreen())),
                ),
              ]),
              section('Help', [
                ListTile(
                  leading: const Icon(Icons.lightbulb_outline_rounded),
                  title: const Text('Suggest a name or feature'),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () => _open(context, '$_issues/new?labels=idea'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.bug_report_outlined),
                  title: const Text('Report a bug'),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () => _open(context, '$_issues/new?labels=bug'),
                ),
              ]),
              section('About', [
                const ListTile(leading: Icon(Icons.pets_rounded), title: Text('Whiskr'), subtitle: Text('Version 2.0 · Find a name your pet will grow into')),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.restart_alt_rounded, color: theme.colorScheme.error),
                  title: Text(
                    'Reset everything',
                    style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.w700),
                  ),
                  onTap: () => _reset(context),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 6),
        decoration: BoxDecoration(color: theme.colorScheme.surfaceContainer, borderRadius: BorderRadius.circular(20)),
        child: Column(
          children: [
            FittedBox(
              child: Text(value, style: nameStyle(context, size: 26).copyWith(color: theme.colorScheme.primary)),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
