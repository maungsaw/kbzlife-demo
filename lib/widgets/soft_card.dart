import 'package:flutter/material.dart';

import '../const.dart';

/// Mirrors the prototype's `.soft-card` — paper surface with a soft,
/// colored (not default grey) shadow.
class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(AppRadii.card),
        // Layered shadow reads as "lifted off the grey page": a tight,
        // darker shadow hugs the card for contact depth, a broader soft
        // one behind it carries the ambient lift. No border needed — the
        // card is pure white against a grey canvas, so the shadow alone
        // reads as an edge (unlike the previous milk-on-white palette,
        // where a white card needed its own border to read against a
        // near-identical background).
        boxShadow: [
          BoxShadow(
            color: AppColors.deepAlpha(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: AppColors.deepAlpha(0.10),
            blurRadius: 28,
            spreadRadius: -4,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadii.card),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.card),
        onTap: onTap,
        child: card,
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
        color: AppColors.deepAlpha(0.55),
      ),
    );
  }
}
