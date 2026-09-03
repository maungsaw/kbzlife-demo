import 'dart:ui';

enum AnnouncementPriority { low, medium, high, urgent }

extension PriorityExtension on AnnouncementPriority {
  String get label => name.toUpperCase();
  Color get color {
    switch (this) {
      case AnnouncementPriority.urgent:
        return const Color(0xFFEF4444);
      case AnnouncementPriority.high:
        return const Color(0xFFF97316);
      case AnnouncementPriority.medium:
        return const Color(0xFF3B82F6);
      case AnnouncementPriority.low:
        return const Color(0xFF6B7280);
    }
  }
}

class AnnouncementModel {
  final String id;
  final String title;
  final String bodyContent;
  final String imageUrl;
  final String embeddedLink;
  final String type;
  final String category;
  final AnnouncementPriority priority;
  final String publishDate;
  final bool isPrivate;
  final List<String> targetRoles;
  bool isRead;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.bodyContent,
    required this.imageUrl,
    required this.embeddedLink,
    required this.type,
    required this.category,
    required this.priority,
    required this.publishDate,
    required this.isPrivate,
    this.targetRoles = const [],
    this.isRead = false,
  });
}
