import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'const.dart';
import 'providers/commission_provider.dart';

class CommissionReportScreen extends ConsumerStatefulWidget {
  const CommissionReportScreen({super.key});

  @override
  ConsumerState<CommissionReportScreen> createState() => _CommissionReportScreenState();
}

class _CommissionReportScreenState extends ConsumerState<CommissionReportScreen> {
  // Real Product Portfolio Data categorized from KBZ Life Insurance
  final List<CategoryReportModel> categories = [
    CategoryReportModel(
      label: 'Protection',
      count: 24,
      amount: 'MMK 24,800,000',
      icon: Icons.shield_outlined,
      iconBg: const Color(0xFFE0EDFF),
      iconColor: const Color(0xFF1D4ED8),
      heightRatio: 0.70,
      products: [
        KbzProductItem('Personal Accident Insurance', 'MMK 8,500,000', 9),
        KbzProductItem('Group Life Insurance', 'MMK 7,200,000', 6),
        KbzProductItem('Credit Life Insurance (Single)', 'MMK 4,100,000', 4),
        KbzProductItem(
          'Credit Life Insurance (Short Term)',
          'MMK 3,200,000',
          3,
        ),
        KbzProductItem('Travel Insurance', 'MMK 1,800,000', 2),
      ],
    ),
    CategoryReportModel(
      label: 'Saving',
      count: 8,
      amount: 'MMK 8,750,000',
      icon: Icons.savings_outlined,
      iconBg: const Color(0xFFFFF1E6),
      iconColor: const Color(0xFFEA580C),
      heightRatio: 0.28,
      products: [
        KbzProductItem('Universal Life Insurance', 'MMK 4,250,000', 3),
        KbzProductItem('Short Term Endowment Insurance', 'MMK 2,800,000', 3),
        KbzProductItem('Education Life Insurance', 'MMK 1,700,000', 2),
      ],
    ),
    CategoryReportModel(
      label: 'Health',
      count: 13,
      amount: 'MMK 13,650,000',
      icon: Icons.favorite_border,
      iconBg: const Color(0xFFFFE4E6),
      iconColor: const Color(0xFFE11D48),
      heightRatio: 0.42,
      products: [
        KbzProductItem('Health Insurance (Medical Care)', 'MMK 7,800,000', 7),
        KbzProductItem('Critical Illness Insurance', 'MMK 4,350,000', 4),
        KbzProductItem('Micro Health Insurance', 'MMK 1,500,000', 2),
      ],
    ),
    CategoryReportModel(
      label: 'Travel',
      count: 32,
      amount: 'MMK 32,250,000',
      icon: Icons.card_travel,
      iconBg: const Color(0xFFF3E8FF),
      iconColor: const Color(0xFF9333EA),
      heightRatio: 0.95,
      products: [
        KbzProductItem('Inbound Travel Insurance', 'MMK 18,500,000', 18),
        KbzProductItem('Outbound Travel Insurance', 'MMK 13,750,000', 14),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final commissionState = ref.watch(commissionProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Report',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.black87,
                ),
                onPressed: () {},
              ),
              Positioned(
                right: 12,
                top: 12,
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
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Banner
            //  _buildHeaderBanner(),
            const SizedBox(height: 16),

            // Commission Overview Chart Section
            _buildChartSection(commissionState),

            const SizedBox(height: 16),

            // Top Performing Category Card
            _buildTopCategoryCard(),

            const SizedBox(height: 16),

            // Category Breakdowns & Detailed Products List
            _buildProductCategoryBreakdown(commissionState),

            const SizedBox(height: 16),

            // Summary Grid Section
            _buildSummarySection(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(CommissionState commissionState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.bar_chart_rounded,
                      color: AppColors.primaryColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Commission Overview',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      commissionState.selectedPeriod,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 14,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 210,
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    5,
                    (index) => Row(
                      children: [
                        SizedBox(
                          width: 24,
                          child: Text(
                            '${(4 - index) * 10}',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 10,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey.shade100,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  left: 28,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: categories.map((cat) {
                      final isSelected = commissionState.expandedCategoryLabel == cat.label;
                      return GestureDetector(
                        onTap: () {
                          ref.read(commissionProvider.notifier).toggleCategory(cat.label);
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              cat.amount,
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? AppColors.secondaryColor
                                    : AppColors.primaryColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 36,
                              height: 130 * cat.heightRatio,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isSelected
                                      ? [
                                          AppColors.primaryColor,
                                          AppColors.secondaryColor,
                                        ]
                                      : [
                                          AppColors.secondaryColor,
                                          AppColors.primaryColor,
                                        ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.topCenter,
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                '${cat.count}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryColor
                                    : cat.iconBg,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                cat.icon,
                                size: 16,
                                color: isSelected
                                    ? Colors.white
                                    : cat.iconColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              cat.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? AppColors.primaryColor
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopCategoryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Performing Category',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.card_travel,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Travel Insurance',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'MMK 32,250,000',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Highest commission this month',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '32',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const Text(
                    'Commissions',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductCategoryBreakdown(CommissionState commissionState) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.list_alt_rounded,
                      color: AppColors.primaryColor,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Products Breakdown',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Text(
                'KBZ Life Portfolio',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (context, index) =>
                Divider(color: Colors.grey.shade100, height: 1),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isExpanded = commissionState.expandedCategoryLabel == cat.label;

              return ExpansionTile(
                key: Key(cat.label),
                initiallyExpanded: isExpanded,
                tilePadding: EdgeInsets.zero,
                onExpansionChanged: (expanded) {
                  ref.read(commissionProvider.notifier).toggleCategory(cat.label);
                },
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: cat.iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(cat.icon, size: 18, color: cat.iconColor),
                ),
                title: Text(
                  cat.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Text(
                  '${cat.count} Policies Issued',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      cat.amount,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ],
                ),
                children: cat.products.map((product) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${product.policies} policies sold',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          product.commissionAmount,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.article_outlined,
                  color: AppColors.primaryColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Summary',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryMetric(
                  icon: Icons.monetization_on_outlined,
                  iconBg: AppColors.primaryColor.withValues(alpha: 0.1),
                  iconColor: AppColors.primaryColor,
                  value: '77',
                  subValue: 'MMK 77,450,000',
                  subColor: AppColors.primaryColor,
                  label: 'Total Commissions',
                ),
              ),
              Expanded(
                child: _buildSummaryMetric(
                  icon: Icons.trending_up_rounded,
                  iconBg: const Color(0xFFDCFCE7),
                  iconColor: const Color(0xFF16A34A),
                  value: '12%',
                  subValue: 'MMK 8,600,000',
                  subColor: const Color(0xFF16A34A),
                  label: 'Vs Last Month',
                ),
              ),
              Expanded(
                child: _buildSummaryMetric(
                  icon: Icons.pie_chart_outline_rounded,
                  iconBg: const Color(0xFFF3E8FF),
                  iconColor: const Color(0xFF9333EA),
                  value: '4',
                  subValue: '',
                  subColor: Colors.transparent,
                  label: 'Categories',
                ),
              ),
              Expanded(
                child: _buildSummaryMetric(
                  icon: Icons.people_alt_outlined,
                  iconBg: const Color(0xFFFFEDD5),
                  iconColor: const Color(0xFFEA580C),
                  value: '36',
                  subValue: '',
                  subColor: Colors.transparent,
                  label: 'Policies',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetric({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required String subValue,
    required Color subColor,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        if (subValue.isNotEmpty) ...[
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              subValue,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: subColor,
              ),
            ),
          ),
        ],
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }
}

class CategoryReportModel {
  final String label;
  final int count;
  final String amount;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final double heightRatio;
  final List<KbzProductItem> products;

  CategoryReportModel({
    required this.label,
    required this.count,
    required this.amount,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.heightRatio,
    required this.products,
  });
}

class KbzProductItem {
  final String name;
  final String commissionAmount;
  final int policies;

  KbzProductItem(this.name, this.commissionAmount, this.policies);
}
