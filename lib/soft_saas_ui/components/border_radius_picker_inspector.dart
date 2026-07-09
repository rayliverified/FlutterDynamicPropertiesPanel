/// Soft SaaS UI BorderRadius Picker — Inspector-style with mini preview.
///
/// Compact positional layout, same pattern as the alignment Inspector picker:
///
///   [TL input] [mini box] [TR input]
///   [BL input]            [BR input]
///
/// The mini box paints 4 corner arcs, highlighting whichever input is
/// focused or whichever corner is hovered/dragged. Dragging anywhere in a
/// corner quadrant of the mini box directly changes that corner's radius.
library;

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../design_tokens.dart';
import '../typography.dart';
import 'number_input.dart';

enum _Corner { topLeft, topRight, bottomLeft, bottomRight }

const _defaultRadiusPresets = <double>[0, 5, 8, 10, 12, 15, 20, 25, 100];

class SoftSaaSBorderRadiusPickerInspector extends StatefulWidget {
  const SoftSaaSBorderRadiusPickerInspector({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 200,
    this.label,
    this.enabled = true,
    this.presets = _defaultRadiusPresets,
  });

  final BorderRadius value;
  final ValueChanged<BorderRadius> onChanged;
  final double min;
  final double max;
  final String? label;
  final bool enabled;
  final List<double> presets;

  @override
  State<SoftSaaSBorderRadiusPickerInspector> createState() =>
      _SoftSaaSBorderRadiusPickerInspectorState();
}

