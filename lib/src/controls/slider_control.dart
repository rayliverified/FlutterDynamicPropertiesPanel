/// SliderControl — compact inline slider with value to the right.
///
/// Matches the preview tile's slider style: plain track, white thumb,
/// no popup label, no min/max labels. The current value sits to the right
/// in primary text at a light weight.
library;

import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

class _EdgeToEdgeTrackShape extends RoundedRectSliderTrackShape {
  const _EdgeToEdgeTrackShape();

  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 4.0;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    return Rect.fromLTWH(
      offset.dx,
      trackTop,
      parentBox.size.width,
      trackHeight,
    );
  }
}

class SliderControl extends StatelessWidget {
  const SliderControl({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 100.0,
    this.suffix,
    this.decimalPlaces,
  });

  final dynamic value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final String? suffix;
  final int? decimalPlaces;

  String _formatValue(double v) {
    final String s;
    if (decimalPlaces != null) {
      s = decimalPlaces! == 0
          ? v.round().toString()
          : v.toStringAsFixed(decimalPlaces!);
    } else {
      s = v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);
    }
    return suffix != null ? '$s$suffix' : s;
  }

  void _handleChanged(double v) {
    onChanged(decimalPlaces == 0 ? v.roundToDouble() : v);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final v = ((value is num) ? (value as num).toDouble() : min).clamp(
      min,
      max,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              activeTrackColor: SoftSaaSTokens.primaryColor(brightness),
              inactiveTrackColor: SoftSaaSTokens.primaryBorder(brightness),
              thumbColor: Colors.white,
              overlayColor: SoftSaaSTokens.primaryColor(
                brightness,
              ).withValues(alpha: 0.12),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 7,
                elevation: 3,
              ),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              trackShape: const _EdgeToEdgeTrackShape(),
            ),
            child: Slider(
              value: v,
              min: min,
              max: max,
              onChanged: _handleChanged,
            ),
          ),
        ),
        SizedBox(
          width: 48,
          child: Text(
            _formatValue(v),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: SoftSaaSTokens.primaryText(brightness),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}
