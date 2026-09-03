import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../data/models/product.dart';
import '../const.dart';
import 'product_icons.dart';

class ProductScene extends ConsumerWidget {
  const ProductScene({super.key, required this.product, this.size = 88});

  final Product product;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: Size.square(size), painter: const _ScenePainter()),
          if (_artFor(product.code) case final art?)
            CustomPaint(size: Size.square(size), painter: _ArtPainter(art))
          else ...[
            CustomPaint(
              size: Size.square(size * 0.62),
              painter: const _ShieldPainter(),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: size * 0.05),
              child: FaIcon(
                ProductVisuals.iconFor(product),
                size: size * 0.26,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

_Art? _artFor(String code) => switch (code) {
  'UL-01' || 'STE-01' => _Art.savings,
  'EL-01' || 'GL-01' => _Art.family,
  'PA-01' || 'TV-01' => _Art.accident,
  'HI-01' || 'CI-01' || 'IM-01' || 'MH-01' => _Art.hospital,
  _ => null,
};

enum _Art { savings, family, accident, outdoor, hospital }

class _ArtPainter extends CustomPainter {
  const _ArtPainter(this.art);
  final _Art art;

  static const _deep = AppColors.deep;
  static const _primaryColor = AppColors.primaryColor;
  static const _sky = AppColors.primaryColor;

  @override
  void paint(Canvas canvas, Size s) {
    switch (art) {
      case _Art.savings:
        _savings(canvas, s);
      case _Art.family:
        _family(canvas, s);
      case _Art.accident:
        _accident(canvas, s);
      case _Art.outdoor:
        _outdoor(canvas, s);
      case _Art.hospital:
        _hospital(canvas, s);
    }
  }

  Paint _fill(Color c) => Paint()..color = c;

  Paint _stroke(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  void _rrect(
    Canvas c,
    Size s,
    double l,
    double t,
    double w,
    double h,
    double r,
    Color color,
  ) {
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(l * s.width, t * s.height, w * s.width, h * s.height),
        Radius.circular(r * s.width),
      ),
      _fill(color),
    );
  }

  void _person(
    Canvas c,
    Size s,
    double x,
    double y,
    double scale,
    Color color,
  ) {
    final u = s.width;
    c.drawCircle(Offset(x * u, y * u), 0.075 * u * scale, _fill(color));
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(x * u, (y + 0.20 * scale) * u),
          width: 0.20 * u * scale,
          height: 0.24 * u * scale,
        ),
        Radius.circular(0.09 * u * scale),
      ),
      _fill(color),
    );
  }

  void _savings(Canvas c, Size s) {
    final u = s.width;
    for (var i = 0; i < 3; i++) {
      final h = 0.10 + i * 0.10;
      _rrect(
        c,
        s,
        0.20 + i * 0.19,
        0.74 - h,
        0.14,
        h,
        0.03,
        [_sky, _primaryColor, _deep][i],
      );
    }
    final p = Path()
      ..moveTo(0.20 * u, 0.44 * u)
      ..lineTo(0.44 * u, 0.26 * u)
      ..lineTo(0.60 * u, 0.36 * u)
      ..lineTo(0.82 * u, 0.16 * u);
    c.drawPath(p, _stroke(_deep, 0.055 * u));
    final head = Path()
      ..moveTo(0.84 * u, 0.13 * u)
      ..lineTo(0.66 * u, 0.16 * u)
      ..lineTo(0.80 * u, 0.30 * u)
      ..close();
    c.drawPath(head, _fill(_deep));
  }

  void _family(Canvas c, Size s) {
    final u = s.width;
    final canopy = Path()
      ..moveTo(0.10 * u, 0.40 * u)
      ..arcToPoint(
        Offset(0.90 * u, 0.40 * u),
        radius: Radius.circular(0.42 * u),
      )
      ..close();
    c.drawPath(canopy, _fill(_deep));
    c.drawLine(
      Offset(0.50 * u, 0.40 * u),
      Offset(0.50 * u, 0.62 * u),
      _stroke(_primaryColor, 0.035 * u),
    );
    _person(c, s, 0.30, 0.58, 1.0, _primaryColor);
    _person(c, s, 0.70, 0.58, 1.0, _primaryColor);
    _person(c, s, 0.50, 0.68, 0.72, _sky);
  }

  void _accident(Canvas c, Size s) {
    final u = s.width;
    c.drawOval(
      Rect.fromCenter(
        center: Offset(0.42 * u, 0.86 * u),
        width: 0.52 * u,
        height: 0.12 * u,
      ),
      _fill(_sky.withValues(alpha: 0.55)),
    );
    c.save();
    c.translate(0.40 * u, 0.52 * u);
    c.rotate(-0.5);
    c.drawCircle(Offset(0, -0.16 * u), 0.085 * u, _fill(_primaryColor));
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 0.21 * u, height: 0.28 * u),
        Radius.circular(0.10 * u),
      ),
      _fill(_primaryColor),
    );
    c.restore();
    c.drawLine(
      Offset(0.20 * u, 0.34 * u),
      Offset(0.30 * u, 0.26 * u),
      _stroke(_primaryColor, 0.05 * u),
    );
    final sign = Path()
      ..moveTo(0.78 * u, 0.46 * u)
      ..lineTo(0.94 * u, 0.84 * u)
      ..lineTo(0.62 * u, 0.84 * u)
      ..close();
    c.drawPath(sign, _fill(_deep));
    c.drawLine(
      Offset(0.78 * u, 0.58 * u),
      Offset(0.78 * u, 0.70 * u),
      _stroke(Colors.white, 0.035 * u),
    );
    c.drawCircle(Offset(0.78 * u, 0.76 * u), 0.018 * u, _fill(Colors.white));
  }

  void _outdoor(Canvas c, Size s) {
    final u = s.width;
    c.drawCircle(
      Offset(0.78 * u, 0.22 * u),
      0.09 * u,
      _fill(_sky.withValues(alpha: 0.6)),
    );
    final far = Path()
      ..moveTo(0.02 * u, 0.84 * u)
      ..lineTo(0.34 * u, 0.34 * u)
      ..lineTo(0.66 * u, 0.84 * u)
      ..close();
    c.drawPath(far, _fill(_sky));
    final near = Path()
      ..moveTo(0.36 * u, 0.86 * u)
      ..lineTo(0.68 * u, 0.44 * u)
      ..lineTo(0.99 * u, 0.86 * u)
      ..close();
    c.drawPath(near, _fill(_primaryColor));
    _person(c, s, 0.22, 0.56, 0.9, _deep);
    c.drawLine(
      Offset(0.34 * u, 0.56 * u),
      Offset(0.36 * u, 0.82 * u),
      _stroke(_deep, 0.028 * u),
    );
  }

  void _hospital(Canvas c, Size s) {
    final u = s.width;
    _rrect(c, s, 0.14, 0.44, 0.07, 0.28, 0.02, _primaryColor);
    _rrect(c, s, 0.14, 0.62, 0.66, 0.12, 0.04, _deep);
    _rrect(c, s, 0.20, 0.74, 0.03, 0.10, 0.015, _primaryColor);
    _rrect(c, s, 0.72, 0.74, 0.03, 0.10, 0.015, _primaryColor);
    c.drawCircle(Offset(0.28 * u, 0.55 * u), 0.065 * u, _fill(_sky));
    _rrect(c, s, 0.34, 0.52, 0.44, 0.11, 0.05, _sky);
    c.drawLine(
      Offset(0.90 * u, 0.24 * u),
      Offset(0.90 * u, 0.80 * u),
      _stroke(_primaryColor, 0.025 * u),
    );
    _rrect(c, s, 0.84, 0.24, 0.11, 0.16, 0.03, _deep);
    c.drawLine(
      Offset(0.895 * u, 0.28 * u),
      Offset(0.895 * u, 0.36 * u),
      _stroke(Colors.white, 0.022 * u),
    );
    c.drawLine(
      Offset(0.855 * u, 0.32 * u),
      Offset(0.935 * u, 0.32 * u),
      _stroke(Colors.white, 0.022 * u),
    );
  }

  @override
  bool shouldRepaint(_ArtPainter old) => old.art != art;
}

