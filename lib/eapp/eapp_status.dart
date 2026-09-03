import 'package:flutter/material.dart';

import '../const.dart';

/// Doc 26 — Layer B: workflow status after Submit. Never mixed with the
/// wizard's own step progress (Layer A), which lives only inside the
/// wizard while a Draft is being filled.
enum EappStatus { draft, submitted, correction, approved, rejected }

extension EappStatusX on EappStatus {
  String get label => switch (this) {
    EappStatus.draft => 'Draft',
    EappStatus.submitted => 'Submitted',
    EappStatus.correction => 'Mark for Correction',
    EappStatus.approved => 'Approved',
    EappStatus.rejected => 'Rejected',
  };

  /// Doc 26 §6 — "what's next" one-liner used on the App tracker row.
  String get whatsNext => switch (this) {
    EappStatus.draft => 'Resume wizard to finish',
    EappStatus.submitted => 'Waiting on underwriting',
    EappStatus.correction => 'Needs a fix from you',
    EappStatus.approved => 'Ready to convert / view policy',
    EappStatus.rejected => 'Closed · read reason',
  };

  /// Doc 26 §3 status dictionary pill colors (bg, fg) — matches the
  /// existing status-pill palette used by policies/tasks in this app.
  (Color, Color) get pillColors => switch (this) {
    EappStatus.draft => (kAppColors.border, kAppColors.textSecondary),
    EappStatus.submitted => (kAppColors.infoLight, kAppColors.infoText),
    EappStatus.correction => (kAppColors.warningLight, kAppColors.warningText),
    EappStatus.approved => (kAppColors.successLight, kAppColors.successText),
    EappStatus.rejected => (kAppColors.roseLight, kAppColors.roseAccent),
  };

  IconData get icon => switch (this) {
    EappStatus.draft => Icons.edit_note,
    EappStatus.submitted => Icons.send_outlined,
    EappStatus.correction => Icons.flag_outlined,
    EappStatus.approved => Icons.check_circle_outline,
    EappStatus.rejected => Icons.cancel_outlined,
  };
}
