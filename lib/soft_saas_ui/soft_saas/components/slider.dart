import 'package:flutter/material.dart';
import '../design_tokens.dart';

/// Custom track shape that removes Flutter's default horizontal thumb-radius
/// inset, so the track runs edge-to-edge within its container.
class _FullWidthSliderTrackShape extends RoundedRectSliderTrackShape {
  const _FullWidthSliderTrackShape();

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

/// A slider/range input component
///
/// Features:
/// - Draggable thumb
/// - Min/max values
/// - Step increment
/// - Value display
/// - Dark mode support
/// - Neumorphic styling
class SoftSaaSSlider extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;
  final bool showValue;
  final bool showMinMaxLabels;
  final String Function(double)? valueFormatter;
  final bool isDarkMode;

  const SoftSaaSSlider({
    super.key,
    required this.value,
    this.min = 0.0,
    this.max = 100.0,
    this.divisions,
    this.label,
    this.onChanged,
    this.onChangeEnd,
    this.showValue = true,
    this.showMinMaxLabels = true,
    this.valueFormatter,
    this.isDarkMode = false,
  });

  String _formatValue(double value) {
    if (valueFormatter != null) {
      return valueFormatter!(value);
    }
    return value.toStringAsFixed(divisions != null ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || showValue)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode
                          ? SoftSaaSTokens.darkPrimaryText
                          : SoftSaaSTokens.lightPrimaryText,
                    ),
                  ),
                if (showValue)
                  Text(
                    _formatValue(value),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: SoftSaaSTokens.primary,
                    ),
                  ),
              ],
            ),
          ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            activeTrackColor: SoftSaaSTokens.primary,
            inactiveTrackColor: isDarkMode
                ? SoftSaaSTokens.darkTertiaryBackground
                : SoftSaaSTokens.lightSecondaryBorder,
            thumbColor: Colors.white,
            overlayColor: SoftSaaSTokens.primary.withValues(alpha: 0.12),
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 7,
              elevation: 3,
            ),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            trackShape: const _FullWidthSliderTrackShape(),
            valueIndicatorColor: SoftSaaSTokens.primary,
            valueIndicatorTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            label: divisions != null ? _formatValue(value) : null,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
        ),
        if (showMinMaxLabels)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatValue(min),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDarkMode
                        ? SoftSaaSTokens.darkTertiaryText
                        : SoftSaaSTokens.lightTertiaryText,
                  ),
                ),
                Text(
                  _formatValue(max),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDarkMode
                        ? SoftSaaSTokens.darkTertiaryText
                        : SoftSaaSTokens.lightTertiaryText,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// A range slider for selecting a range between two values
class SoftSaaSRangeSlider extends StatelessWidget {
  final RangeValues values;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final ValueChanged<RangeValues>? onChanged;
  final ValueChanged<RangeValues>? onChangeEnd;
  final bool showValues;
  final String Function(double)? valueFormatter;
  final bool isDarkMode;

  const SoftSaaSRangeSlider({
    super.key,
    required this.values,
    this.min = 0.0,
    this.max = 100.0,
    this.divisions,
    this.label,
    this.onChanged,
    this.onChangeEnd,
    this.showValues = true,
    this.valueFormatter,
    this.isDarkMode = false,
  });

  String _formatValue(double value) {
    if (valueFormatter != null) {
      return valueFormatter!(value);
    }
    return value.toStringAsFixed(divisions != null ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || showValues)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode
                          ? SoftSaaSTokens.darkPrimaryText
                          : SoftSaaSTokens.lightPrimaryText,
                    ),
                  ),
                if (showValues)
                  Text(
                    '${_formatValue(values.start)} - ${_formatValue(values.end)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: SoftSaaSTokens.primary,
                    ),
                  ),
              ],
            ),
          ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            activeTrackColor: SoftSaaSTokens.primary,
            inactiveTrackColor: isDarkMode
                ? SoftSaaSTokens.darkTertiaryBackground
                : SoftSaaSTokens.lightSecondaryBorder,
            thumbColor: SoftSaaSTokens.primary,
            overlayColor: SoftSaaSTokens.primary.withValues(alpha: 0.2),
            rangeThumbShape: const RoundRangeSliderThumbShape(
              enabledThumbRadius: 8,
              elevation: 2,
            ),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
            valueIndicatorColor: SoftSaaSTokens.primary,
            valueIndicatorTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          child: RangeSlider(
            values: values,
            min: min,
            max: max,
            divisions: divisions,
            labels: divisions != null
                ? RangeLabels(
                    _formatValue(values.start),
                    _formatValue(values.end),
                  )
                : null,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
        ),
        // Min/Max labels
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatValue(min),
                style: TextStyle(
                  fontSize: 11,
                  color: isDarkMode
                      ? SoftSaaSTokens.darkTertiaryText
                      : SoftSaaSTokens.lightTertiaryText,
                ),
              ),
              Text(
                _formatValue(max),
                style: TextStyle(
                  fontSize: 11,
                  color: isDarkMode
                      ? SoftSaaSTokens.darkTertiaryText
                      : SoftSaaSTokens.lightTertiaryText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
