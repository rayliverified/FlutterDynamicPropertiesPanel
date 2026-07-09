import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas/design_tokens.dart';

/// Visual style for the [SoftSaaSResizableRow] drag handle.
enum SoftSaaSResizableHandleStyle {
  /// Single vertical column of dots (the original style).
  dots,

  /// 2 × 3 grid of dots — the classic "grip" drag handle.
  grip,
}

/// A row with a draggable vertical divider between a flex-expanded [left]
/// panel and a fixed-width [right] panel.
///
/// The right panel starts at [initialRightWidth] and can be resized between
/// [minRightWidth] and [maxRightWidth] by dragging the handle. The left panel
/// fills the remaining space.
class SoftSaaSResizableRow extends StatefulWidget {
  const SoftSaaSResizableRow({
    super.key,
    required this.left,
    required this.right,
    required this.initialRightWidth,
    this.minRightWidth = 200,
    this.maxRightWidth = double.infinity,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    this.handleStyle = SoftSaaSResizableHandleStyle.grip,
    this.onResize,
  }) : assert(
         minRightWidth >= 0 &&
             maxRightWidth > minRightWidth &&
             initialRightWidth >= minRightWidth,
         'initialRightWidth must be >= minRightWidth, maxRightWidth must be > minRightWidth',
       );

  /// The panel that fills remaining space.
  final Widget left;

  /// The panel whose width the user can drag to resize.
  final Widget right;

  final double initialRightWidth;
  final double minRightWidth;
  final double maxRightWidth;
  final CrossAxisAlignment crossAxisAlignment;
  final SoftSaaSResizableHandleStyle handleStyle;

  /// Fired during drag with the new right width.
  final ValueChanged<double>? onResize;

  @override
  State<SoftSaaSResizableRow> createState() => _SoftSaaSResizableRowState();
}

class _SoftSaaSResizableRowState extends State<SoftSaaSResizableRow> {
  late double _rightWidth;
  double? _totalWidth;

  bool _hovering = false;
  bool _dragging = false;

  bool get _active => _hovering || _dragging;

  static const double _triggerWidth = 12;
  static const double _dotRadius = 1.25;
  static const double _dotSpacing = 1.5;

  /// Right panel width captured at pointer-down. Paired with
  /// `event.localPosition.dx` on each move (the standard resizable-row
  /// pattern) — when the handle stops moving past the clamp, `localPosition`
  /// keeps tracking the cursor so reversal resumes at the cursor's current
  /// location, not from the far end of overshoot.
  double _dragStartRightWidth = 0;

  @override
  void initState() {
    super.initState();
    _rightWidth = widget.initialRightWidth;
  }

  @override
  void didUpdateWidget(covariant SoftSaaSResizableRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.minRightWidth != widget.minRightWidth ||
        oldWidget.maxRightWidth != widget.maxRightWidth) {
      _rightWidth = _rightWidth.clamp(
        widget.minRightWidth,
        widget.maxRightWidth,
      );
    }
  }

  double _clamp(double w) {
    double clamped = w.clamp(widget.minRightWidth, widget.maxRightWidth);
    if (_totalWidth != null) {
      clamped = clamped.clamp(0, _totalWidth! - 80);
    }
    return clamped;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        if (_totalWidth != maxW) {
          _totalWidth = maxW;
          _rightWidth = _clamp(_rightWidth);
        }

        final handleColor = _active
            ? SoftSaaSTokens.tertiaryText(brightness)
            : SoftSaaSTokens.primaryBorder(brightness);

        // Handle position: centred on the boundary between the two panels.
        final handleLeft = maxW - _rightWidth - _triggerWidth / 2;

        final handle = switch (widget.handleStyle) {
          SoftSaaSResizableHandleStyle.dots => _DotsHandle(
            rows: 5,
            columns: 1,
            radius: _dotRadius,
            spacing: _dotSpacing,
            color: handleColor,
          ),
          SoftSaaSResizableHandleStyle.grip => _DotsHandle(
            rows: 3,
            columns: 2,
            radius: _dotRadius,
            spacing: _dotSpacing,
            color: handleColor,
          ),
        };

        return Stack(
          children: [
            Row(
              crossAxisAlignment: widget.crossAxisAlignment,
              children: [
                Expanded(child: widget.left),
                SizedBox(width: _rightWidth, child: widget.right),
              ],
            ),
            Positioned(
              top: 0,
              bottom: 0,
              left: handleLeft,
              width: _triggerWidth,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeColumn,
                hitTestBehavior: HitTestBehavior.opaque,
                onEnter: (_) => setState(() => _hovering = true),
                onExit: (_) => setState(() => _hovering = false),
                child: Listener(
                  behavior: HitTestBehavior.opaque,
                  onPointerDown: (e) {
                    _dragging = true;
                    _dragStartRightWidth = _rightWidth;
                    setState(() {});
                  },
                  onPointerMove: (e) {
                    // Compute the candidate width from
                    // dragStart + local cursor offset (sign flipped because
                    // we're sizing the right panel). When clamped past the
                    // end, the handle stops rebuilding so localPosition
                    // keeps tracking the cursor — reversal resumes instantly
                    // at the cursor's position.
                    final calculated =
                        _dragStartRightWidth - e.localPosition.dx;
                    final newWidth = _clamp(calculated);
                    _rightWidth = newWidth;
                    setState(() {});
                    widget.onResize?.call(_rightWidth);
                  },
                  onPointerUp: (_) {
                    _dragging = false;
                    _dragStartRightWidth = _rightWidth;
                    setState(() {});
                  },
                  child: Center(child: handle),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Renders a grid of [columns] × [rows] dots centred on the handle line.
class _DotsHandle extends StatelessWidget {
  const _DotsHandle({
    required this.rows,
    required this.columns,
    required this.radius,
    required this.spacing,
    required this.color,
  });

  final int rows;
  final int columns;
  final double radius;
  final double spacing;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int r = 0; r < rows; r++) ...[
          if (r > 0) SizedBox(height: spacing),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int c = 0; c < columns; c++) ...[
                if (c > 0) SizedBox(width: spacing),
                dot,
              ],
            ],
          ),
        ],
      ],
    );
  }
}
