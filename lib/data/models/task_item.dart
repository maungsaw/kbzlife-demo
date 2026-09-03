/// FR-07 §4: two permission tiers of status. Agents may only reach
/// pending/inProgress/completed/cancelled; only a Manager can close a
/// Completed task to `done` (§2.1 — "exclusively authorized to review
/// submitted proof and transition a task from Completed to Done").
enum TaskStatus { pending, inProgress, completed, cancelled, done, overdue }

/// Doc 21/76 — task type vocabulary: `Recruitment` was renamed to
/// `Leave appointment`; `On-Boarding` is a distinct type with its own
/// form body (this prototype keeps the type only, not the full tabs).
enum TaskType {
  meeting,
  call,
  onboarding,
  leaveAppointment,
  servicing,
  eapp,
  other,
  followUp,
}

extension TaskTypeX on TaskType {
  String get label => switch (this) {
    TaskType.meeting => 'Meeting',
    TaskType.call => 'Call',
    TaskType.onboarding => 'On-Boarding',
    TaskType.leaveAppointment => 'Leave appointment',
    TaskType.servicing => 'Servicing',
    TaskType.eapp => 'e-App',
    TaskType.other => 'Other',
    TaskType.followUp => throw UnimplementedError(),
  };
}

/// Doc 76 — On-Boarding task type payload: Agent Info tab fields plus a
/// Training Detail answer map (dropdown label -> selected option). Kept
/// as prototype-only data; nothing here calls a Core license API.
class OnboardingDetail {
  const OnboardingDetail({
    required this.agentName,
    this.nrcOrPassport = '',
    this.phone = '',
    this.stateRegion = 'Yangon',
    this.address = '',
    this.joinDate,
    this.training = const {},
  });

  final String agentName;
  final String nrcOrPassport;
  final String phone;
  final String stateRegion;
  final String address;
  final DateTime? joinDate;

  /// e.g. `{'Licensing Training': 'Not started', 'Mock Test': 'Not taken'}`.
  final Map<String, String> training;

  OnboardingDetail copyWith({
    String? agentName,
    String? nrcOrPassport,
    String? phone,
    String? stateRegion,
    String? address,
    DateTime? joinDate,
    Map<String, String>? training,
  }) => OnboardingDetail(
    agentName: agentName ?? this.agentName,
    nrcOrPassport: nrcOrPassport ?? this.nrcOrPassport,
    phone: phone ?? this.phone,
    stateRegion: stateRegion ?? this.stateRegion,
    address: address ?? this.address,
    joinDate: joinDate ?? this.joinDate,
    training: training ?? this.training,
  );
}

/// BRD Section 6 — Task Management priority vocabulary (separate from the
/// legacy [TaskItem.highPriority] flag, kept for the calendar badge).
enum TaskPriority { low, medium, high, urgent }

extension TaskPriorityX on TaskPriority {
  String get label => switch (this) {
    TaskPriority.low => 'Low',
    TaskPriority.medium => 'Medium',
    TaskPriority.high => 'High',
    TaskPriority.urgent => 'Urgent',
  };
}

class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    required this.dueAt,
    required this.status,
    this.highPriority = false,
    this.clientName,
    this.assignedBy = 'Manager',
    this.type = TaskType.other,
    this.onboarding,
    this.description,
    this.embeddedLink,
    this.priority,
    this.reporter,
    this.department,
    this.startDate,
    this.completionDate,
    this.attachment,
    this.progress,
  });

  final String id;
  final String title;
  final DateTime dueAt;
  final TaskStatus status;
  final bool highPriority;
  final String? clientName;

  /// FR-07 §2.2: agents cannot edit Title/Schedule/Scope — only status —
  /// so the UI always shows who set the task, never lets it be renamed.
  final String assignedBy;
  final TaskType type;

  /// Doc 76 — only set when [type] is `TaskType.onboarding`.
  final OnboardingDetail? onboarding;

  // --- BRD Section 6 additions ----------------------------------------
  /// Task Description — rich text in the BRD; plain multiline here.
  final String? description;
  final String? embeddedLink;
  final TaskPriority? priority;

  /// Reporter/Requester — who raised the task (distinct from [assignedBy],
  /// which is the manager who scheduled/owns it).
  final String? reporter;
  final String? department;

  /// Start Date, distinct from the existing [dueAt] (Due Date).
  final DateTime? startDate;
  final DateTime? completionDate;
  final String? attachment;

  /// 0-100, optional.
  final int? progress;

  TaskItem copyWith({TaskStatus? status}) => TaskItem(
    id: id,
    title: title,
    dueAt: dueAt,
    status: status ?? this.status,
    highPriority: highPriority,
    clientName: clientName,
    assignedBy: assignedBy,
    type: type,
    onboarding: onboarding,
    description: description,
    embeddedLink: embeddedLink,
    priority: priority,
    reporter: reporter,
    department: department,
    startDate: startDate,
    completionDate: completionDate,
    attachment: attachment,
    progress: progress,
  );
}
