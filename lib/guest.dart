import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'const.dart';
import 'providers/router_provider.dart';
import 'service_widget.dart';

class BeforeLoginDashboardScreen extends ConsumerStatefulWidget {
  final VoidCallback? onLogin;
  final VoidCallback? onRegister;

  const BeforeLoginDashboardScreen({super.key, this.onLogin, this.onRegister});

  @override
  ConsumerState<BeforeLoginDashboardScreen> createState() =>
      _BeforeLoginDashboardScreenState();
}

class _BeforeLoginDashboardScreenState
    extends ConsumerState<BeforeLoginDashboardScreen> {
  late PageController _pageController;
  Timer? _carouselTimer;
  int _currentBannerIndex = 0;

  final List<Map<String, String>> _guestCampaigns = [
    {
      'tag': 'RECRUITMENT PROMO',
      'title': 'Grow Your Agency',
      'description':
          'Earn up to 35% commission, access instant tools, and issue policies on the go.',
      'buttonText': 'Become an Agent',
      'imageUrl':
          'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=800&q=80',
    },
    {
      'tag': 'WELCOME BONUS',
      'title': 'Fast-Track Onboarding',
      'description':
          'Complete initial licensing training to earn a 100,000 MMK starter bonus.',
      'buttonText': 'Register Today',
      'imageUrl':
          'https://images.unsplash.com/photo-1557804506-669a67965ba0?auto=format&fit=crop&w=800&q=80',
    },
    {
      'tag': 'COMMISSION BOOST',
      'title': 'High-Demand Products',
      'description':
          'Explore top-converting Motor & Health insurance plans with immediate payout.',
      'buttonText': 'View Catalog',
      'imageUrl':
          'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&w=800&q=80',
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
        _currentBannerIndex =
            (_currentBannerIndex + 1) % _guestCampaigns.length;
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

  // void _handleTabNavigation(int index) {
  //   if (index == 1) {
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => MobileLoginScreen()),
  //     );
  //   } else {
  //     ref.read(guestTabProvider.notifier).state = index;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.cream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: context.colors.primaryColor, width: 2),
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
              'Welcome,',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              'Guest Agent',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () => context.push(RoutePaths.login),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: Size(0, 36),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildGuestHomeContent(),
    );
  }

  Widget _buildGuestHomeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 12),
          _buildCampaignCarousel(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ServicesCard(isGuest: true),
          ),
          const SizedBox(height: 16),
          _buildWhyJoinSection(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCampaignCarousel() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentBannerIndex = index);
            },
            itemCount: _guestCampaigns.length,
            itemBuilder: (context, index) {
              final item = _guestCampaigns[index];
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: NetworkImage(item['imageUrl']!),
                    fit: BoxFit.cover,
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
                              icon: Icon(
                                Icons.rocket_launch_outlined,
                                size: context.iconSm,
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
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _guestCampaigns.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              width: _currentBannerIndex == index ? 18 : 6,
              decoration: BoxDecoration(
                color: _currentBannerIndex == index
                    ? context.colors.primaryColor
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWhyJoinSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Why Join Our Network',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  value: '5,000+',
                  label: 'Agents',
                  sublabel: 'Nationwide',
                ),
              ),
              Container(width: 1, height: 40, color: context.colors.divider),
              Expanded(
                child: _buildStatCard(
                  value: '24 Hrs',
                  label: 'Avg Payout',
                  sublabel: 'Fast Claims',
                ),
              ),
              Container(width: 1, height: 40, color: context.colors.divider),
              Expanded(
                child: _buildStatCard(
                  value: 'Up to 35%',
                  label: 'Commission',
                  sublabel: 'Tiered Boost',
                ),
              ),
              Container(width: 1, height: 40, color: context.colors.divider),
              Expanded(
                child: _buildStatCard(
                  value: 'Dedicated',
                  label: 'Support',
                  sublabel: 'Desk',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required String sublabel,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: context.colors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: context.colors.primaryColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sublabel,
            style: TextStyle(
              fontSize: 9,
              color: context.colors.primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
