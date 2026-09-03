import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'const.dart';

class ComparisonScreen extends ConsumerStatefulWidget {
  final int age;
  final double monthlyPremium;
  final int policyTermYears;
  final double calculatedSumInsured;
  final int ageMultiplier;

  const ComparisonScreen({
    super.key,
    required this.age,
    required this.monthlyPremium,
    required this.policyTermYears,
    required this.calculatedSumInsured,
    required this.ageMultiplier,
  });

  @override
  ConsumerState<ComparisonScreen> createState() => _ComparisonScreenState();
}

class _ComparisonScreenState extends ConsumerState<ComparisonScreen> {
  int _selectedProductIndex = 0;

  @override
  Widget build(BuildContext context) {
    final annualized = widget.monthlyPremium * 12;

    final List<_ComparisonProduct> products = [
      _ComparisonProduct(
        name: 'KBZ Universal Life',
        tag: 'Recommended Plan',
        isPrimary: true,
        sumInsured: widget.calculatedSumInsured,
        multiplier: '${widget.ageMultiplier}x Annual APE',
        maturityType: 'Age 80 Limit',
        investmentGrowth: 'Guaranteed + Dividend',
        partialWithdrawal: 'Allowed (Post Year 3)',
        policyLoan: 'Up to 80% Cash Value',
        claimProcess: 'Priority Fast-Track',
      ),
      _ComparisonProduct(
        name: 'Short Term Endowment',
        tag: 'Guaranteed Saving',
        isPrimary: false,
        sumInsured: annualized * 15,
        multiplier: '15x Fixed',
        maturityType: '${widget.policyTermYears} Years Fixed',
        investmentGrowth: 'Fixed Guaranteed Rate',
        partialWithdrawal: 'Not Allowed',
        policyLoan: 'Not Available',
        claimProcess: 'Standard Processing',
      ),
      _ComparisonProduct(
        name: 'Term Life Insurance',
        tag: 'Pure Protection',
        isPrimary: false,
        sumInsured: annualized * 10,
        multiplier: '10x Fixed',
        maturityType: '${widget.policyTermYears} Years Fixed',
        investmentGrowth: 'None (Pure Protection)',
        partialWithdrawal: 'Not Allowed',
        policyLoan: 'Not Available',
        claimProcess: 'Standard Processing',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text(
              'Compare Plans',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Age ${widget.age} • MMK ${_formatCurrency(widget.monthlyPremium)}/mo',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // Dynamic Product Selector Tabs
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedProductIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(products[index].name),
                    selected: isSelected,
                    selectedColor: AppColors.primaryColor,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primaryColor
                          : Colors.grey.shade300,
                    ),
                    onSelected: (_) =>
                        setState(() => _selectedProductIndex = index),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Main Comparative Feature List
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildComparisonCard(
                    context,
                    product: products[_selectedProductIndex],
                  ),
                  const SizedBox(height: 20),

                  // Feature Details Matrix
                  _buildFeatureMatrix(products[_selectedProductIndex]),
                ],
              ),
            ),
          ),
        ],
      ),

      // Floating Action Bottom Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Coverage',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    Text(
                      'MMK ${_formatCurrency(products[_selectedProductIndex].sumInsured)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 48,
                width: 160,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => const UniversalLifeEAppScreen(),
                    //   ),
                    // );
                  },
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: const Text(
                    'Select Plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonCard(
    BuildContext context, {
    required _ComparisonProduct product,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: product.isPrimary ? AppColors.accentNavy : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: product.isPrimary
              ? AppColors.accentNavy
              : Colors.grey.shade200,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: product.isPrimary
                      ? AppColors.goldAccent.withValues(alpha: 0.2)
                      : Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  product.tag.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: product.isPrimary
                        ? AppColors.goldAccent
                        : Colors.blue.shade700,
                  ),
                ),
              ),
              if (product.isPrimary)
                const Icon(
                  Icons.stars_rounded,
                  color: AppColors.goldAccent,
                  size: 22,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            product.name,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: product.isPrimary ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'ESTIMATED COVERAGE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: product.isPrimary ? Colors.white60 : Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'MMK ${_formatCurrency(product.sumInsured)}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: product.isPrimary ? Colors.white : AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureMatrix(_ComparisonProduct product) {
    final features = [
      _FeatureRow(
        'Coverage Multiplier',
        product.multiplier,
        Icons.bar_chart_rounded,
      ),
      _FeatureRow(
        'Policy Duration',
        product.maturityType,
        Icons.timer_outlined,
      ),
      _FeatureRow(
        'Investment Growth',
        product.investmentGrowth,
        Icons.trending_up_rounded,
      ),
      _FeatureRow(
        'Partial Withdrawal',
        product.partialWithdrawal,
        Icons.account_balance_wallet_outlined,
      ),
      _FeatureRow(
        'Policy Loan Benefit',
        product.policyLoan,
        Icons.request_quote_outlined,
      ),
      _FeatureRow('Claim Settlement', product.claimProcess, Icons.bolt_rounded),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: features.map((f) {
          final isLast = features.last == f;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        f.icon,
                        size: 18,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f.title,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            f.value,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) Divider(height: 1, color: Colors.grey.shade100),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

class _ComparisonProduct {
  final String name;
  final String tag;
  final bool isPrimary;
  final double sumInsured;
  final String multiplier;
  final String maturityType;
  final String investmentGrowth;
  final String partialWithdrawal;
  final String policyLoan;
  final String claimProcess;

  _ComparisonProduct({
    required this.name,
    required this.tag,
    required this.isPrimary,
    required this.sumInsured,
    required this.multiplier,
    required this.maturityType,
    required this.investmentGrowth,
    required this.partialWithdrawal,
    required this.policyLoan,
    required this.claimProcess,
  });
}

class _FeatureRow {
  final String title;
  final String value;
  final IconData icon;

  _FeatureRow(this.title, this.value, this.icon);
}
