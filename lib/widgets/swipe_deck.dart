import 'dart:math';

import 'package:flutter/material.dart';

import '../models/pet_name.dart';
import '../state/deck_store.dart';
import '../theme.dart';
import 'name_card.dart';

/// The top card follows your finger; flick it right to like or left to skip.
/// Buttons call [SwipeDeckState.fling] so they animate the same way.
class SwipeDeck extends StatefulWidget {
  const SwipeDeck({super.key, required this.current, required this.next, required this.onDecide, required this.isLiked});

  final PetName current;
  final PetName? next;
  final void Function(Verdict) onDecide;
  final bool Function(PetName) isLiked;

  @override
  State<SwipeDeck> createState() => SwipeDeckState();
}

class SwipeDeckState extends State<SwipeDeck> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 280));
  Offset _drag = Offset.zero;
  Animation<Offset>? _animation;
  Verdict? _leaving;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() => _drag = _animation!.value));
    _controller.addStatusListener((status) {
      if (status != AnimationStatus.completed) return;
      final verdict = _leaving;
      _leaving = null;
      setState(() => _drag = Offset.zero);
      if (verdict != null) widget.onDecide(verdict);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateTo(Offset target, {Verdict? verdict}) {
    _leaving = verdict;
    _animation = Tween(begin: _drag, end: target).animate(CurvedAnimation(parent: _controller, curve: verdict == null ? Curves.elasticOut : Curves.easeIn));
    _controller.duration = Duration(milliseconds: verdict == null ? 500 : 260);
    _controller.forward(from: 0);
  }

  /// Throws the top card off screen
  void fling(Verdict verdict) {
    if (_controller.isAnimating) return;
    final width = MediaQuery.sizeOf(context).width;
    _animateTo(Offset(verdict == Verdict.like ? width * 1.4 : -width * 1.4, _drag.dy + 40), verdict: verdict);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final progress = (_drag.dx / (box.maxWidth * .4)).clamp(-1.0, 1.0);
        final angle = progress * pi / 14;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            if (widget.next != null)
              Positioned.fill(
                child: Transform.scale(
                  scale: .94 + .06 * progress.abs(),
                  child: Opacity(
                    opacity: .6 + .4 * progress.abs(),
                    child: NameCard(key: ValueKey(widget.next!.name), name: widget.next!),
                  ),
                ),
              ),
            Positioned.fill(
              child: GestureDetector(
                onPanUpdate: (d) {
                  if (_controller.isAnimating) return;
                  setState(() => _drag += d.delta);
                },
                onPanEnd: (d) {
                  if (_controller.isAnimating) return;
                  final vx = d.velocity.pixelsPerSecond.dx;
                  if (_drag.dx > box.maxWidth * .3 || vx > 900) {
                    fling(Verdict.like);
                  } else if (_drag.dx < -box.maxWidth * .3 || vx < -900) {
                    fling(Verdict.skip);
                  } else {
                    _animateTo(Offset.zero);
                  }
                },
                child: Transform.translate(
                  offset: _drag,
                  child: Transform.rotate(
                    angle: angle,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: NameCard(key: ValueKey(widget.current.name), name: widget.current, liked: widget.isLiked(widget.current)),
                        ),
                        _Stamp(text: 'LIKE', color: brand, angle: -.25, alignment: Alignment.topLeft, opacity: progress.clamp(0.0, 1.0)),
                        _Stamp(text: 'NOPE', color: const Color(0xFF8A93A6), angle: .25, alignment: Alignment.topRight, opacity: (-progress).clamp(0.0, 1.0)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Stamp extends StatelessWidget {
  const _Stamp({required this.text, required this.color, required this.angle, required this.alignment, required this.opacity});

  final String text;
  final Color color;
  final double angle;
  final Alignment alignment;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    if (opacity <= 0) return const SizedBox.shrink();
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Align(
          alignment: alignment,
          child: Opacity(
            opacity: opacity,
            child: Transform.rotate(
              angle: angle,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: color, width: 4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  text,
                  style: TextStyle(color: color, fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: 2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
