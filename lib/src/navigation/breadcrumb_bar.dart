import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

import '../core/navigation_controller.dart';

/// A breadcrumb navigation bar for the dynamic properties panel.
///
/// Renders the current [NavigationController] stack as clickable breadcrumbs,
/// allowing users to navigate back to any parent level.
///
/// Styled with SoftSaaS tokens for consistent appearance in both
/// light and dark modes.
///
/// ```dart
/// BreadcrumbBar(
///   controller: myNavigationController,
///   isDark: isDark,
///   onHomePressed: () => controller.navigateToRoot(),
/// )
/// ```
class BreadcrumbBar extends StatelessWidget {
  const BreadcrumbBar({
    super.key,
    required this.controller,
    this.isDark,
    this.onHomePressed,
  });

  /// The navigation controller whose stack drives the breadcrumbs.
  final NavigationController controller;

  /// Override dark mode detection. Defaults to theme brightness.
  final bool? isDark;

  /// Called when the home icon is tapped.
  final VoidCallback? onHomePressed;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final dark = isDark ?? (brightness == Brightness.dark);
    final breadcrumbs = controller.breadcrumbs;

    if (breadcrumbs.isEmpty) return const SizedBox.shrink();

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final items = controller.breadcrumbs;
        if (items.isEmpty) return const SizedBox.shrink();
        return _buildBar(context, items, dark);
      },
    );
  }

  Widget _buildBar(
    BuildContext context,
    List<NavigationBreadcrumb> items,
    bool dark,
  ) {
    final brightness = dark ? Brightness.dark : Brightness.light;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF0A0A0A) : const Color(0xFFF9FAFB),
        border: Border(
          bottom: BorderSide(
            color: dark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Home icon
            InkWell(
              onTap: onHomePressed ?? () => controller.navigateToRoot(),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  LucideIcons.house,
                  size: 13,
                  color: SoftSaaSTokens.secondaryText(brightness),
                ),
              ),
            ),
            const SizedBox(width: 2),

            // Breadcrumb items
            ...List.generate(items.length, (index) {
              final crumb = items[index];
              return Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Separator chevron
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      Icons.chevron_right,
                      size: 14,
                      color: dark
                          ? const Color(0xFF4B5563)
                          : const Color(0xFFD1D5DB),
                    ),
                  ),
                  // Breadcrumb label
                  _buildCrumb(context, crumb, dark),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCrumb(
    BuildContext context,
    NavigationBreadcrumb crumb,
    bool dark,
  ) {
    final brightness = dark ? Brightness.dark : Brightness.light;
    final textColor = crumb.isCurrent
        ? (dark ? Colors.white : Colors.black)
        : SoftSaaSTokens.secondaryText(brightness);

    final fontWeight = crumb.isCurrent ? FontWeight.w600 : FontWeight.w500;

    final displayText = crumb.level.type ?? crumb.level.label;

    Widget labelWidget = Text(
      displayText,
      style: TextStyle(
        fontSize: SoftSaaSTokens.fontSizeXS,
        fontWeight: fontWeight,
        color: textColor,
        height: 1.0,
      ),
    );

    if (!crumb.isCurrent && crumb.onTap != null) {
      return InkWell(
        onTap: crumb.onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: labelWidget,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: labelWidget,
    );
  }
}
