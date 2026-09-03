import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'const.dart';

class PremiumCalculatorScreen extends ConsumerStatefulWidget {
  final String productName;

  const PremiumCalculatorScreen({super.key, this.productName = 'Universal Life'});

  @override
  ConsumerState<PremiumCalculatorScreen> createState() =>
      _PremiumCalculatorScreenState();
}

class _PremiumCalculatorScreenState extends ConsumerState<PremiumCalculatorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      appBar: AppBar(
        title: Text('${widget.productName} Calculator'),
      ),
      body: const Center(
        child: Text('Calculator coming soon'),
      ),
    );
  }
}
