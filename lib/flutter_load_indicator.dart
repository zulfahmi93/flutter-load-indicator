library flutter_load_indicator;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// An indeterminate progress indicator with jumping box that casts shadow.
class JumpingBoxProgressIndicator extends StatefulWidget {
  static const Color _kFillColor = const Color(0xFF2979FF);
  static const Color _kShadowColor = const Color(0xFF000000);
  static const double _kMaxElevation = 10.0;

  /// Indicator fill color.
  final Color fillColor;

  /// Indication shadow color.
  final Color shadowColor;

  /// Maximum elevation the indicator can go.
  final double maxElevation;

  /// Create new [JumpingBoxProgressIndicator].
  const JumpingBoxProgressIndicator(
      {Key key,
      this.fillColor = _kFillColor,
      this.shadowColor = _kShadowColor,
      this.maxElevation = _kMaxElevation})
      : super(key: key);

  @override
  _JumpingBoxProgressIndicatorState createState() =>
      new _JumpingBoxProgressIndicatorState(
          maxElevation: maxElevation,
          fillColor: fillColor,
          shadowColor: shadowColor);
}

class _JumpingBoxProgressIndicatorState
    extends State<JumpingBoxProgressIndicator>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  final Color fillColor;
  final Color shadowColor;
  final double maxElevation;

  _JumpingBoxProgressIndicatorState(
      {this.fillColor, this.shadowColor, this.maxElevation});

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    final CurvedAnimation curve =
        new CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _animation = new Tween<double>(begin: 0.0, end: 2.0).animate(curve)
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          _controller
            ..reset()
            ..forward();
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new AnimatedBuilder(
      animation: _animation,
      builder: (BuildContext context, Widget child) {
        return _buildIndicator(context, _animation.value);
      },
    );
  }

  Widget _buildIndicator(BuildContext context, double animationValue) {
    return new Container(
      constraints: const BoxConstraints.tightFor(
        width: double.infinity,
        height: 80.0,
      ),
      child: new CustomPaint(
        painter: new _JumpingBoxProgressIndicatorPainter(
            animationValue: animationValue,
            fillColor: fillColor,
            shadowColor: shadowColor,
            maxElevation: maxElevation),
      ),
    );
  }
}

class _JumpingBoxProgressIndicatorPainter extends CustomPainter {
  final Color fillColor;
  final Color shadowColor;
  final double animationValue;
  final double maxElevation;
  final double _gap = 0.2;

  const _JumpingBoxProgressIndicatorPainter(
      {@required this.animationValue,
      @required this.fillColor,
      @required this.shadowColor,
      @required this.maxElevation});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = new Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final Offset centre = new Offset(size.width / 2.0, size.height / 2.0);
    for (int i = 0; i < 5; i++) {
      double multiplier = animationValue - (i * _gap);
      multiplier = multiplier < 0.0 ? 0.0 : multiplier;
      multiplier *= 2 * maxElevation;
      multiplier = multiplier > 10.0 ? 20.0 - multiplier : multiplier;
      multiplier = multiplier < 0.0 ? 0.0 : multiplier;
      final double elevation = multiplier + 2.0;

      final Offset bottomOffset = new Offset(0.0, elevation);

      final Offset offset = centre + new Offset((i - 2) * 30.0, 0.0);
      final Offset topLeft = new Offset(offset.dx - 10.0, 0.0);
      final Offset bottomRight = new Offset(offset.dx + 10.0, size.height);
      final Rect rect2 = new Rect.fromPoints(
          topLeft - bottomOffset, bottomRight - bottomOffset);
      final Path path2 = new Path()..addRect(rect2);
      canvas
        ..drawShadow(path2, shadowColor, elevation, true)
        ..drawRect(rect2, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
