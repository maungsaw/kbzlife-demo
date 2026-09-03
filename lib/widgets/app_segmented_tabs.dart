import 'package:flutter/material.dart';

import '../const.dart';

/// One exclusive choice, shown as a segmented tab strip: a cream track with
/// the chosen segment raised on white. It started on the Sign step
/// (E-Sign / Upload) and is now the single control for every either/or in
/// the e-App — document type, applicant type, gender, notification — so
/// those choices no longer read as four different kinds of control.
class AppSegmentedTabs<T> extends StatelessWidget {
  const AppSegmentedTabs({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.label,
  });

  /// (value, label, icon) per segment; the icon may be null.
  final List<(T, String, IconData?)> options;
  final T value;
  final ValueChanged<T>? onChanged;

  /// Optional field label, styled like the other e-App field labels.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final strip = Container(
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          for (final (i, (v, text, icon)) in options.indexed) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onChanged == null ? null : () => onChanged!(v),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: value == v ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: value == v
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(
                          icon,
                          size: 14,
                          color: value == v
                              ? AppColors.primaryColor
                              : AppColors.muted,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Flexible(
                        child: Text(
                          text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: value == v
                                ? AppColors.primaryColor
                                : AppColors.muted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );

    if (label == null) return strip;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label!,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.accentNavy,
          ),
        ),
        const SizedBox(height: 6),
        strip,
      ],
    );
  }
}
