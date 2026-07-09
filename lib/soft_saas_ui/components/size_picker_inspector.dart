// Soft SaaS UI Size Picker — Inspector-style with aspect-ratio indicator.
//
// Layout:
//   [aspect ▾]  [W input]  [🔗]  [H input]
//
// The aspect indicator shows a small rectangle proportional to W:H with a
// triangle that opens a preset-ratio menu (1:1, 16:9, 4:3, etc.). When the
// chain is locked, adjusting either input (including drag) keeps the ratio.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../design_tokens.dart';
import '../typography.dart';
import 'number_preset_input.dart';

enum _Axis { width, height }

/// A named aspect ratio preset.
class SoftSaaSAspectRatioPreset {
  const SoftSaaSAspectRatioPreset({required this.label, required this.ratio});

  final String label;
  final double ratio;
}

const _defaultPresets = <SoftSaaSAspectRatioPreset>[
  SoftSaaSAspectRatioPreset(label: '1:1', ratio: 1),
  SoftSaaSAspectRatioPreset(label: '4:3', ratio: 4 / 3),
  SoftSaaSAspectRatioPreset(label: '3:4', ratio: 3 / 4),
  SoftSaaSAspectRatioPreset(label: '3:2', ratio: 3 / 2),
  SoftSaaSAspectRatioPreset(label: '2:3', ratio: 2 / 3),
  SoftSaaSAspectRatioPreset(label: '16:9', ratio: 16 / 9),
  SoftSaaSAspectRatioPreset(label: '9:16', ratio: 9 / 16),
  SoftSaaSAspectRatioPreset(label: '21:9', ratio: 21 / 9),
];

class SoftSaaSSizePickerInspector extends StatefulWidget {
  const SoftSaaSSizePickerInspector({
    super.key,
    required this.width,
    required this.height,
    required this.onChanged,
    this.enabled = true,
    this.min = 0,
    this.max = double.infinity,
    this.label,
    this.presets = _defaultPresets,
  });

  final double? width;
  final double? height;
  final void Function(double? width, double? height) onChanged;
  final bool enabled;
  final double min;
  final double max;
  final String? label;
  final List<SoftSaaSAspectRatioPreset> presets;

  @override
  State<SoftSaaSSizePickerInspector> createState() =>
      _SoftSaaSSizePickerInspectorState();
}

