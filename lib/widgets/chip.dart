import 'package:flutter/material.dart';

import '../const.dart';

enum AppIconChipStyle { solid, tinted }

class AppIconChip extends StatelessWidget {
  const AppIconChip({
    super.key,
    required this.icon,
    this.size = 52,
    this.style = AppIconChipStyle.solid,
    this.locked = false,
  });

  final IconData icon;

  final double size;
  final AppIconChipStyle style;
  final bool locked;
  static const _glyphRatio = 0.56;

  @override
  Widget build(BuildContext context) {
    final solid = style == AppIconChipStyle.solid;
    final chip = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.3),
        gradient: solid
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  context.colors.primaryColor,
                  context.colors.secondaryColor,
                ],
              )
            : null,
        color: solid
            ? null
            : context.colors.primaryColor.withValues(alpha: 0.14),
      ),
      child: Icon(
        icon,
        size: size * _glyphRatio,
        color: solid ? Colors.white : context.colors.baltic,
      ),
    );

    if (!locked) return chip;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        chip,
        Positioned(
          right: -4,
          bottom: -4,
          child: Container(
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: context.colors.paper,
              shape: BoxShape.circle,
              // A hairline ring, or the white disc disappears into the
              // pale tile behind it and the lock looks like a smudge.
              border: Border.all(color: context.colors.deepAlpha(0.10)),
            ),
            child: Icon(
              Icons.lock,
              size: size * 0.34,
              color: context.colors.deepAlpha(0.55),
            ),
          ),
        ),
      ],
    );
  }
}
