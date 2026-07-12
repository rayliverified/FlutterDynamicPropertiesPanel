import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';
import 'tile_shared.dart';

class RolloutPercentTile extends StatelessWidget {
  const RolloutPercentTile({
    super.key,
    required this.percentage,
    required this.onChanged,
    required this.brightness,
  });

  final double percentage;
  final ValueChanged<double> onChanged;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final pct = percentage.clamp(0.0, 100.0);
    return PreviewTile(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TileLabel('Rollout %', LucideIcons.percent, brightness),
              const Spacer(),
              Text(
                '${pct.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: SoftSaaSTokens.primaryText(brightness),
                  height: 1,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          SoftSaaSSlider(
            value: pct,
            min: 0,
            max: 100,
            showValue: false,
            showMinMaxLabels: false,
            isDarkMode: brightness == Brightness.dark,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
