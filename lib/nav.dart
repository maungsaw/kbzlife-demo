import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

import 'const.dart';
import 'providers/nav_provider.dart';
import 'providers/router_provider.dart';

class BottomApp extends ConsumerWidget {
  final bool isGuest;
  final bool isOnline;
  final ValueChanged<int>? onTabChanged;
  final int currentIndex;
  final bool showFab;

  const BottomApp({
    super.key,
    required this.isGuest,
    this.isOnline = true,
    this.onTabChanged,
    this.currentIndex = 0,
    this.showFab = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final currentTab = onTabChanged != null
        ? _tabIndexFromPath(location)
        : ref.watch(currentTabProvider);
    const double barHeight = 56.0;

    final tabs = isGuest
        ? _guestTabs(context, ref, currentTab)
        : _authTabs(context, ref, currentTab);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              height: barHeight,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(barHeight / 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: tabs,
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (showFab) _buildFab(context, ref),
        ],
      ),
    );
  }

  List<Widget> _guestTabs(BuildContext context, WidgetRef ref, int currentTab) {
    return [
      _tooltip(
        message: 'Home',
        child: IconButton(
          icon: FaIcon(
            FontAwesomeIcons.solidHouse,
            color: currentTab == 0 ? context.colors.primaryColor : Colors.grey,
            size: context.iconLg,
          ),
          onPressed: () => onTabChanged?.call(0),
        ),
      ),
      _tooltip(
        message: 'CRM',
        child: IconButton(
          icon: FaIcon(
            FontAwesomeIcons.users,
            color: currentTab == 1 ? context.colors.primaryColor : Colors.grey,
            size: context.iconLg,
          ),
          onPressed: () => onTabChanged?.call(1),
        ),
      ),
      _tooltip(
        message: 'Products',
        child: IconButton(
          icon: FaIcon(
            FontAwesomeIcons.boxOpen,
            color: currentTab == 2 ? context.colors.primaryColor : Colors.grey,
            size: context.iconLg,
          ),
          onPressed: () => onTabChanged?.call(2),
        ),
      ),
      _tooltip(
        message: 'Profile',
        child: IconButton(
          icon: FaIcon(
            FontAwesomeIcons.solidUser,
            color: currentTab == 3 ? context.colors.primaryColor : Colors.grey,
            size: context.iconLg,
          ),
          onPressed: () => onTabChanged?.call(3),
        ),
      ),
    ];
  }

  List<Widget> _authTabs(BuildContext context, WidgetRef ref, int currentTab) {
    return [
      _tooltip(
        message: 'Home',
        child: IconButton(
          icon: FaIcon(
            FontAwesomeIcons.solidHouse,
            color: currentTab == 0 ? context.colors.primaryColor : Colors.grey,
            size: context.iconLg,
          ),
          onPressed: () => onTabChanged?.call(0),
        ),
      ),
      _tooltip(
        message: 'CRM',
        child: IconButton(
          icon: FaIcon(
            FontAwesomeIcons.users,
            color: currentTab == 1 ? context.colors.primaryColor : Colors.grey,
            size: context.iconLg,
          ),
          onPressed: () => onTabChanged?.call(1),
        ),
      ),
      _tooltip(
        message: 'Products',
        child: IconButton(
          icon: FaIcon(
            FontAwesomeIcons.boxOpen,
            color: currentTab == 2 ? context.colors.primaryColor : Colors.grey,
            size: context.iconLg,
          ),
          onPressed: () => onTabChanged?.call(2),
        ),
      ),
      _tooltip(
        message: 'Profile',
        child: _buildUserIconButton(context, ref, currentTab, onTabChanged),
      ),
    ];
  }

  int _tabIndexFromPath(String path) {
    if (path.startsWith('/guest')) {
      if (path.contains('/calculator')) return 1;
      if (path.contains('/products')) return 2;
      if (path.contains('/profile')) return 3;
      return 0;
    }
    if (path.contains('/crm')) return 1;
    if (path.contains('/products')) return 2;
    if (path.contains('/profile')) return 3;
    return 0;
  }

  Widget _tooltip({required String message, required Widget child}) {
    return Tooltip(
      message: message,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      showDuration: const Duration(milliseconds: 1200),
      waitDuration: const Duration(milliseconds: 300),
      child: child,
    );
  }

  Widget _buildFab(BuildContext context, WidgetRef ref) {
    const double mainFabSize = 56.0;

    return CompositedTransformTarget(
      link: LayerLink(),
      child: _tooltip(
        message: isGuest ? 'Login' : 'More Options',
        child: GestureDetector(
          onTap: () {
            if (isGuest) {
              context.push(RoutePaths.login);
            } else {
              _showOverlayMenu(context);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: mainFabSize,
            height: mainFabSize,
            decoration: BoxDecoration(
              color: context.colors.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: FaIcon(
                isGuest
                    ? FontAwesomeIcons.shieldHeart
                    : FontAwesomeIcons.shieldHeart,
                color: Colors.white,
                size: context.iconXl,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserIconButton(
    BuildContext context,
    WidgetRef ref,
    int currentTab,
    ValueChanged<int>? onTabChanged,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.solidUser,
            color: currentTab == 3 ? context.colors.primaryColor : Colors.grey,
            size: context.iconLg,
          ),
          onPressed: () {
            if (onTabChanged != null) {
              onTabChanged(3);
            } else {
              ref.read(currentTabProvider.notifier).state = 3;
            }
          },
        ),
        Positioned(
          right: 8,
          top: 10,
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: isOnline ? context.colors.online : context.colors.away,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  void _showOverlayMenu(BuildContext context) {
    void navigateTo(String path) {
      context.push(path);
    }

    showGeneralDialog(
      context: context,
      barrierLabel: 'overlay_menu',
      barrierColor: Colors.black.withValues(alpha: 0.2),
      barrierDismissible: true,
      pageBuilder: (_, _, _) => const SizedBox.shrink(),
      transitionBuilder: (_, animation, _, child) {
        return FadeTransition(
          opacity: animation,
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 88, right: 20),
              child: _overlayMenuRow(context, navigateTo),
            ),
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
  }

  Widget _overlayMenuRow(BuildContext context, Function(String) navigateTo) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _overlayItem(
            context: context,
            icon: FontAwesomeIcons.fileSignature,
            label: 'Create Proposal',
            onTap: () {
              Navigator.pop(context);
              navigateTo(RoutePaths.products);
            },
          ),
          const SizedBox(height: 16),
          _overlayItem(
            context: context,
            icon: FontAwesomeIcons.userPlus,
            label: 'Add People',
            onTap: () {
              Navigator.pop(context);
              navigateTo(RoutePaths.crmCreateLead);
            },
          ),
          const SizedBox(height: 16),
          _overlayItem(
            context: context,
            icon: FontAwesomeIcons.listCheck,
            label: 'Create Task',
            onTap: () {
              Navigator.pop(context);
              navigateTo(RoutePaths.taskCreate);
            },
          ),
        ],
      ),
    );
  }

  Widget _overlayItem({
    required BuildContext context,
    required FaIconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: context.colors.primaryColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: FaIcon(icon, color: Colors.white, size: context.iconLg),
          ),
        ),
      ),
    );
  }
}

class NavShell extends ConsumerStatefulWidget {
  final bool isGuest;
  final bool isOnline;
  final StatefulNavigationShell? navigationShell;

  const NavShell({
    super.key,
    required this.isGuest,
    this.isOnline = true,
    this.navigationShell,
  });

  @override
  ConsumerState<NavShell> createState() => _NavShellState();
}

class _NavShellState extends ConsumerState<NavShell> {
  @override
  Widget build(BuildContext context) {
    final tabPaths = widget.isGuest
        ? ['/guest/home', 'login', '/guest/products', '/guest/profile']
        : ['/home', '/crm', '/products', '/profile'];

    return Scaffold(
      backgroundColor: context.colors.cream,
      body: widget.navigationShell,
      bottomNavigationBar: BottomApp(
        isGuest: widget.isGuest,
        isOnline: widget.isOnline,
        onTabChanged: (index) => context.go(tabPaths[index]),
        currentIndex: widget.navigationShell?.currentIndex ?? 0,
        showFab: true,
      ),
    );
  }
}
