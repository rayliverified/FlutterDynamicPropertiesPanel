import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

/// Top bar for the production example app.
/// Flat 46px toolbar with bottom border, brand icon, title/subtitle.
class TopBar extends StatelessWidget {
  const TopBar({
    super.key,
    required this.isDark,
    required this.darkMode,
    required this.onToggleTheme,
  });

  final bool isDark;
  final bool darkMode;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final border = SoftSaaSTokens.primaryBorder(brightness);
    final bg = SoftSaaSTokens.primaryBackground(brightness);

    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: bg,
        border: Border(bottom: BorderSide(color: border, width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 12, right: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Brand icon — 24×24 rounded square with tinted bg
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: SoftSaaSTokens.primaryColor(
                  brightness,
                ).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                LucideIcons.sliders_horizontal,
                size: 14,
                color: SoftSaaSTokens.primaryColor(brightness),
              ),
            ),
            const SizedBox(width: 8),
            // Title block.
            Expanded(
              child: Text(
                'Dynamic Properties Panel',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                  height: 1.0,
                  color: SoftSaaSTokens.primaryText(brightness),
                ),
              ),
            ),
            // Theme toggle
            SoftSaaSIconButton(
              icon: darkMode ? LucideIcons.sun : LucideIcons.moon,
              tooltip: darkMode
                  ? 'Switch to light mode'
                  : 'Switch to dark mode',
              size: SoftSaaSButtonSize.small,
              variant: SoftSaaSIconButtonVariant.ghost,
              iconColor: SoftSaaSTokens.primaryText(brightness),
              onPressed: onToggleTheme,
            ),
          ],
        ),
      ),
    );
  }
}
