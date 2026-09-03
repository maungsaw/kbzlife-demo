import 'eapp_status.dart';

/// Doc 26 — one entry in a single application's Layer B event spine
/// (§5 timeline UX rules: full spine always shown, timestamps read as
/// "Core said this happened").
class EappTimelineEvent {
  const EappTimelineEvent({
    required this.status,
    required this.at,
    required this.actor,
    this.note,
  });
  final EappStatus status;
  final DateTime at;
  final String actor;
  final String? note;
}

/// Doc 26 — a submitted (or draft) application as it appears on the
/// App tracker + status detail. UI-only mock data — no backend.
class EappApplication {
  const EappApplication({
    required this.id,
    required this.holderName,
    required this.productName,
    required this.ref,
    required this.status,
    required this.draftStep,
    required this.history,
    this.correctionReason,
    this.rejectionReason,
  });

  final String id;
  final String holderName;
  final String productName;
  final String ref;
  final EappStatus status;

  /// Layer A step to resume at — only meaningful while [status] is
  /// draft or correction (doc 26 §2: step numbers leave the list once
  /// truly submitted and living in Layer B).
  final int draftStep;

  final List<EappTimelineEvent> history;
  final String? correctionReason;
  final String? rejectionReason;

  EappTimelineEvent get latestEvent => history.last;
}

final mockEappApplications = <EappApplication>[
  EappApplication(
    id: 'app-1',
    holderName: 'Daw Hla Hla Win',
    productName: 'KBZ Life Secure',
    ref: 'EA-10231',
    status: EappStatus.correction,
    draftStep: 2,
    correctionReason: 'NRC photo is blurred — please rescan the front side.',
    history: [
      EappTimelineEvent(
        status: EappStatus.draft,
        at: DateTime(2026, 8, 18, 9, 40),
        actor: 'You',
      ),
      EappTimelineEvent(
        status: EappStatus.submitted,
        at: DateTime(2026, 8, 18, 10, 5),
        actor: 'You',
      ),
      EappTimelineEvent(
        status: EappStatus.correction,
        at: DateTime(2026, 8, 19, 14, 22),
        actor: 'Underwriting',
        note: 'NRC photo is blurred — please rescan the front side.',
      ),
    ],
  ),
  EappApplication(
    id: 'app-2',
    holderName: 'U Kyaw Zin Htoo',
    productName: 'KBZ Life Family Shield',
    ref: 'EA-10214',
    status: EappStatus.submitted,
    draftStep: 5,
    history: [
      EappTimelineEvent(
        status: EappStatus.draft,
        at: DateTime(2026, 8, 20, 8, 12),
        actor: 'You',
      ),
      EappTimelineEvent(
        status: EappStatus.submitted,
        at: DateTime(2026, 8, 20, 8, 30),
        actor: 'You',
      ),
    ],
  ),
  EappApplication(
    id: 'app-3',
    holderName: 'Ma Su Su Aung',
    productName: 'KBZ Life Education Plan',
    ref: 'EA-10190',
    status: EappStatus.approved,
    draftStep: 5,
    history: [
      EappTimelineEvent(
        status: EappStatus.draft,
        at: DateTime(2026, 8, 10, 9, 0),
        actor: 'You',
      ),
      EappTimelineEvent(
        status: EappStatus.submitted,
        at: DateTime(2026, 8, 10, 9, 20),
        actor: 'You',
      ),
      EappTimelineEvent(
        status: EappStatus.approved,
        at: DateTime(2026, 8, 15, 11, 5),
        actor: 'Underwriting',
        note: 'All checks passed.',
      ),
    ],
  ),
  EappApplication(
    id: 'app-4',
    holderName: 'Ko Zaw Myint',
    productName: 'KBZ Life Secure',
    ref: 'EA-10176',
    status: EappStatus.rejected,
    draftStep: 5,
    rejectionReason:
        'Declared health condition falls outside underwriting appetite.',
    history: [
      EappTimelineEvent(
        status: EappStatus.draft,
        at: DateTime(2026, 8, 5, 13, 0),
        actor: 'You',
      ),
      EappTimelineEvent(
        status: EappStatus.submitted,
        at: DateTime(2026, 8, 5, 13, 15),
        actor: 'You',
      ),
      EappTimelineEvent(
        status: EappStatus.rejected,
        at: DateTime(2026, 8, 9, 16, 40),
        actor: 'Underwriting',
        note: 'Declared health condition falls outside underwriting appetite.',
      ),
    ],
  ),
  EappApplication(
    id: 'app-5',
    holderName: 'Daw Ei Ei Phyo',
    productName: 'KBZ Life Retirement Saver',
    ref: 'EA-10240',
    status: EappStatus.draft,
    draftStep: 1,
    history: [
      EappTimelineEvent(
        status: EappStatus.draft,
        at: DateTime(2026, 8, 24, 17, 5),
        actor: 'You',
      ),
    ],
  ),
];
