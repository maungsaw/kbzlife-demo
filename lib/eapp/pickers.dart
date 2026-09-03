import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../const.dart';
import '../widgets/app_text_field.dart';

Future<String?> showIdentificationPickerSheet(
  BuildContext context, {
  String? initial,
}) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: AppColors.paper,
    builder: (context) => _IdSheet(initial: initial),
  );
}

class _IdSheet extends ConsumerStatefulWidget {
  const _IdSheet({this.initial});
  final String? initial;

  @override
  ConsumerState<_IdSheet> createState() => _IdSheetState();
}

class _IdSheetState extends ConsumerState<_IdSheet> {
  late String _type;
  String _state = '12';
  String _township = 'KaMaNa';
  String _idType = 'N';
  final _numberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial == 'No ID') {
      _type = 'No ID';
    } else if (initial != null && initial.isNotEmpty) {
      // Try to parse NRC format: 12/KaMaNa(N)127487
      final nrcRegex = RegExp(r'^(\d+)/(\w+)\((\w+)\)(\d+)$');
      final match = nrcRegex.firstMatch(initial);
      if (match != null) {
        _type = 'NRC';
        _state = match.group(1) ?? '12';
        _township = match.group(2) ?? 'KaMaNa';
        _idType = match.group(3) ?? 'N';
        _numberController.text = match.group(4) ?? '';
      } else {
        // Assume passport or other
        _type = 'Passport';
        _numberController.text = initial;
      }
    } else {
      _type = 'NRC';
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showNrcRow = _type == 'NRC' || _type == 'Old NRC';
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 4,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Identification',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: AppColors.deep,
            ),
          ),
          const SizedBox(height: 14),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.4,
                    children: [
                      for (final t in ['NRC', 'Old NRC', 'Passport', 'No ID'])
                        _IdTypeTile(
                          label: t,
                          selected: _type == t,
                          onTap: () => setState(() => _type = t),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (showNrcRow) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _MiniDropdown(
                            label: 'State',
                            value: _state,
                            options: const ['12', '9', '1'],
                            onChanged: (v) => setState(() => _state = v),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MiniDropdown(
                            label: 'Township',
                            value: _township,
                            options: const ['KaMaNa', 'PaZaTa', 'LaMaNa'],
                            onChanged: (v) => setState(() => _township = v),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _MiniDropdown(
                            label: 'Type',
                            value: _idType,
                            options: const ['N', 'P', 'E'],
                            onChanged: (v) => setState(() => _idType = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    AppTextField(
                      controller: _numberController,
                      onChanged: (_) => setState(() {}),
                      keyboardType: TextInputType.number,
                      label: 'NRC Number',
                      hint: '',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_state/$_township($_idType)${_numberController.text}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.deepAlpha(0.45),
                      ),
                    ),
                  ] else if (_type == 'Passport') ...[
                    AppTextField(
                      controller: _numberController,
                      label: 'Passport Number',
                      hint: '',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ] else ...[
                    Text(
                      'No identification on file',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.deepAlpha(0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final display = switch (_type) {
                  'NRC' || 'Old NRC' =>
                    '$_state/$_township($_idType)${_numberController.text}',
                  'Passport' => _numberController.text,
                  _ => 'No ID',
                };
                Navigator.pop(context, display);
              },
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}

class _IdTypeTile extends StatelessWidget {
  const _IdTypeTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primaryColor : Colors.transparent,
            width: 1.6,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                  color: selected
                      ? AppColors.primaryColor
                      : AppColors.deepAlpha(0.6),
                ),
              ),
            ),
            if (selected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MiniDropdown extends StatelessWidget {
  const _MiniDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });
  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: [
            for (final o in options)
              DropdownMenuItem(
                value: o,
                child: Text(o, style: const TextStyle(fontSize: 12.5)),
              ),
          ],
          onChanged: (v) => v == null ? null : onChanged(v),
        ),
      ),
    );
  }
}

Future<String?> showHeightPickerSheet(
  BuildContext context, {
  String initial = "5' 7\"",
}) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.paper,
    builder: (context) => _WheelPickerSheet(
      title: 'Select your height',
      leftLabel: 'ft',
      rightLabel: 'in',
      leftRange: List.generate(7, (i) => '${i + 2}'),
      rightRange: List.generate(12, (i) => '$i'),
      formatPreview: (l, r) => "$l' $r\"",
    ),
  );
}

Future<String?> showWeightPickerSheet(
  BuildContext context, {
  String initial = '105.0',
}) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.paper,
    builder: (context) => _WheelPickerSheet(
      title: 'Select your weight',
      leftLabel: 'lb',
      rightLabel: '.',
      leftRange: List.generate(181, (i) => '${i + 70}'),
      rightRange: List.generate(10, (i) => '$i'),
      formatPreview: (l, r) => '$l.$r lb',
    ),
  );
}

class _WheelPickerSheet extends ConsumerStatefulWidget {
  const _WheelPickerSheet({
    required this.title,
    required this.leftLabel,
    required this.rightLabel,
    required this.leftRange,
    required this.rightRange,
    required this.formatPreview,
  });
  final String title;
  final String leftLabel;
  final String rightLabel;
  final List<String> leftRange;
  final List<String> rightRange;
  final String Function(String left, String right) formatPreview;

  @override
  ConsumerState<_WheelPickerSheet> createState() => _WheelPickerSheetState();
}

class _WheelPickerSheetState extends ConsumerState<_WheelPickerSheet> {
  int _leftIndex = 0;
  int _rightIndex = 0;

  @override
  Widget build(BuildContext context) {
    final left = widget.leftRange[_leftIndex];
    final right = widget.rightRange[_rightIndex];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: AppColors.deep,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.formatPreview(left, right),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 22,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    widget.leftLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepAlpha(0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Center(
                  child: Text(
                    widget.rightLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.deepAlpha(0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 180,
            child: Row(
              children: [
                Expanded(
                  child: _Wheel(
                    values: widget.leftRange,
                    onChanged: (i) => setState(() => _leftIndex = i),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _Wheel(
                    values: widget.rightRange,
                    onChanged: (i) => setState(() => _rightIndex = i),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, widget.formatPreview(left, right)),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}

class _Wheel extends StatelessWidget {
  const _Wheel({required this.values, required this.onChanged});
  final List<String> values;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: ListWheelScrollView.useDelegate(
        itemExtent: 44,
        diameterRatio: 1.6,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: values.length,
          builder: (context, i) => Center(
            child: Text(
              values[i],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.deep,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