class _SoftSaaSBorderRadiusPickerInspectorState
    extends State<SoftSaaSBorderRadiusPickerInspector> {
  bool _uniform = false;
  _Corner? _active; // set by input focus/drag
  _Corner? _hoverCorner; // set by mini box hover
  _Corner? _dragCorner; // set by mini box drag

  @override
  void initState() {
    super.initState();
    final v = widget.value;
    _uniform =
        v.topLeft == v.topRight &&
        v.topRight == v.bottomLeft &&
        v.bottomLeft == v.bottomRight;
  }

  void _set(_Corner c, double r) {
    final v = widget.value;
    final radius = Radius.circular(r);
    if (_uniform) {
      widget.onChanged(BorderRadius.all(radius));
      return;
    }
    widget.onChanged(
      BorderRadius.only(
        topLeft: c == _Corner.topLeft ? radius : v.topLeft,
        topRight: c == _Corner.topRight ? radius : v.topRight,
        bottomLeft: c == _Corner.bottomLeft ? radius : v.bottomLeft,
        bottomRight: c == _Corner.bottomRight ? radius : v.bottomRight,
      ),
    );
  }

  void _toggleUniform() {
    final newUniform = !_uniform;
    setState(() => _uniform = newUniform);
    if (newUniform) {
      final r = widget.value.topLeft.x;
      widget.onChanged(BorderRadius.all(Radius.circular(r)));
    }
  }

  double _radiusForCorner(_Corner c) {
    switch (c) {
      case _Corner.topLeft:
        return widget.value.topLeft.x;
      case _Corner.topRight:
        return widget.value.topRight.x;
      case _Corner.bottomLeft:
        return widget.value.bottomLeft.x;
      case _Corner.bottomRight:
        return widget.value.bottomRight.x;
    }
  }

  Widget _cornerInput(_Corner c, double value) {
    return SizedBox(
      width: 60,
      child: Focus(
        onFocusChange: (f) => setState(() {
          if (f) {
            _active = c;
          } else if (_active == c) {
            _active = null;
          }
        }),
        child: SoftSaaSNumberInput(
          value: value,
          enabled: widget.enabled,
          size: SoftSaaSNumberInputSize.small,
          min: widget.min,
          max: widget.max,
          showStepper: false,
          decimalPlaces: 0,
          allowNegative: false,
          presets: widget.presets,
          onChanged: (v) {
            if (v == null) return;
            _set(c, v);
          },
          onDragUpdate: (v) {
            if (v == null) return;
            if (_active != c) setState(() => _active = c);
            _set(c, v);
          },
          onDragEnd: () => setState(() {
            if (_active == c) _active = null;
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    // Mini box drag takes priority, then input focus, then hover preview.
    final effectiveActive = _dragCorner ?? _active ?? _hoverCorner;

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
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _cornerInput(_Corner.topLeft, widget.value.topLeft.x),
                const SizedBox(height: 6),
                _cornerInput(_Corner.bottomLeft, widget.value.bottomLeft.x),
              ],
            ),
            const SizedBox(width: 8),
            _MiniCornerBox(
              value: widget.value,
              active: effectiveActive,
              uniform: _uniform,
              enabled: widget.enabled,
              brightness: brightness,
              onUniformToggle: _toggleUniform,
              onHoverCorner: (c) => setState(() => _hoverCorner = c),
              onDragStart: (c) => setState(() => _dragCorner = c),
              onDragUpdate: (c, delta) {
                if (_dragCorner != c) setState(() => _dragCorner = c);
                final curr = _radiusForCorner(c);
                final next = (curr + delta).clamp(widget.min, widget.max);
                _set(c, next);
              },
              onDragEnd: () => setState(() => _dragCorner = null),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _cornerInput(_Corner.topRight, widget.value.topRight.x),
                const SizedBox(height: 6),
                _cornerInput(_Corner.bottomRight, widget.value.bottomRight.x),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// 60×60 mini box showing corner arc indicators. Dragging in any quadrant
/// changes that corner's radius directly. No quadrant click-targets — hover
/// highlights arcs, drag changes values, lock button lives in the center.
class _MiniCornerBox extends StatefulWidget {
  const _MiniCornerBox({
    required this.value,
    required this.active,
    required this.uniform,
    required this.enabled,
    required this.brightness,
    required this.onUniformToggle,
    required this.onHoverCorner,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final BorderRadius value;
  final _Corner? active;
  final bool uniform;
  final bool enabled;
  final Brightness brightness;
  final VoidCallback onUniformToggle;
  final ValueChanged<_Corner?> onHoverCorner;
  final ValueChanged<_Corner> onDragStart;
  final void Function(_Corner corner, double delta) onDragUpdate;
  final VoidCallback onDragEnd;

  @override
  State<_MiniCornerBox> createState() => _MiniCornerBoxState();
}

class _MiniCornerBoxState extends State<_MiniCornerBox> {
  _Corner? _activeDragCorner;

  static const double _kSize = 52.0;
  // Radius of the center exclusion zone (lock button area).
  static const double _kLockZone = 12.0;

  _Corner? _zoneFor(Offset pos) {
    const cx = _kSize / 2;
    const cy = _kSize / 2;
    final dx = pos.dx - cx;
    final dy = pos.dy - cy;
    // Exclude center where the lock button lives.
    if (dx.abs() < _kLockZone && dy.abs() < _kLockZone) return null;
    if (pos.dx < cx && pos.dy < cy) return _Corner.topLeft;
    if (pos.dx >= cx && pos.dy < cy) return _Corner.topRight;
    if (pos.dx < cx && pos.dy >= cy) return _Corner.bottomLeft;
    return _Corner.bottomRight;
  }

  @override
  Widget build(BuildContext context) {
    const size = _kSize;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: SoftSaaSTokens.secondaryBackground(widget.brightness),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: SoftSaaSTokens.primaryBorder(widget.brightness),
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _CornerPainter(
                value: widget.value,
                active: widget.active,
                primary: SoftSaaSTokens.primaryColor(widget.brightness),
                secondary: SoftSaaSTokens.secondaryText(widget.brightness),
              ),
            ),
          ),
          // Hover + drag gesture layer — translucent so the lock button above
          // still wins its own tap events.
          Positioned.fill(
            child: MouseRegion(
              cursor: widget.enabled
                  ? SystemMouseCursors.resizeLeftRight
                  : SystemMouseCursors.basic,
              onHover: widget.enabled
                  ? (event) =>
                        widget.onHoverCorner(_zoneFor(event.localPosition))
                  : null,
              onExit: widget.enabled ? (_) => widget.onHoverCorner(null) : null,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanStart: widget.enabled
                    ? (details) {
                        final corner = _zoneFor(details.localPosition);
                        if (corner != null) {
                          setState(() => _activeDragCorner = corner);
                          widget.onDragStart(corner);
                        }
                      }
                    : null,
                onPanUpdate: widget.enabled
                    ? (details) {
                        if (_activeDragCorner != null) {
                          widget.onDragUpdate(
                            _activeDragCorner!,
                            details.delta.dx,
                          );
                        }
                      }
                    : null,
                onPanEnd: widget.enabled
                    ? (_) {
                        setState(() => _activeDragCorner = null);
                        widget.onDragEnd();
                      }
                    : null,
              ),
            ),
          ),
          // Lock button is last (on top) so it wins tap hit-testing over the
          // gesture layer below.
          _UniformLockButton(
            locked: widget.uniform,
            enabled: widget.enabled,
            onTap: widget.onUniformToggle,
            brightness: widget.brightness,
          ),
        ],
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  _CornerPainter({
    required this.value,
    required this.active,
    required this.primary,
    required this.secondary,
  });

  final BorderRadius value;
  final _Corner? active;
  final Color primary;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 6.0;
    const arm = 14.0;
    final rect = Rect.fromLTRB(pad, pad, size.width - pad, size.height - pad);

    void corner(_Corner c, double radius) {
      final isActive = active == c;
      final stroke = Paint()
        ..color = isActive ? primary : secondary.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = isActive ? 1.5 : 1.1;
      final display = radius.clamp(0.0, arm);
      final path = Path();
      switch (c) {
        case _Corner.topLeft:
          path.moveTo(rect.left, rect.top + arm);
          path.lineTo(rect.left, rect.top + display);
          path.quadraticBezierTo(
            rect.left,
            rect.top,
            rect.left + display,
            rect.top,
          );
          path.lineTo(rect.left + arm, rect.top);
        case _Corner.topRight:
          path.moveTo(rect.right - arm, rect.top);
          path.lineTo(rect.right - display, rect.top);
          path.quadraticBezierTo(
            rect.right,
            rect.top,
            rect.right,
            rect.top + display,
          );
          path.lineTo(rect.right, rect.top + arm);
        case _Corner.bottomLeft:
          path.moveTo(rect.left, rect.bottom - arm);
          path.lineTo(rect.left, rect.bottom - display);
          path.quadraticBezierTo(
            rect.left,
            rect.bottom,
            rect.left + display,
            rect.bottom,
          );
          path.lineTo(rect.left + arm, rect.bottom);
        case _Corner.bottomRight:
          path.moveTo(rect.right - arm, rect.bottom);
          path.lineTo(rect.right - display, rect.bottom);
          path.quadraticBezierTo(
            rect.right,
            rect.bottom,
            rect.right,
            rect.bottom - display,
          );
          path.lineTo(rect.right, rect.bottom - arm);
      }
      canvas.drawPath(path, stroke);
    }

    corner(_Corner.topLeft, value.topLeft.x);
    corner(_Corner.topRight, value.topRight.x);
    corner(_Corner.bottomLeft, value.bottomLeft.x);
    corner(_Corner.bottomRight, value.bottomRight.x);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter old) =>
      old.value != value || old.active != active;
}

class _UniformLockButton extends StatefulWidget {
  const _UniformLockButton({
    required this.locked,
    required this.enabled,
    required this.onTap,
    required this.brightness,
  });

  final bool locked;
  final bool enabled;
  final VoidCallback onTap;
  final Brightness brightness;

  @override
  State<_UniformLockButton> createState() => _UniformLockButtonState();
}

class _UniformLockButtonState extends State<_UniformLockButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.locked
        ? SoftSaaSTokens.primaryColor(widget.brightness)
        : SoftSaaSTokens.secondaryText(widget.brightness);
    return MouseRegion(
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: Tooltip(
          message: widget.locked ? 'Unlock corners' : 'Lock corners',
          child: AnimatedContainer(
            duration: SoftSaaSTokens.transitionDuration,
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _hovered
                  ? SoftSaaSTokens.controlHoverOverlay(widget.brightness)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Icon(
              widget.locked ? LucideIcons.lock : LucideIcons.lock_open,
              size: 12,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
