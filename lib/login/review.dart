import 'package:demo_ui/const.dart';
import 'package:demo_ui/providers/router_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminReviewProgressScreen extends StatelessWidget {
  const AdminReviewProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.paper,
      appBar: AppBar(
        title: const Text('Review Progress'),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.colors.away.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.hourglass_top_rounded,
                size: 64,
                color: context.colors.away,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Registration Under Review',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            Text(
              'Your registration is currently pending review. Please kindly wait for an invitation from KBZLIFE Insurance.',
              style: TextStyle(fontSize: 14, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => context.go(RoutePaths.home),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Home'),
            ),
          ],
        ),
      ),
    );
  }
}
