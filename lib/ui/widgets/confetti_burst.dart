import 'dart:math';

import 'package:flutter/material.dart';

/// Lightweight confetti burst used on the result screen.
///
/// Implemented locally (12 circles flying outward) so the app does not need a
/// dependency for a one-second celebration. Extracted from `result_screen.dart`
/// so it can be reused and adjusted independently.
class ConfettiBurst extends StatefulWidget {
  const ConfettiBurst({
    super.key,
    this.duration = const Duration(milliseconds: 900),
    this.particleCount = 12,
  });

  final Duration duration;
  final int particleCount;

  @override
  State<ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<ConfettiBurst>
    with SingleTickerProviderStateMixin {
  static const List<Color> _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
  ];

  late final AnimationController _ctrl;
  final List<Offset> _targets = [];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..forward();
    final random = Random(DateTime.now().millisecondsSinceEpoch);
    for (var i = 0; i < widget.particleCount; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final distance = 60 + random.nextDouble() * 80;
      _targets.add(Offset(cos(angle) * distance, sin(angle) * distance));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 220,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final t = Curves.easeOut.transform(_ctrl.value);
          return Stack(
            children: [
              for (var i = 0; i < _targets.length; i++)
                Positioned(
                  left: 110 + (_targets[i] * t).dx,
                  top: 110 + (_targets[i] * t).dy,
                  child: Opacity(
                    opacity: 1.0 - t,
                    child: Container(
                      width: 10.0 * (1.0 - 0.4 * t),
                      height: 10.0 * (1.0 - 0.4 * t),
                      decoration: BoxDecoration(
                        color: _colors[i % _colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
