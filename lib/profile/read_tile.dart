import 'package:flutter/material.dart';

import '../const.dart';

class ReadOnlyProfileTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const ReadOnlyProfileTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: context.iconXl, color: context.colors.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: context.colors.muted),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: context.colors.accentNavy,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.lock_clock_outlined,
            size: context.iconMd,
            color: context.colors.border,
          ),
        ],
      ),
    );
  }
}
