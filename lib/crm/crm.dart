import 'package:demo_ui/widgets/tab_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import '../const.dart';
import '../providers/crm_providers.dart';
import '../providers/router_provider.dart';
import '../widgets/app_segmented_tabs.dart';
import 'count_mill.dart';
import 'model.dart';
import 'role_bradge.dart';

class UserDashboardScreen extends ConsumerStatefulWidget {
  final CRMUser? initialUser;
  final CRMRepository repository;

  const UserDashboardScreen({
    super.key,
    this.initialUser,
    required this.repository,
  });

  @override
  ConsumerState<UserDashboardScreen> createState() =>
      _UserDashboardScreenState();
}

class _UserDashboardScreenState extends ConsumerState<UserDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<CRMContactModel> _allContacts = [];

  CRMUser get _currentUser {
    final navStack = ref.watch(
      crmDashboardProvider.select((s) => s.navigationStack),
    );
    return navStack.isNotEmpty
        ? navStack.last
        : CRMUser(id: '', name: '', role: UserRole.fa);
  }

  bool get _hasTeamMembers {
    final navStack = ref.watch(
      crmDashboardProvider.select((s) => s.navigationStack),
    );
    if (navStack.isEmpty) return false;
    return widget.repository.users.any((u) => u.managerId == _currentUser.id);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _initData() {
    final rootUser =
        widget.initialUser ??
        widget.repository.users.firstWhere(
          (u) => u.id == 'usr_dm',
          orElse: () => widget.repository.users.first,
        );
    ref.read(crmDashboardProvider.notifier).pushUser(rootUser);
    _loadData();
  }

  void _loadData() async {
    final contacts = await widget.repository.fetchContacts();
    if (mounted) {
      _allContacts = contacts;
      ref.read(crmDashboardProvider.notifier).setLoading(false);
    }
  }

  Set<String> _getScopedUserIds(GroupScope scope, String currentUserId) {
    switch (scope) {
      case GroupScope.personalGroup:
        final directReports = widget.repository.users
            .where((u) => u.managerId == currentUserId)
            .map((u) => u.id);
        return {currentUserId, ...directReports};

      case GroupScope.totalGroup:
        Set<String> ids = {currentUserId};
        List<String> toProcess = [currentUserId];

        while (toProcess.isNotEmpty) {
          final parentId = toProcess.removeAt(0);
          final children = widget.repository.users
              .where((u) => u.managerId == parentId)
              .map((u) => u.id);
          for (var childId in children) {
            if (!ids.contains(childId)) {
              ids.add(childId);
              toProcess.add(childId);
            }
          }
        }
        return ids;
    }
  }

  List<CRMContactModel> get _accessibleContacts {
    final navStack = ref.watch(
      crmDashboardProvider.select((s) => s.navigationStack),
    );
    if (navStack.isEmpty) return [];
    final allowedUserIds = _getScopedUserIds(
      GroupScope.totalGroup,
      _currentUser.id,
    );
    return _allContacts
        .where((c) => allowedUserIds.contains(c.assignedAgentId))
        .toList();
  }

  List<CRMContactModel> get _filteredContacts {
    final state = ref.watch(crmDashboardProvider);
    return _accessibleContacts.where((c) {
      if (state.selectedTypeFilter != null &&
          c.contactType != state.selectedTypeFilter) {
        return false;
      }

      if (state.selectedStageFilter != null &&
          !c.products.any((p) => p.stage == state.selectedStageFilter)) {
        return false;
      }

      if (state.selectedAgentFilter != null &&
          c.assignedAgentId != state.selectedAgentFilter) {
        return false;
      }

      if (state.searchQuery.isNotEmpty) {
        final query = state.searchQuery.toLowerCase();
        final agentName = _getUserById(c.assignedAgentId).name.toLowerCase();
        final matchName = c.name.toLowerCase().contains(query);
        final matchPhone = c.phone.contains(query);
        final matchId = c.id.toLowerCase().contains(query);
        final matchAgent = agentName.contains(query);
        final matchProduct = c.productSummary.toLowerCase().contains(query);

        if (!matchName &&
            !matchPhone &&
            !matchId &&
            !matchAgent &&
            !matchProduct) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  List<CRMUser> get _subTeamMembers {
    final state = ref.watch(crmDashboardProvider);
    final navStack = state.navigationStack;
    if (navStack.isEmpty) return [];
    final allowedUserIds = _getScopedUserIds(
      state.selectedGroupScope,
      _currentUser.id,
    );
    allowedUserIds.remove(_currentUser.id);
    return widget.repository.users
        .where((u) => allowedUserIds.contains(u.id))
        .toList();
  }

  CRMUser _getUserById(String id) {
    return widget.repository.users.firstWhere(
      (u) => u.id == id,
      orElse: () => CRMUser(id: id, name: 'Unknown', role: UserRole.fa),
    );
  }

  void _showFilterBottomSheet() {
    final navStack = ref.read(
      crmDashboardProvider.select((s) => s.navigationStack),
    );
    if (navStack.isEmpty) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final accessibleAgents = widget.repository.users
                .where(
                  (u) => _getScopedUserIds(
                    GroupScope.totalGroup,
                    _currentUser.id,
                  ).contains(u.id),
                )
                .toList();

            final state = ref.watch(crmDashboardProvider);

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter Contacts',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ref
                                .read(crmDashboardProvider.notifier)
                                .resetFilters();
                            setModalState(() {});
                          },
                          child: const Text('Reset All'),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 10),

                    const Text(
                      'Contact Status',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ContactType.values.map((type) {
                        final isSelected = state.selectedTypeFilter == type;
                        String label;
                        switch (type) {
                          case ContactType.lead:
                            label = 'Unqualified';
                            break;
                          case ContactType.halfQualified:
                            label = 'Half-Qualified';
                            break;
                          case ContactType.client:
                            label = 'Qualified';
                            break;
                        }

                        return ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          selectedColor: AppColors.primaryColor.withValues(
                            alpha: 0.2,
                          ),
                          onSelected: (selected) {
                            ref
                                .read(crmDashboardProvider.notifier)
                                .setTypeFilter(selected ? type : null);
                            setModalState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Product Opportunity Stage',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: ProductStage.values.map((stage) {
                        final isSelected = state.selectedStageFilter == stage;
                        return ChoiceChip(
                          label: Text(stage.name.toUpperCase()),
                          selected: isSelected,
                          selectedColor: AppColors.primaryColor.withValues(
                            alpha: 0.2,
                          ),
                          onSelected: (selected) {
                            ref
                                .read(crmDashboardProvider.notifier)
                                .setStageFilter(selected ? stage : null);
                            setModalState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Assigned Agent',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: state.selectedAgentFilter,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      hint: const Text('Select Agent'),
                      items: accessibleAgents.map((agent) {
                        return DropdownMenuItem(
                          value: agent.id,
                          child: Text('${agent.name} (${agent.role.label})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        ref
                            .read(crmDashboardProvider.notifier)
                            .setAgentFilter(val);
                        setModalState(() {});
                      },
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          context.pop();
                        },
                        child: const Text(
                          'Apply Filters',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBody() {
    final showTeamTab = _hasTeamMembers;
    final isLoading = ref.watch(
      crmDashboardProvider.select((s) => s.isLoading),
    );

    return Column(
      children: [
        _buildBreadcrumbs(),
        Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                )
              : showTeamTab
              ? CustomTabView(
                  controller: _tabController,
                  tabs: [
                    const TabItemData(label: 'Overview'),
                    const TabItemData(label: 'Team Hierarchy'),
                  ],
                  tabViews: [_buildOverviewTab(), _buildTeamHierarchyTab()],
                )
              : _buildOverviewTab(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final navStack = ref.watch(
      crmDashboardProvider.select((s) => s.navigationStack),
    );
    final isRootLevel = navStack.length == 1;
    return PopScope(
      canPop: isRootLevel,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          ref.read(crmDashboardProvider.notifier).popUser();
        }
      },
      child: Material(
        color: AppColors.surfaceBg,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: !isRootLevel,
              pinned: true,

              title: Text(
                "Customers",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: _showFilterBottomSheet,
                  icon: Icon(
                    Icons.filter_list_rounded,
                    color:
                        ref.watch(
                          crmDashboardProvider.select(
                            (s) => s.hasActiveFilters,
                          ),
                        )
                        ? AppColors.primaryColor
                        : Colors.grey.shade700,
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.add_rounded),
                  onPressed: () {
                    context.push(RoutePaths.crmCreateLead);
                  },
                ),
              ],
            ),
            SliverFillRemaining(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBreadcrumbs() {
    final navStack = ref.watch(
      crmDashboardProvider.select((s) => s.navigationStack),
    );
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: navStack.asMap().entries.map((entry) {
            final index = entry.key;
            final user = entry.value;
            final isLast = index == navStack.length - 1;

            return Row(
              children: [
                InkWell(
                  onTap: isLast
                      ? null
                      : () {
                          ref
                              .read(crmDashboardProvider.notifier)
                              .popToIndex(index);
                          _tabController.index = 0;
                        },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 3,
                    ),
                    child: Text(
                      user.name,
                      style: TextStyle(
                        color: isLast ? AppColors.primaryColor : Colors.grey,
                        fontSize: 11,
                        fontWeight: isLast ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey,
                    size: 16,
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    final contacts = _filteredContacts;
    final totalLeads = contacts
        .where((c) => c.contactType == ContactType.lead)
        .length;
    final totalHalfQualified = contacts
        .where((c) => c.contactType == ContactType.halfQualified)
        .length;
    final totalClients = contacts
        .where((c) => c.contactType == ContactType.client)
        .length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Leads',
                count: totalLeads,
                color: Colors.orange.shade800,
                bgColor: Colors.orange.withValues(alpha: 0.1),
                icon: Icons.person_add_alt_1_rounded,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: MetricCard(
                title: 'Half-Qualified',
                count: totalHalfQualified,
                color: Colors.purple.shade700,
                bgColor: Colors.purple.withValues(alpha: 0.1),
                icon: Icons.star_half_rounded,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: MetricCard(
                title: 'Clients',
                count: totalClients,
                color: Colors.green.shade700,
                bgColor: Colors.green.withValues(alpha: 0.1),
                icon: Icons.verified_user_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (v) =>
                    ref.read(crmDashboardProvider.notifier).setSearchQuery(v),
                decoration: InputDecoration(
                  hintText: 'Search contacts, products, agents...',
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Colors.grey,
                  ),
                  suffixIcon:
                      ref
                          .watch(
                            crmDashboardProvider.select((s) => s.searchQuery),
                          )
                          .isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            ref
                                .read(crmDashboardProvider.notifier)
                                .setSearchQuery('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Contacts (${contacts.length})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (contacts.isEmpty)
          const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                'No contacts match your query or filters.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ...contacts.map((c) => _buildContactCard(c)),
      ],
    );
  }

  Widget _buildTeamHierarchyTab() {
    final members = _subTeamMembers;
    final selectedGroupScope = ref.watch(
      crmDashboardProvider.select((s) => s.selectedGroupScope),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppSegmentedTabs<GroupScope>(
          value: selectedGroupScope,
          options: const [
            (GroupScope.personalGroup, 'Personal Group', Icons.people_outline),
            (GroupScope.totalGroup, 'Total Group', Icons.group_outlined),
          ],
          onChanged: (scope) =>
              ref.read(crmDashboardProvider.notifier).setGroupScope(scope),
        ),
        const SizedBox(height: 16),

        if (members.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FaIcon(
                  FontAwesomeIcons.userGroup,
                  size: 32,
                  color: Colors.grey,
                ),
                const SizedBox(height: 12),
                Text(
                  'No Sub-Team Members',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_currentUser.name} (${_currentUser.role.label}) does not have members under ${selectedGroupScope.label}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          )
        else
          ...members.map((member) {
            final memberContacts = _allContacts
                .where((c) => c.assignedAgentId == member.id)
                .toList();
            final leadsCount = memberContacts
                .where((c) => c.contactType == ContactType.lead)
                .length;
            final halfQualifiedCount = memberContacts
                .where((c) => c.contactType == ContactType.halfQualified)
                .length;
            final clientsCount = memberContacts
                .where((c) => c.contactType == ContactType.client)
                .length;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  onTap: () {
                    ref.read(crmDashboardProvider.notifier).pushUser(member);
                    _tabController.index = 0;
                  },
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryColor.withValues(
                      alpha: 0.1,
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.user,
                      size: 14,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  title: Text(
                    member.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  subtitle: Text(
                    member.role.label,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: MiniCountPill(
                          label: 'L',
                          count: leadsCount,
                          color: Colors.orange.shade800,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: MiniCountPill(
                          label: 'HQ',
                          count: halfQualifiedCount,
                          color: Colors.purple.shade700,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: MiniCountPill(
                          label: 'C',
                          count: clientsCount,
                          color: Colors.green.shade700,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildContactCard(CRMContactModel contact) {
    final uniqueStages = contact.products.map((p) => p.stage).toSet();
    final String stageLabel;

    if (uniqueStages.isEmpty) {
      stageLabel = 'N/A';
    } else if (uniqueStages.length == 1) {
      stageLabel = uniqueStages.first.name.toUpperCase();
    } else {
      stageLabel = 'HALF-QUALIFIED';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          onTap: () {
            context.push(RoutePaths.crmDetail, extra: contact);
          },
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  contact.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  stageLabel,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Products: ${contact.products.length}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  contact.phone,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade800),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
