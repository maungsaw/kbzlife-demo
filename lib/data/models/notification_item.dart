enum NotificationKind { premiumDue, renewal, announcement, task, system }

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.kind,
    required this.receivedAt,
    this.unread = true,
    this.done = false,
    this.snoozedUntil,
  });

  final String id;
  final String title;
  final String body;
  final NotificationKind kind;
  final DateTime receivedAt;
  final bool unread;
  final bool done;
  final DateTime? snoozedUntil;

  bool get isSnoozed => snoozedUntil != null && snoozedUntil!.isAfter(DateTime.now());

  NotificationItem copyWith({bool? unread, bool? done, DateTime? snoozedUntil, bool clearSnooze = false}) =>
      NotificationItem(
        id: id,
        title: title,
        body: body,
        kind: kind,
        receivedAt: receivedAt,
        unread: unread ?? this.unread,
        done: done ?? this.done,
        snoozedUntil: clearSnooze ? null : (snoozedUntil ?? this.snoozedUntil),
      );
}
