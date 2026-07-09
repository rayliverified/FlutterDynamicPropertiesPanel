/// Soft SaaS UI Alignment Picker — Inspector-style right-panel layout.
///
/// Compact horizontal layout: `[mini 32×32 anchor] [X input] [Y input]`.
/// Meant for dense inspector panels where the 75×75 grid is too big.
///
/// This is a **standalone** widget — not a variant of [SoftSaaSAlignmentPicker].
/// Choose the widget that matches your surface instead of flipping a variant.
library;

import 'package:flutter/material.dart';

import '../design_tokens.dart';
import '../typography.dart';
import 'number_input.dart';

class SoftSaaSAlignmentPickerInspector extends StatelessWidget {
  const SoftSaaSAlignmentPickerInspector({
    super.key,
    required this.alignment,
    required this.onChanged,
    this.label,
    this.enabled = true,
  });

  final Alignment alignment;
  final ValueChanged<Alignment> onChanged;
  final String? label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: SoftSaaSTypography.label(brightness)),
          const SizedBox(height: 6),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _MiniAnchor(
              alignment: alignment,
              enabled: enabled,
              brightness: brightness,
              onChanged: onChanged,
            ),
            const SizedBox(width: 8),
            _AxisInput(
              axisLabel: 'X',
              value: alignment.x,
              enabled: enabled,
              onChanged: (v) => onChanged(Alignment(v, alignment.y)),
            ),
            const SizedBox(width: 6),
            _AxisInput(
              axisLabel: 'Y',
              value: alignment.y,
              enabled: enabled,
              onChanged: (v) => onChanged(Alignment(alignment.x, v)),
            ),
          ],
        ),
      ],
    );
  }
}

/// Axis-labeled compact number input used by the Inspector layout.
class _AxisInput extends StatelessWidget {
  const _AxisInput({
    required this.axisLabel,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String axisLabel;
  final double value;
  final bool enabled;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          axisLabel,
          style: SoftSaaSTypography.labelSmall(
            brightness,
          ).copyWith(color: SoftSaaSTokens.tertiaryText(brightness)),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 56,
          child: SoftSaaSNumberInput(
            value: value,
            min: -1,
            max: 1,
            step: 0.1,
            decimalPlaces: 1,
            allowNegative: true,
            showStepper: false,
            enabled: enabled,
            size: SoftSaaSNumberInputSize.small,
            onChanged: (v) {
              if (v == null) return;
              onChanged(v.clamp(-1.0, 1.0));
            },
          ),
        ),
      ],
    );
  }
}

/// Tiny 32×32 visual indicator + click target. Taps snap to the closest
/// standard alignment cell. Hovered cell previews in primary color.
class _MiniAnchor extends StatefulWidget {
  const _MiniAnchor({
    required this.alignment,
    required this.enabled,
    required this.brightness,
    required this.onChanged,
  });

  final Alignment alignment;
  final bool enabled;
  final Brightness brightness;
  final ValueChanged<Alignment> onChanged;

  @override
  State<_MiniAnchor> createState() => _MiniAnchorState();
}

class _MiniAnchorState extends State<_MiniAnchor> {
  Alignment? _hovered;

  static const double _size = 32.0;

  Alignment _snap(Offset local) {
    double axis(double v, double max) {
      final third = max / 3;
      if (v < third) return -1;
      if (v < 2 * third) return 0;
      return 1;
    }

    return Alignment(axis(local.dx, _size), axis(local.dy, _size));
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onHover: widget.enabled
          ? (e) {
              final snapped = _snap(e.localPosition);
              if (snapped != _hovered) setState(() => _hovered = snapped);
            }
          : null,
      onExit: (_) => setState(() => _hovered = null),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.enabled
            ? (d) => widget.onChanged(_snap(d.localPosition))
            : null,
        child: Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            color: SoftSaaSTokens.secondaryBackground(widget.brightness),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(
              color: SoftSaaSTokens.primaryBorder(widget.brightness),
            ),
          ),
          child: CustomPaint(
            painter: _AnchorDotPainter(
              alignment: widget.alignment,
              hovered: _hovered,
              color: SoftSaaSTokens.primaryColor(widget.brightness),
              hoverColor: SoftSaaSTokens.primaryColor(
                widget.brightness,
              ).withValues(alpha: 0.4),
              track: SoftSaaSTokens.secondaryText(
                widget.brightness,
              ).withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnchorDotPainter extends CustomPainter {
  _AnchorDotPainter({
    required this.alignment,
    required this.hovered,
    required this.color,
    required this.hoverColor,
    required this.track,
  });

  final Alignment alignment;
  final Alignment? hovered;
  final Color color;
  final Color hoverColor;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const inset = 8.0;
    final w = size.width - inset * 2;
    final h = size.height - inset * 2;
    final dotPaint = Paint()..color = track;
    final activePaint = Paint()..color = color;
    final hoverPaint = Paint()..color = hoverColor;

    for (var yi = -1; yi <= 1; yi++) {
      for (var xi = -1; xi <= 1; xi++) {
        final dx = inset + ((xi + 1) / 2) * w;
        final dy = inset + ((yi + 1) / 2) * h;
        final xd = xi.toDouble();
        final yd = yi.toDouble();
        final active = alignment.x == xd && alignment.y == yd;
        final isHovered =
            !active && hovered != null && hovered!.x == xd && hovered!.y == yd;
        canvas.drawCircle(
          Offset(dx, dy),
          active ? 3 : (isHovered ? 2.5 : 1.5),
          active ? activePaint : (isHovered ? hoverPaint : dotPaint),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AnchorDotPainter old) =>
      old.alignment != alignment ||
      old.hovered != hovered ||
      old.color != color ||
      old.hoverColor != hoverColor ||
      old.track != track;
}
