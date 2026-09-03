import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../const.dart';
import 'data.dart';
import 'role_badge.dart';

class _TeamNode {
  final CRMUser user;
  final int ownPolicyCount;
  int totalPolicyCount;
  final List<_TeamNode> subordinates;
  final List<_TeamNode> flatSubordinates;

  _TeamNode({
    required this.user,
    required this.ownPolicyCount,
    this.totalPolicyCount = 0,
    required this.subordinates,
    required this.flatSubordinates,
  });
}

class TeamStructurePage extends StatefulWidget {
  final CRMUser currentUser;
  final List<PolicyModel> allPolicies;
  final PolicyRepository repository;
  final ValueChanged<CRMUser> onPushUser;

  const TeamStructurePage({
    super.key,
    required this.currentUser,
    required this.allPolicies,
    required this.repository,
    required this.onPushUser,
  });

  @override
  State<TeamStructurePage> createState() => _TeamStructurePageState();
}

class _TeamStructurePageState extends State<TeamStructurePage> {
  late List<_TeamNode> _directManagers;

  @override
  void initState() {
    super.initState();
    _directManagers = _computeHierarchyData();
  }

  @override
  void didUpdateWidget(covariant TeamStructurePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allPolicies != widget.allPolicies ||
        oldWidget.currentUser.id != widget.currentUser.id ||
        oldWidget.repository.users != widget.repository.users) {
      setState(() {
        _directManagers = _computeHierarchyData();
      });
    }
  }

  List<_TeamNode> _computeHierarchyData() {
    final Map<String, int> ownPolicyCounts = {};
    for (final policy in widget.allPolicies) {
      ownPolicyCounts[policy.assignedAgentId] =
          (ownPolicyCounts[policy.assignedAgentId] ?? 0) + 1;
    }

    final Map<String, List<CRMUser>> managerToSubsMap = {};
    for (final user in widget.repository.users) {
      if (user.managerId != null) {
        managerToSubsMap.putIfAbsent(user.managerId!, () => []).add(user);
      }
    }

    final Set<String> visited = {};

    _TeamNode buildTree(CRMUser user) {
      if (visited.contains(user.id)) {
        return _TeamNode(
          user: user,
          ownPolicyCount: 0,
          totalPolicyCount: 0,
          subordinates: [],
          flatSubordinates: [],
        );
      }
      visited.add(user.id);

      final List<CRMUser> directChildren =
          managerToSubsMap[user.id] ?? <CRMUser>[];
      final childNodes = directChildren.map(buildTree).toList();

      final ownCount = ownPolicyCounts[user.id] ?? 0;
      int accumulatedTotal = ownCount;

      final List<_TeamNode> flatSubs = [];
      for (final child in childNodes) {
        accumulatedTotal += child.totalPolicyCount;
        flatSubs.add(child);
        flatSubs.addAll(child.flatSubordinates);
      }

      return _TeamNode(
        user: user,
        ownPolicyCount: ownCount,
        totalPolicyCount: accumulatedTotal,
        subordinates: childNodes,
        flatSubordinates: flatSubs,
      );
    }

    final List<CRMUser> directManagerUsers =
        managerToSubsMap[widget.currentUser.id] ?? <CRMUser>[];
    return directManagerUsers.map(buildTree).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentUser.role == UserRole.fa) {
      return const Center(
        child: Text(
          'FA role has no downstream team members.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    if (_directManagers.isEmpty) {
      return const Center(
        child: Text(
          'No group hierarchy found.',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _directManagers.length,
      itemBuilder: (context, index) {
        final managerNode = _directManagers[index];
        final manager = managerNode.user;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ExpansionTile(
            initiallyExpanded: true,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.deepOrange.withValues(alpha: 0.1),
              child: const FaIcon(
                FontAwesomeIcons.users,
                size: 14,
                color: Colors.deepOrange,
              ),
            ),
            title: Row(
              children: [
                Text.rich(
                  TextSpan(
                    text: manager.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                RoleBadge(role: manager.role),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text:
                          '${managerNode.flatSubordinates.length} Subordinates',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    TextSpan(
                      text: ' • ',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                      ),
                    ),
                    TextSpan(
                      text: 'Total: ${managerNode.totalPolicyCount} Policies',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    TextSpan(
                      text: ' (Own: ${managerNode.ownPolicyCount})',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.deepOrange,
              ),
              onPressed: () => widget.onPushUser(manager),
            ),
            children: managerNode.flatSubordinates
                .map((subNode) => _buildSubUserGroup(context, subNode))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildSubUserGroup(BuildContext context, _TeamNode node) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          Material(
            color: const Color(0xFFF8F9FA),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 4,
              ),
              leading: const Icon(
                Icons.subdirectory_arrow_right,
                size: 18,
                color: Colors.grey,
              ),
              title: Text.rich(
                TextSpan(
                  children: [WidgetSpan(child: RoleBadge(role: node.user.role))],
                  text: node.user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),

              subtitle: Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Own: ${node.ownPolicyCount} Policies',
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextSpan(
                      text: ' • ',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                      ),
                    ),
                    TextSpan(
                      text: 'Total Downline: ${node.totalPolicyCount} Policies',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            trailing: const Icon(Icons.chevron_right, size: 16),
            onTap: () => widget.onPushUser(node.user),
          ),
          ),
        ],
      ),
    );
  }
}
