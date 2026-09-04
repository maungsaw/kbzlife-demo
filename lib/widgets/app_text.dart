import 'package:flutter/material.dart';

import '../const.dart';

/// The one type scale for form flows (the e-App wizard first among them).
///
/// Three rules, applied everywhere so no two screens drift:
/// * a heading is **larger** than the text under it — hierarchy comes from
///   size, never from weight;
/// * nothing is bold — `w600` is the heaviest weight in the scale, so a
///   card no longer reads as a wall of black;
/// * one ink colour (`textPrimary`), with a single muted tone reserved for
///   text that is genuinely secondary (hints, captions).
///
/// Sizes are exposed as constants too, for the few places that must style a
/// `TextSpan` or an `InputDecoration` rather than take a widget.
abstract final class AppType {
  /// Screen / step heading.
  static const double heading = 19;

  /// Card or section title.
  static const double title = 15.5;

  /// Field labels and table labels.
  static const double label = 12.5;

  /// Body copy and field values.
  static const double body = 13;

  /// Captions, helper lines, chips.
  static const double caption = 11.5;

  /// The heaviest weight in the flow. Bold is deliberately absent.
  static const FontWeight strong = FontWeight.w600;
  static const FontWeight normal = FontWeight.w400;
}

/// Screen or step heading — the largest text on the page.
class AppHeading extends StatelessWidget {
  const AppHeading(this.text, {super.key, this.maxLines = 2, this.align});
  final String text;
  final int maxLines;
  final TextAlign? align;

  @override
  Widget build(BuildContext context) => Text(
    text,
    maxLines: maxLines,
    overflow: TextOverflow.ellipsis,
    textAlign: align,
    style: TextStyle(
      fontSize: AppType.heading,
      fontWeight: AppType.strong,
      height: 1.25,
      color: context.colors.textPrimary,
    ),
  );
}

/// Card / section title — one step down from [AppHeading].
class AppSectionTitle extends StatelessWidget {
  const AppSectionTitle(this.text, {super.key, this.align});
  final String text;
  final TextAlign? align;

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: align,
    style: TextStyle(
      fontSize: AppType.title,
      fontWeight: AppType.strong,
      height: 1.3,
      color: context.colors.textPrimary,
    ),
  );
}

/// Body copy and field values.
class AppBodyText extends StatelessWidget {
  const AppBodyText(
    this.text, {
    super.key,
    this.align,
    this.maxLines,
    this.muted = false,
    this.strong = false,
  });
  final String text;
  final TextAlign? align;
  final int? maxLines;

  /// Secondary copy — the one place a lighter ink is allowed.
  final bool muted;

  /// Emphasis inside body copy: still `w600`, never bold.
  final bool strong;

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: align,
    maxLines: maxLines,
    overflow: maxLines == null ? null : TextOverflow.ellipsis,
    style: TextStyle(
      fontSize: AppType.body,
      fontWeight: strong ? AppType.strong : AppType.normal,
      height: 1.4,
      color: muted ? context.colors.textSecondary : context.colors.textPrimary,
    ),
  );
}

/// Field label — sits above the value it names.
class AppLabelText extends StatelessWidget {
  const AppLabelText(this.text, {super.key, this.align});
  final String text;
  final TextAlign? align;

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: align,
    style: TextStyle(
      fontSize: AppType.label,
      fontWeight: AppType.strong,
      height: 1.3,
      color: context.colors.textPrimary,
    ),
  );
}

/// Helper lines, counters, chip text.
class AppCaptionText extends StatelessWidget {
  const AppCaptionText(
    this.text, {
    super.key,
    this.align,
    this.maxLines,
    this.color,
  });
  final String text;
  final TextAlign? align;
  final int? maxLines;

  /// Only for status colours (error red, success green); plain captions
  /// take the muted ink.
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
    text,
    textAlign: align,
    maxLines: maxLines,
    overflow: maxLines == null ? null : TextOverflow.ellipsis,
    style: TextStyle(
      fontSize: AppType.caption,
      fontWeight: AppType.normal,
      height: 1.35,
      color: color ?? context.colors.textSecondary,
    ),
  );
}
