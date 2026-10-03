import 'package:flutter/material.dart';

/// Keeps list pages readable on wide screens
class PageWidth extends StatelessWidget {
  const PageWidth({super.key, required this.child, this.max = 760});
  final Widget child;
  final double max;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: max),
      child: child,
    ),
  );
}
