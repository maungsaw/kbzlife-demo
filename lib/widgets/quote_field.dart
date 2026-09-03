import 'package:flutter/material.dart';

import '../app_date.dart';
import '../../data/models/quote_field.dart';
import '../const.dart';
import 'app_text_field.dart';

class QuoteFieldRenderer extends StatelessWidget {
  const QuoteFieldRenderer({
    super.key,
    required this.field,
    required this.value,
    required this.onChanged,
    required this.onToggleMulti,
  });
  final QuoteFieldSpec field;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final ValueChanged<String> onToggleMulti;

  @override
  Widget build(BuildContext context) {
    switch (field.type) {
      case QuoteFieldType.date:
        return AppTextField(
          label: field.label,
          readOnly: true,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value as DateTime? ?? DateTime(1990, 1, 1),
              firstDate: DateTime(1930),
              lastDate: DateTime.now(),
            );
            if (picked != null) onChanged(picked);
          },
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
          child: Text(
            value == null ? 'Select date' : AppDate.dMy(value as DateTime),
            style: TextStyle(
              fontSize: 13,
              fontWeight: value == null ? FontWeight.normal : FontWeight.w600,
              color: value == null ? AppColors.muted : AppColors.accentNavy,
            ),
          ),
        );

      case QuoteFieldType.computed:
        return _labeled(
          field.label,
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.deepAlpha(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${value ?? 0}${field.suffix != null ? ' ${field.suffix}' : ''}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.deep,
              ),
            ),
          ),
        );

      case QuoteFieldType.number:
        return _labeled(
          field.label,
          AppTextField(
            initialValue: '${value ?? ''}',
            label: '',
            hint: '',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            suffixText: field.suffix,
            helperText: field.helperText,
            onChanged: (v) => onChanged(num.tryParse(v) ?? 0),
          ),
        );

      case QuoteFieldType.singleSelect:
        return _labeled(
          field.label,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in field.options)
                    ChoiceChip(
                      label: Text(option.label),
                      selected: value == option.value,
                      onSelected: (_) => onChanged(option.value),
                      selectedColor: AppColors.deep,
                      labelStyle: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: value == option.value
                            ? Colors.white
                            : AppColors.deepAlpha(0.6),
                      ),
                      backgroundColor: AppColors.cream,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                        side: BorderSide(color: AppColors.deepAlpha(0.08)),
                      ),
                    ),
                ],
              ),
              if (field.helperText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    field.helperText!,
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.deepAlpha(0.4),
                    ),
                  ),
                ),
            ],
          ),
        );

      case QuoteFieldType.multiSelect:
        final selected = value as Set<String>? ?? {};
        return _labeled(
          field.label,
          Column(
            children: [
              for (final option in field.options)
                CheckboxListTile(
                  value: selected.contains(option.value),
                  onChanged: (_) => onToggleMulti(option.value),
                  title: Text(
                    option.label,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.deep,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
            ],
          ),
        );
    }
  }

  Widget _labeled(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.deepAlpha(0.5),
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
