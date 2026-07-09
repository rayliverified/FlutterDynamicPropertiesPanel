/// ColorControl — color editor controls backed by color_picker library.
///
/// [ColorControl] — swatch + hex input row, using [SoftSaaSColorInput] for the
/// themed text field and [ColorPickerTrigger] injected as the swatch widget.
/// This preserves the visual design system while delegating popup positioning,
/// drag, resize, and transparency checkerboard to [ColorPickerTrigger].
///
/// [ColorSwatchControl] — standalone swatch button backed by [ColorPickerTrigger].
library;

import 'package:color_picker_plus/color_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

// ── ColorControl ─────────────────────────────────────────────────────────────

class ColorControl extends StatelessWidget {
  const ColorControl({
    super.key,
    required this.value,
    required this.onChanged,
    this.showOpacity = false,
  });

  final Color? value;
  final ValueChanged<Color?> onChanged;
  final bool showOpacity;

  Color _effective() => value ?? const Color(0x00000000);

  @override
  Widget build(BuildContext context) {
    final color = _effective();
    return SoftSaaSColorInput(
      color: color,
      allowAlpha: showOpacity,
      onChanged: (c) => onChanged(c),
      size: SoftSaaSColorInputSize.small,
      swatchWidget: ColorPickerTrigger(
        color: color,
        size: 22,
        borderRadius: 7,
        borderWidth: 1,
        allowOpacity: true,
        onPaintChanged: (paint) => onChanged(paint.color),
        popupWidth: 300,
        minHeight: 200,
        maxHeight: 650,
      ),
    );
  }
}

// ── ColorSwatchControl ───────────────────────────────────────────────────────

class ColorSwatchControl extends StatelessWidget {
  const ColorSwatchControl({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 32,
  });

  final Color? value;
  final ValueChanged<Color?> onChanged;
  final double size;

  Color _effective() => value ?? const Color(0x00000000);

  @override
  Widget build(BuildContext context) {
    return ColorPickerTrigger(
      color: _effective(),
      size: size,
      borderRadius: 6,
      borderWidth: 1,
      allowOpacity: true,
      onPaintChanged: (paint) => onChanged(paint.color),
      popupWidth: 300,
      minHeight: 200,
      maxHeight: 650,
    );
  }
}
