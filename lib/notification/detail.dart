import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../const.dart';

import '../providers/router_provider.dart';
import 'model.dart';

class AnnouncementDetailH5Screen extends ConsumerWidget {
  final AnnouncementModel announcement;

  const AnnouncementDetailH5Screen({super.key, required this.announcement});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: context.colors.cream,
      appBar: AppBar(
        title: Text(
          'Announcement Detail',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: context.colors.textPrimary),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: announcement.isPrivate
                  ? context.colors.warningLight
                  : context.colors.successLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: announcement.isPrivate
                    ? context.colors.warningBorder
                    : context.colors.successAccentLight,
              ),
            ),
            child: Text(
              announcement.isPrivate ? 'PRIVATE' : 'PUBLIC',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: announcement.isPrivate
                    ? context.colors.warningText
                    : context.colors.successText,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.border,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    announcement.category,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  announcement.publishDate,
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              announcement.title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: context.colors.textPrimary,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                announcement.imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: context.colors.chipBg,
                  child: const Center(
                    child: Icon(Icons.broken_image_rounded, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.border),
              ),
              child: Text(
                announcement.bodyContent,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: context.colors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Web Link Action',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: context.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                context.push('${RoutePaths.webview}?url=${Uri.encodeComponent(announcement.embeddedLink)}');
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: context.colors.infoLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.colors.infoBorder),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.language_rounded,
                      color: context.colors.infoText,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Open In-App Web View',
                            style: TextStyle(
                              color: context.colors.infoText,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            announcement.embeddedLink,
                            style: TextStyle(
                              color: context.colors.infoText,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: context.iconMd,
                      color: context.colors.infoText,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
