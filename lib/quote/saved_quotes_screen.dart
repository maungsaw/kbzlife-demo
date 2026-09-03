import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../const.dart';
import '../widgets/soft_card.dart';
import 'quote_providers.dart';

class SavedQuotesScreen extends ConsumerWidget {
  const SavedQuotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drafts = ref.watch(savedQuotesProvider);
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(title: const Text('Saved quotes')),
      body: drafts.isEmpty
          ? Center(
              child: Text(
                'No saved quotes yet',
                style: TextStyle(
                  color: AppColors.deepAlpha(0.4),
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: drafts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final d = drafts[i];
                return SoftCard(
                  onTap: () => context.push('/quote?product=${d.productCode}'),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.calculate_outlined,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: AppColors.deep,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Saved ${DateFormat('dd-MMM-yyyy').format(d.savedAt)} · valid 30 days',
                              style: TextStyle(
                                fontSize: 10.5,
                                color: AppColors.deepAlpha(0.45),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${NumberFormat.decimalPattern('en_US').format(d.premium)} MMK',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
