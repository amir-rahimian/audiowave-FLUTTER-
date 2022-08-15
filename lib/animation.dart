import 'package:flutter/material.dart';

class SoundRipple extends StatefulWidget {
  final double decibel;
  const SoundRipple(this.decibel, {Key? key}) : super(key: key);

  @override
  _SoundRippleState createState() => _SoundRippleState();
}

class _SoundRippleState extends State<SoundRipple> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CPainter(
        color: Colors.red,
        centerCSize: widget.decibel - 2,
        centerCRadius: widget.decibel,
        centerCOpacity: widget.decibel / 100,
        otherCSize: (widget.decibel - 2) * 1.2,
        otherCRadius: widget.decibel,
        otherCOpacity: (widget.decibel / 100) / 5,
      ),
    );
  }
}

class CPainter extends CustomPainter {
  final Color color;
  final double centerCSize;
  final double centerCRadius;
  final double centerCOpacity;
  final double otherCSize;
  final double otherCRadius;
  final double otherCOpacity;

  CPainter({
    required this.color,
    required this.centerCSize,
    required this.centerCRadius,
    required this.centerCOpacity,
    required this.otherCSize,
    required this.otherCRadius,
    required this.otherCOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint centerC = Paint();
    centerC.color = color.withOpacity(centerCOpacity);
    centerC.style = PaintingStyle.fill;

    Rect rect = Rect.fromCircle(center: Offset.zero, radius: centerCSize);
    canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(centerCRadius)), centerC);

    canvas.save();
    rotate(
        canvas: canvas, cx: size.height / 2, cy: size.height / 2, angle: 0.7);

    Paint otherC = Paint();
    otherC.color = color.withOpacity(otherCOpacity);
    otherC.style = PaintingStyle.fill;

    Rect otherCRect = Rect.fromCircle(center: Offset.zero, radius: otherCSize);
    canvas.drawRRect(
        RRect.fromRectAndRadius(otherCRect, Radius.circular(otherCRadius)),
        centerC);
    canvas.restore();
  }

  void rotate(
      {required Canvas canvas,
      required double cx,
      required double cy,
      required double angle}) {
    canvas.translate(cx, cy);
    canvas.rotate(angle);
    canvas.translate(-cx, -cy);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
