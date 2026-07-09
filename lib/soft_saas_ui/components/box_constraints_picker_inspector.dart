// Soft SaaS UI BoxConstraints Picker — Inspector-style with mini frame visual.
//
// Layout:
//                 [W↓][W↑]
//    [mini frame]
//                 [H↓][H↑]
//
// The mini frame shows horizontal arrows (min-max width) and vertical
// arrows (min-max height), sized/scaled to the entered values. Sides are
// highlighted while their input is focused.
library;

import 'package:flutter/material.dart';

import '../design_tokens.dart';
import '../typography.dart';
import 'number_preset_input.dart';

class SoftSaaSBoxConstraintsValue {
  const SoftSaaSBoxConstraintsValue({
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
  });

  final double? minWidth;
  final double? maxWidth;
  final double? minHeight;
  final double? maxHeight;

  SoftSaaSBoxConstraintsValue copyWith({
    Object? minWidth = _sentinel,
    Object? maxWidth = _sentinel,
    Object? minHeight = _sentinel,
    Object? maxHeight = _sentinel,
  }) => SoftSaaSBoxConstraintsValue(
    minWidth: identical(minWidth, _sentinel)
        ? this.minWidth
        : minWidth as double?,
    maxWidth: identical(maxWidth, _sentinel)
        ? this.maxWidth
        : maxWidth as double?,
    minHeight: identical(minHeight, _sentinel)
        ? this.minHeight
        : minHeight as double?,
    maxHeight: identical(maxHeight, _sentinel)
        ? this.maxHeight
        : maxHeight as double?,
  );

  static const _sentinel = Object();
}

enum _Axis { width, height }

class SoftSaaSBoxConstraintsPickerInspector extends StatefulWidget {
  const SoftSaaSBoxConstraintsPickerInspector({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.min = 0,
    this.max = double.infinity,
    this.label,
  });

  final SoftSaaSBoxConstraintsValue value;
  final ValueChanged<SoftSaaSBoxConstraintsValue> onChanged;
  final bool enabled;
  final double min;
  final double max;
  final String? label;

  @override
  State<SoftSaaSBoxConstraintsPickerInspector> createState() =>
      _SoftSaaSBoxConstraintsPickerInspectorState();
}

class _SoftSaaSBoxConstraintsPickerInspectorState
    extends State<SoftSaaSBoxConstraintsPickerInspector> {
  _Axis? _active;

  Widget _field({
    required String glyph,
    required double? value,
    required ValueChanged<double?> onChanged,
    required _Axis axis,
  }) {
    return SizedBox(
      width: 92,
      child: Row(
        children: [
          Text(
            glyph,
            maxLines: 1,
            softWrap: false,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: SoftSaaSTokens.tertiaryText(Theme.of(context).brightness),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Focus(
              onFocusChange: (f) => setState(() {
                if (f) {
                  _active = axis;
                } else if (_active == axis) {
                  _active = null;
                }
              }),
              child: SoftSaaSNumberPresetInput(
                value: value,
                enabled: widget.enabled,
                size: SoftSaaSNumberPresetInputSize.small,
                min: widget.min,
                max: widget.max,
                showStepper: false,
                decimalPlaces: 0,
                allowNegative: false,
                width: double.infinity,
                includeNullPreset: true,
                includeZeroPreset: true,
                includeInfinityPreset: true,
                onChanged: onChanged,
                onDragUpdate: (v) {
                  if (_active != axis) setState(() => _active = axis);
                  onChanged(v);
                },
                onDragEnd: () => setState(() {
                  if (_active == axis) _active = null;
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            _MiniConstraintsFrame(
              value: widget.value,
              active: _active,
              brightness: brightness,
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _field(
                      glyph: 'W↓',
                      value: widget.value.minWidth,
                      axis: _Axis.width,
                      onChanged: (v) =>
                          widget.onChanged(widget.value.copyWith(minWidth: v)),
                    ),
                    const SizedBox(width: 6),
                    _field(
                      glyph: 'W↑',
                      value: widget.value.maxWidth,
                      axis: _Axis.width,
                      onChanged: (v) =>
                          widget.onChanged(widget.value.copyWith(maxWidth: v)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _field(
                      glyph: 'H↓',
                      value: widget.value.minHeight,
                      axis: _Axis.height,
                      onChanged: (v) =>
                          widget.onChanged(widget.value.copyWith(minHeight: v)),
                    ),
                    const SizedBox(width: 6),
                    _field(
                      glyph: 'H↑',
                      value: widget.value.maxHeight,
                      axis: _Axis.height,
                      onChanged: (v) =>
                          widget.onChanged(widget.value.copyWith(maxHeight: v)),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniConstraintsFrame extends StatelessWidget {
  const _MiniConstraintsFrame({
    required this.value,
    required this.active,
    required this.brightness,
  });

  final SoftSaaSBoxConstraintsValue value;
  final _Axis? active;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    const size = 56.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: SoftSaaSTokens.secondaryBackground(brightness),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: SoftSaaSTokens.primaryBorder(brightness),
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _ConstraintsPainter(
                hasWidth: value.minWidth != null || value.maxWidth != null,
                hasHeight: value.minHeight != null || value.maxHeight != null,
                activeWidth: active == _Axis.width,
                activeHeight: active == _Axis.height,
                primary: SoftSaaSTokens.primaryColor(brightness),
                secondary: SoftSaaSTokens.secondaryText(brightness),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConstraintsPainter extends CustomPainter {
  _ConstraintsPainter({
    required this.hasWidth,
    required this.hasHeight,
    required this.activeWidth,
    required this.activeHeight,
    required this.primary,
    required this.secondary,
  });

  final bool hasWidth;
  final bool hasHeight;
  final bool activeWidth;
  final bool activeHeight;
  final Color primary;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCenter(
      center: center,
      width: size.width * 0.55,
      height: size.height * 0.55,
    );

    // Inner reference rect.
    final framePaint = Paint()
      ..color = secondary.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRect(rect, framePaint);

    // Width arrows (horizontal).
    final wColor = activeWidth
        ? primary
        : (hasWidth ? secondary : secondary.withValues(alpha: 0.3));
    _drawArrow(
      canvas,
      Offset(4, center.dy),
      Offset(size.width - 4, center.dy),
      wColor,
    );

    // Height arrows (vertical).
    final hColor = activeHeight
        ? primary
        : (hasHeight ? secondary : secondary.withValues(alpha: 0.3));
    _drawArrow(
      canvas,
      Offset(center.dx, 4),
      Offset(center.dx, size.height - 4),
      hColor,
    );
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(from, to, paint);
    // Arrow heads
    const arm = 3.0;
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    if (dx.abs() > dy.abs()) {
      // horizontal
      canvas.drawLine(from, from + const Offset(arm, -arm), paint);
      canvas.drawLine(from, from + const Offset(arm, arm), paint);
      canvas.drawLine(to, to + const Offset(-arm, -arm), paint);
      canvas.drawLine(to, to + const Offset(-arm, arm), paint);
    } else {
      canvas.drawLine(from, from + const Offset(-arm, arm), paint);
      canvas.drawLine(from, from + const Offset(arm, arm), paint);
      canvas.drawLine(to, to + const Offset(-arm, -arm), paint);
      canvas.drawLine(to, to + const Offset(arm, -arm), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConstraintsPainter old) =>
      old.hasWidth != hasWidth ||
      old.hasHeight != hasHeight ||
      old.activeWidth != activeWidth ||
      old.activeHeight != activeHeight;
}
