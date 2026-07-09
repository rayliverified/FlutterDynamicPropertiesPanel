// Inspector-style Rotation picker — compact number input with ° suffix and a
// triangle dropdown exposing common angle presets (0/45/90/135/180/…).
// A small circle dial left of the input previews the current angle.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design_tokens.dart';
import '../typography.dart';
import 'number_input.dart';

const _defaultAnglePresets = <double>[0, 45, 90, 135, 180, 225, 270, 315];

class SoftSaaSRotationPickerInspector extends StatefulWidget {
  const SoftSaaSRotationPickerInspector({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.label,
    this.presets = _defaultAnglePresets,
    this.width = 72,
  });

  /// Rotation in degrees (-360 … 360).
  final double value;
  final ValueChanged<double> onChanged;
  final bool enabled;
  final String? label;
  final List<double> presets;
  final double width;

  @override
  State<SoftSaaSRotationPickerInspector> createState() =>
      _SoftSaaSRotationPickerInspectorState();
}

class _SoftSaaSRotationPickerInspectorState
    extends State<SoftSaaSRotationPickerInspector> {
  bool _inputActive = false;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: SoftSaaSTypography.label(brightness)),
          const SizedBox(height: 6),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _RotationDial(
              value: widget.value,
              enabled: widget.enabled,
              brightness: brightness,
              inputActive: _inputActive,
              onChanged: widget.onChanged,
            ),
            const SizedBox(width: 6),
            Focus(
              onFocusChange: (f) => setState(() => _inputActive = f),
              child: SoftSaaSNumberInput(
                value: widget.value,
                enabled: widget.enabled,
                min: -360,
                max: 360,
                decimalPlaces: 0,
                allowNegative: true,
                size: SoftSaaSNumberInputSize.small,
                showStepper: false,
                width: widget.width,
                suffix: '°',
                presets: widget.presets,
                presetLabel: (v) => '${v.toInt()}°',
                onChanged: (v) {
                  if (v == null) return;
                  widget.onChanged(v);
                },
                onDragUpdate: (v) {
                  if (v == null) return;
                  if (!_inputActive) setState(() => _inputActive = true);
                  widget.onChanged(v);
                },
                onDragEnd: () => setState(() => _inputActive = false),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 32×32 circle showing the current rotation angle. Dragging rotates it.
class _RotationDial extends StatefulWidget {
  const _RotationDial({
    required this.value,
    required this.enabled,
    required this.brightness,
    required this.inputActive,
    required this.onChanged,
  });

  final double value;
  final bool enabled;
  final Brightness brightness;
  final bool inputActive;
  final ValueChanged<double> onChanged;

  @override
  State<_RotationDial> createState() => _RotationDialState();
}

class _RotationDialState extends State<_RotationDial> {
  bool _isDragging = false;

  static const double _size = 32.0;

  double _angleDeg(Offset local) {
    final center = Offset(_size / 2, _size / 2);
    final dx = local.dx - center.dx;
    final dy = local.dy - center.dy;
    final rad = math.atan2(dy, dx);
    // atan2 gives angle from east (3 o'clock); rotate so 0° = north (12 o'clock).
    final deg = (rad * 180 / math.pi + 90) % 360;
    return deg < 0 ? deg + 360 : deg;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.enabled
            ? (d) => widget.onChanged(_angleDeg(d.localPosition))
            : null,
        onPanStart: widget.enabled
            ? (d) {
                setState(() => _isDragging = true);
              }
            : null,
        onPanUpdate: widget.enabled
            ? (d) {
                final angle = _angleDeg(d.localPosition);
                widget.onChanged(angle);
              }
            : null,
        onPanEnd: widget.enabled
            ? (_) => setState(() => _isDragging = false)
            : null,
        child: SizedBox(
          width: _size,
          height: _size,
          child: CustomPaint(
            painter: _DialPainter(
              angleDeg: widget.value,
              active: _isDragging || widget.inputActive,
              color: SoftSaaSTokens.primaryColor(widget.brightness),
              track: SoftSaaSTokens.secondaryText(
                widget.brightness,
              ).withValues(alpha: 0.5),
              border: SoftSaaSTokens.primaryBorder(widget.brightness),
              bg: SoftSaaSTokens.secondaryBackground(widget.brightness),
            ),
          ),
        ),
      ),
    );
  }
}

class _DialPainter extends CustomPainter {
  _DialPainter({
    required this.angleDeg,
    required this.active,
    required this.color,
    required this.track,
    required this.border,
    required this.bg,
  });

  final double angleDeg;
  final bool active;
  final Color color;
  final Color track;
  final Color border;
  final Color bg;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;

    // Background circle.
    canvas.drawCircle(center, radius, Paint()..color = bg);

    // Border circle.
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Needle — line from center to edge at current angle.
    final rad = (angleDeg - 90) * math.pi / 180;
    final tipRadius = radius - 3;
    final tip = Offset(
      center.dx + tipRadius * math.cos(rad),
      center.dy + tipRadius * math.sin(rad),
    );

    final needleColor = active ? color : track;
    canvas.drawLine(
      center,
      tip,
      Paint()
        ..color = needleColor
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );

    // Center dot.
    canvas.drawCircle(center, 2, Paint()..color = needleColor);
  }

  @override
  bool shouldRepaint(covariant _DialPainter old) =>
      old.angleDeg != angleDeg ||
      old.active != active ||
      old.color != color ||
      old.border != border ||
      old.bg != bg;
}
