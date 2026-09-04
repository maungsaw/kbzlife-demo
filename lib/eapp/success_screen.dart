import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_date.dart';
import '../const.dart';
import '../widgets/app_key_value_row.dart';
import '../widgets/chip.dart';
import '../widgets/app_text.dart';
import 'applicant_card.dart';
import 'eapp_status.dart';

/// Doc 119 — the last screen of the e-App. It answers two questions in
/// the order the FA asks them: did it go through, and where is it now.
class EappSuccessScreen extends StatelessWidget {
  const EappSuccessScreen({
    super.key,
    required this.status,
    required this.isRenewal,
    required this.proposalNo,
    required this.customerName,
    required this.productName,
  });
  final EappStatus status;
  final bool isRenewal;
  final String proposalNo;
  final String customerName;
  final String productName;

  /// Doc 119 §3 — the journey the *customer* is on, derived from the
  /// workflow status (doc 26 Layer B) so the two can never disagree.
  /// Proposal is done the moment this screen exists.
  int get _stage => switch (status) {
    EappStatus.approved => 2,
    _ => 1,
  };

  String get _shareText =>
      'KBZ Life proposal $proposalNo'
      '${customerName.isEmpty ? '' : ' for $customerName'}'
      ' · $productName · ${status.label}.';

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Back must not walk into the submitted wizard; the application is
      // gone to underwriting and there is nothing left to edit.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/home');
      },
      child: Scaffold(
        backgroundColor: context.colors.paper,
        body: Stack(
          children: [
            // Confetti sits behind the content and only in the top third —
            // celebratory without competing with the tracker below it.
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 340,
              child: _Confetti(),
            ),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
                      child: Column(
                        children: [
                          const _SuccessCheck(),
                          const SizedBox(height: 24),
                          Text(
                            isRenewal ? 'Renewal submitted' : 'Success',
                            style: TextStyle(
                              fontSize: AppType.heading,
                              fontWeight: AppType.strong,
                              color: context.colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your proposal has been successfully created.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: AppType.body,
                              color: context.colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Doc 120 §2 — which application succeeded. The
                          // reference number itself now lives one tap away
                          // on the Proposal stage instead of taking the
                          // centre of the screen.
                          Text(
                            customerName.isEmpty
                                ? productName
                                : '$customerName · $productName',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: AppType.label,
                              color: context.colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 34),
                          _JourneyTracker(
                            stage: _stage,
                            // Doc 120 §3 — the completed Proposal stage is
                            // the way back into what was just submitted.
                            onTapProposal: () => _openProposal(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => context.push('/e-app/tracker'),
                                child: const Text('Track application'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _CircleIconButton(
                              icon: Icons.share_outlined,
                              tooltip: 'Share',
                              onTap: () => _share(context),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () => context.go('/home'),
                          child: const Text('Back to home'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Doc 120 §3 — the proposal itself. There is no proposal-detail route
  /// in this prototype (the record only exists in the wizard that just
  /// closed), so it opens as a sheet over the success screen rather than
  /// a navigation into a screen that would have to invent a record.
  void _openProposal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadii.sheet),
        ),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: context.colors.deepAlpha(0.15),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const EappCardTitle('Proposal'),
              const SizedBox(height: 12),
              // The number is the reason this sheet exists, so it is the
              // largest thing in it and copies on tap.
              _ProposalNoPill(proposalNo: proposalNo),
              const SizedBox(height: 14),
              AppKeyValueRow(
                label: 'Policy Holder',
                value: customerName.isEmpty ? 'Not set' : customerName,
              ),
              AppKeyValueRow(label: 'Product', value: productName),
              AppKeyValueRow(label: 'Status', value: status.label),
              AppKeyValueRow(
                label: 'Submitted',
                value: AppDate.dMyHm(DateTime.now()),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/e-app/tracker');
                  },
                  child: const Text('Track application'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Doc 120 §4 — a real share, built from what this app already ships:
  /// SMS and email through url_launcher, plus the clipboard. No stub.
  void _share(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadii.sheet),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(top: 8, bottom: 10),
              decoration: BoxDecoration(
                color: context.colors.deepAlpha(0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: EappCardTitle('Share proposal'),
              ),
            ),
            _ShareTile(
              icon: Icons.sms_outlined,
              label: 'Send by SMS',
              onTap: () {
                Navigator.pop(sheetContext);
                launchUrl(
                  Uri(scheme: 'sms', queryParameters: {'body': _shareText}),
                  mode: LaunchMode.externalApplication,
                );
              },
            ),
            _ShareTile(
              icon: Icons.mail_outline,
              label: 'Send by email',
              onTap: () {
                Navigator.pop(sheetContext);
                launchUrl(
                  Uri(
                    scheme: 'mailto',
                    queryParameters: {
                      'subject': 'KBZ Life proposal $proposalNo',
                      'body': _shareText,
                    },
                  ),
                  mode: LaunchMode.externalApplication,
                );
              },
            ),
            _ShareTile(
              icon: Icons.copy_all_outlined,
              label: 'Copy proposal details',
              onTap: () {
                Navigator.pop(sheetContext);
                Clipboard.setData(ClipboardData(text: _shareText));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Proposal details copied')),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ShareTile extends StatelessWidget {
  const _ShareTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // Doc 124 — shared chip.
      leading: AppIconChip(
        icon: icon,
        size: 38,
        style: AppIconChipStyle.tinted,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: AppType.body,
          fontWeight: AppType.strong,
          color: context.colors.textPrimary,
        ),
      ),
      onTap: onTap,
    );
  }
}

/// Doc 120 §1 — the ring draws itself, then the tick lands inside it.
/// The old version scaled a finished check in over 620ms, which was over
/// before the screen had settled; this takes 1.5s and is the thing the
/// eye follows on arrival.
class _SuccessCheck extends StatefulWidget {
  const _SuccessCheck();

  @override
  State<_SuccessCheck> createState() => _SuccessCheckState();
}

class _SuccessCheckState extends State<_SuccessCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 116,
      height: 116,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: _CheckPainter(
            context: context,
            ring: Curves.easeOutCubic.transform(
              (_c.value / 0.55).clamp(0.0, 1.0),
            ),
            tick: Curves.easeOutCubic.transform(
              ((_c.value - 0.5) / 0.5).clamp(0.0, 1.0),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter({
    required this.ring,
    required this.tick,
    required this.context,
  });
  final double ring;
  final double tick;
  final BuildContext context;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = context.colors.mint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final rect = Offset.zero & size;
    canvas.drawArc(rect.deflate(3), -pi / 2, 2 * pi * ring, false, paint);

    if (tick <= 0) return;
    // Two segments of the tick, drawn in order and clipped by [tick].
    final a = Offset(size.width * 0.29, size.height * 0.52);
    final b = Offset(size.width * 0.44, size.height * 0.67);
    final c = Offset(size.width * 0.72, size.height * 0.37);
    final path = Path()..moveTo(a.dx, a.dy);
    const split = 0.38; // share of the tick length in the short leg
    if (tick <= split) {
      final t = tick / split;
      path.lineTo(a.dx + (b.dx - a.dx) * t, a.dy + (b.dy - a.dy) * t);
    } else {
      final t = (tick - split) / (1 - split);
      path.lineTo(b.dx, b.dy);
      path.lineTo(b.dx + (c.dx - b.dx) * t, b.dy + (c.dy - b.dy) * t);
    }
    canvas.drawPath(path, paint..strokeWidth = 6);
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.ring != ring || old.tick != tick;
}

/// Doc 119 §2 — the proposal number, sized to be read across a desk and
/// tappable to copy. Doc 120 §2 moved it off the success screen and into
/// the Proposal sheet, which is where someone goes looking for it.
class _ProposalNoPill extends StatelessWidget {
  const _ProposalNoPill({required this.proposalNo});
  final String proposalNo;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.primaryColor.withValues(alpha: 0.08),
      shape: StadiumBorder(
        side: BorderSide(
          color: context.colors.primaryColor.withValues(alpha: 0.35),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: proposalNo));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Proposal no $proposalNo copied')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 14, 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PROPOSAL NO',
                    style: TextStyle(
                      fontSize: AppType.caption,
                      letterSpacing: 0.8,
                      fontWeight: AppType.strong,
                      color: context.colors.primaryColor.withValues(
                        alpha: 0.75,
                      ),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    proposalNo,
                    style: TextStyle(
                      fontSize: AppType.title,
                      fontWeight: AppType.strong,
                      color: context.colors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.copy_outlined,
                size: context.iconBase,
                color: context.colors.primaryColor.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Doc 119 §3 — Proposal → Underwriting → Payment → Policy. Stages behind
/// the current one are solid, the one ahead is dashed: the file has not
/// travelled that link yet, and a dashed line says so without a caption.
class _JourneyTracker extends StatelessWidget {
  const _JourneyTracker({required this.stage, this.onTapProposal});

  /// 0-based index of the stage the application is sitting in.
  final int stage;

  /// Doc 120 §3 — the Proposal stage is done, and it is also the door
  /// back to what was submitted. Only that stage is tappable; the ones
  /// ahead have nothing behind them yet.
  final VoidCallback? onTapProposal;

  static const _labels = ['Proposal', 'Underwriting', 'Payment', 'Policy'];

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        for (var i = 0; i < _labels.length; i++) ...[
          if (i == 0 && onTapProposal != null)
            InkWell(
              onTap: onTapProposal,
              customBorder: const CircleBorder(),
              child: _JourneyDot(index: i, stage: stage),
            )
          else
            _JourneyDot(index: i, stage: stage),
          if (i != _labels.length - 1)
            Expanded(
              child: _JourneyLink(done: i < stage, dashed: i >= stage),
            ),
        ],
      ],
    );

    final labels = Row(
      children: [
        for (var i = 0; i < _labels.length; i++)
          Expanded(
            child: InkWell(
              onTap: i == 0 ? onTapProposal : null,
              borderRadius: BorderRadius.circular(8),
              child: Column(
                children: [
                  Text(
                    _labels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppType.caption,
                      fontWeight: i <= stage ? AppType.strong : FontWeight.w500,
                      color: i <= stage
                          ? context.colors.textPrimary
                          : context.colors.deepAlpha(0.4),
                    ),
                  ),
                  // The one tappable stage says so, rather than hiding a
                  // link behind an unmarked dot.
                  if (i == 0 && onTapProposal != null)
                    Text(
                      'View',
                      style: TextStyle(
                        fontSize: AppType.caption,
                        fontWeight: AppType.strong,
                        color: context.colors.primaryColor.withValues(
                          alpha: 0.9,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );

    return Column(children: [row, const SizedBox(height: 8), labels]);
  }
}

class _JourneyDot extends StatelessWidget {
  const _JourneyDot({required this.index, required this.stage});
  final int index;
  final int stage;

  @override
  Widget build(BuildContext context) {
    final done = index < stage;
    final current = index == stage;
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done
            ? context.colors.mint
            : current
            ? context.colors.primaryColor
            : context.colors.primaryColor.withValues(alpha: 0.10),
        // The current stage carries a halo so it reads as "here" rather
        // than just another filled dot.
        border: current
            ? Border.all(
                color: context.colors.primaryColor.withValues(alpha: 0.25),
                width: 3,
              )
            : null,
      ),
      child: done
          ? Icon(Icons.check, size: context.iconBase, color: Colors.white)
          : Text(
              '${index + 1}',
              style: TextStyle(
                fontSize: AppType.label,
                fontWeight: AppType.strong,
                color: current ? Colors.white : context.colors.primaryColor,
              ),
            ),
    );
  }
}

class _JourneyLink extends StatelessWidget {
  const _JourneyLink({required this.done, required this.dashed});
  final bool done;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2,
      child: CustomPaint(
        painter: _LinkPainter(
          color: done
              ? context.colors.primaryColor
              : context.colors.deepAlpha(0.18),
          dashed: dashed,
        ),
      ),
    );
  }
}

class _LinkPainter extends CustomPainter {
  const _LinkPainter({required this.color, required this.dashed});
  final Color color;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final y = size.height / 2;
    if (!dashed) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      return;
    }
    const dash = 5.0;
    const gap = 4.0;
    var x = 0.0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, y),
        Offset((x + dash).clamp(0, size.width), y),
        paint,
      );
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_LinkPainter old) =>
      old.color != color || old.dashed != dashed;
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: context.colors.primaryColor.withValues(alpha: 0.10),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              icon,
              size: context.iconBase,
              color: context.colors.primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// Doc 120 §1 — confetti that actually falls. Each piece has its own
/// delay, drop distance and spin over a 2.6s run, so the celebration is
/// something the FA watches rather than something already finished by the
/// time the screen settles. The seed is constant, so the layout does not
/// reshuffle on rebuild.
class _Confetti extends StatefulWidget {
  const _Confetti();

  @override
  State<_Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<_Confetti>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => CustomPaint(
        painter: _ConfettiPainter(progress: _c.value, context: context),
      ),
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({required this.progress, required this.context});

  /// 0 → 1 across the whole run.
  final double progress;
  final BuildContext context;

  @override
  void paint(Canvas canvas, Size size) {
    final palette = [
      context.colors.mint,
      context.colors.primaryColor,
      context.colors.warn,
      context.colors.danger,
      context.colors.primaryColor,
    ];

    final random = Random(7);
    for (var i = 0; i < 46; i++) {
      final x = random.nextDouble() * size.width;
      final restY = random.nextDouble() * size.height;
      final color = palette[random.nextInt(palette.length)];
      final angle = random.nextDouble() * pi;
      final spin = (random.nextDouble() - 0.5) * 4;
      final long = 5.0 + random.nextDouble() * 9;
      final round = random.nextBool();
      final delay = random.nextDouble() * 0.45;

      // Each piece runs its own 0→1 inside the shared clock.
      final t = ((progress - delay) / (1 - delay)).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final eased = Curves.easeOutQuad.transform(t);

      // Falls from above the top edge to its resting place, drifting
      // sideways a little on the way down.
      final y = -40 + (restY + 40) * eased;
      final drift = sin(eased * pi) * 14 * (round ? 1 : -1);
      // Pieces lower down fade first, so the field thins towards the
      // content below instead of ending in a hard line.
      final fade = (1 - restY / size.height).clamp(0.25, 1.0);
      final paint = Paint()..color = color.withValues(alpha: 0.55 * fade * t);

      canvas.save();
      canvas.translate(x + drift, y);
      canvas.rotate(angle + spin * eased);
      if (round) {
        canvas.drawCircle(Offset.zero, 2.5 + random.nextDouble() * 2, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: long, height: 4),
            const Radius.circular(2),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