class _SoftSaaSSizePickerInspectorState
    extends State<SoftSaaSSizePickerInspector> {
  static const double _rowHeight = 32;
  static const double _inputWidth = 86;

  bool _locked = false;
  double _ratio = 1;
  _Axis? _active;

  @override
  void initState() {
    super.initState();
    final h = widget.height;
    final w = widget.width;
    if (w != null && h != null && h != 0 && w.isFinite && h.isFinite) {
      _ratio = w / h;
    } else {
      _ratio = 1;
    }
  }

  double _clamp(double v) {
    if (v.isInfinite) return widget.max.isFinite ? widget.max : v;
    return v.clamp(widget.min, widget.max).toDouble();
  }

  bool get _canApplyRatio {
    final w = widget.width;
    final h = widget.height;
    return _locked &&
        w != null &&
        h != null &&
        w.isFinite &&
        h.isFinite &&
        _ratio.isFinite &&
        _ratio > 0;
  }

  void _setWidth(double? w) {
    if (_canApplyRatio && w != null && w.isFinite) {
      final h = _clamp(w / _ratio);
      widget.onChanged(w, h);
    } else {
      widget.onChanged(w, widget.height);
    }
  }

  void _setHeight(double? h) {
    if (_canApplyRatio && h != null && h.isFinite) {
      final w = _clamp(h * _ratio);
      widget.onChanged(w, h);
    } else {
      widget.onChanged(widget.width, h);
    }
  }

  void _toggleLock() {
    setState(() {
      _locked = !_locked;
      final w = widget.width;
      final h = widget.height;
      if (_locked &&
          w != null &&
          h != null &&
          h != 0 &&
          w.isFinite &&
          h.isFinite) {
        _ratio = w / h;
      }
    });
  }

  void _applyPreset(SoftSaaSAspectRatioPreset preset) {
    setState(() {
      _ratio = preset.ratio;
      _locked = true;
    });
    final baseWidth = widget.width;
    final double w = (baseWidth != null && baseWidth.isFinite && baseWidth > 0)
        ? baseWidth
        : 100.0;
    final h = _clamp(w / preset.ratio);
    widget.onChanged(w, h);
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
            _AspectIndicator(
              width: widget.width,
              height: widget.height,
              active: _active,
              locked: _locked,
              enabled: widget.enabled,
              brightness: brightness,
              presets: widget.presets,
              onPresetSelected: _applyPreset,
              height_: _rowHeight,
            ),
            const SizedBox(width: 6),
            SizedBox(
              width: _inputWidth,
              child: Row(
                children: [
                  Text(
                    'W',
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: SoftSaaSTokens.tertiaryText(brightness),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Focus(
                      onFocusChange: (f) =>
                          setState(() => _active = f ? _Axis.width : null),
                      child: SoftSaaSNumberPresetInput(
                        value: widget.width,
                        enabled: widget.enabled,
                        min: widget.min,
                        max: widget.max,
                        size: SoftSaaSNumberPresetInputSize.small,
                        showStepper: false,
                        width: double.infinity,
                        includeNullPreset: true,
                        includeZeroPreset: true,
                        includeInfinityPreset: true,
                        onChanged: _setWidth,
                        onDragUpdate: _setWidth,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _ChainLockButton(
              locked: _locked,
              enabled: widget.enabled,
              onTap: _toggleLock,
              brightness: brightness,
              size: _rowHeight - 4,
            ),
            SizedBox(
              width: _inputWidth,
              child: Row(
                children: [
                  Text(
                    'H',
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: SoftSaaSTokens.tertiaryText(brightness),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Focus(
                      onFocusChange: (f) =>
                          setState(() => _active = f ? _Axis.height : null),
                      child: SoftSaaSNumberPresetInput(
                        value: widget.height,
                        enabled: widget.enabled,
                        min: widget.min,
                        max: widget.max,
                        size: SoftSaaSNumberPresetInputSize.small,
                        showStepper: false,
                        width: double.infinity,
                        includeNullPreset: true,
                        includeZeroPreset: true,
                        includeInfinityPreset: true,
                        onChanged: _setHeight,
                        onDragUpdate: _setHeight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Compact aspect-ratio indicator with a preset dropdown trigger.
///
/// Renders a small framed rectangle proportional to W:H and a triangle icon
/// the user can click to pick a preset ratio. Height matches the adjacent
/// number inputs so the whole row aligns on a single baseline.
class _AspectIndicator extends StatefulWidget {
  const _AspectIndicator({
    required this.width,
    required this.height,
    required this.active,
    required this.locked,
    required this.enabled,
    required this.brightness,
    required this.presets,
    required this.onPresetSelected,
    required this.height_,
  });

  final double? width;
  final double? height;
  final _Axis? active;
  final bool locked;
  final bool enabled;
  final Brightness brightness;
  final List<SoftSaaSAspectRatioPreset> presets;
  final ValueChanged<SoftSaaSAspectRatioPreset> onPresetSelected;
  final double height_;

  @override
  State<_AspectIndicator> createState() => _AspectIndicatorState();
}

class _AspectIndicatorState extends State<_AspectIndicator> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _menu;

  @override
  void dispose() {
    _closeMenu(rebuild: false);
    super.dispose();
  }

  void _openMenu() {
    if (_menu != null) return;
    final overlay = Overlay.of(context);
    _menu = OverlayEntry(builder: _buildMenu);
    overlay.insert(_menu!);
    setState(() {});
  }

  void _closeMenu({bool rebuild = true}) {
    _menu?.remove();
    _menu = null;
    if (rebuild && mounted) setState(() {});
  }

  void _toggleMenu() {
    if (_menu == null) {
      _openMenu();
    } else {
      _closeMenu();
    }
  }

  Widget _buildMenu(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _closeMenu,
          ),
        ),
        CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          offset: Offset(0, widget.height_ + 4),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 48,
              decoration: BoxDecoration(
                color: SoftSaaSTokens.primaryBackground(widget.brightness),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: SoftSaaSTokens.primaryBorder(widget.brightness),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final preset in widget.presets)
                    _PresetRow(
                      preset: preset,
                      brightness: widget.brightness,
                      onTap: () {
                        widget.onPresetSelected(preset);
                        _closeMenu();
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.height_;
    final triangleColor = _menu != null
        ? SoftSaaSTokens.primaryColor(widget.brightness)
        : SoftSaaSTokens.secondaryText(widget.brightness);

    return CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        cursor: widget.enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,

        child: GestureDetector(
          onTap: widget.enabled ? _toggleMenu : null,
          child: AnimatedContainer(
            duration: SoftSaaSTokens.transitionDuration,
            width: 48,
            height: h,
            padding: const EdgeInsets.only(left: 6, right: 4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: SoftSaaSTokens.primaryBorder(widget.brightness),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: h - 12,
                  height: h - 12,
                  child: CustomPaint(
                    painter: _AspectPainter(
                      width: widget.width,
                      height: widget.height,
                      activeWidth: widget.active == _Axis.width,
                      activeHeight: widget.active == _Axis.height,
                      locked: widget.locked,
                      primary: SoftSaaSTokens.primaryColor(widget.brightness),
                      secondary: SoftSaaSTokens.secondaryText(
                        widget.brightness,
                      ),
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, size: 16, color: triangleColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PresetRow extends StatefulWidget {
  const _PresetRow({
    required this.preset,
    required this.brightness,
    required this.onTap,
  });

  final SoftSaaSAspectRatioPreset preset;
  final Brightness brightness;
  final VoidCallback onTap;

  @override
  State<_PresetRow> createState() => _PresetRowState();
}

class _PresetRowState extends State<_PresetRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: _hovered
              ? SoftSaaSTokens.controlHoverOverlay(widget.brightness)
              : Colors.transparent,
          alignment: Alignment.centerLeft,
          child: Text(
            widget.preset.label,
            style: SoftSaaSTypography.bodySmall(widget.brightness),
          ),
        ),
      ),
    );
  }
}

class _AspectPainter extends CustomPainter {
  _AspectPainter({
    required this.width,
    required this.height,
    required this.activeWidth,
    required this.activeHeight,
    required this.locked,
    required this.primary,
    required this.secondary,
  });

  final double? width;
  final double? height;
  final bool activeWidth;
  final bool activeHeight;
  final bool locked;
  final Color primary;
  final Color secondary;

  @override
  void paint(Canvas canvas, Size size) {
    const pad = 2.0;
    final maxW = size.width - pad * 2;
    final maxH = size.height - pad * 2;

    double rw;
    double rh;
    final w = width;
    final h = height;
    if (w == null ||
        h == null ||
        w <= 0 ||
        h <= 0 ||
        !w.isFinite ||
        !h.isFinite) {
      rw = maxW * 0.7;
      rh = maxH * 0.7;
    } else {
      final scale = math.min(maxW / w, maxH / h);
      rw = w * scale;
      rh = h * scale;
    }

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: rw,
      height: rh,
    );

    final baseFill = Paint()
      ..color = locked
          ? primary.withValues(alpha: 0.12)
          : secondary.withValues(alpha: 0.08);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(1.5)),
      baseFill,
    );

    final wColor = activeWidth ? primary : secondary.withValues(alpha: 0.65);
    final hColor = activeHeight ? primary : secondary.withValues(alpha: 0.65);
    final wPaint = Paint()
      ..color = wColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = activeWidth ? 1.4 : 1
      ..strokeCap = StrokeCap.round;
    final hPaint = Paint()
      ..color = hColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = activeHeight ? 1.4 : 1
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.right, rect.top),
      wPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.right, rect.bottom),
      wPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left, rect.bottom),
      hPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.bottom),
      hPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AspectPainter old) =>
      old.width != width ||
      old.height != height ||
      old.activeWidth != activeWidth ||
      old.activeHeight != activeHeight ||
      old.locked != locked;
}

/// Link / unlink chain button. When locked, only the icon is tinted in the
/// primary color — no filled background — matching the soft_saas_ui
/// selection pattern for icon-only toggles.
class _ChainLockButton extends StatefulWidget {
  const _ChainLockButton({
    required this.locked,
    required this.enabled,
    required this.onTap,
    required this.brightness,
    required this.size,
  });

  final bool locked;
  final bool enabled;
  final VoidCallback onTap;
  final Brightness brightness;
  final double size;

  @override
  State<_ChainLockButton> createState() => _ChainLockButtonState();
}

class _ChainLockButtonState extends State<_ChainLockButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.locked
        ? SoftSaaSTokens.primaryColor(widget.brightness)
        : SoftSaaSTokens.secondaryText(widget.brightness);
    final bg = _hovered
        ? SoftSaaSTokens.controlHoverOverlay(widget.brightness)
        : Colors.transparent;
    return MouseRegion(
      cursor: widget.enabled
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedContainer(
          duration: SoftSaaSTokens.transitionDuration,
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Tooltip(
            message: widget.locked
                ? 'Unlink width and height'
                : 'Link width and height',
            child: Icon(
              widget.locked ? LucideIcons.link : LucideIcons.unlink,
              size: 14,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
