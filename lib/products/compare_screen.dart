import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/mock/mock_data.dart';
import '../../data/models/product.dart';
import '../const.dart';
import '../widgets/soft_card.dart';

class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({
    super.key,
    required this.leftCode,
    required this.rightCode,
  });
  final String leftCode;
  final String rightCode;

  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen> {
  late String _left = widget.leftCode;
  late String _right = widget.rightCode;
  late String _pinned = widget.leftCode;

  Product _byCode(String code) => MockData.products.firstWhere(
    (p) => p.code == code,
    orElse: () => MockData.products.first,
  );

  Future<void> _changeSlot(bool isLeft) async {
    final currentCode = isLeft ? _left : _right;
    final otherCode = isLeft ? _right : _left;
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) =>
          _ChangeSheet(currentCode: currentCode, otherCode: otherCode),
    );
    if (picked == null) return;
    setState(() {
      if (picked == otherCode) {
        _left = isLeft ? otherCode : currentCode;
        _right = isLeft ? currentCode : otherCode;
      } else if (isLeft) {
        _left = picked;
        if (_pinned == currentCode) _pinned = picked;
      } else {
        _right = picked;
        if (_pinned == currentCode) _pinned = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final left = _byCode(_left);
    final right = _byCode(_right);
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Compare')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: _CompareHeader(
                  product: left,
                  pinned: _pinned == left.code,
                  onPin: () => setState(() => _pinned = left.code),
                  onChange: () => _changeSlot(true),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CompareHeader(
                  product: right,
                  pinned: _pinned == right.code,
                  onPin: () => setState(() => _pinned = right.code),
                  onChange: () => _changeSlot(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SoftCard(
            child: Column(
              children: [
                _CompareRow(
                  label: 'Category',
                  left: left.category.name,
                  right: right.category.name,
                ),
                _CompareRow(
                  label: 'Coverage',
                  left: left.coverage,
                  right: right.coverage,
                ),
                _CompareRow(
                  label: 'Tagline',
                  left: left.tagline,
                  right: right.tagline,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _pinned == left.code
                    ? ElevatedButton(
                        onPressed: () =>
                            context.push('/quote?product=${left.code}'),
                        child: Text('Use ${left.name}'),
                      )
                    : OutlinedButton(
                        onPressed: () =>
                            context.push('/quote?product=${left.code}'),
                        child: Text('Use ${left.name}'),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _pinned == right.code
                    ? ElevatedButton(
                        onPressed: () =>
                            context.push('/quote?product=${right.code}'),
                        child: Text('Use ${right.name}'),
                      )
                    : OutlinedButton(
                        onPressed: () =>
                            context.push('/quote?product=${right.code}'),
                        child: Text('Use ${right.name}'),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompareHeader extends StatelessWidget {
  const _CompareHeader({
    required this.product,
    required this.pinned,
    required this.onPin,
    required this.onChange,
  });
  final Product product;
  final bool pinned;
  final VoidCallback onPin;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: onChange,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.name,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: AppColors.deep,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Change',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onPin,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: pinned
                    ? AppColors.primaryColor
                    : AppColors.deepAlpha(0.06),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                pinned ? 'Pinned' : 'Pin',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: pinned ? Colors.white : AppColors.deepAlpha(0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({
    required this.label,
    required this.left,
    required this.right,
  });
  final String label;
  final String left;
  final String right;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: AppColors.deepAlpha(0.4),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  left,
                  style: const TextStyle(fontSize: 12, color: AppColors.deep),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  right,
                  style: const TextStyle(fontSize: 12, color: AppColors.deep),
                ),
              ),
            ],
          ),
          const Divider(height: 16),
        ],
      ),
    );
  }
}

class _ChangeSheet extends StatelessWidget {
  const _ChangeSheet({required this.currentCode, required this.otherCode});
  final String currentCode;
  final String otherCode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Replace product',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: AppColors.deep,
            ),
          ),
          const SizedBox(height: 8),
          for (final p in MockData.products)
            Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.hexagon_outlined,
                  color: AppColors.primaryColor,
                ),
                title: Text(
                  p.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.deep,
                  ),
                ),
                subtitle: Text(
                  '${p.category.name.toUpperCase()} · ${p.code}${p.code == otherCode ? ' · On the other side · tap to swap' : ''}',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: AppColors.deepAlpha(0.5),
                  ),
                ),
                trailing: p.code == currentCode
                    ? const Icon(Icons.check, color: AppColors.mint)
                    : null,
                onTap: () => Navigator.pop(context, p.code),
              ),
            ),
        ],
      ),
    );
  }
}
