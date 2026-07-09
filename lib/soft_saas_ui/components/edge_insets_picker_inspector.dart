/// Soft SaaS UI EdgeInsets Picker — Inspector-style with mini preview.
///
/// Cross-pattern layout:
///
///                [T input]
///   [L input]   [mini box]  [R input]
///                [B input]
///
/// The mini box (60×60) paints 4 inset bars. Hovering over a side strip
/// highlights that bar. Dragging in a side strip changes the value for that
/// side. The center button toggles uniform mode.
library;

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../design_tokens.dart';
import '../typography.dart';
import 'number_input.dart';

enum _Side { top, right, bottom, left }

const _defaultSpacingPresets = <double>[0, 2, 4, 6, 8, 12, 16, 24, 32, 48];

class SoftSaaSEdgeInsetsPickerInspector extends StatefulWidget {
  const SoftSaaSEdgeInsetsPickerInspector({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 999,
    this.label,
    this.enabled = true,
    this.presets = _defaultSpacingPresets,
  });

  final EdgeInsets value;
  final ValueChanged<EdgeInsets> onChanged;
  final double min;
  final double max;
  final String? label;
  final bool enabled;
  final List<double> presets;

  @override
  State<SoftSaaSEdgeInsetsPickerInspector> createState() =>
      _SoftSaaSEdgeInsetsPickerInspectorState();
}

class _SoftSaaSEdgeInsetsPickerInspectorState
    extends State<SoftSaaSEdgeInsetsPickerInspector> {
  bool _uniform = false;
  _Side? _active; // set by input focus/drag
  _Side? _hoverSide; // set by mini box hover
  _Side? _dragSide; // set by mini box drag

  static const double _inputWidth = 60;
  static const double _gap = 8;
  // Centers T/B inputs above/below the mini box: _inputWidth + _gap + _kSize/2 - _inputWidth/2 = 60+8+26-30 = 64
  static const double _topBottomOffset = 64;

  @override
  void initState() {
    super.initState();
    final v = widget.value;
    _uniform = v.left == v.top && v.top == v.right && v.right == v.bottom;
  }

  void _setSide(_Side side, double v) {
    final current = widget.value;
    if (_uniform) {
      widget.onChanged(EdgeInsets.all(v));
      return;
    }
    switch (side) {
      case _Side.top:
        widget.onChanged(current.copyWith(top: v));
      case _Side.right:
        widget.onChanged(current.copyWith(right: v));
      case _Side.bottom:
        widget.onChanged(current.copyWith(bottom: v));
      case _Side.left:
        widget.onChanged(current.copyWith(left: v));
    }
  }

  void _toggleUniform() {
    final newUniform = !_uniform;
    setState(() => _uniform = newUniform);
    if (newUniform) {
      widget.onChanged(EdgeInsets.all(widget.value.left));
    }
  }

  double _valueForSide(_Side s) {
    switch (s) {
      case _Side.top:
        return widget.value.top;
      case _Side.right:
        return widget.value.right;
      case _Side.bottom:
        return widget.value.bottom;
      case _Side.left:
        return widget.value.left;
    }
  }

  Widget _sideInput(_Side side, double value) {
    return SizedBox(
      width: _inputWidth,
      child: Focus(
        onFocusChange: (f) => setState(() {
          if (f) {
            _active = side;
          } else if (_active == side) {
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
            _setSide(side, v);
          },
          onDragUpdate: (v) {
            if (v == null) return;
            if (_active != side) setState(() => _active = side);
            _setSide(side, v);
          },
          onDragEnd: () => setState(() {
            if (_active == side) _active = null;
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    // Mini box drag takes priority, then input focus, then hover preview.
    final effectiveActive = _dragSide ?? _active ?? _hoverSide;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: SoftSaaSTypography.label(brightness)),
          const SizedBox(height: 6),
        ],
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: _topBottomOffset),
              child: _sideInput(_Side.top, widget.value.top),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _sideInput(_Side.left, widget.value.left),
                const SizedBox(width: _gap),
                _MiniInsetBox(
                  value: widget.value,
                  active: effectiveActive,
                  uniform: _uniform,
                  enabled: widget.enabled,
                  brightness: brightness,
                  onUniformToggle: _toggleUniform,
                  onHoverSide: (s) => setState(() => _hoverSide = s),
                  onDragStart: (s) => setState(() => _dragSide = s),
                  onDragUpdate: (s, delta) {
                    if (_dragSide != s) setState(() => _dragSide = s);
                    final curr = _valueForSide(s);
                    final next = (curr + delta).clamp(widget.min, widget.max);
                    _setSide(s, next);
                  },
                  onDragEnd: () => setState(() => _dragSide = null),
                ),
                const SizedBox(width: _gap),
                _sideInput(_Side.right, widget.value.right),
              ],
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: _topBottomOffset),
              child: _sideInput(_Side.bottom, widget.value.bottom),
            ),
          ],
        ),
      ],
    );
  }
}

