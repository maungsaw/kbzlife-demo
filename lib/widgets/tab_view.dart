import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../const.dart';

/// Data class representing a single tab item
class TabItemData {
  final String label;
  final IconData? icon;

  const TabItemData({required this.label, this.icon});
}

/// A highly reusable, customizable TabView component
class CustomTabView extends ConsumerStatefulWidget {
  final List<TabItemData> tabs;
  final List<Widget> tabViews;
  final Color? indicatorColor;
  final Color? labelColor;
  final Color? unselectedLabelColor;
  final bool isScrollable;
  final TabController? controller;

  const CustomTabView({
    super.key,
    required this.tabs,
    required this.tabViews,
    this.indicatorColor,
    this.labelColor,
    this.unselectedLabelColor,
    this.isScrollable = false,
    this.controller,
  }) : assert(
         tabs.length == tabViews.length,
         'The number of tabs must match the number of tabViews.',
       );

  @override
  ConsumerState<CustomTabView> createState() => _CustomTabViewState();
}

class _CustomTabViewState extends ConsumerState<CustomTabView> {
  @override
  Widget build(BuildContext context) {
    // Build the underlying TabBar and TabBarView structures
    final tabBar = TabBar(
      controller: widget.controller,
      isScrollable: widget.isScrollable,
      indicatorColor: widget.indicatorColor ?? context.colors.primaryColor,
      labelColor: widget.labelColor ?? context.colors.primaryColor,
      unselectedLabelColor: widget.unselectedLabelColor ?? context.colors.muted,
      dividerColor: context.colors.border,
      tabs: widget.tabs.map((tab) {
        if (tab.icon != null) {
          return Tab(text: tab.label, icon: Icon(tab.icon!));
        }
        return Tab(text: tab.label);
      }).toList(),
    );

    final tabBarView = TabBarView(
      controller: widget.controller,
      children: widget.tabViews,
    );

    // If an explicit controller is passed, render without DefaultTabController
    if (widget.controller != null) {
      return Column(
        children: [
          tabBar,
          Expanded(child: tabBarView),
        ],
      );
    }

    // Wrap with DefaultTabController if no explicit controller is provided
    return DefaultTabController(
      length: widget.tabs.length,
      child: Column(
        children: [
          tabBar,
          Expanded(child: tabBarView),
        ],
      ),
    );
  }
}
