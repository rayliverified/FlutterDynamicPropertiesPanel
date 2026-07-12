import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';
import 'tile_shared.dart';

class AppearanceTile extends StatelessWidget {
  const AppearanceTile({
    super.key,
    required this.layoutPadding,
    required this.layoutRadius,
    required this.showShadow,
    required this.animDurationMs,
    required this.brightness,
  });

  final double layoutPadding;
  final double layoutRadius;
  final bool showShadow;
  final int animDurationMs;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    final padding = layoutPadding.clamp(0.0, 40.0);
    final radius = layoutRadius.clamp(0.0, 40.0);
    final animDuration = animDurationMs.clamp(0, 2000);
    return PreviewTile(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TileLabel(
                  'Appearance',
                  LucideIcons.layout_panel_top,
                  brightness,
                ),
                const SizedBox(height: 8),
                _metric('Padding', '${padding.toStringAsFixed(0)}px'),
                const SizedBox(height: 3),
                _metric('Radius', '${radius.toStringAsFixed(0)}px'),
                const SizedBox(height: 3),
                _metric('Shadow', showShadow ? 'On' : 'Off'),
                const SizedBox(height: 3),
                _metric('Anim', '${animDuration}ms'),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 120,
            height: 68,
            child: Center(
              child: AnimatedContainer(
                duration: Duration(milliseconds: animDuration),
                curve: Curves.easeOutCubic,
                padding: EdgeInsets.all(padding.clamp(0, 20)),
                decoration: BoxDecoration(
                  color: SoftSaaSTokens.primaryBackground(brightness),
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(
                    color: SoftSaaSTokens.primaryBorder(brightness),
                  ),
                  boxShadow: showShadow
                      ? [
                          BoxShadow(
                            color: brightness == Brightness.dark
                                ? Colors.black.withValues(alpha: 0.35)
                                : Colors.black.withValues(alpha: 0.10),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                            spreadRadius: -4,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 6,
                      width: 38,
                      decoration: BoxDecoration(
                        color: SoftSaaSTokens.primaryColor(
                          brightness,
                        ).withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 4,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: SoftSaaSTokens.primaryBorder(brightness),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      height: 4,
                      width: 56,
                      decoration: BoxDecoration(
                        color: SoftSaaSTokens.primaryBorder(brightness),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: SoftSaaSTokens.tertiaryText(brightness),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: SoftSaaSTokens.primaryText(brightness),
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
