import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';
import 'tile_shared.dart';

class TagsTile extends StatelessWidget {
  const TagsTile({super.key, required this.tags, required this.brightness});

  final List<String> tags;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return PreviewTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              TileLabel('Tags', LucideIcons.tag, brightness),
              const Spacer(),
              Text(
                tags.length.toString(),
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
          if (tags.isEmpty)
            EmptyHint(LucideIcons.tag, 'No tags assigned', brightness)
          else
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: tags
                  .map(
                    (t) => SoftSaaSBadge(
                      label: t,
                      variant: SoftSaaSBadgeVariant.primary,
                      size: SoftSaaSBadgeSize.small,
                      shape: SoftSaaSBadgeShape.pill,
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}
