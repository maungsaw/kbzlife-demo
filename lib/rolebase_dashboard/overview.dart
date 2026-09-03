import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../const.dart';
import 'model.dart';

class OverviewTabPage extends ConsumerStatefulWidget {
  final HierarchyNodeModel node;

  const OverviewTabPage({super.key, required this.node});

  @override
  ConsumerState<OverviewTabPage> createState() => _OverviewTabPageState();
}

class _OverviewTabPageState extends ConsumerState<OverviewTabPage> {
  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final metrics = node.metrics;

    if (node.isFA) {
      return _buildFAOverview(metrics);
    } else {
      return _buildLeaderOverview(metrics, node);
    }
  }

  Widget _buildFAOverview(AgentPerformanceData metrics) {
    return ListView(
      padding: .symmetric(horizontal: 16),
      children: [
        _buildPersonalPerformanceCard(metrics),
        const SizedBox(height: 16),
        _buildFYPSection(metrics),
        const SizedBox(height: 16),
        _buildDueCollectionCard(metrics),
        const SizedBox(height: 16),
        _buildCommissionCard(metrics),
        const SizedBox(height: 16),
        _buildPersistencySection(metrics),
        const SizedBox(height: 16),
        _buildMDRTCard(metrics),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPersonalPerformanceCard(AgentPerformanceData metrics) {
    return Container(
      padding: const .all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.colors.accentNavy, context.colors.primaryColor],
          begin: .topLeft,
          end: .bottomRight,
        ),
        borderRadius: .circular(16),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          const Text(
            'Personal Performance',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _heroStat('APE', '${metrics.ape}M')),
              _heroDivider(),
              Expanded(child: _heroStat('FYP', '${metrics.fyp.totalFyp}M')),
              _heroDivider(),
              Expanded(
                child: _heroStat(
                  'Policies',
                  '${metrics.policyCount.totalCount}',
                ),
              ),
              _heroDivider(),
              Expanded(
                child: _heroStat(
                  'Commission',
                  '${metrics.commission.totalCommission}M',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFYPSection(AgentPerformanceData metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'First Year Premium (FYP)',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Initial FYP',
                '${metrics.fyp.initialFyp}M',
                context.colors.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Subsequent FYP',
                '${metrics.fyp.subsequentFyp}M',
                context.colors.successText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MoM Growth',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: metrics.fyp.momGrowth >= 0
                      ? context.colors.successLight
                      : context.colors.errorLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${metrics.fyp.momGrowth >= 0 ? '+' : ''}${metrics.fyp.momGrowth}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: metrics.fyp.momGrowth >= 0
                        ? context.colors.successText
                        : context.colors.errorText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDueCollectionCard(AgentPerformanceData metrics) {
    final dc = metrics.dueCollection;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Due vs Collected Premium',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Number of Dues', '${dc.numberOfDues}'),
              ),
              Expanded(child: _buildStatItem('Due Amount', '${dc.dueAmount}M')),
              Expanded(
                child: _buildStatItem('Collected', '${dc.collectedAmount}M'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: dc.collectionRatio / 100,
              backgroundColor: context.colors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                context.colors.primaryColor,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Collection Ratio: ${dc.collectionRatio}%',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionCard(AgentPerformanceData metrics) {
    final comm = metrics.commission;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Commission',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Standard',
                  '${comm.standardCommission}M',
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'UL Additional',
                  '${comm.ulAdditionalCommission}M',
                ),
              ),
              Expanded(
                child: _buildStatItem('Total', '${comm.totalCommission}M'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersistencySection(AgentPerformanceData metrics) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          'Persistency',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPersistencyCard(
                'K1 Persistency',
                metrics.k1Persistency,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPersistencyCard(
                'K2 Persistency',
                metrics.k2Persistency,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPersistencyCard(String title, PersistencyMetric metric) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${metric.policyRetentionRate}%',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: context.colors.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            metric.gracePeriodStatus,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 8),
          _buildRatioRow('Policy Count', metric.policyCountRatio),
          const SizedBox(height: 4),
          _buildRatioRow('Premium Amount', metric.premiumAmountRatio),
        ],
      ),
    );
  }

  Widget _buildRatioRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        Text(
          '$value%',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildMDRTCard(AgentPerformanceData metrics) {
    final mdrt = metrics.mdrt;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Road to MDRT',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textPrimary,
                ),
              ),
              Text(
                '${(mdrt.progressPercentage * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: context.colors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: mdrt.progressPercentage,
              backgroundColor: context.colors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                context.colors.primaryColor,
              ),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Eligible Premium',
                  '${mdrt.eligiblePremium}M',
                ),
              ),
              Expanded(
                child: _buildStatItem('Target', '${mdrt.targetThreshold}M'),
              ),
              Expanded(
                child: _buildStatItem(
                  'Commission',
                  '${mdrt.commissionTracker}M',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderOverview(
    AgentPerformanceData metrics,
    HierarchyNodeModel node,
  ) {
    return ListView(
      padding: .only(top: 16),
      children: [
        _buildMyPerformanceLink(metrics),
        const SizedBox(height: 16),
        _buildOverallPerformance(metrics),
        const SizedBox(height: 20),
        _buildKeyPerformance(metrics),
        const SizedBox(height: 20),
        _buildMDRTSection(metrics, node),
        const SizedBox(height: 20),
        _buildDirectReports(node),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMyPerformanceLink(AgentPerformanceData metrics) {
    return GestureDetector(
      onTap: () => _showPerformanceDetailsSheet(metrics),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.colors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: context.iconXl,
                color: context.colors.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My performance',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${(metrics.targetVariance + 100).toInt()}% · FYP ${metrics.fyp.totalFyp}M',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: context.iconBase,
              color: context.colors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallPerformance(AgentPerformanceData metrics) {
    final progress = metrics.actual / metrics.target;
    final displayProgress = progress > 1.0 ? 1.0 : progress;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: displayProgress,
                    strokeWidth: 10,
                    backgroundColor: context.colors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      context.colors.primaryColor,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(displayProgress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: context.colors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Actual  ${metrics.actual}M',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Target  ${metrics.target}M',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: metrics.apeMomGrowth >= 0
                        ? context.colors.successLight
                        : context.colors.errorLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${metrics.apeMomGrowth >= 0 ? '+' : ''}${metrics.apeMomGrowth}% vs last month',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: metrics.apeMomGrowth >= 0
                          ? context.colors.successText
                          : context.colors.errorText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (metrics.isRedFlag)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.colors.errorLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: context.colors.errorText,
                size: context.iconXl,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKeyPerformance(AgentPerformanceData metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key performance',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                'APE',
                '${((metrics.actual / metrics.target) * 100).toInt()}%',
                '${metrics.ape}M',
                'Target ${metrics.target}M',
                metrics.actual / metrics.target,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                'FYP',
                '${((metrics.fyp.totalFyp / metrics.target) * 100).toInt()}%',
                '${metrics.fyp.totalFyp}M',
                'Initial ${metrics.fyp.initialFyp}M',
                metrics.fyp.totalFyp / metrics.target,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                'Subsequent FYP',
                '${((metrics.fyp.subsequentFyp / metrics.fyp.totalFyp) * 100).toInt()}%',
                '${metrics.fyp.subsequentFyp}M',
                'Total FYP ${metrics.fyp.totalFyp}M',
                metrics.fyp.subsequentFyp / metrics.fyp.totalFyp,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKpiCard(
                'Weighted FYP',
                '${((metrics.fyp.weightedFyp / metrics.fyp.totalFyp) * 100).toInt()}%',
                '${metrics.fyp.weightedFyp}M',
                'Total FYP ${metrics.fyp.totalFyp}M',
                metrics.fyp.weightedFyp / metrics.fyp.totalFyp,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiCard(
    String title,
    String percentage,
    String actual,
    String target,
    double progress,
  ) {
    final displayProgress = progress > 1.0 ? 1.0 : progress;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
              Text(
                percentage,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: context.colors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            actual,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            target,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: displayProgress,
              backgroundColor: context.colors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                context.colors.primaryColor,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMDRTSection(
    AgentPerformanceData metrics,
    HierarchyNodeModel node,
  ) {
    final mdrtCount = node.indirectTeam
        .where((m) => m.metrics.mdrt.progressPercentage >= 1.0)
        .length;
    final totalFAs = node.indirectTeam
        .where((m) => m.role == UserRole.fa)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Road to MDRT',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.colors.textPrimary,
              ),
            ),
            Text(
              '$mdrtCount / $totalFAs qualified',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.colors.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${metrics.mdrt.eligiblePremium}M',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.colors.primaryColor,
                    ),
                  ),
                  Text(
                    'Target: ${metrics.mdrt.targetThreshold}M',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: metrics.mdrt.progressPercentage,
                  backgroundColor: context.colors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    metrics.mdrt.progressPercentage >= 1.0
                        ? context.colors.successText
                        : context.colors.primaryColor,
                  ),
                  minHeight: 10,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(metrics.mdrt.progressPercentage * 100).toInt()}% achieved',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  Text(
                    'Commission: ${metrics.mdrt.commissionTracker}M',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Team Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: context.colors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildMDRTSummaryItem(
                    'Qualified',
                    '$mdrtCount',
                    context.colors.successText,
                  ),
                  const SizedBox(width: 16),
                  _buildMDRTSummaryItem(
                    'In Progress',
                    '${totalFAs - mdrtCount}',
                    context.colors.primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMDRTSummaryItem(String label, String count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: $count',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: context.colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDirectReports(HierarchyNodeModel node) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.colors.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.people_outline,
              size: context.iconXl,
              color: context.colors.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Direct reports (${node.directTeam.length})',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: context.iconBase,
            color: context.colors.primaryColor,
          ),
        ],
      ),
    );
  }

  void _showPerformanceDetailsSheet(AgentPerformanceData metrics) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: context.colors.surfaceBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                color: Colors.white,
                child: Text(
                  'Personal Performance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  children: [
                    _sheetHeaderCard(metrics),
                    const SizedBox(height: 16),
                    _sheetFYPSection(metrics),
                    const SizedBox(height: 16),
                    _sheetDueCollectionCard(metrics),
                    const SizedBox(height: 16),
                    _sheetCommissionCard(metrics),
                    const SizedBox(height: 16),
                    _sheetPersistencySection(metrics),
                    const SizedBox(height: 16),
                    _sheetMDRTCard(metrics),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetHeaderCard(AgentPerformanceData metrics) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [context.colors.accentNavy, context.colors.primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Summary',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _heroStat('APE', '${metrics.ape}M')),
              _heroDivider(),
              Expanded(child: _heroStat('FYP', '${metrics.fyp.totalFyp}M')),
              _heroDivider(),
              Expanded(
                child: _heroStat(
                  'Policies',
                  '${metrics.policyCount.totalCount}',
                ),
              ),
              _heroDivider(),
              Expanded(
                child: _heroStat(
                  'Commission',
                  '${metrics.commission.totalCommission}M',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sheetFYPSection(AgentPerformanceData metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'First Year Premium (FYP)',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Initial FYP',
                '${metrics.fyp.initialFyp}M',
                context.colors.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Subsequent FYP',
                '${metrics.fyp.subsequentFyp}M',
                context.colors.successText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.colors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MoM Growth',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: metrics.fyp.momGrowth >= 0
                      ? context.colors.successLight
                      : context.colors.errorLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${metrics.fyp.momGrowth >= 0 ? '+' : ''}${metrics.fyp.momGrowth}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: metrics.fyp.momGrowth >= 0
                        ? context.colors.successText
                        : context.colors.errorText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sheetDueCollectionCard(AgentPerformanceData metrics) {
    final dc = metrics.dueCollection;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Due vs Collected Premium',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Number of Dues', '${dc.numberOfDues}'),
              ),
              Expanded(child: _buildStatItem('Due Amount', '${dc.dueAmount}M')),
              Expanded(
                child: _buildStatItem('Collected', '${dc.collectedAmount}M'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: dc.collectionRatio / 100,
              backgroundColor: context.colors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                context.colors.primaryColor,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Collection Ratio: ${dc.collectionRatio}%',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _sheetCommissionCard(AgentPerformanceData metrics) {
    final comm = metrics.commission;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Commission',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Standard', '${comm.standardCommission}M'),
              _buildStatItem(
                'UL Additional',
                '${comm.ulAdditionalCommission}M',
              ),
              _buildStatItem('Total', '${comm.totalCommission}M'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sheetPersistencySection(AgentPerformanceData metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Persistency',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _sheetPersistencyCard(
                'K1 Persistency',
                metrics.k1Persistency,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _sheetPersistencyCard(
                'K2 Persistency',
                metrics.k2Persistency,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sheetPersistencyCard(String title, PersistencyMetric metric) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${metric.policyRetentionRate}%',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: context.colors.primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            metric.gracePeriodStatus,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 8),
          _sheetRatioRow('Policy Count', metric.policyCountRatio),
          const SizedBox(height: 4),
          _sheetRatioRow('Premium Amount', metric.premiumAmountRatio),
        ],
      ),
    );
  }

  Widget _sheetRatioRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
        Text(
          '$value%',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _sheetMDRTCard(AgentPerformanceData metrics) {
    final mdrt = metrics.mdrt;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Road to MDRT',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textPrimary,
                ),
              ),
              Text(
                '${(mdrt.progressPercentage * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: context.colors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: mdrt.progressPercentage,
              backgroundColor: context.colors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                context.colors.primaryColor,
              ),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Eligible Premium', '${mdrt.eligiblePremium}M'),
              _buildStatItem('Target', '${mdrt.targetThreshold}M'),
              _buildStatItem('Commission', '${mdrt.commissionTracker}M'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroStat(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 9)),
      ],
    );
  }

  Widget _heroDivider() {
    return Container(
      width: 1,
      height: 20,
      color: Colors.white.withValues(alpha: 0.15),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
      ],
    );
  }
}
