import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';
import 'tile_shared.dart';

class MetaTile extends StatelessWidget {
  const MetaTile({
    super.key,
    required this.source,
    this.version,
    required this.brightness,
  });

  final String source;
  final String? version;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return PreviewTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TileLabel('Metadata', LucideIcons.database, brightness),
          const SizedBox(height: 10),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              _metaBadge(source, SoftSaaSTokens.primaryColor(brightness)),
              if (version != null)
                _metaBadge(
                  'v$version',
                  SoftSaaSTokens.tertiaryText(brightness),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
