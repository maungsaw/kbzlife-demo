import 'package:flutter/material.dart';

import '../const.dart';
import 'model.dart';

class TeamStructureTabPage extends StatelessWidget {
  final HierarchyNodeModel node;
  final ValueChanged<HierarchyNodeModel> onSelectMember;

  const TeamStructureTabPage({
    super.key,
    required this.node,
    required this.onSelectMember,
  });

  @override
  Widget build(BuildContext context) {
    final rawTeamList = node.directTeam.isNotEmpty
        ? node.directTeam
        : node.indirectTeam;

    final teamList = rawTeamList.where((m) => m.role != UserRole.dm).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        if (teamList.isEmpty)
          _buildEmptyTeamState()
        else
          ...teamList.map((manager) => _buildManagerCard(manager)),
      ],
    );
  }

  Widget _buildManagerCard(HierarchyNodeModel manager) {
    final subordinates = manager.directTeam
        .where((sub) => sub.role != UserRole.dm)
        .toList();
    final metrics = manager.metrics;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => onSelectMember(manager),
            borderRadius: BorderRadius.vertical(
              top: const Radius.circular(16),
              bottom: subordinates.isEmpty
                  ? const Radius.circular(16)
                  : Radius.zero,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.groups_rounded,
                      color: AppColors.primaryColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                manager.name,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildRoleBadge(
                              manager.designation,
                              badgeColor: const Color(0xFFE3F2FD),
                              textColor: AppColors.primaryColor,
                            ),
                            if (manager.metrics.isRedFlag) ...[
                              const SizedBox(width: 8),
                              _buildRedFlagBadge(),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${subordinates.length} Subordinates • APE: ${metrics.ape}M • FYP: ${metrics.fyp.totalFyp}M',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primaryColor,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          if (subordinates.isNotEmpty)
            const Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),

          ...subordinates.map((sub) => _buildSubordinateTile(sub)),
        ],
      ),
    );
  }

  Widget _buildSubordinateTile(HierarchyNodeModel member) {
    final metrics = member.metrics;

    return InkWell(
      onTap: () => onSelectMember(member),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            const SizedBox(width: 8),
            Icon(
              Icons.subdirectory_arrow_right_rounded,
              size: 18,
              color: Colors.grey.shade400,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          member.name,
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildRoleBadge(
                        member.designation,
                        badgeColor: const Color(0xFFE8F5E9),
                        textColor: const Color(0xFF2E7D32),
                      ),
                      if (member.metrics.isRedFlag) ...[
                        const SizedBox(width: 8),
                        _buildRedFlagBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildMiniStat('APE', '${metrics.ape}M'),
                      const SizedBox(width: 12),
                      _buildMiniStat('FYP', '${metrics.fyp.totalFyp}M'),
                      const SizedBox(width: 12),
                      _buildMiniStat(
                        'Policies',
                        '${metrics.policyCount.totalCount}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Text(
      '$label: $value',
      style: TextStyle(
        color: Colors.grey.shade600,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildRoleBadge(
    String roleText, {
    required Color badgeColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        roleText,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRedFlagBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, size: 12, color: Color(0xFFC62828)),
          SizedBox(width: 2),
          Text(
            'RED FLAG',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Color(0xFFC62828),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTeamState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.groups_outlined, size: 48, color: Color(0xFFE0E0E0)),
          SizedBox(height: 12),
          Text(
            'No team members found',
            style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
