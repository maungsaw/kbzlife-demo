import 'commission.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:go_router/go_router.dart';

import 'const.dart';
import 'crm/index.dart';
import 'eapp/eapp_screen.dart';
import 'login/index.dart';
import 'policy/index.dart';
import 'providers/router_provider.dart';
import 'task/index.dart';
import 'tracker/index.dart';

class ServiceItem {
  final String title;
  final IconData icon;
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
    'Proposal': RoutePaths.eapp,
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
      icon: BootstrapIcons.box_seam,
      isGuestAllowed: true,
      tabIndex: 2,
      guestTabIndex: 1,
    ),
    ServiceItem(
      title: 'Calculator',
      icon: BootstrapIcons.calculator,
      isGuestAllowed: true,
    ),
    const ServiceItem(
      title: 'Online',
      icon: BootstrapIcons.globe,
      isGuestAllowed: true,
      externalUrl: 'https://selfservice.kbzlife.com/',
    ),
    ServiceItem(
      title: 'Proposal',
      icon: BootstrapIcons.file_earmark_text,
      isGuestAllowed: false,
      targetScreen: (context) => const EAppScreen(),
    ),
    ServiceItem(
      title: 'Commission',
      icon: BootstrapIcons.wallet2,
      isGuestAllowed: false,
      targetScreen: (context) => CommissionReportScreen(),
    ),
    ServiceItem(
      title: 'Tracker',
      icon: BootstrapIcons.graph_up,
      isGuestAllowed: false,
      targetScreen: (context) => ApplicationTrackerListScreen(),
    ),
    ServiceItem(
      title: 'CRM',
      icon: BootstrapIcons.people,
      isGuestAllowed: false,
      targetScreen: (context) => CRMListViewScreen(),
      tabIndex: 1,
      guestTargetScreen: (context) => MobileLoginScreen(),
    ),
    ServiceItem(
      title: 'Tasks',
      icon: BootstrapIcons.list_check,
      isGuestAllowed: false,
      targetScreen: (context) => const ModernTaskCalendarScreen(),
    ),
    ServiceItem(
      title: 'Policy',
      icon: BootstrapIcons.file_text,
      isGuestAllowed: false,
      targetScreen: (context) => const PolicyListScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: .circular(20),
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
                  letterSpacing: -0.3,
                  fontWeight: .bold,
                ),
              ),

              if (isGuest)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.sizeOf(context).width * 0.018,
                    vertical: MediaQuery.sizeOf(context).height * 0.004,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.warningLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.colors.warningBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.lock_clock_rounded,
                        size: context.iconSm,
                        color: context.colors.warningText,
                      ),
                      SizedBox(width: MediaQuery.sizeOf(context).width * 0.008),
                      Text(
                        'Guest Mode',
                        style: TextStyle(
                          fontSize: MediaQuery.sizeOf(context).width * 0.025,
                          fontWeight: FontWeight.w700,
                          color: context.colors.warningText,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.012),
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
                  final accent = context.colors.primaryColor;

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
      final paths = ['/home', '/crm', '/products', '/profile', '/e-app'];
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tileSize = constraints.maxWidth;
              final textSpace = 20.0;
              final containerSize = (tileSize - textSpace).clamp(40.0, 54.0);
              final iconSize = containerSize * 0.48;
              final lockIconSize = containerSize * 0.18;

              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: containerSize,
                    height: containerSize,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.colors.primaryColor,
                              borderRadius: BorderRadius.circular(
                                containerSize * 0.50,
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                widget.service.icon,
                                size: iconSize,
                                color: context.colors.surfaceBg,
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
                                color: context.colors.primaryColor.withValues(
                                  alpha: 0.5,
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                Icons.lock_rounded,
                                size: lockIconSize,
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
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: context.colors.textSecondary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
