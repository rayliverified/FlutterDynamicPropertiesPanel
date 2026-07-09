// Soft SaaS UI Color Input.
//
// Hex-color text field matching the [SoftSaaSTextInput] visual language.
// Handles short-hex expansion, paste, `#` prefix, uppercase normalization,
// and optional alpha. A leading color swatch opens a picker via callback —
// the picker itself lives in a separate package to keep this component
// dependency-free.
library;

import 'package:flutter/material.dart';

import '../design_tokens.dart';
import '../typography.dart';
import '../utils/color_utils.dart';
import '../utils/hex_color_formatter.dart';

/// Size variant — mirrors [SoftSaaSTextInputSize].
enum SoftSaaSColorInputSize { small, medium, large }

class SoftSaaSColorInput extends StatefulWidget {
  const SoftSaaSColorInput({
    super.key,
    required this.color,
    this.onChanged,
    this.onSwatchTap,
    this.allowAlpha = false,
    this.enabled = true,
    this.size = SoftSaaSColorInputSize.medium,
    this.label,
    this.errorText,
    this.showSwatch = true,
    this.swatchWidget,
  });

  /// Current color value.
  final Color color;

  /// Called when the user commits a new color via the hex field.
  final ValueChanged<Color>? onChanged;

  /// Called when the leading swatch is tapped. Typically opens a color picker.
  /// If null, the swatch is non-interactive but still shown.
  /// Ignored when [swatchWidget] is provided.
  final VoidCallback? onSwatchTap;

  /// If true, 8-digit ARGB hex is accepted; otherwise input is constrained
  /// to 6-digit RGB and the existing alpha is preserved.
  final bool allowAlpha;

  final bool enabled;

  final SoftSaaSColorInputSize size;

  /// Optional label rendered above the field.
  final String? label;

  /// Optional error text rendered below the field.
  final String? errorText;

  /// Whether to render the leading color swatch.
  final bool showSwatch;

  /// Custom widget rendered in place of the built-in [_Swatch].
  /// Use this to inject a [ColorPickerTrigger] (or similar) so the popup
  /// benefits from smart positioning while the themed hex input is preserved.
  /// When provided, [onSwatchTap] is ignored.
  final Widget? swatchWidget;

  @override
  State<SoftSaaSColorInput> createState() => _SoftSaaSColorInputState();
}

