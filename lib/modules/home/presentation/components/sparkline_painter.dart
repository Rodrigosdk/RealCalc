
import 'package:flutter/material.dart';

/// Desenha uma linha de tendência simples a partir de uma lista de valores.
class SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double strokeWidth;

  const SparklinePainter({
    required this.data,
    required this.color,
    this.strokeWidth = 1.6,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final double minValue = data.reduce((a, b) => a < b ? a : b);
    final double maxValue = data.reduce((a, b) => a > b ? a : b);
    final double range = maxValue - minValue;
    final double stepX = size.width / (data.length - 1);

    Offset pointAt(int index) {
      final double value = data[index];
      final double normalized = range == 0 ? 0.5 : (value - minValue) / range;
      final double y = size.height - (normalized * size.height);
      return Offset(stepX * index, y);
    }

    final path = Path()..moveTo(pointAt(0).dx, pointAt(0).dy);
    for (int i = 1; i < data.length; i++) {
      final point = pointAt(i);
      path.lineTo(point.dx, point.dy);
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SparklinePainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}