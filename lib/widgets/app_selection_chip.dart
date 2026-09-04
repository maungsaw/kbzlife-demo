import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../const.dart';
import 'app_text.dart';

class AppSelectionChip extends ConsumerStatefulWidget {
  const AppSelectionChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;

  @override
  ConsumerState<AppSelectionChip> createState() => _AppSelectionChipState();
}

class _AppSelectionChipState extends ConsumerState<AppSelectionChip> {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: widget.selected,
      label: widget.label,
      child: ChoiceChip(
        label: Text(widget.label),
        selected: widget.selected,
        onSelected: widget.onSelected,
        showCheckmark: true,
        checkmarkColor: Colors.white,
        avatar: widget.icon == null
            ? null
            : Icon(widget.icon, size: context.iconBase),
        selectedColor: context.colors.primaryColor,
        backgroundColor: context.colors.paper,
        side: BorderSide(
          color: widget.selected
              ? context.colors.primaryColor
              : context.colors.primaryColor.withValues(alpha: 0.10),
          width: 1,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: TextStyle(
          color: widget.selected
              ? Colors.white
              : context.colors.primaryColor.withValues(alpha: 0.68),
          fontWeight: AppType.strong,
          fontSize: AppType.label,
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
