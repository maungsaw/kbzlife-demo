import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../const.dart';
import '../widgets/pill_tabs.dart';
import 'data.dart';
import 'model.dart';
import 'overview.dart';
import 'team_structure.dart';

class PerformanceDashboardPage extends ConsumerStatefulWidget {
  final HierarchyNodeModel? rootNode;

  const PerformanceDashboardPage({super.key, this.rootNode});

  @override
  ConsumerState<PerformanceDashboardPage> createState() =>
      _PerformanceDashboardPageState();
}

class _PerformanceDashboardPageState
    extends ConsumerState<PerformanceDashboardPage> {
  late List<HierarchyNodeModel> _breadcrumbs;
  String _selectedChannel = 'All';
  String _selectedProduct = 'All';
  String _selectedBranch = 'All';
  String _selectedTerritory = 'All';

  @override
  void initState() {
    super.initState();
    _breadcrumbs = [widget.rootNode ?? sampleHierarchy];
  }

  HierarchyNodeModel get _currentNode => _breadcrumbs.last;

  void _openDirectMember(HierarchyNodeModel member) {
    setState(() {
      _breadcrumbs.add(member);
    });
  }

  void _goBack() {
    if (_breadcrumbs.length <= 1) return;
    setState(() {
      _breadcrumbs.removeLast();
    });
  }

  void _goToBreadcrumb(int index) {
    if (index < 0 || index >= _breadcrumbs.length) return;
    setState(() {
      _breadcrumbs = _breadcrumbs.sublist(0, index + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: _breadcrumbs.length > 1
            ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: context.iconLg,
                  color: context.colors.accentNavy,
                ),
                onPressed: _goBack,
              )
            : IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: context.iconLg,
                  color: context.colors.accentNavy,
                ),
                onPressed: () => context.pop(),
              ),
        title: Text(
          _currentNode.isFA ? 'My Dashboard' : 'Performance Dashboard',
          style: TextStyle(
            color: context.colors.accentNavy,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_currentNode.isLeader)
            IconButton(
              icon: Icon(Icons.tune_rounded, color: context.colors.muted),
              onPressed: _showFiltersSheet,
            ),
          IconButton(
            icon: Icon(
              Icons.notifications_none_rounded,
              color: context.colors.muted,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildBreadcrumbs(),
          // if (!_currentNode.isFA) ...[
          //   Padding(
          //     padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          //     child: _buildProfileCard(),
          //   ),
          // ],
          const SizedBox(height: 6),
          if (_currentNode.isLeader)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: PillTabs(
                  tabs: [
                    PillTab(
                      label: 'Overview',
                      child: OverviewTabPage(node: _currentNode),
                    ),
                    PillTab(
                      label: 'Team Hierarchy',
                      child: TeamStructureTabPage(
                        node: _currentNode,
                        onSelectMember: _openDirectMember,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(child: OverviewTabPage(node: _currentNode)),
        ],
      ),
    );
  }

  Widget _buildBreadcrumbs() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _breadcrumbs.asMap().entries.map((entry) {
            final index = entry.key;
            final node = entry.value;
            final isLast = index == _breadcrumbs.length - 1;

            return Row(
              children: [
                InkWell(
                  onTap: isLast ? null : () => _goToBreadcrumb(index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 3,
                    ),
                    child: Text(
                      node.name,
                      style: TextStyle(
                        color: isLast
                            ? context.colors.primaryColor
                            : context.colors.muted,
                        fontSize: 11,
                        fontWeight: isLast ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                if (!isLast)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: context.colors.muted,
                    size: context.iconBase,
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // Widget _buildProfileCard() {
  //   final node = _currentNode;
  //   final metrics = node.metrics;

  //   return Container(
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [context.colors.accentNavy, context.colors.primaryColor],
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       ),
  //       borderRadius: BorderRadius.circular(16),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             _whiteAvatar(node.name),
  //             const SizedBox(width: 12),
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     node.name,
  //                     style: const TextStyle(
  //                       color: Colors.white,
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 3),
  //                   Text(
  //                     node.designation,
  //                     style: const TextStyle(
  //                       color: Colors.white70,
  //                       fontSize: 11,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 2),
  //                   Text(
  //                     node.id,
  //                     style: const TextStyle(
  //                       color: Colors.white54,
  //                       fontSize: 9,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             if (metrics.isRedFlag)
  //               Container(
  //                 padding: const EdgeInsets.symmetric(
  //                   horizontal: 8,
  //                   vertical: 4,
  //                 ),
  //                 decoration: BoxDecoration(
  //                   color: context.colors.errorLight,
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //                 child: Row(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     Icon(
  //                       Icons.warning_amber_rounded,
  //                       size: context.iconSm,
  //                       color: context.colors.errorText,
  //                     ),
  //                     SizedBox(width: 4),
  //                     Text(
  //                       'RED FLAG',
  //                       style: TextStyle(
  //                         fontSize: 9,
  //                         fontWeight: FontWeight.bold,
  //                         color: context.colors.errorText,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               )
  //             else
  //               Container(
  //                 padding: const EdgeInsets.symmetric(
  //                   horizontal: 8,
  //                   vertical: 4,
  //                 ),
  //                 decoration: BoxDecoration(
  //                   color: Colors.white.withValues(alpha: 0.1),
  //                   borderRadius: BorderRadius.circular(8),
  //                 ),
  //                 child: Text(
  //                   metrics.apeMomGrowth >= 0
  //                       ? '+${metrics.apeMomGrowth}%'
  //                       : '${metrics.apeMomGrowth}%',
  //                   style: TextStyle(
  //                     color: metrics.apeMomGrowth >= 0
  //                         ? Colors.greenAccent
  //                         : Colors.redAccent,
  //                     fontWeight: FontWeight.bold,
  //                     fontSize: 10,
  //                   ),
  //                 ),
  //               ),
  //           ],
  //         ),
  //         const SizedBox(height: 15),
  //         Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
  //           decoration: BoxDecoration(
  //             color: Colors.white.withValues(alpha: 0.08),
  //             borderRadius: BorderRadius.circular(11),
  //           ),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceAround,
  //             children: [
  //               _heroStat('APE', '${metrics.ape}M'),
  //               _heroDivider(),
  //               _heroStat('FYP', '${metrics.fyp.totalFyp}M'),
  //               _heroDivider(),
  //               _heroStat('Policies', '${metrics.policyCount.totalCount}'),
  //               _heroDivider(),
  //               _heroStat(
  //                 'Commission',
  //                 '${metrics.commission.totalCommission}M',
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _heroStat(String title, String value) {
  //   return Column(
  //     children: [
  //       Text(
  //         value,
  //         style: const TextStyle(
  //           color: Colors.white,
  //           fontSize: 13,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       const SizedBox(height: 2),
  //       Text(title, style: const TextStyle(color: Colors.white70, fontSize: 9)),
  //     ],
  //   );
  // }

  // Widget _heroDivider() {
  //   return Container(
  //     width: 1,
  //     height: 20,
  //     color: Colors.white.withValues(alpha: 0.15),
  //   );
  // }

  void _showFiltersSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) => Container(
            padding: const EdgeInsets.all(20),
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filters',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setModalState(() {
                          _selectedChannel = 'All';
                          _selectedProduct = 'All';
                          _selectedBranch = 'All';
                          _selectedTerritory = 'All';
                        });
                        setState(() {});
                      },
                      child: Text(
                        'Reset all',
                        style: TextStyle(
                          color: context.colors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildFilterSection(
                  title: 'Channel',
                  value: _selectedChannel,
                  options: ['All', 'Banking', 'Agency', 'Corporate'],
                  onChanged: (value) {
                    setModalState(() => _selectedChannel = value);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 20),
                _buildFilterSection(
                  title: 'Product',
                  value: _selectedProduct,
                  options: ['All', 'Life', 'Health', 'Accident', 'Credit'],
                  onChanged: (value) {
                    setModalState(() => _selectedProduct = value);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 20),
                _buildFilterSection(
                  title: 'Branch',
                  value: _selectedBranch,
                  options: ['All', 'Yangon', 'Mandalay', 'Naypyidaw'],
                  onChanged: (value) {
                    setModalState(() => _selectedBranch = value);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 20),
                _buildFilterSection(
                  title: 'Territory',
                  value: _selectedTerritory,
                  options: ['All', 'South', 'North', 'Central'],
                  onChanged: (value) {
                    setModalState(() => _selectedTerritory = value);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = option == value;
            return GestureDetector(
              onTap: () => onChanged(option),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colors.primaryColor
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? context.colors.primaryColor
                        : context.colors.border,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : context.colors.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Widget _whiteAvatar(String name) {
  //   final initial = name.trim().isEmpty
  //       ? '?'
  //       : name.trim().substring(0, 1).toUpperCase();

  //   return Container(
  //     width: 46,
  //     height: 46,
  //     decoration: BoxDecoration(
  //       color: Colors.white.withValues(alpha: 0.12),
  //       shape: BoxShape.circle,
  //       border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
  //     ),
  //     alignment: Alignment.center,
  //     child: Text(
  //       initial,
  //       style: const TextStyle(
  //         color: Colors.white,
  //         fontSize: 17,
  //         fontWeight: FontWeight.bold,
  //       ),
  //     ),
  //   );
  // }
}
