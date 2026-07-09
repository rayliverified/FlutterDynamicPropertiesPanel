/// Soft SaaS UI Number Input Component
///
/// Production-ready numeric input with direct typing, horizontal drag
/// adjustment, stepper buttons, min/max clamping, and decimal/negative rules.
///
/// The default constructor provides a flat, border-first field matching the
/// production DialogTextField / SoftSaaSTextInput pattern:
/// - radius 7
/// - compact padding (10h × 12v for medium)
/// - no shadow
/// - focus via border color shift + width change
///
/// Set [elevated] to true for the neumorphic shadow style.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_tokens.dart';
import '../neumorphic_shadows.dart';
import '../typography.dart';

/// Number input size — matches [SoftSaaSTextInputSize] for visual consistency.
enum SoftSaaSNumberInputSize {
  /// Dense, for compact forms and toolbars.
  small,

  /// Standard, for dialogs and settings.
  medium,

  /// Spacious, for prominent standalone fields.
  large,
}

/// Numeric input with drag-to-adjust, stepper buttons, and clamping.
///
/// Default style is flat and border-first (radius 7, no shadow) matching
/// [SoftSaaSTextInput]. Set [elevated] to true for the neumorphic shadow
/// treatment.
///
/// Features:
/// - Direct numeric text entry with validation
/// - Horizontal drag to adjust values
/// - Stepper up/down buttons
/// - Min/max bounds with clamping
/// - Decimal places control
/// - Optional suffix (e.g., '%', 'px')
/// - Optional label above field
///
/// Example:
/// ```dart
/// SoftSaaSNumberInput(
///   value: 42,
///   min: 0,
///   max: 100,
///   step: 5,
///   suffix: '%',
///   onChanged: (v) => print(v),
/// )
/// ```
class SoftSaaSNumberInput extends StatefulWidget {
  // ── Default (flat) constructor ─────────────────────────────────────

  const SoftSaaSNumberInput({
    super.key,
    this.value,
    this.onChanged,
    this.onDragUpdate,
    this.onDragEnd,
    this.readOnly = false,
    this.label,
    this.labelAlignment = TextAlign.left,
    this.focusNode,
    this.showLabel = false,
    this.prefix,
    this.suffix,
    this.min,
    this.max,
    this.step = 1.0,
    this.dragSensitivity = 1.0,
    this.width,
    this.decimalPlaces,
    this.allowNegative = true,
    this.showStepper = true,
    this.size = SoftSaaSNumberInputSize.medium,
    this.enabled = true,
    this.elevated = false,
    this.presets,
    this.presetLabel,
  });

  // ── Fields ────────────────────────────────────────────────────────

  /// Current numeric value. `null` means empty.
  final double? value;

  /// Called with the committed value on submit, blur, stepper, or drag-end.
  final ValueChanged<double?>? onChanged;

  /// Called with the live value during horizontal drag.
  final ValueChanged<double?>? onDragUpdate;

  /// Called when a horizontal drag gesture ends.
  final VoidCallback? onDragEnd;

  /// Whether the field is read-only (no typing, dragging, or stepping).
  final bool readOnly;

  /// Label text displayed above the input.
  final String? label;

  /// Alignment of the label text.
  final TextAlign labelAlignment;

  /// Optional external focus node.
  final FocusNode? focusNode;

  /// Whether to show the label above the input.
  final bool showLabel;

  /// Optional prefix label rendered inside the field on the leading edge
  /// (e.g., 'W', 'H'). Unlike [suffix], this is a visual label only — it
  /// is never appended to the controller text or the committed value.
  final String? prefix;

  /// Optional suffix appended to the display (e.g., '%', 'px').
  final String? suffix;

  /// Minimum allowed value.
  final double? min;

  /// Maximum allowed value.
  final double? max;

  /// Step size for drag and stepper increments.
  final double step;

  /// Drag sensitivity multiplier (higher = more responsive).
  final double dragSensitivity;

  /// Fixed width. Defaults to 100 for the default style, unset for elevated.
  final double? width;

  /// Number of decimal places to display. `null` = auto (strip trailing zeros).
  final int? decimalPlaces;

  /// Whether negative values are allowed.
  final bool allowNegative;

  /// Whether to show up/down stepper buttons.
  final bool showStepper;

  /// Size variant — matches [SoftSaaSTextInputSize] dimensions.
  final SoftSaaSNumberInputSize size;

