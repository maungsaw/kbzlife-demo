import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../const.dart';
import '../providers/router_provider.dart';
import '../widgets/tab_view.dart';
import 'model.dart';

class CRMDetailViewScreen extends ConsumerStatefulWidget {
  final CRMContactModel contact;

  const CRMDetailViewScreen({super.key, required this.contact});

  @override
  ConsumerState<CRMDetailViewScreen> createState() =>
      _CRMDetailViewScreenState();
}

class _CRMDetailViewScreenState extends ConsumerState<CRMDetailViewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getEffectiveStageLabel(List<CRMProductOpportunity> products) {
    final uniqueStages = products.map((p) => p.stage).toSet();
    if (uniqueStages.isEmpty) {
      return 'N/A';
    } else if (uniqueStages.length == 1) {
      return uniqueStages.first.name.toUpperCase();
    } else {
      return 'HALF-QUALIFIED';
    }
  }

  Color _getStageColor(String stageLabel) {
    switch (stageLabel.toUpperCase()) {
      case 'QUALIFIED':
        return const Color(0xFF2E7D32);
      case 'UNQUALIFIED':
        return const Color(0xFFC62828);
      case 'HALF-QUALIFIED':
        return const Color(0xFF7C3AED);
      case 'PENDING':
        return const Color(0xFFD97706);
      case 'LOST':
        return const Color(0xFF64748B);
      default:
        return AppColors.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final contact = widget.contact;
    final initials = contact.name.isNotEmpty
        ? contact.name.trim().split(' ').map((e) => e[0]).take(2).join()
        : 'C';

    final effectiveStageLabel = _getEffectiveStageLabel(contact.products);
    final stageColor = _getStageColor(effectiveStageLabel);

    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(
        automaticallyImplyActions: true,
        title: const Text(
          'Customer Details',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF0F172A)),
            onPressed: () {},
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primaryColor.withValues(
                            alpha: 0.1,
                          ),
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: AppColors.primaryColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contact.name,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: stageColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  effectiveStageLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: stageColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildHeaderActionCard(
                            icon: Icons.phone_outlined,
                            label: 'Call',
                            onTap: () => launchUrl(Uri.parse('tel:${contact.phone}')),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildHeaderActionCard(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            onTap: () => launchUrl(Uri.parse('mailto:${contact.email}')),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildHeaderActionCard(
                            icon: Icons.description_outlined,
                            label: 'Start e-App',
                            onTap: () {
                              final params = {
                                'crmName': contact.name,
                                'crmPhone': contact.phone,
                                'crmEmail': contact.email,
                              };
                              if (contact.products.isNotEmpty) {
                                params['product'] = contact.products.first.productName;
                              }
                              final query = params.entries
                                  .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
                                  .join('&');
                              context.push('${RoutePaths.eapp}?$query');
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: CustomTabView(
          tabs: const [
            TabItemData(label: 'Overview'),
            TabItemData(label: 'Products'),
            TabItemData(label: 'History'),
          ],
          controller: _tabController,
          tabViews: [
            _buildOverviewTab(contact),
            _buildProductsTab(contact),
            _buildHistoryTab(contact),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.primaryColor.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primaryColor, size: 26),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(CRMContactModel contact) {
    final effectiveStageLabel = _getEffectiveStageLabel(contact.products);
    final stageColor = _getStageColor(effectiveStageLabel);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _tabController.animateTo(1),
                child: _buildMetricCard(
                  '${contact.products.length}',
                  'Products',
                  AppColors.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => _tabController.animateTo(1),
                child: _buildMetricCard(
                  effectiveStageLabel,
                  'Stage',
                  stageColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildInfoField('FULL NAME', contact.name)),
                  Expanded(child: _buildInfoField('PHONE', contact.phone)),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoField(
                      'PRODUCT COUNT',
                      '${contact.products.length}',
                    ),
                  ),
                  Expanded(
                    child: _buildInfoField('STAGE', effectiveStageLabel),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (effectiveStageLabel == 'HALF-QUALIFIED')
          _buildBanner(
            icon: Icons.star_half_rounded,
            color: const Color(0xFF7C3AED),
            message:
                'This contact has products across different opportunity stages.',
          ),

        if (effectiveStageLabel == 'UNQUALIFIED')
          _buildBanner(
            icon: Icons.cancel_outlined,
            color: const Color(0xFFC62828),
            message:
                'All linked products for this contact are currently unqualified.',
          ),
      ],
    );
  }

  Widget _buildMetricCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner({
    required IconData icon,
    required Color color,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsTab(CRMContactModel contact) {
    if (contact.products.isEmpty) {
      return const Center(
        child: Text(
          'No product opportunities linked.',
          style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w500),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: contact.products.length,
      itemBuilder: (context, index) {
        final product = contact.products[index];
        final productStageName = product.stage.name.toUpperCase();
        final pStageColor = _getStageColor(productStageName);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Est. Value: ${product.estimatedValue.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: pStageColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  productStageName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: pStageColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab(CRMContactModel contact) {
    if (contact.activities.isEmpty) {
      return const Center(
        child: Text(
          'No activity history recorded.',
          style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w500),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: contact.activities.length,
      itemBuilder: (context, index) {
        final activity = contact.activities[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  activity.icon,
                  color: AppColors.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          activity.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          '${activity.timestamp.day}/${activity.timestamp.month}/${activity.timestamp.year}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity.note,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
