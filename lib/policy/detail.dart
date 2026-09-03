import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../const.dart';
import '../providers/router_provider.dart';
import '../widgets/tab_view.dart';

class PolicyDetailScreen extends ConsumerStatefulWidget {
  final String policyNo;

  const PolicyDetailScreen({super.key, this.policyNo = 'POL12345678'});

  @override
  ConsumerState<PolicyDetailScreen> createState() =>
      _PolicyDetailScreenState();
}

class _PolicyDetailScreenState extends ConsumerState<PolicyDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showMoreActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'More Actions',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildActionTile(
                  icon: Icons.download_outlined,
                  title: 'Download Policy Document',
                  onTap: () => context.pop(),
                ),
                _buildActionTile(
                  icon: Icons.share_outlined,
                  title: 'Share Policy Details',
                  onTap: () => context.pop(),
                ),
                _buildActionTile(
                  icon: Icons.receipt_long_outlined,
                  title: 'View Payment History',
                  onTap: () {
                    context.pop();
                    _tabController.animateTo(2);
                  },
                ),
                _buildActionTile(
                  icon: Icons.history_outlined,
                  title: 'View Policy Timeline',
                  onTap: () {
                    context.pop();
                    context.push(RoutePaths.policyTimeline);
                  },
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.grey.shade100,
                    ),
                    onPressed: () => context.pop(),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: const Color(0xFFF8F9FA),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          leading: Icon(icon, color: Colors.black, size: 22),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            size: 18,
            color: Colors.grey,
          ),
          onTap: onTap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Policy Detail',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black, size: 24),
            onPressed: () => _showMoreActions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.policyNo,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: const [
                          CircleAvatar(
                            radius: 3,
                            backgroundColor: Colors.green,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Active',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Universal Life Plan',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.picture_as_pdf_rounded,
                          size: 16,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'View Policy Document',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomTabView(
              controller: _tabController,
              tabs: const [
                TabItemData(label: 'Overview'),
                TabItemData(label: 'Coverage'),
                TabItemData(label: 'Payment'),
                TabItemData(label: 'Beneficiaries'),
              ],
              tabViews: [
                _buildOverviewTab(),
                _buildCoverageTab(),
                _buildPaymentTab(),
                _buildBeneficiariesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildNextDueBanner(),
        const SizedBox(height: 16),
        _buildInfoCard([
          _buildInfoRow(Icons.person_outline, 'Client Name', 'U Win Htet'),
          _buildInfoRow(Icons.badge_outlined, 'Client ID', 'CLT123456'),
          _buildInfoRow(
            Icons.credit_card_outlined,
            'NRC Number',
            '12/ABCD(N)123456',
          ),
          _buildInfoRow(Icons.phone_outlined, 'Phone Number', '09 420 123 456'),
          _buildInfoRow(
            Icons.calendar_today_outlined,
            'Policy Issue Date',
            '15 Jun 2021',
          ),
          _buildInfoRow(
            Icons.verified_user_outlined,
            'Policy Status',
            'Active',
            isStatus: true,
          ),
          _buildInfoRow(Icons.shield_outlined, 'Sum Assured', 'MMK 50,000,000'),
          _buildInfoRow(
            Icons.account_balance_wallet_outlined,
            'Premium Amount',
            'MMK 120,000',
            isLast: true,
          ),
        ]),
      ],
    );
  }

  Widget _buildNextDueBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withValues(alpha: 0.12),
            AppColors.primaryColor.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_repeat,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  'Next Premium Due',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '15 Sep 2025',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoverageTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Plan Coverage'),
        const SizedBox(height: 10),
        _buildInfoCard([
          _buildDetailRow('Basic Life Benefit', 'MMK 50,000,000'),
          _buildDetailRow('Accidental Death Benefit', 'MMK 50,000,000'),
          _buildDetailRow('Total & Permanent Disability', 'MMK 50,000,000'),
          _buildDetailRow('Critical Illness Benefit', 'MMK 25,000,000'),
          _buildDetailRow(
            'Hospital Cash Benefit',
            'MMK 100,000/Day',
            isLast: true,
          ),
        ]),
        const SizedBox(height: 20),
        _buildSectionHeader('Coverage Period'),
        const SizedBox(height: 10),
        _buildInfoCard([
          _buildDetailRow('Policy Term', '30 Years'),
          _buildDetailRow(
            'Effective Date Range',
            '15 Jun 2024 – 15 Jun 2054',
            isLast: true,
          ),
        ]),
      ],
    );
  }

  Widget _buildPaymentTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Premium Summary'),
        const SizedBox(height: 10),
        _buildInfoCard([
          _buildDetailRow('Premium Amount', 'MMK 120,000'),
          _buildDetailRow('Payment Mode', 'Annual'),
          _buildDetailRow(
            'Next Premium Due',
            '15 Sep 2025',
            highlightColor: AppColors.primaryColor,
          ),
          _buildDetailRow('Grace Period End Date', '15 Oct 2025', isLast: true),
        ]),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('Payment History'),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
              child: Text(
                'View All',
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildPaymentItem(
          '15 Jun 2024',
          'MMK 120,000',
          'Paid',
          'RCP2406150001',
        ),
        _buildPaymentItem(
          '15 Jun 2023',
          'MMK 120,000',
          'Paid',
          'RCP2306150001',
        ),
        _buildPaymentItem(
          '15 Jun 2022',
          'MMK 120,000',
          'Paid',
          'RCP2206150001',
        ),
      ],
    );
  }

  Widget _buildBeneficiariesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionHeader('Primary Beneficiaries'),
        const SizedBox(height: 10),
        _buildBeneficiaryCard('Daw Khin Moe', 'Wife', '60%', isPrimary: true),
        const SizedBox(height: 20),
        _buildSectionHeader('Contingent Beneficiaries'),
        const SizedBox(height: 10),
        _buildBeneficiaryCard(
          'Ma Htet Htet',
          'Daughter',
          '30%',
          isPrimary: false,
        ),
        const SizedBox(height: 10),
        _buildBeneficiaryCard(
          'U Aung Than',
          'Brother',
          '10%',
          isPrimary: false,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 16,
        letterSpacing: -0.3,
        color: Colors.black,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isStatus = false,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: Colors.grey.shade700),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const Spacer(),
          if (isStatus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? highlightColor,
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: highlightColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(
    String date,
    String amount,
    String status,
    String receiptNo,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, color: Colors.green, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Receipt: $receiptNo',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: .end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                status,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBeneficiaryCard(
    String name,
    String relationship,
    String share, {
    required bool isPrimary,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isPrimary
                            ? AppColors.primaryColor.withValues(alpha: 0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isPrimary ? 'Primary' : 'Contingent',
                        style: TextStyle(
                          color: isPrimary
                              ? AppColors.primaryColor
                              : Colors.grey.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Relationship: $relationship',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: .end,
            children: [
              Text(
                'Share',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
              ),
              Text(
                share,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PolicyTimelineScreen extends StatelessWidget {
  const PolicyTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Policy Timeline',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildTimelineTile(
            date: '15 Jun 2024',
            title: 'Policy Issued',
            description: 'Policy has been successfully issued.',
            icon: Icons.assignment_turned_in_rounded,
            iconColor: AppColors.primaryColor,
          ),
          _buildTimelineTile(
            date: '15 Jun 2024',
            title: 'Premium Paid',
            description: 'Annual premium MMK 120,000 has been paid.',
            icon: Icons.payments_rounded,
            iconColor: Colors.blue.shade600,
          ),
          _buildTimelineTile(
            date: '15 Sep 2024',
            title: 'Next Premium Due',
            description: 'Next premium MMK 120,000 due on 15 Sep 2025.',
            icon: Icons.event_rounded,
            iconColor: Colors.orange.shade700,
          ),
          _buildTimelineTile(
            date: '15 Jun 2025',
            title: 'Policy In Force',
            description: 'Policy is active and in force.',
            icon: Icons.check_circle_rounded,
            iconColor: Colors.purple.shade600,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineTile({
    required String date,
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: .start,
      children: [
        Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            if (!isLast)
              Container(width: 2, height: 48, color: Colors.grey.shade300),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
