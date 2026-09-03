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
      color: context.colors.cream,
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
                  border: Border.all(
                    color: context.colors.primaryColor,
                    width: 2,
                  ),
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
                        child: Icon(
                          Icons.account_circle_rounded,
                          color: Colors.blue,
                          size: context.iconXl,
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
                    icon: Icon(
                      Icons.notifications_active_rounded,
                      color: context.colors.primaryColor,
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
              child: Container(color: context.colors.border, height: 1),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 80),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                _buildMyPerformance(),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: ServicesCard(),
                ),
                const SizedBox(height: 8),
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
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Performance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    context.push(RoutePaths.performance);
                  },
                  child: const Text('View Details'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildRoadToMdrtCard(),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 2.4,
              padding: EdgeInsets.zero,
              children: [
                _MetricCard(title: 'FYP', value: '8.75 K', currency: 'MMK'),
                _MetricCard(
                  title: 'Commission',
                  value: '1.25 K',
                  currency: 'MMK',
                ),
                _MetricCard(title: 'Policies', value: '24'),
                _MetricCard(title: 'Persistency', value: '75%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoadToMdrtCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: context.colors.infoLight,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.military_tech,
              color: context.colors.infoText,
              size: context.iconLg,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Road to MDRT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.4,
                    minHeight: 4,
                    backgroundColor: context.colors.divider,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      context.colors.infoText,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '40%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: context.colors.infoText,
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey, size: context.iconLg),
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
                                foregroundColor: context.colors.primaryColor,
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
  final String title;
  final String value;
  final String? currency;

  const _MetricCard({required this.title, required this.value, this.currency});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text.rich(
            TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.colors.primaryColor,
              ),
              children: [
                if (currency != null && currency!.isNotEmpty)
                  TextSpan(
                    text: ' $currency',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: context.colors.primaryColor,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
