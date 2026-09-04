import 'package:demo_ui/const.dart';
import 'package:flutter/material.dart';

class AdminReviewProgressScreen extends StatelessWidget {
  const AdminReviewProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.paper,
      appBar: AppBar(
        title: const Text('Review Progress'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(),
        ),
      ),
      body: const Center(
        child: Padding(
          padding: .all(16),
          child: Text(
            'Your registration is in pending stage and please kindly wait invitation from KBZLIFE Insurance.',
          ),
        ),
      ),
    );
  }
}
