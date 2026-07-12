import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';
import 'tile_shared.dart';

class CtaTile extends StatelessWidget {
  const CtaTile({
    super.key,
    required this.title,
    required this.variant,
    required this.fontSize,
    required this.lineHeight,
    required this.brightness,
  });

  final String title;
  final String variant;
  final double fontSize;
  final double lineHeight;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final size = fontSize.clamp(8.0, 72.0);
    final v = switch (variant) {
      'secondary' => SoftSaaSButtonVariant.secondary,
      'ghost' => SoftSaaSButtonVariant.ghost,
      _ => SoftSaaSButtonVariant.primary,
    };
    return PreviewTile(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TileLabel('Live CTA', LucideIcons.square_mouse_pointer, brightness),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: SoftSaaSButton(
              variant: v,
              size: SoftSaaSButtonSize.large,
              onPressed: () {},
              child: Text(
                title,
                style: TextStyle(
                  fontSize: size.clamp(10, 20),
                  height: lineHeight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                LucideIcons.type,
                size: 12,
                color: SoftSaaSTokens.tertiaryText(brightness),
              ),
              const SizedBox(width: 5),
              Text(
                '${size.toStringAsFixed(0)}px · $variant',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: SoftSaaSTokens.secondaryText(brightness),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
