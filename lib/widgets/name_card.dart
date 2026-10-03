import 'package:flutter/material.dart';

import '../models/pet_name.dart';
import '../theme.dart';

/// A flat color per style, so each card has its own mood
Color styleColor(NameStyle style, Brightness b) {
  const light = {
    NameStyle.cute: Color(0xFFFFE3EC),
    NameStyle.classic: Color(0xFFE6ECF7),
    NameStyle.funny: Color(0xFFFFF1C9),
    NameStyle.food: Color(0xFFFFE6D6),
    NameStyle.nature: Color(0xFFE2F2E1),
    NameStyle.mythic: Color(0xFFEDE5FA),
    NameStyle.cosmic: Color(0xFFE0E7FF),
    NameStyle.tough: Color(0xFFE9E6E3),
    NameStyle.fancy: Color(0xFFF7E8F4),
    NameStyle.inventive: Color(0xFFDDF4F3),
  };
  const dark = {
    NameStyle.cute: Color(0xFF3B2632),
    NameStyle.classic: Color(0xFF253047),
    NameStyle.funny: Color(0xFF3A3322),
    NameStyle.food: Color(0xFF3D2C22),
    NameStyle.nature: Color(0xFF233528),
    NameStyle.mythic: Color(0xFF30284A),
    NameStyle.cosmic: Color(0xFF232C4D),
    NameStyle.tough: Color(0xFF302D2B),
    NameStyle.fancy: Color(0xFF3A2638),
    NameStyle.inventive: Color(0xFF1F3A39),
  };
  return (b == Brightness.dark ? dark : light)[style]!;
}

class NameCard extends StatelessWidget {
  const NameCard({super.key, required this.name, this.liked = false});

  final PetName name;
  final bool liked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = styleColor(name.style, theme.brightness);
    final muted = theme.colorScheme.onSurface.withValues(alpha: .7);
    final species = name.species.isEmpty ? 'Any pet' : name.species.map((s) => s.emoji).join(' ');

    return Container(
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(32)),
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Pill(text: '${name.style.emoji}  ${name.style.label}'),
              const Spacer(),
              if (liked) const Icon(Icons.favorite, color: brand),
            ],
          ),
          const Spacer(),
          Text(name.style.emoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 18),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(name.name, style: nameStyle(context, size: 52), maxLines: 1),
          ),
          const SizedBox(height: 10),
          Text(name.meaning, style: theme.textTheme.titleMedium?.copyWith(color: muted, height: 1.35)),
          const Spacer(),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Pill(
                text: name.gender == Gender.neutral
                    ? '⚥  Any gender'
                    : name.gender == Gender.male
                    ? '♂  Boy'
                    : '♀  Girl',
              ),
              _Pill(text: species),
              _Pill(text: '${name.name.replaceAll(' ', '').length} letters'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: scheme.surface.withValues(alpha: .7), borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
    );
  }
}
