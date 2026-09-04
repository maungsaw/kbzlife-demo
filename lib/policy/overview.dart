import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../const.dart';
import '../providers/router_provider.dart';
import '../widgets/app_selection_chip.dart';
import 'data.dart';

class OverviewPage extends ConsumerStatefulWidget {
  final List<PolicyModel> data;
  final CRMUser currentUser;
  final PolicyRepository repository;

  const OverviewPage({
    super.key,
    required this.data,
    required this.currentUser,
    required this.repository,
  });

  @override
  ConsumerState<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends ConsumerState<OverviewPage> {
  String _searchQuery = '';
  String _selectedStatusFilter = 'All';

  late Set<String> _allowedAgentIds;
  List<PolicyModel> _displayedPolicies = [];

  @override
  void initState() {
    super.initState();
    _recomputeAll();
  }

  @override
  void didUpdateWidget(covariant OverviewPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data ||
        oldWidget.currentUser.id != widget.currentUser.id ||
        oldWidget.repository.users != widget.repository.users) {
      _recomputeAll();
    }
  }

  void _recomputeAll() {
    _allowedAgentIds = _computeDownlineAgentIds();
    _applyFilters();
  }

  Set<String> _computeDownlineAgentIds() {
    final Map<String, List<String>> managerToSubsMap = {};
    for (final user in widget.repository.users) {
      if (user.managerId != null) {
        managerToSubsMap.putIfAbsent(user.managerId!, () => []).add(user.id);
      }
    }

    final Set<String> allowedIds = {widget.currentUser.id};

    void collectSubtree(String parentId) {
      final subs = managerToSubsMap[parentId];
      if (subs == null) return;
      for (final subId in subs) {
        if (!allowedIds.contains(subId)) {
          allowedIds.add(subId);
          collectSubtree(subId);
        }
      }
    }

    collectSubtree(widget.currentUser.id);
    return allowedIds;
  }

  void _applyFilters() {
    final cleanQuery = _searchQuery.trim().toLowerCase();
    final cleanFilter = _selectedStatusFilter.toLowerCase();

    _displayedPolicies = widget.data.where((p) {
      if (!_allowedAgentIds.contains(p.assignedAgentId)) return false;

      if (_selectedStatusFilter != 'All' &&
          p.status.toLowerCase() != cleanFilter) {
        return false;
      }

      if (cleanQuery.isNotEmpty) {
        final matchesPolicyNo = p.policyNo.toLowerCase().contains(cleanQuery);
        final matchesClient = p.clientName.toLowerCase().contains(cleanQuery);
        final matchesPlan = p.plan.toLowerCase().contains(cleanQuery);
        return matchesPolicyNo || matchesClient || matchesPlan;
      }

      return true;
    }).toList();
  }

  void _onSearchChanged(String val) {
    setState(() {
      _searchQuery = val;
      _applyFilters();
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Policies',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: ['All', 'Active', 'Pending'].map((status) {
                      final isSelected = _selectedStatusFilter == status;
                      return AppSelectionChip(
                        label: status,
                        selected: isSelected,
                        onSelected: (_) {
                          setModalState(() {
                            _selectedStatusFilter = status;
                          });
                          setState(() {
                            _applyFilters();
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search policy no, client or plan...',
                    prefixIcon: Icon(Icons.search, size: context.iconXl),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: _showFilterBottomSheet,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Icon(
                          Icons.filter_list,
                          color: context.colors.primaryColor,
                          size: context.iconXxl,
                        ),
                        if (_selectedStatusFilter != 'All')
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Policies (${_displayedPolicies.length})',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: _displayedPolicies.isEmpty
                ? const Center(
                    child: Text(
                      'No matching policies found.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _displayedPolicies.length,
                    itemBuilder: (context, index) {
                      return _buildPolicyItem(
                        context,
                        _displayedPolicies[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyItem(BuildContext context, PolicyModel policy) {
    final isActive = policy.status == 'Active';
    final isOwnPolicy = policy.assignedAgentId == widget.currentUser.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          onTap: () {
            context.push(RoutePaths.policyDetail.replaceFirst(':policyNo', policy.policyNo));
          },
          title: Row(
            children: [
              Flexible(
                child: Text(
                  policy.policyNo,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!isOwnPolicy) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Team',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  policy.status,
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${policy.clientName} • ${policy.plan}',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Next Due: ${policy.nextDue}',
                        style: TextStyle(
                          color: context.colors.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      policy.premium,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          trailing: Icon(Icons.chevron_right, size: context.iconLg, color: Colors.grey),
        ),
      ),
    );
  }
}
