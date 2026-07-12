import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';
import 'tile_shared.dart';

class ReachTile extends StatelessWidget {
  const ReachTile({
    super.key,
    required this.users,
    required this.window,
    required this.trend,
    required this.brightness,
  });

  final int users;
  final String window;
  final List<double> trend;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return PreviewTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TileLabel('Reach', LucideIcons.eye, brightness),
          const SizedBox(height: 8),
          Text(
            users.toString().replaceAllMapped(
              RegExp(r'\B(?=(\d{3})+(?!\d))'),
              (_) => ',',
            ),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: SoftSaaSTokens.primaryText(brightness),
              height: 1,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'users · $window',
            style: TextStyle(
              fontSize: 10,
              color: SoftSaaSTokens.tertiaryText(brightness),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 24,
            width: double.infinity,
            child: Sparkline(
              data: trend.isEmpty ? const [0, 0] : trend,
              color: SoftSaaSTokens.primaryColor(brightness),
            ),
          ),
        ],
      ),
    );
  }
}

class Sparkline extends StatelessWidget {
  const Sparkline({super.key, required this.data, required this.color});

  final List<double> data;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SparklinePainter(data: data, color: color),
      size: Size.infinite,
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.data, required this.color});

  final List<double> data;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxV = data.reduce((a, b) => a > b ? a : b);
    final minV = data.reduce((a, b) => a < b ? a : b);
    final range = (maxV - minV).abs() < 1e-6 ? 1.0 : (maxV - minV);
    final dx = size.width / (data.length - 1);

    final path = Path();
    final fill = Path();
    for (var i = 0; i < data.length; i++) {
      final x = dx * i;
      final y = size.height - ((data[i] - minV) / range) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
        fill.moveTo(x, size.height);
        fill.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fill.lineTo(x, y);
      }
    }
    fill.lineTo(size.width, size.height);
    fill.close();

    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0.0)],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.data != data || old.color != color;
}
