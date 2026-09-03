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
          Icon(icon, size: 20, color: AppColors.muted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: AppColors.muted),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentNavy,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.lock_clock_outlined,
            size: 14,
            color: AppColors.border,
          ),
        ],
      ),
    );
  }
}
