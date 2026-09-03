import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'crm.dart';
import 'model.dart' as model;

class CRMListViewScreen extends ConsumerWidget {
  const CRMListViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = model.CRMRepository();

    return UserDashboardScreen(
      repository: repo,
    );
  }
}