class _ScenePainter extends CustomPainter {
  const _ScenePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.width * 0.22),
    );
    canvas.save();
    canvas.clipRRect(r);

    canvas.drawRRect(
      r,
      Paint()..color = AppColors.primaryColor.withValues(alpha: 0.10),
    );

    final blob = Paint()
      ..color = AppColors.primaryColor.withValues(alpha: 0.13);
    canvas.drawCircle(
      Offset(size.width * 0.22, size.height * 0.26),
      size.width * 0.30,
      blob,
    );
    canvas.drawCircle(
      Offset(size.width * 0.86, size.height * 0.84),
      size.width * 0.26,
      blob,
    );

    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.82, size.width, size.height * 0.18),
      Paint()..color = AppColors.primaryColor.withValues(alpha: 0.10),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ScenePainter oldDelegate) => false;
}

class _ShieldPainter extends CustomPainter {
  const _ShieldPainter();

  static Path shieldPath(Size s) {
    double x(double v) => v * s.width;
    double y(double v) => v * s.height;
    return Path()
      ..moveTo(x(0.5), y(0.03))
      ..lineTo(x(0.94), y(0.20))
      ..lineTo(x(0.94), y(0.50))
      ..cubicTo(x(0.94), y(0.75), x(0.76), y(0.91), x(0.5), y(0.98))
      ..cubicTo(x(0.24), y(0.91), x(0.06), y(0.75), x(0.06), y(0.50))
      ..lineTo(x(0.06), y(0.20))
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = shieldPath(size);
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryColor, AppColors.deep],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.05
        ..color = AppColors.primaryColor.withValues(alpha: 0.45),
    );
  }

  @override
  bool shouldRepaint(_ShieldPainter oldDelegate) => false;
}
