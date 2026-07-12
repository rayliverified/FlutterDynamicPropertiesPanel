import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';
import 'tile_shared.dart';

class AudienceTile extends StatelessWidget {
  const AudienceTile({
    super.key,
    required this.audiences,
    required this.brightness,
  });

  final List<String> audiences;
  final Brightness brightness;

  static const _allSegments =
      <String, ({String label, int reach, IconData icon})>{
        'consumer': (label: 'Consumer', reach: 2842, icon: LucideIcons.user),
        'power_user': (label: 'Power User', reach: 914, icon: LucideIcons.zap),
        'enterprise': (
          label: 'Enterprise',
          reach: 312,
          icon: LucideIcons.building_2,
        ),
      };

  static String _formatReach(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(n >= 10000 ? 0 : 1)}K';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    final selectedSet = audiences.toSet();
    final entries = _allSegments.entries.toList();
    return PreviewTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              TileLabel('Audience', LucideIcons.users, brightness),
              const Spacer(),
              Text(
                '${selectedSet.length}/${entries.length}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: SoftSaaSTokens.tertiaryText(brightness),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...entries.map((e) {
            final active = selectedSet.contains(e.key);
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    e.value.icon,
                    size: 12,
                    color: active
                        ? SoftSaaSTokens.primaryColor(brightness)
                        : SoftSaaSTokens.tertiaryText(brightness),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      e.value.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: active
                            ? SoftSaaSTokens.primaryText(brightness)
                            : SoftSaaSTokens.tertiaryText(brightness),
                      ),
                    ),
                  ),
                  Text(
                    _formatReach(e.value.reach),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: active
                          ? SoftSaaSTokens.secondaryText(brightness)
                          : SoftSaaSTokens.tertiaryText(brightness),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active
                          ? SoftSaaSTokens.primaryColor(brightness)
                          : SoftSaaSTokens.primaryBorder(brightness),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
