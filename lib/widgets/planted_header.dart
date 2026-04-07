import 'package:flutter/material.dart';
import '../models/score_categories.dart';

class PlantedHeader extends StatelessWidget {
  final double height;

  const PlantedHeader({super.key, this.height = 80});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8BB88A), kHeaderGreen, Color(0xFF5D7E65)],
              ),
            ),
          ),
          // Leaf decorations
          Positioned.fill(
            child: CustomPaint(painter: _LeafPainter()),
          ),
          // "Planted" title
          Center(
            child: Text(
              'Planted',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: height * 0.45,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1,
                shadows: const [
                  Shadow(
                    color: Color(0x44000000),
                    blurRadius: 4,
                    offset: Offset(1, 2),
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

class _LeafPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Draw several decorative leaves in the top-right area
    _drawLeaf(canvas, paint, Offset(size.width * 0.78, size.height * 0.15),
        size.height * 0.5, -0.3, const Color(0x55FFFFFF));
    _drawLeaf(canvas, paint, Offset(size.width * 0.88, size.height * 0.35),
        size.height * 0.45, 0.4, const Color(0x44FFFFFF));
    _drawLeaf(canvas, paint, Offset(size.width * 0.92, size.height * 0.05),
        size.height * 0.35, -0.8, const Color(0x33FFFFFF));
    _drawLeaf(canvas, paint, Offset(size.width * 0.72, size.height * 0.55),
        size.height * 0.38, 0.2, const Color(0x33FFFFFF));

    // Left side small leaves
    _drawLeaf(canvas, paint, Offset(size.width * 0.05, size.height * 0.2),
        size.height * 0.3, 2.8, const Color(0x22FFFFFF));
    _drawLeaf(canvas, paint, Offset(size.width * 0.10, size.height * 0.7),
        size.height * 0.28, 2.4, const Color(0x22FFFFFF));
  }

  void _drawLeaf(Canvas canvas, Paint paint, Offset tip, double length,
      double angle, Color color) {
    paint.color = color;
    canvas.save();
    canvas.translate(tip.dx, tip.dy);
    canvas.rotate(angle);

    final width = length * 0.45;
    final path = Path();
    // Leaf shape: pointed oval
    path.moveTo(0, 0);
    path.cubicTo(
      width * 0.6, -length * 0.25,
      width * 0.8, -length * 0.55,
      0, -length,
    );
    path.cubicTo(
      -width * 0.8, -length * 0.55,
      -width * 0.6, -length * 0.25,
      0, 0,
    );
    canvas.drawPath(path, paint);

    // Midrib
    final ribPaint = Paint()
      ..color = const Color(0x33FFFFFF)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(const Offset(0, 0), Offset(0, -length), ribPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Small inline header used in the scoring table
class PlantedTableHeader extends StatelessWidget {
  const PlantedTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8BB88A), kHeaderGreen],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _LeafPainter())),
          const Center(
            child: Text(
              'Planted',
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
