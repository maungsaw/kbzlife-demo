import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../const.dart';
import '../providers/router_provider.dart';
import '../widgets/app_selection_chip.dart';
import 'model.dart';
import 'data.dart';

class NotificationInboxScreen extends ConsumerStatefulWidget {
  final bool isAuthenticated;
  final String currentUserRole;

  const NotificationInboxScreen({
    super.key,
    this.isAuthenticated = true,
    this.currentUserRole = 'Financial Advisor',
  });

  @override
  ConsumerState<NotificationInboxScreen> createState() =>
      _NotificationInboxScreenState();
}

class _NotificationInboxScreenState
    extends ConsumerState<NotificationInboxScreen> {
  late List<AnnouncementModel> _announcements;
  String _selectedTypeFilter = 'All';

  @override
  void initState() {
    super.initState();
    _announcements = MockAnnouncementRepository.getMockAnnouncements();
  }

  int get _unreadCount {
    return _announcements.where((item) => !item.isRead).length;
  }

  List<AnnouncementModel> get _filteredList {
    return _announcements.where((item) {
      if (item.isPrivate && !widget.isAuthenticated) return false;

      if (item.isPrivate && item.targetRoles.isNotEmpty) {
        final bool isAuthorizedRole = item.targetRoles.contains(
          widget.currentUserRole,
        );
        if (!isAuthorizedRole) return false;
      }

      if (_selectedTypeFilter == 'Unread') return !item.isRead;
      if (_selectedTypeFilter == 'Read') return item.isRead;
      if (_selectedTypeFilter == 'All') return true;

      return item.type.toLowerCase() == _selectedTypeFilter.toLowerCase();
    }).toList();
  }

  void _markAllAsRead() {
    setState(() {
      for (var item in _announcements) {
        item.isRead = true;
      }
    });
  }

  void _onAnnouncementTap(AnnouncementModel item) {
    setState(() => item.isRead = true);
    context.push(RoutePaths.announcementDetail, extra: item);
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredList;

    return Scaffold(
      backgroundColor: context.colors.cream,
      appBar: AppBar(
        title: Text(
          'Announcements',
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark all read',
                style: TextStyle(
                  color: context.colors.infoText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: context.colors.textPrimary),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children:
                    [
                      'All',
                      'Unread',
                      'Read',
                      'Important',
                      'Alert',
                      'General',
                    ].map((type) {
                      final isSelected = _selectedTypeFilter == type;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: AppSelectionChip(
                          onSelected: (_) =>
                              setState(() => _selectedTypeFilter = type),
                          label: type,
                          selected: isSelected,
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Text(
                      'No announcements available.',
                      style: TextStyle(color: context.colors.textMuted),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (context, index) =>
                        _buildModernCard(list[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCard(AnnouncementModel item) {
    final bool isUnread = !item.isRead;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUnread ? context.colors.infoLight : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread ? context.colors.infoBorder : context.colors.border,
          width: isUnread ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _onAnnouncementTap(item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isUnread) ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: context.colors.infoText,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    _buildPill(
                      item.type,
                      context.colors.chipBg,
                      context.colors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    _buildPill(
                      item.priority.label,
                      item.priority.color.withValues(alpha: 0.12),
                      item.priority.color,
                    ),
                    const Spacer(),
                    if (item.isPrivate)
                      Icon(
                        Icons.lock_outline,
                        size: context.iconMd,
                        color: context.colors.warningText,
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isUnread ? FontWeight.w800 : FontWeight.w500,
                    color: context.colors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.category,
                      style: TextStyle(
                        fontSize: 12,
                        color: isUnread
                            ? context.colors.infoText
                            : context.colors.muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      item.publishDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPill(String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
