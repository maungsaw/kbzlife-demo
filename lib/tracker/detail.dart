import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../const.dart';
import 'index.dart';

/// 1. Timeline Node Model mapping to your backend/local data dates
class StatusTimelineNode {
  final ApplicationStatus status;
  final String title;
  final String subtitle;
  final DateTime? timestamp;

  const StatusTimelineNode({
    required this.status,
    required this.title,
    required this.subtitle,
    this.timestamp,
  });
}

class ApplicationTrackerDetailScreen extends ConsumerStatefulWidget {
  final ApplicationStatus status;
  final List<StatusTimelineNode>? customTimelineNodes;

  const ApplicationTrackerDetailScreen({
    super.key,
    this.status = ApplicationStatus.markForCorrection,
    this.customTimelineNodes,
  });

  @override
  ConsumerState<ApplicationTrackerDetailScreen> createState() =>
      _ApplicationTrackerDetailScreenState();
}

class _ApplicationTrackerDetailScreenState
    extends ConsumerState<ApplicationTrackerDetailScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _formatTimeTaken(DateTime startTime) {
    final difference = DateTime.now().difference(startTime);
    if (difference.isNegative) return '0m';

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    final List<String> parts = [];
    if (days > 0) parts.add('${days}d');
    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0 || parts.isEmpty) parts.add('${minutes}m');

    return parts.join(' ');
  }

  List<StatusTimelineNode> _buildDynamicTimeline() {
    if (widget.customTimelineNodes != null &&
        widget.customTimelineNodes!.isNotEmpty) {
      return widget.customTimelineNodes!;
    }

    return [
      StatusTimelineNode(
        status: ApplicationStatus.draft,
        title: 'Draft',
        subtitle: 'Application saved as draft',
        timestamp: DateTime(2026, 8, 28, 9, 15),
      ),
      StatusTimelineNode(
        status: ApplicationStatus.submitted,
        title: 'Submitted',
        subtitle: 'Application submitted successfully',
        timestamp: DateTime(2026, 8, 30, 10, 42),
      ),
      StatusTimelineNode(
        status: ApplicationStatus.underwriting,
        title: 'Underwriting',
        subtitle: 'Underwriter review in progress',
        timestamp: DateTime(2026, 8, 30, 11, 5),
      ),
      if (widget.status == ApplicationStatus.markForCorrection)
        StatusTimelineNode(
          status: ApplicationStatus.markForCorrection,
          title: 'Mark for Correction',
          subtitle: 'Additional documents or edits required',
          timestamp: DateTime(2026, 8, 30, 14, 30),
        ),
      if (widget.status == ApplicationStatus.rejected)
        StatusTimelineNode(
          status: ApplicationStatus.rejected,
          title: 'Rejected',
          subtitle: 'Application did not pass verification',
          timestamp: DateTime(2026, 8, 30, 15, 0),
        )
      else
        const StatusTimelineNode(
          status: ApplicationStatus.approved,
          title: 'Approved',
          subtitle: 'Policy issuance ready',
          timestamp: null,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final timelineNodes = _buildDynamicTimeline();
    final currentStatusIndex = timelineNodes.indexWhere(
      (node) => node.status == widget.status,
    );

    return Scaffold(
      backgroundColor: context.colors.cream,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: context.iconLg),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Application Details'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'APP-2026-00821',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: context.colors.accentNavy,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.border.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Universal Life',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: context.colors.muted,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildDynamicBanner(widget.status),
                        const SizedBox(height: 16),
                        _buildSummaryCard(),
                        const SizedBox(height: 20),
                        Text(
                          'Application Progress',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: context.colors.accentNavy,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ...List.generate(timelineNodes.length, (index) {
                          final node = timelineNodes[index];
                          final isLast = index == timelineNodes.length - 1;
                          final bool isCurrent =
                              index == currentStatusIndex ||
                              (currentStatusIndex == -1 && index == 0);
                          final bool isCompleted =
                              currentStatusIndex != -1 &&
                              index < currentStatusIndex;

                          return _buildTimelineItem(
                            node: node,
                            isCurrent: isCurrent,
                            isCompleted: isCompleted,
                            isLast: isLast,
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                _buildBottomFooter(widget.status),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required StatusTimelineNode node,
    required bool isCurrent,
    required bool isCompleted,
    required bool isLast,
  }) {
    final bool isCorrection =
        node.status == ApplicationStatus.markForCorrection;
    final bool isRejected = node.status == ApplicationStatus.rejected;

    Color iconColor = context.colors.border;
    IconData icon = Icons.radio_button_unchecked;

    if (isCorrection) {
      iconColor = context.colors.statusCorrection;
      icon = Icons.warning_rounded;
    } else if (isRejected) {
      iconColor = context.colors.primaryColor;
      icon = Icons.cancel_rounded;
    } else if (isCompleted) {
      iconColor = context.colors.statusApproved;
      icon = Icons.check_circle_rounded;
    }

    final String? durationText = isCurrent && node.timestamp != null
        ? _formatTimeTaken(node.timestamp!)
        : null;

    final Color themeColor = isCorrection
        ? context.colors.statusCorrection
        : isRejected
        ? context.colors.primaryColor
        : context.colors.statusSubmitted;

    return Row(
      crossAxisAlignment: .start,
      children: [
        Column(
          children: [
            if (isCurrent && !isRejected)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                  backgroundColor: themeColor.withValues(alpha: 0.2),
                ),
              )
            else
              Icon(icon, size: context.iconLg, color: iconColor),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: isCompleted
                    ? context.colors.statusApproved
                    : context.colors.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    node.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isCurrent || isCorrection
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: isCurrent ? themeColor : context.colors.accentNavy,
                    ),
                  ),
                  if (isCurrent && durationText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: themeColor.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 9,
                            height: 9,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                themeColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Taking $durationText',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: themeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (node.timestamp != null) ...[
                const SizedBox(height: 2),
                Text(
                  '${node.timestamp!.day} Aug ${node.timestamp!.year}, '
                  '${node.timestamp!.hour.toString().padLeft(2, '0')}:'
                  '${node.timestamp!.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 10, color: context.colors.muted),
                ),
              ],
              if (node.subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  node.subtitle,
                  style: TextStyle(fontSize: 10, color: context.colors.muted),
                ),
              ],
              const SizedBox(height: 14),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDynamicBanner(ApplicationStatus status) {
    Color bannerColor;
    IconData bannerIcon;
    String bannerTitle;
    String bannerMessage;

    switch (status) {
      case ApplicationStatus.markForCorrection:
        bannerColor = context.colors.statusCorrection;
        bannerIcon = Icons.warning_amber_rounded;
        bannerTitle = 'MARK FOR CORRECTION';
        bannerMessage =
            'Action required\nPlease review the requested corrections and resubmit the application.';
        break;
      case ApplicationStatus.approved:
        bannerColor = context.colors.statusApproved;
        bannerIcon = Icons.check_circle_rounded;
        bannerTitle = 'APPROVED';
        bannerMessage = 'Congratulations! The application has been approved.';
        break;
      case ApplicationStatus.rejected:
        bannerColor = context.colors.primaryColor;
        bannerIcon = Icons.cancel_rounded;
        bannerTitle = 'REJECTED';
        bannerMessage =
            'Application was rejected. Please view documents for details.';
        break;
      case ApplicationStatus.underwriting:
        bannerColor = context.colors.statusSubmitted;
        bannerIcon = Icons.hourglass_top_rounded;
        bannerTitle = 'UNDERWRITING';
        bannerMessage =
            'Application is currently under review by our underwriting team.';
        break;
      case ApplicationStatus.submitted:
      default:
        bannerColor = context.colors.statusApproved;
        bannerIcon = Icons.check_circle_rounded;
        bannerTitle = 'SUBMITTED';
        bannerMessage =
            'Your application has been submitted successfully and is under review.';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: bannerColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Icon(bannerIcon, color: bannerColor, size: context.iconLg),
              const SizedBox(width: 8),
              Text(
                bannerTitle,
                style: TextStyle(
                  color: bannerColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            bannerMessage,
            style: TextStyle(
              fontSize: 11,
              height: 1.4,
              color: context.colors.accentNavy,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.colors.border),
      ),
        child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _MetaField(label: 'Policy Holder', value: 'Aung Aung'),
              ),
              Expanded(
                child: _MetaField(
                  label: 'Application Date',
                  value: '30 Aug 2026',
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetaField(label: 'Agent', value: 'Maung Maung'),
              ),
              Expanded(
                child: _MetaField(
                  label: 'Last Updated',
                  value: '30 Aug 2026, 10:42 AM',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomFooter(ApplicationStatus status) {
    final bool isCorrection = status == ApplicationStatus.markForCorrection;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: context.colors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: context.colors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {},
              icon: Icon(
                Icons.description_outlined,
                size: context.iconBase,
                color: context.colors.accentNavy,
              ),
              label: Text(
                'View Documents',
                style: TextStyle(color: context.colors.accentNavy, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: isCorrection
                ? ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {},
                    icon: Icon(Icons.edit, size: context.iconBase, color: Colors.white),
                    label: const Text(
                      'View Corrections',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: context.colors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {},
                    icon: Icon(
                      Icons.share_outlined,
                      size: context.iconBase,
                      color: context.colors.accentNavy,
                    ),
                    label: Text(
                      'Share',
                      style: TextStyle(
                        color: context.colors.accentNavy,
                        fontSize: 12,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MetaField extends StatelessWidget {
  final String label;
  final String value;
  const _MetaField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: context.colors.muted),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: context.colors.accentNavy,
          ),
        ),
      ],
    );
  }
}
