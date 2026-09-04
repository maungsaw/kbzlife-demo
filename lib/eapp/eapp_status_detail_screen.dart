import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../app_date.dart';
import '../const.dart';
import '../widgets/app_text.dart';
import '../widgets/soft_card.dart';
import 'eapp_status.dart';
import 'eapp_tracker_data.dart';

class EappStatusDetailScreen extends ConsumerStatefulWidget {
  const EappStatusDetailScreen({super.key, required this.appId});
  final String appId;

  @override
  ConsumerState<EappStatusDetailScreen> createState() =>
      _EappStatusDetailScreenState();
}

class _EappStatusDetailScreenState
    extends ConsumerState<EappStatusDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final app = mockEappApplications
        .where((a) => a.id == widget.appId)
        .firstOrNull;

    if (app == null) {
      return Scaffold(
        backgroundColor: context.colors.cream,
        appBar: AppBar(title: const Text('Status detail')),
        body: Center(
          child: Text(
            'Application not found',
            style: TextStyle(color: context.colors.textSecondary),
          ),
        ),
      );
    }

    final (bg, fg) = app.status.pillColors;

    return Scaffold(
      backgroundColor: context.colors.cream,
      appBar: AppBar(title: const Text('Status detail')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _StageStepper(status: app.status),
          const SizedBox(height: 16),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.holderName,
                  style: TextStyle(
                    fontWeight: AppType.strong,
                    fontSize: AppType.title,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${app.productName} · ${app.ref}',
                  style: TextStyle(
                    fontSize: AppType.label,
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    app.status.label,
                    style: TextStyle(
                      fontSize: AppType.label,
                      fontWeight: AppType.strong,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (app.status == EappStatus.submitted ||
              app.status == EappStatus.correction) ...[
            const SizedBox(height: 14),
            _TimeInProcessCard(since: app.latestEvent.at),
          ],
          const SizedBox(height: 14),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('Timeline'),
                const SizedBox(height: 14),
                _Timeline(app: app),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('Latest event'),
                const SizedBox(height: 8),
                Text(
                  app.latestEvent.status.label,
                  style: TextStyle(
                    fontWeight: AppType.strong,
                    fontSize: AppType.body,
                    color: context.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${AppDate.dMyHm(app.latestEvent.at)} · ${app.latestEvent.actor}',
                  style: TextStyle(
                    fontSize: AppType.caption,
                    color: context.colors.textSecondary,
                  ),
                ),
                if (app.latestEvent.note != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    app.latestEvent.note!,
                    style: TextStyle(
                      fontSize: AppType.label,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          _StatusCta(app: app),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.app});
  final EappApplication app;

  @override
  Widget build(BuildContext context) {
    final reachedStatuses = app.history.map((e) => e.status).toSet();
    final spine = <EappStatus>[
      EappStatus.draft,
      EappStatus.submitted,
      if (app.status == EappStatus.correction ||
          reachedStatuses.contains(EappStatus.correction))
        EappStatus.correction,
      if (app.status == EappStatus.rejected)
        EappStatus.rejected
      else
        EappStatus.approved,
    ];

    return Column(
      children: [
        for (var i = 0; i < spine.length; i++)
          _TimelineTile(
            status: spine[i],
            event: app.history.where((e) => e.status == spine[i]).firstOrNull,
            isCurrent: spine[i] == app.status,
            isLast: i == spine.length - 1,
          ),
      ],
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.status,
    required this.event,
    required this.isCurrent,
    required this.isLast,
  });
  final EappStatus status;
  final EappTimelineEvent? event;
  final bool isCurrent;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final localEvent = event;
    final done = localEvent != null;
    final future = !done && !isCurrent;
    final dotColor = isCurrent
        ? context.colors.primaryColor
        : (done ? context.colors.mint : context.colors.deepAlpha(0.15));

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  done ? Icons.check : status.icon,
                  color: Colors.white,
                  size: context.iconSm,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: context.colors.deepAlpha(0.1),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.label,
                    style: TextStyle(
                      fontWeight: AppType.strong,
                      fontSize: AppType.label,
                      color: future
                          ? context.colors.textSecondary
                          : context.colors.deep,
                    ),
                  ),
                  if (localEvent != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${AppDate.dMyHm(localEvent.at)} · ${localEvent.actor}',
                      style: TextStyle(
                        fontSize: AppType.caption,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    if (localEvent.note != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        localEvent.note!,
                        style: TextStyle(
                          fontSize: AppType.caption,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ],
                  ] else
                    Text(
                      future ? 'Not yet reached' : '',
                      style: TextStyle(
                        fontSize: AppType.caption,
                        color: context.colors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCta extends StatelessWidget {
  const _StatusCta({required this.app});
  final EappApplication app;

  @override
  Widget build(BuildContext context) {
    switch (app.status) {
      case EappStatus.submitted:
        return Text(
          "You'll get a notification when this status changes.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: AppType.label,
            color: context.colors.textSecondary,
          ),
        );
      case EappStatus.correction:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              final params = <String, String>{'step': '${app.draftStep}'};
              if (app.correctionReason != null) {
                params['note'] = app.correctionReason!;
              }
              context.push(
                Uri(path: '/e-app', queryParameters: params).toString(),
              );
            },
            child: const Text('Fix now'),
          ),
        );
      case EappStatus.approved:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => context.push('/policies'),
            child: const Text('Go to client / view policy'),
          ),
        );
      case EappStatus.rejected:
      case EappStatus.draft:
        return const SizedBox.shrink();
    }
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

class _TimeInProcessCard extends StatefulWidget {
  const _TimeInProcessCard({required this.since});
  final DateTime since;

  @override
  State<_TimeInProcessCard> createState() => _TimeInProcessCardState();
}

class _TimeInProcessCardState extends State<_TimeInProcessCard> {
  static const _target = Duration(minutes: 30);
  late final DateTime _startedAt = DateTime.now();
  late Timer _ticker;
  Duration _elapsed = Duration.zero;
  bool _notifyMe = true;

  @override
  void initState() {
    super.initState();
    _tick();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final now = DateTime.now();
    final elapsed = now.isAfter(_startedAt)
        ? now.difference(_startedAt)
        : Duration.zero;
    if (mounted) setState(() => _elapsed = elapsed);
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  String get _label {
    final remaining = _target - _elapsed;
    if (remaining.isNegative) return '00:00';
    final h = remaining.inHours;
    final m = remaining.inMinutes.remainder(60);
    final s = remaining.inSeconds.remainder(60);
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _toggleNotify() {
    setState(() => _notifyMe = !_notifyMe);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          _notifyMe
              ? "You'll be notified when this status changes."
              : "You won't be notified — tap the bell to turn it back on.",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = (1 - _elapsed.inSeconds / _target.inSeconds).clamp(
      0.0,
      1.0,
    );
    final overdue = _elapsed > _target;
    final gaugeColor = overdue
        ? context.colors.warn
        : context.colors.primaryColor;

    return SoftCard(
      child: Column(
        children: [
          SizedBox(
            width: 148,
            height: 148,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: remaining),
              duration: const Duration(seconds: 1),
              curve: Curves.linear,
              builder: (context, value, child) => CustomPaint(
                painter: _GaugePainter(
                  progress: value,
                  color: gaugeColor,
                  context: context,
                ),
                child: child,
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      overdue ? 'OVERDUE' : 'TIME REMAINING',
                      style: TextStyle(
                        fontSize: AppType.caption,
                        fontWeight: AppType.strong,
                        letterSpacing: 0.8,
                        color: context.colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _label,
                      style: TextStyle(
                        fontSize: AppType.heading,
                        fontWeight: AppType.strong,
                        color: overdue
                            ? context.colors.warn
                            : context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: _toggleNotify,
                      child: Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _notifyMe
                              ? context.colors.primaryColor.withValues(
                                  alpha: 0.12,
                                )
                              : context.colors.deepAlpha(0.06),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _notifyMe
                              ? Icons.notifications_active_rounded
                              : Icons.notifications_off_outlined,
                          size: context.iconBase,
                          color: _notifyMe
                              ? context.colors.primaryColor
                              : context.colors.deepAlpha(0.4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            overdue
                ? 'Taking longer than the typical 30-minute review window.'
                : 'Typically reviewed within 30 minutes during working hours.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppType.caption,
              fontWeight: overdue ? AppType.strong : FontWeight.normal,
              color: overdue
                  ? context.colors.warn
                  : context.colors.deepAlpha(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.progress,
    required this.color,
    required this.context,
  });
  final double progress;
  final Color color;
  final BuildContext context;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 6;

    final track = Paint()
      ..color = context.colors.deepAlpha(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    const startAngle = -math.pi / 2;
    final sweep = 2 * math.pi * progress;

    if (progress > 0) {
      final arc = Paint()
        ..shader = SweepGradient(
          startAngle: 0,
          endAngle: 2 * math.pi,
          transform: GradientRotation(startAngle),
          colors: [color.withValues(alpha: 0.35), color],
          stops: [0, progress],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        arc,
      );

      final dotAngle = startAngle + sweep;
      final dotCenter = Offset(
        center.dx + radius * math.cos(dotAngle),
        center.dy + radius * math.sin(dotAngle),
      );
      canvas.drawCircle(dotCenter, 5, Paint()..color = color);
      canvas.drawCircle(
        dotCenter,
        7,
        Paint()
          ..color = color.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class _StageStepper extends StatelessWidget {
  const _StageStepper({required this.status});
  final EappStatus status;

  static const _labels = ['Proposal', 'Underwrite', 'Payment', 'Policy'];

  int get _stageIndex => switch (status) {
    EappStatus.draft => 0,
    EappStatus.submitted || EappStatus.correction || EappStatus.rejected => 1,
    EappStatus.approved => 3,
  };

  @override
  Widget build(BuildContext context) {
    final current = _stageIndex;
    final stalled = status == EappStatus.rejected;

    return Row(
      children: [
        for (var i = 0; i < _labels.length; i++) ...[
          Expanded(
            flex: i == _labels.length - 1 ? 0 : 1,
            child: Column(
              children: [
                _StageDot(
                  number: i + 1,
                  done: i < current,
                  isCurrent: i == current,
                  isError: stalled && i == current,
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _labels[i],
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: AppType.caption,
                      fontWeight: i <= current
                          ? AppType.strong
                          : FontWeight.w600,
                      color: i <= current
                          ? context.colors.textPrimary
                          : context.colors.deepAlpha(0.35),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (i != _labels.length - 1)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: i < current
                    ? Container(height: 2, color: context.colors.primaryColor)
                    : (i == current && !stalled)
                    ? _DashedLine(
                        color: stalled
                            ? context.colors.danger
                            : context.colors.primaryColor.withValues(
                                alpha: 0.5,
                              ),
                      )
                    : Container(
                        height: 2,
                        color: context.colors.deepAlpha(0.12),
                      ),
              ),
            ),
        ],
      ],
    );
  }
}

class _StageDot extends StatelessWidget {
  const _StageDot({
    required this.number,
    required this.done,
    required this.isCurrent,
    required this.isError,
  });
  final int number;
  final bool done;
  final bool isCurrent;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError
        ? context.colors.danger
        : (done || isCurrent)
        ? context.colors.primaryColor
        : context.colors.deepAlpha(0.15);
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: done
          ? Icon(Icons.check, color: Colors.white, size: context.iconMd)
          : Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontSize: AppType.label,
                fontWeight: AppType.strong,
              ),
            ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 5.0;
        const dashGap = 4.0;
        final count = (constraints.maxWidth / (dashWidth + dashGap)).floor();
        return Row(
          children: [
            for (var i = 0; i < count; i++) ...[
              Container(width: dashWidth, height: 2, color: color),
              if (i != count - 1) const SizedBox(width: dashGap),
            ],
          ],
        );
      },
    );
  }
}
