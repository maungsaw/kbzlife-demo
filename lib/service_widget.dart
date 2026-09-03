import 'commission.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'const.dart';
import 'crm/index.dart';
import 'login/index.dart';
import 'policy/index.dart';
import 'products/product_library_screen.dart';
import 'providers/router_provider.dart';
import 'task/index.dart';
import 'tracker/index.dart';

class ServiceItem {
  final String title;
  final FaIconData icon;
  final bool isGuestAllowed;
  final Widget Function(BuildContext)? targetScreen;
  final String? externalUrl;
  final int? tabIndex;
  final int? guestTabIndex;
  final Widget Function(BuildContext)? guestTargetScreen;

  const ServiceItem({
    required this.title,
    required this.icon,
    this.isGuestAllowed = false,
    this.targetScreen,
    this.externalUrl,
    this.tabIndex,
    this.guestTabIndex,
    this.guestTargetScreen,
  });
}

class ServiceRegistry {
  static const Map<String, String> routePaths = {
    'Products': RoutePaths.products,
    'Calculator': RoutePaths.calculator,
    'Proposal': RoutePaths.products,
    'Commission': RoutePaths.commission,
    'Tracker': RoutePaths.trackerList,
    'CRM': RoutePaths.crm,
    'Tasks': RoutePaths.taskList,
    'Policy': RoutePaths.policyList,
  };

  static const Map<String, String> guestRoutePaths = {
    'Products': '/guest/products',
    'Calculator': RoutePaths.calculator,
    'Proposal': RoutePaths.login,
    'Commission': RoutePaths.login,
    'Tracker': RoutePaths.login,
    'CRM': RoutePaths.login,
    'Tasks': RoutePaths.login,
    'Policy': RoutePaths.login,
  };
}

class ServicesCard extends StatelessWidget {
  final bool isGuest;

  const ServicesCard({super.key, this.isGuest = false});

  List<ServiceItem> get _services => [
    ServiceItem(
      title: 'Products',
      icon: FontAwesomeIcons.boxOpen,
      isGuestAllowed: true,
      tabIndex: 2,
      guestTabIndex: 1,
    ),
    ServiceItem(
      title: 'Calculator',
      icon: FontAwesomeIcons.calculator,
      isGuestAllowed: true,
    ),
    ServiceItem(
      title: 'Proposal',
      icon: FontAwesomeIcons.fileSignature,
      isGuestAllowed: false,
      tabIndex: 2,
      guestTabIndex: 2,
      targetScreen: (context) => const ProductsLibraryScreen(),
    ),
    ServiceItem(
      title: 'Commission',
      icon: FontAwesomeIcons.wallet,
      isGuestAllowed: false,
      targetScreen: (context) => CommissionReportScreen(),
    ),
    ServiceItem(
      title: 'Tracker',
      icon: FontAwesomeIcons.chartLine,
      isGuestAllowed: false,
      targetScreen: (context) => ApplicationTrackerListScreen(),
    ),
    ServiceItem(
      title: 'CRM',
      icon: FontAwesomeIcons.users,
      isGuestAllowed: false,
      targetScreen: (context) => CRMListViewScreen(),
      tabIndex: 1,
      guestTargetScreen: (context) => MobileLoginScreen(),
    ),
    ServiceItem(
      title: 'Tasks',
      icon: FontAwesomeIcons.listCheck,
      isGuestAllowed: false,
      targetScreen: (context) => const ModernTaskCalendarScreen(),
    ),
    ServiceItem(
      title: 'Policy',
      icon: FontAwesomeIcons.fileContract,
      isGuestAllowed: false,
      targetScreen: (context) => const PolicyListScreen(),
    ),

    const ServiceItem(
      title: 'Online',
      icon: FontAwesomeIcons.globe,
      isGuestAllowed: true,
      externalUrl: 'https://selfservice.kbzlife.com/',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: .circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: .start,
        mainAxisSize: .min,
        children: [
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                'Our Services',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: .w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),

              if (isGuest)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFFFEDD5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize
                        .min, // Prevents row from stretching infinitely
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_clock_rounded,
                        size:
                            14, // Set close to font size (11–14px) for proportional alignment
                        color: Color(0xFFF97316),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Guest Mode',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF97316),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 500 ? 5 : 4;
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: _services.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 6,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  final service = _services[index];
                  final isLocked = isGuest && !service.isGuestAllowed;
                  final accent = AppColors.primaryColor;

                  return _ServiceTile(
                    service: service,
                    accentColor: accent,
                    isLocked: isLocked,
                    isGuest: isGuest,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ServiceTile extends ConsumerStatefulWidget {
  final ServiceItem service;
  final Color accentColor;
  final bool isLocked;
  final bool isGuest;

  const _ServiceTile({
    required this.service,
    required this.accentColor,
    required this.isLocked,
    this.isGuest = false,
  });

  @override
  ConsumerState<_ServiceTile> createState() => _ServiceTileState();
}

class _ServiceTileState extends ConsumerState<_ServiceTile> {
  bool _isPressed = false;

  Future<void> _handleTap() async {
    if (widget.isGuest) {
      if (widget.service.externalUrl != null) {
        context.push(
          '${RoutePaths.webview}?url=${Uri.encodeComponent(widget.service.externalUrl!)}',
        );
      } else if (widget.service.guestTabIndex != null) {
        final paths = ['/guest/home', '/guest/products', '/guest/profile'];
        if (widget.service.guestTabIndex! < paths.length) {
          context.go(paths[widget.service.guestTabIndex!]);
        }
      } else {
        final path = ServiceRegistry.guestRoutePaths[widget.service.title];
        if (path != null) {
          context.push(path);
        } else {
          context.push(RoutePaths.login);
        }
      }
      return;
    }

    // Normal mode navigation
    if (widget.service.tabIndex != null) {
      final paths = ['/home', '/crm', '/products', '/profile'];
      if (widget.service.tabIndex! < paths.length) {
        context.go(paths[widget.service.tabIndex!]);
      }
    } else if (widget.service.externalUrl != null) {
      context.push(
        '${RoutePaths.webview}?url=${Uri.encodeComponent(widget.service.externalUrl!)}',
      );
    } else {
      final path = ServiceRegistry.routePaths[widget.service.title];
      if (path != null) {
        context.push(path);
      } else {
        context.push(RoutePaths.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isLocked
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: widget.isLocked
          ? null
          : (_) => setState(() => _isPressed = false),
      onTapCancel: widget.isLocked
          ? null
          : () => setState(() => _isPressed = false),
      onTap: widget.isLocked ? null : _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedOpacity(
          opacity: widget.isLocked ? 0.55 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.09),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: FaIcon(
                            widget.service.icon,
                            size: 32,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ),
                    ),
                    if (widget.isLocked)
                      Positioned(
                        top: -2,
                        right: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.5,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.lock_rounded,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.service.title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