class _SoftSaaSColorInputState extends State<SoftSaaSColorInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late Color _color;

  @override
  void initState() {
    super.initState();
    _color = widget.color;
    _controller = TextEditingController(
      text: colorToHex(_color, withHashtag: true, withAlpha: widget.allowAlpha),
    );
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant SoftSaaSColorInput old) {
    super.didUpdateWidget(old);
    if (widget.color != old.color && widget.color != _color) {
      setState(() => _color = widget.color);
      _syncText();
    }
    if (widget.allowAlpha != old.allowAlpha) {
      _syncText();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // Select everything after the hash, so typing replaces existing value.
      final start = _controller.text.startsWith('#') ? 1 : 0;
      _controller.selection = TextSelection(
        baseOffset: start,
        extentOffset: _controller.text.length,
      );
    } else {
      _commitFromText();
    }
    setState(() {});
  }

  void _syncText() {
    final normalized = colorToHex(
      _color,
      withHashtag: true,
      withAlpha: widget.allowAlpha,
    );
    if (_controller.text != normalized) {
      _controller.text = normalized;
    }
  }

  /// Parse the current field contents into a [Color], respecting [allowAlpha]
  /// rules, then fire [onChanged] if the value differs.
  void _commitFromText() {
    final raw = _controller.text.trim();
    Color? parsed;

    if (raw.isNotEmpty) {
      if (widget.allowAlpha) {
        parsed = hexToColor(raw, fallback: null);
      } else {
        // RGB-only: 3- or 6-digit, preserve existing alpha.
        final hexOnly = raw.startsWith('#') ? raw.substring(1) : raw;
        if (hexOnly.isNotEmpty) {
          var expanded = hexOnly;
          if (hexOnly.length == 3) {
            expanded = hexOnly.split('').map((c) => c + c).join();
          }
          if (expanded.length <= 6) {
            final normalized = parseHex(expanded, withAlpha: false);
            final rgb = int.tryParse('FF$normalized', radix: 16);
            if (rgb != null) {
              parsed = Color(rgb).withValues(alpha: _color.a);
            }
          }
        }
      }
    }

    if (parsed != null && parsed != _color) {
      _color = parsed;
      widget.onChanged?.call(parsed);
    }
    _syncText();
  }

  // ─── Sizing ────────────────────────────────────────────────────────────

  double _height() {
    switch (widget.size) {
      case SoftSaaSColorInputSize.small:
        return 32;
      case SoftSaaSColorInputSize.medium:
        return 36;
      case SoftSaaSColorInputSize.large:
        return 44;
    }
  }

  double _fontSize() {
    switch (widget.size) {
      case SoftSaaSColorInputSize.small:
      case SoftSaaSColorInputSize.medium:
        return 13;
      case SoftSaaSColorInputSize.large:
        return 15;
    }
  }

  double _swatchSize() {
    switch (widget.size) {
      case SoftSaaSColorInputSize.small:
        return 22;
      case SoftSaaSColorInputSize.medium:
        return 24;
      case SoftSaaSColorInputSize.large:
        return 32;
    }
  }

  EdgeInsets _fieldPadding() {
    switch (widget.size) {
      case SoftSaaSColorInputSize.small:
        return const EdgeInsets.only(left: 4, right: 8);
      case SoftSaaSColorInputSize.medium:
        return const EdgeInsets.only(left: 5, right: 10);
      case SoftSaaSColorInputSize.large:
        return const EdgeInsets.only(left: 6, right: 12);
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final hasError = widget.errorText != null;
    final focused = _focusNode.hasFocus;

    final bg = SoftSaaSTokens.primaryBackground(brightness);
    final border = hasError
        ? SoftSaaSTokens.errorColor(brightness)
        : focused
        ? SoftSaaSTokens.primaryColor(brightness).withValues(alpha: 0.5)
        : SoftSaaSTokens.primaryBorder(brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: SoftSaaSTypography.label(brightness)),
          const SizedBox(height: 6),
        ],
        AnimatedContainer(
          duration: SoftSaaSTokens.transitionDuration,
          curve: SoftSaaSTokens.transitionCurve,
          height: _height(),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: border, width: 1.5),
          ),
          padding: _fieldPadding(),
          child: Row(
            children: [
              if (widget.showSwatch) ...[
                if (widget.swatchWidget != null)
                  widget.swatchWidget!
                else
                  _Swatch(
                    color: _color,
                    size: _swatchSize(),
                    onTap: widget.enabled ? widget.onSwatchTap : null,
                    brightness: brightness,
                  ),
                const SizedBox(width: 5),
              ],
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  inputFormatters: [
                    HexColorInputFormatter(allowAlpha: widget.allowAlpha),
                  ],
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _commitFromText(),
                  style: TextStyle(
                    fontSize: _fontSize(),
                    color: SoftSaaSTokens.primaryText(brightness),
                    fontFeatures: const [FontFeature.tabularFigures()],
                    letterSpacing: 0.2,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            style: SoftSaaSTypography.bodySmallSecondary(
              brightness,
            ).copyWith(color: SoftSaaSTokens.errorColor(brightness)),
          ),
        ],
      ],
    );
  }
}

/// Checkerboard-backed color swatch used in the color input's leading slot.
class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.size,
    required this.brightness,
    this.onTap,
  });

  final Color color;
  final double size;
  final Brightness brightness;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = SoftSaaSTokens.secondaryBorder(brightness);
    return MouseRegion(
      cursor: onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: borderColor),
          ),
          clipBehavior: Clip.antiAlias,
          child: CustomPaint(
            painter: _CheckerPainter(brightness: brightness),
            child: Container(color: color),
          ),
        ),
      ),
    );
  }
}

class _CheckerPainter extends CustomPainter {
  _CheckerPainter({required this.brightness});

  final Brightness brightness;

  @override
  void paint(Canvas canvas, Size size) {
    const cell = 4.0;
    final light = brightness == Brightness.light
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF4B5563);
    final dark = brightness == Brightness.light
        ? const Color(0xFFE5E7EB)
        : const Color(0xFF374151);
    final lightPaint = Paint()..color = light;
    final darkPaint = Paint()..color = dark;
    for (var y = 0.0; y < size.height; y += cell) {
      for (var x = 0.0; x < size.width; x += cell) {
        final isDark = ((x / cell).floor() + (y / cell).floor()).isOdd;
        canvas.drawRect(
          Rect.fromLTWH(x, y, cell, cell),
          isDark ? darkPaint : lightPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CheckerPainter old) =>
      old.brightness != brightness;
}
