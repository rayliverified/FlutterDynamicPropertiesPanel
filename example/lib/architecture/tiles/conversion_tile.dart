import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';
import 'tile_shared.dart';

class ConversionTile extends StatelessWidget {
  const ConversionTile({
    super.key,
    required this.rate,
    required this.unit,
    required this.delta,
    required this.comparison,
    required this.brightness,
  });

  final double rate;
  final String unit;
  final double delta;
  final String comparison;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return PreviewTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TileLabel('Conversion', LucideIcons.trending_up, brightness),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                rate.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: SoftSaaSTokens.primaryText(brightness),
                  height: 1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 2),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit == 'percent' ? '%' : unit,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: SoftSaaSTokens.secondaryText(brightness),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Icon(
                delta >= 0
                    ? LucideIcons.arrow_up_right
                    : LucideIcons.arrow_down_right,
                size: 11,
                color: delta >= 0
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
              ),
              const SizedBox(width: 2),
              Text(
                '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: delta >= 0
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                comparison,
                style: TextStyle(
                  fontSize: 10,
                  color: SoftSaaSTokens.tertiaryText(brightness),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 16,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(12, (i) {
                const heights = <double>[
                  4, 6, 5, 8, 7, 10, 9, 12, 11, 13, 12, 14, //
                ];
                return Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Container(
                        height: heights[i],
                        decoration: BoxDecoration(
                          color: SoftSaaSTokens.primaryColor(
                            brightness,
                          ).withValues(alpha: 0.4 + (i / 24)),
                          borderRadius: BorderRadius.circular(1.5),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
