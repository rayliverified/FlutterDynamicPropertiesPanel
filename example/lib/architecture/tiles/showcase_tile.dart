import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/icons/lucide_icon_registry.dart';
import 'tile_shared.dart';
import 'preview_component.dart';

class ShowcaseTile extends StatelessWidget {
  const ShowcaseTile({
    super.key,
    required this.mainAxisAlignmentName,
    required this.crossAxisAlignmentName,
    required this.children,
    required this.attributes,
    required this.brightness,
  });

  final String mainAxisAlignmentName;
  final String crossAxisAlignmentName;
  final List<Map<String, dynamic>> children;
  final Map<String, dynamic> attributes;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final mainAlignment = switch (mainAxisAlignmentName) {
      'center' => MainAxisAlignment.center,
      'end' => MainAxisAlignment.end,
      'spaceBetween' || 'between' => MainAxisAlignment.spaceBetween,
      'spaceAround' || 'around' => MainAxisAlignment.spaceAround,
      'spaceEvenly' || 'evenly' => MainAxisAlignment.spaceEvenly,
      _ => MainAxisAlignment.start,
    };
    final crossAlignment = switch (crossAxisAlignmentName) {
      'start' => CrossAxisAlignment.start,
      'end' => CrossAxisAlignment.end,
      'stretch' => CrossAxisAlignment.stretch,
      _ => CrossAxisAlignment.center,
    };

    return PreviewTile(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TileLabel('Layout Showcase', LucideIcons.panels_top_left, brightness),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 96,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: SoftSaaSTokens.tertiaryBackground(brightness),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: SoftSaaSTokens.primaryBorder(brightness),
              ),
            ),
            child: children.isEmpty
                ? EmptyHint(LucideIcons.box, 'No child components', brightness)
                : Row(
                    mainAxisAlignment: mainAlignment,
                    crossAxisAlignment: crossAlignment,
                    children: children
                        .take(4)
                        .map((child) {
                          final id = child['componentId']?.toString();
                          final rawConfig = child['config'];
                          final config = rawConfig is Map
                              ? Map<String, dynamic>.from(rawConfig)
                              : <String, dynamic>{};
                          return ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 132,
                              maxHeight: 72,
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: id == null
                                  ? EmptyHint(
                                      LucideIcons.box,
                                      'Unconfigured',
                                      brightness,
                                    )
                                  : PreviewComponent(
                                      componentId: id,
                                      config: config,
                                      brightness: brightness,
                                    ),
                            ),
                          );
                        })
                        .toList(growable: false),
                  ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                LucideIcons.list_tree,
                size: 11,
                color: SoftSaaSTokens.tertiaryText(brightness),
              ),
              const SizedBox(width: 5),
              Text(
                'Attributes',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: SoftSaaSTokens.secondaryText(brightness),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (attributes.isEmpty)
            Text(
              'No attributes',
              style: TextStyle(
                fontSize: 10,
                color: SoftSaaSTokens.tertiaryText(brightness),
              ),
            )
          else
            Wrap(
              spacing: 6,
              runSpacing: 5,
              children: attributes.entries
                  .map((entry) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: SoftSaaSTokens.tertiaryBackground(brightness),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: SoftSaaSTokens.primaryBorder(brightness),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            lookupLucideIcon(entry.value.toString()) ??
                                Icons.help_outline,
                            size: 11,
                            color: SoftSaaSTokens.primaryColor(brightness),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: SoftSaaSTokens.secondaryText(brightness),
                            ),
                          ),
                        ],
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
        ],
      ),
    );
  }
}
