import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pet_name.dart';
import '../state/deck_store.dart';
import '../state/settings_store.dart';
import '../theme.dart';

/// Three short pages on first launch, ending with "who are we naming?"
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pages = PageController();
  int _page = 0;
  Species? _species;

  void _finish() {
    final deck = context.read<DeckStore>();
    deck.filters = deck.filters.copyWith(species: () => _species);
    context.read<SettingsStore>().finishOnboarding();
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final last = _page == 2;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: AnimatedOpacity(
                  opacity: last ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: TextButton(onPressed: last ? null : _finish, child: const Text('Skip')),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (p) => setState(() => _page = p),
                children: [
                  const _Intro(
                    art: _Bubbles(names: ['Biscuit', 'Luna', 'Mochi', 'Zeus', 'Pickles', 'Nova']),
                    title: 'Find a name your pet will grow into',
                    text: 'Hundreds of hand-picked names, each with a meaning, for dogs, cats, rabbits, birds and more.',
                  ),
                  const _Intro(
                    art: _CardStack(),
                    title: 'Swipe right on the ones you love',
                    text: 'Like a name to save it, skip the rest. Filter by species, gender, style and even the first letter.',
                  ),
                  _SpeciesPicker(selected: _species, onSelect: (s) => setState(() => _species = s)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                children: [
                  for (var i = 0; i < 3; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 6),
                      width: i == _page ? 26 : 8,
                      height: 8,
                      decoration: BoxDecoration(color: i == _page ? scheme.primary : scheme.outlineVariant, borderRadius: BorderRadius.circular(99)),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: last ? _finish : () => _pages.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOutCubic),
                    style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 28)),
                    child: Text(last ? 'Start discovering' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.art, required this.title, required this.text});
  final Widget art;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          Expanded(child: Center(child: art)),
          Text(title, textAlign: TextAlign.center, style: nameStyle(context, size: 32)),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: .7), height: 1.4),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

/// Names floating around a paw
class _Bubbles extends StatelessWidget {
  const _Bubbles({required this.names});
  final List<String> names;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const spots = [Alignment(-.9, -.8), Alignment(.8, -.9), Alignment(-1, .1), Alignment(1, .05), Alignment(-.6, .9), Alignment(.7, .85)];
    return SizedBox(
      width: 320,
      height: 300,
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
              child: const Center(child: Icon(Icons.pets_rounded, color: Colors.white, size: 64)),
            ),
          ),
          for (var i = 0; i < names.length; i++)
            Align(
              alignment: spots[i],
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 500 + i * 120),
                curve: Curves.easeOutBack,
                builder: (context, t, child) => Transform.scale(scale: t, child: child),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: i.isEven ? honey : scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(999)),
                  child: Text(names[i], style: nameStyle(context, size: 18).copyWith(color: i.isEven ? const Color(0xFF2B1D00) : null)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CardStack extends StatelessWidget {
  const _CardStack();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget card(String name, String emoji, Color color, double angle, Offset offset) => Transform.translate(
      offset: offset,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: 200,
          height: 250,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(28)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 44)),
              const SizedBox(height: 8),
              Text(name, style: nameStyle(context, size: 30)),
            ],
          ),
        ),
      ),
    );
    return SizedBox(
      width: 320,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: [
          card('Clover', '🌿', const Color(0xFFE2F2E1), -.18, const Offset(-50, 10)),
          card('Waffles', '🧁', const Color(0xFFFFE6D6), .16, const Offset(50, 10)),
          card('Luna', '🐉', const Color(0xFFEDE5FA), 0, Offset.zero),
          Positioned(
            right: 30,
            bottom: 20,
            child: CircleAvatar(
              radius: 30,
              backgroundColor: scheme.primary,
              child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpeciesPicker extends StatelessWidget {
  const _SpeciesPicker({required this.selected, required this.onSelect});
  final Species? selected;
  final void Function(Species?) onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      children: [
        const SizedBox(height: 12),
        Text('Who are we naming?', textAlign: TextAlign.center, style: nameStyle(context, size: 32)),
        const SizedBox(height: 10),
        Text(
          'We’ll start with names that suit them. You can change this any time.',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(color: scheme.onSurface.withValues(alpha: .7)),
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            for (final s in Species.values) _Tile(emoji: s.emoji, label: s.label, on: selected == s, onTap: () => onSelect(selected == s ? null : s)),
            _Tile(emoji: '🐾', label: 'Not sure yet', on: selected == null, onTap: () => onSelect(null)),
          ],
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.emoji, required this.label, required this.on, required this.onTap});
  final String emoji;
  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: on ? scheme.primary.withValues(alpha: .12) : scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: on ? scheme.primary : scheme.outlineVariant.withValues(alpha: .6), width: on ? 2 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 34)),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
