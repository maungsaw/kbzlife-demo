/// BRD Section 5 — Announcement field spec.
enum AnnouncementStatus { draft, published, expired }

extension AnnouncementStatusX on AnnouncementStatus {
  String get label => switch (this) {
        AnnouncementStatus.draft => 'Draft',
        AnnouncementStatus.published => 'Published',
        AnnouncementStatus.expired => 'Expired',
      };
}

enum AnnouncementType { general, important, alert }

extension AnnouncementTypeX on AnnouncementType {
  String get label => switch (this) {
        AnnouncementType.general => 'General',
        AnnouncementType.important => 'Important',
        AnnouncementType.alert => 'Alert',
      };
}

enum AnnouncementPriority { low, medium, high, urgent }

extension AnnouncementPriorityX on AnnouncementPriority {
  String get label => switch (this) {
        AnnouncementPriority.low => 'Low',
        AnnouncementPriority.medium => 'Medium',
        AnnouncementPriority.high => 'High',
        AnnouncementPriority.urgent => 'Urgent',
      };
}

class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.postedAt,
    this.imageUrl,
    this.linkLabel,
    this.linkUrl,
    this.type,
    this.category,
    this.status = AnnouncementStatus.published,
    this.publishDate,
    this.expiryDate,
    this.targetAudience = 'All agents',
    this.priority = AnnouncementPriority.medium,
    this.attachment,
  });

  final String id;
  final String title;

  /// Description — plain multiline text stands in for rich text here.
  final String body;
  final DateTime postedAt;
  final String? imageUrl;

  /// Embedded Links (optional URL).
  final String? linkLabel;
  final String? linkUrl;

  final AnnouncementType? type;
  final String? category;
  final AnnouncementStatus status;
  final DateTime? publishDate;
  final DateTime? expiryDate;
  final String targetAudience;
  final AnnouncementPriority priority;

  /// Attachment (optional media) — filename only in this mock prototype.
  final String? attachment;
}
