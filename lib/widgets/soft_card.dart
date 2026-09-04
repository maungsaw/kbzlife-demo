import 'package:flutter/material.dart';

import '../const.dart';
import 'app_text.dart';

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
    // The surface is a Material, not a DecoratedBox: anything inside that
    // paints its own background or ink (ListTile, Checkbox/RadioListTile,
    // InkWell) needs the nearest Material to be this card, or Flutter
    // asserts that those effects would be painted behind it.
    return Material(
      color: context.colors.paper,
      borderRadius: BorderRadius.circular(AppRadii.card),
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? Padding(padding: padding, child: child)
          : InkWell(
              onTap: onTap,
              child: Padding(padding: padding, child: child),
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
        fontSize: AppType.caption,
        fontWeight: AppType.strong,
        letterSpacing: 1.1,
        color: context.colors.deepAlpha(0.55),
      ),
    );
  }
}
