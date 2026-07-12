import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';
import 'tile_shared.dart';
import 'preview_component.dart';

class ChildSlotTile extends StatelessWidget {
  const ChildSlotTile({
    super.key,
    required this.componentId,
    required this.config,
    required this.brightness,
  });

  final String? componentId;
  final Map<String, dynamic> config;
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
              TileLabel('Child slot', LucideIcons.box, brightness),
              const Spacer(),
              if (componentId != null)
                Text(
                  componentId!.replaceAll('__builtin_', ''),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: SoftSaaSTokens.tertiaryText(brightness),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          if (componentId == null)
            EmptyHint(LucideIcons.box, 'No component assigned', brightness)
          else
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: PreviewComponent(
                  componentId: componentId!,
                  config: config,
                  brightness: brightness,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
