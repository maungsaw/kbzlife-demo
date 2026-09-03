import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../const.dart';
import '../providers/router_provider.dart';
import 'model.dart';
import '../widgets/pill_tabs.dart';

class UniversalLifeDetailScreen extends StatelessWidget {
  final ProductItem product;

  const UniversalLifeDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: context.iconXl,
            color: Colors.black87,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Product Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.colors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.share_outlined,
              size: context.iconXxl,
              color: Colors.black87,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProductHeader(context, product),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PillTabs(
                tabs: [
                  PillTab(label: 'About', child: _buildAboutTab(context, product)),
                  PillTab(label: 'Coverage', child: _buildCoverageTab(context, product)),
                  PillTab(label: 'Eligibility', child: _buildEligibleTab(context, product)),
                ],
              ),
            ),
          ),
          _buildBottomButton(context),
        ],
      ),
    );
  }

  Widget _buildProductHeader(BuildContext context, ProductItem product) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: context.colors.cyanAccent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                product.icon,
                size: context.icon4xl,
                color: context.colors.primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.shortDescription,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab(BuildContext context, ProductItem product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.fullDescription,
            style: TextStyle(
              fontSize: 14,
              color: context.colors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'This Policy Is Designed For',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ...product.designedFor.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildDesignedForItem(
                context: context,
                icon: item.icon,
                title: item.title,
                description: item.description,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Why Should You Buy This Policy?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ...product.whyBuy.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildWhyBuyItem(context, item),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDesignedForItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.colors.cyanAccent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Icon(icon, size: context.iconXl, color: context.colors.primaryColor),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
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
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWhyBuyItem(BuildContext context, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: context.colors.primaryColor,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, size: context.iconMd, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: context.colors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildCoverageTab(BuildContext context, ProductItem product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...product.benefits.map(
            (benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildCoverageSection(
                context: context,
                title: benefit,
                icon: Icons.check_circle_outline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverageSection({
    required BuildContext context,
    required String title,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.surfaceBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: context.iconXxl, color: context.colors.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: context.colors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEligibleTab(BuildContext context, ProductItem product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEligibilityRow(context, 'Minimum Entry Age', product.minAge),
          _buildEligibilityRow(context, 'Maximum Entry Age', product.maxAge),
          _buildEligibilityRow(context, 'Policy Term', product.policyTerm),
          _buildEligibilityRow(context, 'Minimum Premium', product.minPremium),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: context.colors.cyanAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: context.iconXl,
                  color: context.colors.primaryColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Contact your agent for full eligibility details and underwriting requirements.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEligibilityRow(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.colors.border, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: context.colors.border, width: 1)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            context.push('${RoutePaths.calculator}?product=${Uri.encodeComponent(product.title)}');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colors.primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'GET A QUOTE',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
