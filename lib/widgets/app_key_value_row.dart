import 'package:flutter/material.dart';

import 'app_text.dart';

/// A label and its value on one line — the read-out row every form screen
/// uses (step summaries, Review, the success screen).
///
/// The label column is a fixed width so that every row, on every card, in
/// every step, sits on the same vertical rule. Before this widget each
/// screen rolled its own row and none of them lined up.
class AppKeyValueRow extends StatelessWidget {
  const AppKeyValueRow({
    super.key,
    required this.label,
    required this.value,
    this.padding = const EdgeInsets.symmetric(vertical: 5),
  });

  final String label;
  final String value;
  final EdgeInsets padding;

  /// The shared label column width. Exposed so a screen that needs to
  /// indent something under a row can line up with it.
  static const double labelWidth = 130;

  /// Gap between the label column and the value.
  static const double gap = 12;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: labelWidth, child: AppLabelText(label)),
          const SizedBox(width: gap),
          Expanded(child: AppBodyText(value)),
        ],
      ),
    );
  }
}
