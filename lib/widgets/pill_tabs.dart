import 'package:flutter/material.dart';

import '../const.dart';

class PillTab {
  final String label;
  final Widget? child;
  final IconData? icon;

  const PillTab({required this.label, this.child, this.icon});
}

class PillTabs extends StatefulWidget {
  final List<PillTab> tabs;
  final int initialIndex;
  final ValueChanged<int>? onPageChanged;

  const PillTabs({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.onPageChanged,
  });

  @override
  State<PillTabs> createState() => _PillTabsState();
}

class _PillTabsState extends State<PillTabs>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex;
  late AnimationController _controller;
  double _startX = 0;
  double _endX = 0;
  double _startW = 0;
  double _endW = 0;
  final List<GlobalKey> _tabKeys = [];
  final GlobalKey _rowKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _tabKeys.addAll(List.generate(widget.tabs.length, (_) => GlobalKey()));
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startX = _getTabCenter(_selectedIndex);
        _startW = _getTabWidth(_selectedIndex);
        _endX = _startX;
        _endW = _startW;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap(int index) {
    if (_selectedIndex != index) {
      _startX = _getTabCenter(_selectedIndex);
      _startW = _getTabWidth(_selectedIndex);
      _endX = _getTabCenter(index);
      _endW = _getTabWidth(index);
      setState(() => _selectedIndex = index);
      _controller.forward(from: 0);
      widget.onPageChanged?.call(index);
    }
  }

  double _getTabCenter(int index) {
    final rowBox = _rowKey.currentContext?.findRenderObject() as RenderBox?;
    final tabBox =
        _tabKeys[index].currentContext?.findRenderObject() as RenderBox?;
    if (rowBox == null || tabBox == null) return 0;
    final tabPos = tabBox.localToGlobal(Offset.zero, ancestor: rowBox);
    return tabPos.dx + tabBox.size.width / 2;
  }

  double _getTabWidth(int index) {
    final tabBox =
        _tabKeys[index].currentContext?.findRenderObject() as RenderBox?;
    return tabBox?.size.width ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: context.colors.paper,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: context.colors.deepAlpha(0.08)),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final value = Curves.easeInOutCubic.transform(
                    _controller.value,
                  );
                  final cx = _startX + (_endX - _startX) * value;
                  final w = _startW + (_endW - _startW) * value;
                  return Positioned(
                    left: cx - w / 2,
                    top: 4,
                    bottom: 4,
                    width: w,
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.colors.primaryColor.withValues(
                          alpha: 0.9,
                        ),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            color: context.colors.primaryColor.withValues(
                              alpha: 0.3 * value,
                            ),
                            blurRadius: 8 * value,
                            offset: Offset(0, 2 * value),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              Row(
                key: _rowKey,
                children: [
                  for (final t in widget.tabs.asMap().entries)
                    Expanded(
                      child: GestureDetector(
                        key: _tabKeys[t.key],
                        onTap: () => _onTap(t.key),
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: t.key == _selectedIndex
                                ? Colors.white
                                : context.colors.deepAlpha(0.6),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 4,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (t.value.icon != null) ...[
                                  Icon(
                                    t.value.icon,
                                    size: context.iconMd,
                                    color: t.key == _selectedIndex
                                        ? Colors.white
                                        : context.colors.deepAlpha(0.6),
                                  ),
                                  const SizedBox(width: 4),
                                ],
                                Text(t.value.label),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (widget.tabs[_selectedIndex].child != null)
          Expanded(child: widget.tabs[_selectedIndex].child!),
      ],
    );
  }
}
