import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'const.dart';
import 'providers/router_provider.dart';
import 'service_widget.dart';

class AuthorizedAgentScreen extends ConsumerStatefulWidget {
  const AuthorizedAgentScreen({super.key});

  @override
  ConsumerState<AuthorizedAgentScreen> createState() =>
      _AuthorizedAgentScreenState();
}

class _AuthorizedAgentScreenState extends ConsumerState<AuthorizedAgentScreen> {
  late PageController _pageController;
  Timer? _carouselTimer;
  int _currentBannerIndex = 0;

  final List<Map<String, String>> _campaigns = [
    {
      'tag': 'FEATURED CAMPAIGN',
      'title': 'Summer Protection Drive',
      'description':
          'Earn up to 15% extra commission on Life & Health policies this month.',
      'buttonText': 'Join Campaign',
      'imageUrl': 'assets/icons/images.png',
    },
    {
      'tag': 'LIMITED TIME',
      'title': 'AutoShield Booster',
      'description':
          'Double bonus points for every vehicle coverage issued this week.',
      'buttonText': 'Claim Bonus',
      'imageUrl': 'assets/icons/images.png',
    },
    {
      'tag': 'REFERRAL PROGRAM',
      'title': 'Agent Network Rewards',
      'description': 'Refer a new agent to receive 250,000 MMK cash reward.',
      'buttonText': 'Refer Agent',
      'imageUrl': 'assets/icons/images.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        _currentBannerIndex = (_currentBannerIndex + 1) % _campaigns.length;
        _pageController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 600),
          curve: Curves.fastOutSlowIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryColor, width: 2),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/icons/brand-mark.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 32,
                        height: 32,
                        color: Colors.blue[100],
                        child: const Icon(
                          Icons.account_circle_rounded,
                          color: Colors.blue,
                          size: 20,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning,',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  'Agent Alex',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_active_rounded,
                      color: AppColors.primaryColor,
                    ),
                    onPressed: () {
                      context.push(RoutePaths.notificationInbox);
                    },
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        '3',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: AppColors.border, height: 1),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 80),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 12),
                _buildMyPerformance(),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: ServicesCard(),
                ),
                const SizedBox(height: 12),
                _buildCampaignCarousel(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyPerformance() {
    return InkWell(
      onTap: () {
        context.push(RoutePaths.performance);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.baltic.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: AppColors.baltic.withValues(alpha: 0.04),
              blurRadius: 28,
              spreadRadius: -4,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'My Performance',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Keep going! You're on the right track.",
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    context.push(RoutePaths.performance);
                  },
                  child: const Text('View Details'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildRoadToMdrtCard(),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.45,
              padding: const EdgeInsets.only(bottom: 12),
              children: const [
                _MetricCard(
                  icon: Icons.account_balance_wallet_rounded,
                  iconBgColor: Color(0xFFE3F2FD),
                  iconColor: Color(0xFF1E88E5),
                  title: 'FYP',
                  value: '8.75 K',
                  currency: 'MMK',
                  percentage: '↑ 12.5%',
                  comparedTo: 'vs Last Month',
                ),
                _MetricCard(
                  icon: Icons.monetization_on_rounded,
                  iconBgColor: Color(0xFFEDE7F6),
                  iconColor: Color(0xFF7E57C2),
                  title: 'Commission',
                  value: '1.25 K',
                  currency: 'MMK',
                  percentage: '↑ 8.3%',
                  comparedTo: 'vs Last Month',
                ),
                _MetricCard(
                  icon: Icons.shield_outlined,
                  iconBgColor: Color(0xFFE8F5E9),
                  iconColor: Color(0xFF43A047),
                  title: 'Policies',
                  value: '24',
                  percentage: '↑ 14.2%',
                  comparedTo: 'vs Last Month',
                ),
                _MetricCard(
                  icon: Icons.bar_chart_rounded,
                  iconBgColor: Color(0xFFFFF3E0),
                  iconColor: Color(0xFFFB8C00),
                  title: 'Persistency',
                  value: '75%',
                  percentage: '↑ 2.6%',
                  comparedTo: 'vs Last Month',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoadToMdrtCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.military_tech,
              color: Color(0xFF1E88E5),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Road to MDRT',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 0.4,
                    minHeight: 6,
                    backgroundColor: Color(0xFFE0E0E0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF0288D1),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            '40%',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0288D1),
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildCampaignCarousel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: MediaQuery.of(context).size.height * 0.22,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentNavy.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: AppColors.accentNavy.withValues(alpha: 0.04),
            blurRadius: 28,
            spreadRadius: -4,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentBannerIndex = index);
            },
            itemCount: _campaigns.length,
            itemBuilder: (context, index) {
              final item = _campaigns[index];
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(item['imageUrl']!),
                    fit: BoxFit.fill,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.85),
                        Colors.black.withValues(alpha: 0.3),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              item['tag']!,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item['title']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['description']!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IntrinsicWidth(
                          child: SizedBox(
                            height: 32,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                context.push(RoutePaths.login);
                              },
                              icon: const Icon(
                                Icons.rocket_launch_outlined,
                                size: 13,
                              ),
                              label: Text(item['buttonText']!),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppColors.primaryColor,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _campaigns.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 6,
                  width: _currentBannerIndex == index ? 18 : 6,
                  decoration: BoxDecoration(
                    color: _currentBannerIndex == index
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String title;
  final String value;
  final String? currency;
  final String percentage;
  final String comparedTo;

  const _MetricCard({
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    required this.title,
    required this.value,
    this.currency,
    required this.percentage,
    required this.comparedTo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
              if (currency != null) ...[
                const SizedBox(width: 4),
                Text(
                  currency!,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ],
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                percentage,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Text(
                comparedTo,
                style: const TextStyle(fontSize: 9, color: Colors.black38),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
