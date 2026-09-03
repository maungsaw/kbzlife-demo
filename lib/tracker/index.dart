import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../const.dart';
import '../providers/router_provider.dart';

enum ApplicationStatus {
  draft,
  submitted,
  underwriting,
  markForCorrection,
  approved,
  rejected,
}

extension ApplicationStatusExtension on ApplicationStatus {
  String get label {
    switch (this) {
      case ApplicationStatus.draft:
        return 'Draft';
      case ApplicationStatus.submitted:
        return 'Submitted';
      case ApplicationStatus.underwriting:
        return 'Underwriting';
      case ApplicationStatus.markForCorrection:
        return 'Mark for Correction';
      case ApplicationStatus.approved:
        return 'Approved';
      case ApplicationStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case ApplicationStatus.draft:
        return AppColors.statusDraft;
      case ApplicationStatus.submitted:
        return AppColors.statusSubmitted;
      case ApplicationStatus.underwriting:
        return AppColors.statusUnderwriting;
      case ApplicationStatus.markForCorrection:
        return AppColors.statusCorrection;
      case ApplicationStatus.approved:
        return AppColors.statusApproved;
      case ApplicationStatus.rejected:
        return AppColors.statusRejected;
    }
  }

  IconData get icon {
    switch (this) {
      case ApplicationStatus.draft:
        return Icons.edit_note_rounded;
      case ApplicationStatus.submitted:
        return Icons.send_rounded;
      case ApplicationStatus.underwriting:
        return Icons.hourglass_top_rounded;
      case ApplicationStatus.markForCorrection:
        return Icons.assignment_late_rounded;
      case ApplicationStatus.approved:
        return Icons.check_circle_rounded;
      case ApplicationStatus.rejected:
        return Icons.cancel_rounded;
    }
  }
}

class ApplicationItem {
  final String proposalId;
  final String applicantName;
  final String planName;
  final ApplicationStatus status;
  final String updatedAt;
  final String agentName;
  final String applicationDate;

  ApplicationItem({
    required this.proposalId,
    required this.applicantName,
    required this.planName,
    required this.status,
    required this.updatedAt,
    required this.agentName,
    required this.applicationDate,
  });
}

class ApplicationTrackerListScreen extends ConsumerStatefulWidget {
  const ApplicationTrackerListScreen({super.key});

  @override
  ConsumerState<ApplicationTrackerListScreen> createState() =>
      _ApplicationTrackerListScreenState();
}

class _ApplicationTrackerListScreenState
    extends ConsumerState<ApplicationTrackerListScreen> {
  ApplicationStatus? _selectedStatusFilter;
  final TextEditingController _searchController = TextEditingController();

  final List<ApplicationItem> _allApplications = [
    ApplicationItem(
      proposalId: 'APP-2026-00821',
      applicantName: 'Aung Aung',
      planName: 'Universal Life',
      status: ApplicationStatus.markForCorrection,
      updatedAt: 'Updated 2 mins ago',
      agentName: 'Maung Maung',
      applicationDate: '30 Aug 2026',
    ),
    ApplicationItem(
      proposalId: 'APP-2026-00820',
      applicantName: 'Su Su',
      planName: 'Universal Life',
      status: ApplicationStatus.submitted,
      updatedAt: 'Updated just now',
      agentName: 'Maung Maung',
      applicationDate: '30 Aug 2026',
    ),
    ApplicationItem(
      proposalId: 'APP-2026-00819',
      applicantName: 'Daw Khin',
      planName: 'Whole Life',
      status: ApplicationStatus.approved,
      updatedAt: 'Updated 1 hour ago',
      agentName: 'Maung Maung',
      applicationDate: '29 Aug 2026',
    ),
    ApplicationItem(
      proposalId: 'APP-2026-00818',
      applicantName: 'U Kyaw',
      planName: 'Term Life',
      status: ApplicationStatus.rejected,
      updatedAt: 'Updated 3 hours ago',
      agentName: 'Maung Maung',
      applicationDate: '28 Aug 2026',
    ),
    ApplicationItem(
      proposalId: 'APP-2026-00817',
      applicantName: 'Daw Mya',
      planName: 'Universal Life',
      status: ApplicationStatus.draft,
      updatedAt: 'Updated yesterday',
      agentName: 'Maung Maung',
      applicationDate: '27 Aug 2026',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredApps = _allApplications.where((app) {
      if (_selectedStatusFilter != null &&
          app.status != _selectedStatusFilter) {
        return false;
      }
      final query = _searchController.text.toLowerCase();
      if (query.isNotEmpty) {
        return app.proposalId.toLowerCase().contains(query) ||
            app.applicantName.toLowerCase().contains(query);
      }
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: const [
            Text('Application Tracker'),
            SizedBox(height: 2),
            Text(
              '• Last synced just now',
              style: TextStyle(fontSize: 10, color: AppColors.primaryColor),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.autorenew_rounded,
              color: AppColors.primaryColor,
              size: 20,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Search by ID, Name or NRC',
                            prefixIcon: const Icon(
                              Icons.search,
                              size: 18,
                              color: AppColors.muted,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.zero,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: AppColors.border,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.filter_list_rounded,
                        color: AppColors.accentNavy,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _filterChip('All', _selectedStatusFilter == null, () {
                      setState(() => _selectedStatusFilter = null);
                    }),
                    _filterChip(
                      'Draft',
                      _selectedStatusFilter == ApplicationStatus.draft,
                      () => setState(
                        () => _selectedStatusFilter = ApplicationStatus.draft,
                      ),
                    ),
                    _filterChip(
                      'Submitted',
                      _selectedStatusFilter == ApplicationStatus.submitted,
                      () => setState(
                        () =>
                            _selectedStatusFilter = ApplicationStatus.submitted,
                      ),
                    ),
                    _filterChip(
                      'Correction',
                      _selectedStatusFilter ==
                          ApplicationStatus.markForCorrection,
                      () => setState(
                        () => _selectedStatusFilter =
                            ApplicationStatus.markForCorrection,
                      ),
                    ),
                    _filterChip(
                      'Approved',
                      _selectedStatusFilter == ApplicationStatus.approved,
                      () => setState(
                        () =>
                            _selectedStatusFilter = ApplicationStatus.approved,
                      ),
                    ),
                    _filterChip(
                      'Rejected',
                      _selectedStatusFilter == ApplicationStatus.rejected,
                      () => setState(
                        () =>
                            _selectedStatusFilter = ApplicationStatus.rejected,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filteredApps.length} Applications',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.muted,
                      ),
                    ),
                    Row(
                      children: const [
                        Text(
                          'Sort',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: AppColors.muted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredApps.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final app = filteredApps[index];
                    return Material(
                      color: Colors.white,
                      child: ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: app.status.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            app.status.icon,
                            size: 18,
                            color: app.status.color,
                          ),
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              app.proposalId,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.accentNavy,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: app.status.color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                app.status.label,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: app.status.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${app.applicantName}\n${app.planName}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.muted,
                                ),
                              ),
                              Text(
                                app.updatedAt,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: AppColors.muted,
                        ),
                        onTap: () {
                          context.push(RoutePaths.trackerDetail.replaceFirst(':status', app.status.name));
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primaryColor : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : AppColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}