  /// Whether the field is enabled.
  final bool enabled;

  /// Whether to use the neumorphic shadow style instead of the default
  /// flat border-first look.
  final bool elevated;

  /// Optional preset values. When provided, the stepper is replaced with a
  /// small triangle button that opens a dropdown of preset choices.
  final List<double>? presets;

  /// Formatter for preset rows in the dropdown. Defaults to the numeric
  /// value (with decimals respected) suffixed with [suffix] when set.
  final String Function(double)? presetLabel;

  @override
  State<SoftSaaSNumberInput> createState() => _SoftSaaSNumberInputState();
}

// ═══════════════════════════════════════════════════════════════════════
// STATE
// ═══════════════════════════════════════════════════════════════════════

class _SoftSaaSNumberInputState extends State<SoftSaaSNumberInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isDragging = false;
  double _dragStartValue = 0.0;
  Offset? _dragStartPosition;
  final LayerLink _presetLink = LayerLink();
  OverlayEntry? _presetOverlay;

  bool get _hasPresets => (widget.presets?.isNotEmpty ?? false);

  void _togglePresets() {
    if (_presetOverlay != null) {
      _closePresets();
    } else {
      _openPresets();
    }
  }

  void _openPresets() {
    if (_presetOverlay != null) return;
    _presetOverlay = OverlayEntry(builder: _buildPresetOverlay);
    Overlay.of(context).insert(_presetOverlay!);
    setState(() {});
  }

  void _closePresets() {
    _presetOverlay?.remove();
    _presetOverlay = null;
    if (mounted) setState(() {});
  }

  String _presetDisplayLabel(double v) {
    if (widget.presetLabel != null) return widget.presetLabel!(v);
    String text = _formatValue(v);
    if (widget.suffix != null) text = '$text${widget.suffix}';
    return text;
  }

  double _presetMenuWidth() {
    final renderBox = context.findRenderObject() as RenderBox?;
    final measured = renderBox?.size.width;
    if (measured != null && measured.isFinite && measured > 0) {
      return measured;
    }

    final configured = widget.width;
    if (configured != null && configured.isFinite && configured > 0) {
      return configured;
    }

    return 120;
  }

  Widget _buildPresetOverlay(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final menuWidth = _presetMenuWidth();
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _closePresets,
          ),
        ),
        CompositedTransformFollower(
          link: _presetLink,
          showWhenUnlinked: false,
          targetAnchor: Alignment.bottomRight,
          followerAnchor: Alignment.topRight,
          offset: const Offset(0, 4),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: menuWidth,
              decoration: BoxDecoration(
                color: SoftSaaSTokens.primaryBackground(brightness),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: SoftSaaSTokens.primaryBorder(brightness),
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
                  for (final preset in widget.presets!)
                    _PresetMenuRow(
                      label: _presetDisplayLabel(preset),
                      selected: widget.value == preset,
                      brightness: brightness,
                      onTap: () {
                        _setControllerToValue(preset);
                        widget.onChanged?.call(preset);
                        _closePresets();
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
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _controller = TextEditingController();
    _updateControllerText();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(SoftSaaSNumberInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh controller when external value changes and field is not active.
    if (widget.value != oldWidget.value &&
        !_focusNode.hasFocus &&
        !_isDragging) {
      _updateControllerText();
    }
    // Swap focus node if caller replaced it.
    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_onFocusChange);
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    _presetOverlay?.remove();
    _presetOverlay = null;
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  // ── Text <-> value helpers ────────────────────────────────────────

  String _formatValue(double v) {
    String text;
    if (widget.decimalPlaces != null) {
      text = v.toStringAsFixed(widget.decimalPlaces!);
    } else {
      text = v.toString().replaceAll(RegExp(r'\.?0+$'), '');
    }
    return text;
  }

  void _updateControllerText() {
    final v = widget.value;
    if (v == null) {
      _controller.text = '';
      return;
    }
    String text = _formatValue(v);
    if (widget.suffix != null) text = '$text${widget.suffix}';
    _controller.text = text;
  }

  void _setControllerToValue(double v) {
    String text = _formatValue(v);
    if (widget.suffix != null) text = '$text${widget.suffix}';
    _controller.text = text;
  }

  String _stripSuffix(String text) {
    if (widget.suffix != null && text.endsWith(widget.suffix!)) {
      return text.substring(0, text.length - widget.suffix!.length);
    }
    return text;
  }

  double _clamp(double v) {
    if (widget.min != null && v < widget.min!) v = widget.min!;
    if (widget.max != null && v > widget.max!) v = widget.max!;
    return v;
  }

  // ── Focus handling ────────────────────────────────────────────────

  void _onFocusChange() {
    setState(() {}); // Rebuild for focus styling.

    if (_focusNode.hasFocus) {
      // Strip suffix and select all for easy editing.
      final bare = _stripSuffix(_controller.text);
      _controller.text = bare;
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: bare.length,
      );
    } else if (!_isDragging) {
      _validateAndCommit();
    }
  }

  void _validateAndCommit() {
    String text = _stripSuffix(_controller.text.trim());

    if (text.isEmpty) {
      _updateControllerText();
      widget.onChanged?.call(null);
      return;
    }

    final parsed = num.tryParse(text);
    if (parsed != null) {
      final clamped = _clamp(parsed.toDouble());
      _setControllerToValue(clamped);
      widget.onChanged?.call(clamped);
    } else {
      // Revert to last valid value.
      _updateControllerText();
    }
  }

  // ── Stepper ───────────────────────────────────────────────────────

  bool get _canIncrement =>
      widget.enabled &&
      !widget.readOnly &&
      (widget.max == null || (widget.value ?? 0.0) < widget.max!);

  bool get _canDecrement =>
      widget.enabled &&
      !widget.readOnly &&
      (widget.min == null || (widget.value ?? 0.0) > widget.min!);

  void _increment() {
    final next = _clamp((widget.value ?? 0.0) + widget.step);
    _setControllerToValue(next);
    widget.onChanged?.call(next);
  }

  void _decrement() {
    final next = _clamp((widget.value ?? 0.0) - widget.step);
    _setControllerToValue(next);
    widget.onChanged?.call(next);
  }

  // ── Size helpers ──────────────────────────────────────────────────

  EdgeInsets _getContentPadding() {
    switch (widget.size) {
      case SoftSaaSNumberInputSize.small:
        return const EdgeInsets.fromLTRB(10, 5, 4, 5);
      case SoftSaaSNumberInputSize.medium:
        return const EdgeInsets.fromLTRB(10, 7, 4, 7);
      case SoftSaaSNumberInputSize.large:
        return const EdgeInsets.fromLTRB(12, 11, 6, 11);
    }
  }

  double _getStepperVerticalPadding() {
    switch (widget.size) {
      case SoftSaaSNumberInputSize.small:
        return 5;
      case SoftSaaSNumberInputSize.medium:
        return 7;
      case SoftSaaSNumberInputSize.large:
        return 11;
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case SoftSaaSNumberInputSize.small:
        return 13.0;
      case SoftSaaSNumberInputSize.medium:
        return 13.0;
      case SoftSaaSNumberInputSize.large:
        return 15.0;
    }
  }

  double _getStepperIconSize() {
    switch (widget.size) {
      case SoftSaaSNumberInputSize.small:
        return 10.0;
      case SoftSaaSNumberInputSize.medium:
        return 11.0;
      case SoftSaaSNumberInputSize.large:
        return 13.0;
    }
  }

  double _getStepperButtonSize() {
    switch (widget.size) {
      case SoftSaaSNumberInputSize.small:
        return 14.0;
      case SoftSaaSNumberInputSize.medium:
        return 15.0;
      case SoftSaaSNumberInputSize.large:
        return 17.0;
    }
  }

  // ── Build ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bg = SoftSaaSTokens.primaryBackground(brightness);
    final isFocused = _focusNode.hasFocus;
    final showPresets = _hasPresets && !widget.readOnly;
    final showStepper = widget.showStepper && !widget.readOnly && !showPresets;
    final textPrimary = SoftSaaSTokens.primaryText(brightness);
    final textTertiary = SoftSaaSTokens.tertiaryText(brightness);
    final secondaryText = SoftSaaSTokens.secondaryText(brightness);

    final fieldPadding = showStepper
        ? _getContentPadding().copyWith(
            top: _getStepperVerticalPadding(),
            bottom: _getStepperVerticalPadding(),
          )
        : _getContentPadding();

    final field = AnimatedContainer(
      duration: widget.elevated
          ? SoftSaaSTokens.transitionDuration
          : const Duration(milliseconds: 150),
      curve: widget.elevated ? SoftSaaSTokens.transitionCurve : Curves.easeOut,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(
          widget.elevated ? SoftSaaSTokens.radiusXLarge : 7,
        ),
        border: Border.all(
          color: _isDragging
              ? SoftSaaSTokens.secondaryBorder(brightness)
              : widget.elevated
              ? isFocused
                    ? SoftSaaSTokens.primaryBorder(brightness)
                    : SoftSaaSTokens.tertiaryBackground(brightness)
              : isFocused
              ? SoftSaaSTokens.primaryColor(brightness).withValues(alpha: 0.5)
              : SoftSaaSTokens.primaryBorder(brightness),
          width: widget.elevated ? 1 : 1.5,
        ),
        boxShadow: widget.elevated
            ? (isFocused
                  ? NeumorphicShadows.getFocusShadow(brightness)
                  : NeumorphicShadows.getLevel2(brightness))
            : null,
      ),
      child: Padding(
        padding: fieldPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.prefix != null)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Text(
                  widget.prefix!,
                  style: TextStyle(
                    fontSize: _getFontSize(),
                    color: textTertiary,
                    fontWeight: SoftSaaSTokens.fontWeightMedium,
                  ),
                ),
              ),
            Expanded(
              child: IgnorePointer(
                ignoring: _isDragging,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  readOnly: widget.readOnly,
                  enabled: widget.enabled,
                  textAlign: TextAlign.left,
                  keyboardType: TextInputType.numberWithOptions(
                    decimal: true,
                    signed: widget.allowNegative,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      widget.allowNegative
                          ? RegExp(r'^-?\d*\.?\d*')
                          : RegExp(r'^\d*\.?\d*'),
                    ),
                  ],
                  style: widget.elevated
                      ? SoftSaaSTypography.bodyMedium(
                          brightness,
                        ).copyWith(fontWeight: SoftSaaSTokens.fontWeightNormal)
                      : TextStyle(
                          fontSize: _getFontSize(),
                          fontWeight: SoftSaaSTokens.fontWeightNormal,
                        ).copyWith(color: textPrimary),
                  cursorColor: SoftSaaSTokens.primaryColor(brightness),
                  cursorWidth: 1.5,
                  cursorRadius: const Radius.circular(1),
                  onSubmitted: (_) => _validateAndCommit(),
                  decoration: InputDecoration(
                    hintText: widget.elevated ? null : '--',
                    hintStyle: widget.elevated
                        ? null
                        : TextStyle(
                            fontSize: _getFontSize(),
                          ).copyWith(color: textTertiary),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    filled: false,
                  ),
                ),
              ),
            ),
            if (showStepper) _buildStepper(brightness),
            if (!showStepper && !showPresets && widget.suffix != null)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Center(
                  child: Text(
                    widget.suffix!,
                    style: TextStyle(
                      fontSize: _getFontSize(),
                      color: secondaryText,
                    ),
                  ),
                ),
              ),
            if (showPresets)
              _PresetTrigger(
                brightness: brightness,
                active: _presetOverlay != null,
                onTap: _togglePresets,
              ),
          ],
        ),
      ),
    );

    final Widget inputWidget = MouseRegion(
      cursor: _isDragging
          ? SystemMouseCursors.resizeLeftRight
          : SystemMouseCursors.click,
      child: GestureDetector(
        onHorizontalDragStart: (widget.readOnly || !widget.enabled)
            ? null
            : (DragStartDetails details) {
                setState(() {
                  _isDragging = true;
                  _dragStartValue = widget.value ?? 0.0;
                  _dragStartPosition = details.globalPosition;
                });
              },
        onHorizontalDragUpdate: (widget.readOnly || !widget.enabled)
            ? null
            : (DragUpdateDetails details) {
                if (_dragStartPosition == null) return;
                final rawDelta =
                    (details.globalPosition.dx - _dragStartPosition!.dx) *
                    widget.dragSensitivity;
                // Snap to nearest step so drag increments by whole numbers.
                final snapped = (rawDelta / widget.step).round() * widget.step;
                final next = _clamp(_dragStartValue + snapped);
                widget.onDragUpdate?.call(next);
                _setControllerToValue(next);
              },
        onHorizontalDragEnd: (widget.readOnly || !widget.enabled)
            ? null
            : (DragEndDetails details) {
                if (_dragStartPosition != null) {
                  final rawDelta =
                      (details.globalPosition.dx - _dragStartPosition!.dx) *
                      widget.dragSensitivity;
                  final snapped =
                      (rawDelta / widget.step).round() * widget.step;
                  final next = _clamp(_dragStartValue + snapped);
                  widget.onChanged?.call(next);
                }
                setState(() {
                  _isDragging = false;
                  _dragStartPosition = null;
                });
                widget.onDragEnd?.call();
              },
        child: SizedBox(
          width: widget.width ?? 100,
          child: _hasPresets
              ? CompositedTransformTarget(link: _presetLink, child: field)
              : field,
        ),
      ),
    );

    // Wrap with label if requested.
    if (widget.showLabel && widget.label != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: widget.labelAlignment == TextAlign.right
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 4),
            child: Text(
              widget.label!,
              style: SoftSaaSTypography.bodySmallSecondary(brightness).copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 10,
                height: 1.0,
              ),
            ),
          ),
          inputWidget,
        ],
      );
    }

    return inputWidget;
  }

  // ═══════════════════════════════════════════════════════════════════
  // STEPPER BUTTONS
  // ═══════════════════════════════════════════════════════════════════

  Widget _buildStepper(Brightness brightness) {
    final iconSize = _getStepperIconSize();
    final buttonSize = _getStepperButtonSize();

    final enabledColor = SoftSaaSTokens.secondaryText(brightness);
    final disabledColor = SoftSaaSTokens.tertiaryText(brightness);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _StepperButton(
          icon: Icons.keyboard_arrow_up,
          iconSize: iconSize,
          buttonSize: buttonSize,
          enabledColor: enabledColor,
          disabledColor: disabledColor,
          onPressed: _canIncrement ? _increment : null,
        ),
        _StepperButton(
          icon: Icons.keyboard_arrow_down,
          iconSize: iconSize,
          buttonSize: buttonSize,
          enabledColor: enabledColor,
          disabledColor: disabledColor,
          onPressed: _canDecrement ? _decrement : null,
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// STEPPER BUTTON
// ═══════════════════════════════════════════════════════════════════════

/// A small filled triangle button used as a dropdown trigger for preset
/// values. Lives inside the number input on the suffix side.
class _PresetTrigger extends StatefulWidget {
  const _PresetTrigger({
    required this.brightness,
    required this.active,
    required this.onTap,
  });

  final Brightness brightness;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_PresetTrigger> createState() => _PresetTriggerState();
}

class _PresetTriggerState extends State<_PresetTrigger> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = (widget.active || _hovered)
        ? SoftSaaSTokens.primaryColor(widget.brightness)
        : SoftSaaSTokens.secondaryText(widget.brightness);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Icon(Icons.arrow_drop_down, size: 16, color: color),
        ),
      ),
    );
  }
}

