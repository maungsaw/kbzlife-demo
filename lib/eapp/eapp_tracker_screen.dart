import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../const.dart';
import '../widgets/soft_card.dart';
import '../widgets/app_selection_chip.dart';
import 'eapp_status.dart';
import 'eapp_tracker_data.dart';

class EappTrackerScreen extends ConsumerStatefulWidget {
  const EappTrackerScreen({super.key});

  @override
  ConsumerState<EappTrackerScreen> createState() => _EappTrackerScreenState();
}

class _EappTrackerScreenState extends ConsumerState<EappTrackerScreen> {
  EappStatus? _filter;

  @override
  Widget build(BuildContext context) {
    final apps = mockEappApplications
        .where((a) => _filter == null || a.status == _filter)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('App tracker')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  AppSelectionChip(
                    label: 'All',
                    selected: _filter == null,
                    onSelected: (_) => setState(() => _filter = null),
                  ),
                  const SizedBox(width: 8),
                  for (final s in EappStatus.values) ...[
                    AppSelectionChip(
                      label: s.label,
                      selected: _filter == s,
                      onSelected: (_) => setState(() => _filter = s),
                    ),
                    if (s != EappStatus.values.last) const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: apps.isEmpty
                ? Center(
                    child: Text(
                      'No applications',
                      style: TextStyle(
                        color: context.colors.deepAlpha(0.4),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    itemCount: apps.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _AppRow(app: apps[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AppRow extends StatelessWidget {
  const _AppRow({required this.app});
  final EappApplication app;

  void _onTap(BuildContext context) {
    switch (app.status) {
      case EappStatus.draft:
      case EappStatus.correction:
        final params = <String, String>{'step': '${app.draftStep}'};
        if (app.correctionReason != null) {
          params['note'] = app.correctionReason!;
        }
        context.push(Uri(path: '/e-app', queryParameters: params).toString());
      case EappStatus.submitted:
      case EappStatus.approved:
      case EappStatus.rejected:
        context.push('/e-app/tracker/${app.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      onTap: () => _onTap(context),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.colors.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              app.status.icon,
              color: context.colors.primaryColor,
              size: context.iconXl,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.holderName,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: context.colors.deep,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${app.productName} · ${app.ref}',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: context.colors.deepAlpha(0.5),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  app.status.whatsNext,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: context.colors.deepAlpha(0.4),
                  ),
                ),
              ],
            ),
          ),
          _StatusPill(status: app.status),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final EappStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = status.pillColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.label,
        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}
