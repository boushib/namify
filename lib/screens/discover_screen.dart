import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/names.dart';
import '../models/pet_name.dart';
import '../state/deck_store.dart';
import '../state/favorites_store.dart';
import '../state/settings_store.dart';
import '../theme.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/name_sheet.dart';
import '../widgets/swipe_deck.dart';
import 'litter_screen.dart';

/// Today's pick: the same name for everyone on a given day
PetName nameOfTheDay([DateTime? now]) {
  final d = now ?? DateTime.now();
  final names = catalog.where((n) => n.style != NameStyle.inventive).toList();
  return names[(d.year * 372 + d.month * 31 + d.day) % names.length];
}

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _deck = GlobalKey<SwipeDeckState>();
  bool _burst = false;

  void _decide(Verdict verdict) {
    final deck = context.read<DeckStore>();
    final name = deck.current;
    if (name == null) return;
    if (verdict == Verdict.like) {
      context.read<FavoritesStore>().add(name);
      if (context.read<SettingsStore>().haptics) HapticFeedback.mediumImpact();
      setState(() => _burst = true);
      Future.delayed(const Duration(milliseconds: 650), () => mounted ? setState(() => _burst = false) : null);
    } else if (context.read<SettingsStore>().haptics) {
      HapticFeedback.selectionClick();
    }
    deck.decide(verdict);
  }

  void _undo() {
    final last = context.read<DeckStore>().undo();
    if (last != null && last.$2 == Verdict.like) context.read<FavoritesStore>().remove(last.$1.name);
  }

  @override
  Widget build(BuildContext context) {
    final deck = context.watch<DeckStore>();
    final favorites = context.watch<FavoritesStore>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final current = deck.current;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => _deck.currentState?.fling(Verdict.like),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _deck.currentState?.fling(Verdict.skip),
        const SingleActivator(LogicalKeyboardKey.backspace): _undo,
        const SingleActivator(LogicalKeyboardKey.space): () => current == null ? null : NameSheet.show(context, current),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(),
                              style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurface.withValues(alpha: .6), fontWeight: FontWeight.w700),
                            ),
                            Text('Discover names', style: theme.textTheme.headlineMedium),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        tooltip: 'Name a litter',
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LitterScreen())),
                        icon: const Icon(Icons.auto_awesome_rounded),
                      ),
                      const SizedBox(width: 6),
                      Badge(
                        isLabelVisible: deck.filters.extraCount > 0,
                        label: Text('${deck.filters.extraCount}'),
                        backgroundColor: scheme.secondary,
                        textColor: scheme.onSecondary,
                        child: IconButton.filledTonal(tooltip: 'Filters', onPressed: () => FilterSheet.show(context), icon: const Icon(Icons.tune_rounded)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _SpeciesBar(
                  selected: deck.filters.species,
                  onSelect: (s) => deck.filters = deck.filters.copyWith(species: () => s),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 560),
                        child: current == null
                            ? _NoMatches(onClear: () => deck.filters = const Filters())
                            : Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned.fill(
                                    child: GestureDetector(
                                      onTap: () => NameSheet.show(context, current),
                                      child: SwipeDeck(key: _deck, current: current, next: deck.next, onDecide: _decide, isLiked: (n) => favorites.contains(n.name)),
                                    ),
                                  ),
                                  if (_burst) const Positioned.fill(child: IgnorePointer(child: _HeartBurst())),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _RoundButton(icon: Icons.undo_rounded, size: 52, tooltip: 'Undo', onTap: deck.canUndo ? _undo : null),
                      const SizedBox(width: 18),
                      _RoundButton(icon: Icons.close_rounded, size: 70, tooltip: 'Skip', onTap: current == null ? null : () => _deck.currentState?.fling(Verdict.skip)),
                      const SizedBox(width: 18),
                      _RoundButton(icon: Icons.favorite_rounded, size: 70, tooltip: 'Like', filled: true, onTap: current == null ? null : () => _deck.currentState?.fling(Verdict.like)),
                      const SizedBox(width: 18),
                      _RoundButton(icon: Icons.info_outline_rounded, size: 52, tooltip: 'Details', onTap: current == null ? null : () => NameSheet.show(context, current)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    return h < 12
        ? 'Good morning'
        : h < 18
        ? 'Good afternoon'
        : 'Good evening';
  }
}

class _SpeciesBar extends StatelessWidget {
  const _SpeciesBar({required this.selected, required this.onSelect});
  final Species? selected;
  final void Function(Species?) onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget chip(String label, bool on, VoidCallback tap) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: on ? scheme.primary : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: on ? scheme.primary : scheme.outlineVariant.withValues(alpha: .6)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: tap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w800, color: on ? scheme.onPrimary : scheme.onSurface),
            ),
          ),
        ),
      ),
    );

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        children: [chip('All pets', selected == null, () => onSelect(null)), for (final s in Species.values) chip('${s.emoji}  ${s.label}', selected == s, () => onSelect(selected == s ? null : s))],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.size, required this.tooltip, this.onTap, this.filled = false});

  final IconData icon;
  final double size;
  final String tooltip;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onTap != null;
    return Tooltip(
      message: tooltip,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1 : .35,
        child: Material(
          color: filled ? scheme.primary : scheme.surfaceContainerLow,
          shape: CircleBorder(side: filled ? BorderSide.none : BorderSide(color: scheme.outlineVariant.withValues(alpha: .6))),
          elevation: filled ? 6 : 0,
          shadowColor: scheme.primary.withValues(alpha: .4),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(icon, size: size * .44, color: filled ? scheme.onPrimary : (icon == Icons.close_rounded ? scheme.onSurface : scheme.primary)),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoMatches extends StatelessWidget {
  const _NoMatches({required this.onClear});
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🔍', style: TextStyle(fontSize: 64)),
        const SizedBox(height: 16),
        Text('No names match', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text('Try fewer filters, or add the Inventive style for endless new names.', textAlign: TextAlign.center, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 20),
        FilledButton.tonal(onPressed: onClear, child: const Text('Clear filters')),
      ],
    );
  }
}

/// A heart that pops and fades over the card when you like a name
class _HeartBurst extends StatelessWidget {
  const _HeartBurst();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOut,
      builder: (context, t, _) => Center(
        child: Opacity(
          opacity: (1 - t).clamp(0, 1),
          child: Transform.scale(
            scale: .6 + t * .9,
            child: const Icon(Icons.favorite_rounded, color: brand, size: 120),
          ),
        ),
      ),
    );
  }
}