class _PresetMenuRow extends StatefulWidget {
  const _PresetMenuRow({
    required this.label,
    required this.selected,
    required this.brightness,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Brightness brightness;
  final VoidCallback onTap;

  @override
  State<_PresetMenuRow> createState() => _PresetMenuRowState();
}

class _PresetMenuRowState extends State<_PresetMenuRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.selected
        ? SoftSaaSTokens.primaryColor(widget.brightness)
        : SoftSaaSTokens.primaryText(widget.brightness);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: _hovered
              ? SoftSaaSTokens.controlHoverOverlay(widget.brightness)
              : Colors.transparent,
          alignment: Alignment.centerLeft,
          child: Text(
            widget.label,
            style: SoftSaaSTypography.bodySmall(
              widget.brightness,
            ).copyWith(color: color),
          ),
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.iconSize,
    required this.buttonSize,
    required this.enabledColor,
    required this.disabledColor,
    this.onPressed,
  });

  final IconData icon;
  final double iconSize;
  final double buttonSize;
  final Color enabledColor;
  final Color disabledColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    return MouseRegion(
      cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: onPressed,
        child: SizedBox(
          width: buttonSize,
          height: buttonSize * 0.65,
          child: Center(
            child: Icon(
              icon,
              size: iconSize,
              color: isEnabled ? enabledColor : disabledColor,
            ),
          ),
        ),
      ),
    );
  }
}