/// 60×60 square showing 4 inset bars and a center uniform-lock button.
/// Hovering over a side strip highlights it; dragging changes its value.
class _MiniInsetBox extends StatefulWidget {
  const _MiniInsetBox({
    required this.value,
    required this.active,
    required this.uniform,
    required this.enabled,
    required this.brightness,
    required this.onUniformToggle,
    required this.onHoverSide,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  final EdgeInsets value;
  final _Side? active;
  final bool uniform;
  final bool enabled;
  final Brightness brightness;
  final VoidCallback onUniformToggle;
  final ValueChanged<_Side?> onHoverSide;
  final ValueChanged<_Side> onDragStart;
  final void Function(_Side side, double delta) onDragUpdate;
  final VoidCallback onDragEnd;

  @override
  State<_MiniInsetBox> createState() => _MiniInsetBoxState();
}

class _MiniInsetBoxState extends State<_MiniInsetBox> {
  _Side? _activeDragSide;

  static const double _kSize = 52.0;
  static const double _kThreshold = 17.0; // edge-zone width

  _Side? _zoneFor(Offset pos) {
    final dy = pos.dy;
    final dx = pos.dx;
    final inTop = dy < _kThreshold;
    final inBottom = dy > _kSize - _kThreshold;
    final inLeft = dx < _kThreshold;
    final inRight = dx > _kSize - _kThreshold;

    // In corner areas, pick the axis that is furthest from its opposite edge.
    if (inTop && inLeft) return dy < dx ? _Side.top : _Side.left;
    if (inTop && inRight) {
      return dy < (_kSize - dx) ? _Side.top : _Side.right;
    }
    if (inBottom && inLeft) {
      return (_kSize - dy) < dx ? _Side.bottom : _Side.left;
    }
    if (inBottom && inRight) {
      return (_kSize - dy) < (_kSize - dx) ? _Side.bottom : _Side.right;
    }

    if (inTop) return _Side.top;
    if (inBottom) return _Side.bottom;
    if (inLeft) return _Side.left;
    if (inRight) return _Side.right;
    return null; // center — lock button
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
              painter: _InsetPainter(
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
                  ? (event) => widget.onHoverSide(_zoneFor(event.localPosition))
                  : null,
              onExit: widget.enabled ? (_) => widget.onHoverSide(null) : null,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onPanStart: widget.enabled
                    ? (details) {
                        final side = _zoneFor(details.localPosition);
                        if (side != null) {
                          setState(() => _activeDragSide = side);
                          widget.onDragStart(side);
                        }
                      }
                    : null,
                onPanUpdate: widget.enabled
                    ? (details) {
                        if (_activeDragSide != null) {
                          widget.onDragUpdate(
                            _activeDragSide!,
                            details.delta.dx,
                          );
                        }
                      }
                    : null,
                onPanEnd: widget.enabled
                    ? (_) {
                        setState(() => _activeDragSide = null);
                        widget.onDragEnd();
                      }
                    : null,
              ),
            ),
          ),
          // Lock button is last (on top) so it wins tap hit-testing.
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

class _InsetPainter extends CustomPainter {
  _InsetPainter({
    required this.value,
    required this.active,
    required this.primary,
    required this.secondary,
  });

  final EdgeInsets value;
  final _Side? active;
  final Color primary;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 5.0;
    const inner = 14.0;
    final outer = Rect.fromLTRB(pad, pad, size.width - pad, size.height - pad);
    final innerRect = Rect.fromLTRB(
      outer.left + inner,
      outer.top + inner,
      outer.right - inner,
      outer.bottom - inner,
    );

    void side(_Side s, Offset from, Offset to) {
      final isActive = active == s;
      final color = isActive ? primary : secondary.withValues(alpha: 0.4);
      canvas.drawLine(
        from,
        to,
        Paint()
          ..color = color
          ..strokeWidth = isActive ? 1.5 : 1.1
          ..strokeCap = StrokeCap.round,
      );
    }

    side(
      _Side.top,
      Offset(innerRect.left, outer.top + 1.5),
      Offset(innerRect.right, outer.top + 1.5),
    );
    side(
      _Side.bottom,
      Offset(innerRect.left, outer.bottom - 1.5),
      Offset(innerRect.right, outer.bottom - 1.5),
    );
    side(
      _Side.left,
      Offset(outer.left + 1.5, innerRect.top),
      Offset(outer.left + 1.5, innerRect.bottom),
    );
    side(
      _Side.right,
      Offset(outer.right - 1.5, innerRect.top),
      Offset(outer.right - 1.5, innerRect.bottom),
    );
  }

  @override
  bool shouldRepaint(covariant _InsetPainter old) =>
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
          message: widget.locked
              ? 'Unlock (independent sides)'
              : 'Lock (uniform)',
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
