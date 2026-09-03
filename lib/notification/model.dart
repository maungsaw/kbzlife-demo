import 'dart:ui';

import '../const.dart';

enum AnnouncementPriority { low, medium, high, urgent }

extension PriorityExtension on AnnouncementPriority {
  String get label => name.toUpperCase();
  Color get color {
    switch (this) {
      case AnnouncementPriority.urgent:
        return kAppColors.danger;
      case AnnouncementPriority.high:
        return kAppColors.warningText;
      case AnnouncementPriority.medium:
        return kAppColors.infoText;
      case AnnouncementPriority.low:
        return kAppColors.muted;
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
