import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/router_provider.dart';
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

class _NotificationInboxScreenState extends ConsumerState<NotificationInboxScreen> {
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Announcements',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
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
                        child: ChoiceChip(
                          label: Text(type),
                          selected: isSelected,
                          selectedColor: const Color(0xFF1E293B),
                          backgroundColor: const Color(0xFFF1F5F9),
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide.none,
                          ),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF475569),
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            fontSize: 13,
                          ),
                          onSelected: (_) =>
                              setState(() => _selectedTypeFilter = type),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const Center(
                    child: Text(
                      'No announcements available.',
                      style: TextStyle(color: Color(0xFF94A3B8)),
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
        color: isUnread ? const Color(0xFFF0F9FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isUnread ? const Color(0xFFBAE6FD) : const Color(0xFFE2E8F0),
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
                        decoration: const BoxDecoration(
                          color: Color(0xFF0284C7),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    _buildPill(
                      item.type,
                      const Color(0xFFF1F5F9),
                      const Color(0xFF334155),
                    ),
                    const SizedBox(width: 8),
                    _buildPill(
                      item.priority.label,
                      item.priority.color.withValues(alpha: 0.12),
                      item.priority.color,
                    ),
                    const Spacer(),
                    if (item.isPrivate)
                      const Icon(
                        Icons.lock_outline,
                        size: 14,
                        color: Color(0xFFF97316),
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
                    color: const Color(0xFF0F172A),
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
                            ? const Color(0xFF0369A1)
                            : const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      item.publishDate,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
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
