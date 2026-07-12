import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';
import 'tile_shared.dart';

class ActivityTile extends StatelessWidget {
  const ActivityTile({
    super.key,
    required this.rollout,
    required this.onRolloutChanged,
    required this.brightness,
  });

  final bool rollout;
  final ValueChanged<bool> onRolloutChanged;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return PreviewTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TileLabel('Rollout', LucideIcons.rocket, brightness),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  rollout ? 'Live' : 'Paused',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: rollout
                        ? const Color(0xFF10B981)
                        : SoftSaaSTokens.warningColor(brightness),
                  ),
                ),
              ),
              SoftSaaSSwitch(
                value: rollout,
                size: SoftSaaSCheckboxSize.small,
                onChanged: onRolloutChanged,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Divider(
              height: 1,
              color: SoftSaaSTokens.primaryBorder(brightness),
            ),
          ),
          _activityRow(
            icon: rollout ? LucideIcons.rocket : LucideIcons.circle_pause,
            color: rollout
                ? const Color(0xFF10B981)
                : SoftSaaSTokens.warningColor(brightness),
            title: rollout ? 'Deployed' : 'Paused',
            time: '2h ago',
          ),
          const SizedBox(height: 8),
          _activityRow(
            icon: LucideIcons.git_commit_horizontal,
            color: SoftSaaSTokens.primaryColor(brightness),
            title: 'Variant synced',
            time: '6h ago',
          ),
          const SizedBox(height: 8),
          _activityRow(
            icon: LucideIcons.users,
            color: SoftSaaSTokens.tertiaryText(brightness),
            title: 'Audience updated',
            time: '1d ago',
          ),
        ],
      ),
    );
  }

  Widget _activityRow({
    required IconData icon,
    required Color color,
    required String title,
    required String time,
  }) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.14),
          ),
          child: Icon(icon, size: 10, color: color),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: SoftSaaSTokens.primaryText(brightness),
            ),
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 10,
            color: SoftSaaSTokens.tertiaryText(brightness),
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
