import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';
import 'tile_shared.dart';

class FrameTile extends StatelessWidget {
  const FrameTile({
    super.key,
    required this.width,
    required this.height,
    required this.maxWidth,
    required this.maxHeight,
    required this.brightness,
  });

  final double width;
  final double height;
  final double maxWidth;
  final double maxHeight;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return PreviewTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TileLabel('Frame', LucideIcons.frame, brightness),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: CustomPaint(
              painter: _FrameBoxPainter(
                w: width,
                h: height,
                maxW: maxWidth,
                maxH: maxHeight,
                color: SoftSaaSTokens.primaryColor(brightness),
                borderColor: SoftSaaSTokens.primaryBorder(brightness),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _frameMetric('W', '${width.toStringAsFixed(0)}px'),
              const SizedBox(width: 12),
              _frameMetric('H', '${height.toStringAsFixed(0)}px'),
              const Spacer(),
              _frameMetric(
                'Max',
                '${maxWidth.toStringAsFixed(0)}×${maxHeight.toStringAsFixed(0)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _frameMetric(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: SoftSaaSTokens.tertiaryText(brightness),
          ),
        ),
        const SizedBox(width: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: SoftSaaSTokens.primaryText(brightness),
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _FrameBoxPainter extends CustomPainter {
  _FrameBoxPainter({
    required this.w,
    required this.h,
    required this.maxW,
    required this.maxH,
    required this.color,
    required this.borderColor,
  });

  final double w;
  final double h;
  final double maxW;
  final double maxH;
  final Color color;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = maxW > 0 ? (w / maxW).clamp(0.1, 1.0) : 0.5;
    final scaleY = maxH > 0 ? (h / maxH).clamp(0.1, 1.0) : 0.5;
    final boxW = size.width * scaleX * 0.85;
    final boxH = size.height * scaleY * 0.85;
    final left = (size.width - boxW) / 2;
    final top = (size.height - boxH) / 2;
    final rect = Rect.fromLTWH(left, top, boxW, boxH);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = borderColor.withValues(alpha: 0.15),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()
        ..color = color.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)),
      Paint()
        ..color = color.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final cornerSize = math.min(8.0, boxW / 4);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.square;

    canvas.drawLine(Offset(left, top + cornerSize), Offset(left, top), paint);
    canvas.drawLine(Offset(left, top), Offset(left + cornerSize, top), paint);
    canvas.drawLine(
      Offset(left + boxW - cornerSize, top),
      Offset(left + boxW, top),
      paint,
    );
    canvas.drawLine(
      Offset(left + boxW, top),
      Offset(left + boxW, top + cornerSize),
      paint,
    );
    canvas.drawLine(
      Offset(left, top + boxH - cornerSize),
      Offset(left, top + boxH),
      paint,
    );
    canvas.drawLine(
      Offset(left, top + boxH),
      Offset(left + cornerSize, top + boxH),
      paint,
    );
    canvas.drawLine(
      Offset(left + boxW - cornerSize, top + boxH),
      Offset(left + boxW, top + boxH),
      paint,
    );
    canvas.drawLine(
      Offset(left + boxW, top + boxH),
      Offset(left + boxW, top + boxH - cornerSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(_FrameBoxPainter old) =>
      old.w != w || old.h != h || old.maxW != maxW || old.maxH != maxH;
}
