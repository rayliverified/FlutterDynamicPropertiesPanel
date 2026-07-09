// Soft SaaS UI Tabs Component
//
// Compact, left-aligned, scrollable tab strip. The selected tab uses the same
// elevated trigger styling as `SoftSaaSDropdown.elevated` (primary background
// + 1px border + subtle 4-layer shadow + 7px radius). Inactive tabs are ghost
// with a faint hover overlay.

import 'package:flutter/material.dart';
import '../design_tokens.dart';

/// A single tab entry.
class SoftSaaSTab {
  const SoftSaaSTab({required this.label, this.icon, this.subtitle});

  final String label;
  final IconData? icon;

  /// Optional tooltip-style subtitle (not rendered in the tab itself).
  final String? subtitle;
}

/// Size variants mirror the dropdown sizes for visual parity.
enum SoftSaaSTabsSize { small, medium }

/// Horizontally scrollable tab strip. The active tab gets elevated styling
/// (border + shadow + primary background) to match `SoftSaaSDropdown.elevated`.
class SoftSaaSTabs extends StatelessWidget {
  const SoftSaaSTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
    this.size = SoftSaaSTabsSize.small,
    this.padding = const EdgeInsets.fromLTRB(12, 4, 12, 6),
    this.showBottomBorder = true,
    this.backgroundColor,
  });

  final List<SoftSaaSTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final SoftSaaSTabsSize size;
  final EdgeInsetsGeometry padding;
  final bool showBottomBorder;

  /// Strip background. Defaults to `primaryBackground(brightness)`.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final bg = backgroundColor ?? SoftSaaSTokens.primaryBackground(brightness);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: showBottomBorder
            ? Border(
                bottom: BorderSide(
                  color: SoftSaaSTokens.primaryBorder(brightness),
                  width: 1,
                ),
              )
            : null,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < tabs.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              _SoftSaaSTabButton(
                tab: tabs[i],
                active: i == selectedIndex,
                size: size,
                brightness: brightness,
                onTap: () => onChanged(i),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SoftSaaSTabButton extends StatefulWidget {
  const _SoftSaaSTabButton({
    required this.tab,
    required this.active,
    required this.size,
    required this.brightness,
    required this.onTap,
  });

  final SoftSaaSTab tab;
  final bool active;
  final SoftSaaSTabsSize size;
  final Brightness brightness;
  final VoidCallback onTap;

  @override
  State<_SoftSaaSTabButton> createState() => _SoftSaaSTabButtonState();
}

class _SoftSaaSTabButtonState extends State<_SoftSaaSTabButton> {
  bool _hovered = false;

  EdgeInsets get _padding {
    switch (widget.size) {
      case SoftSaaSTabsSize.small:
        return const EdgeInsets.fromLTRB(12, 3, 12, 5);
      case SoftSaaSTabsSize.medium:
        return const EdgeInsets.fromLTRB(14, 5, 14, 7);
    }
  }

  double get _fontSize => widget.size == SoftSaaSTabsSize.small ? 12 : 13;
  double get _iconSize => widget.size == SoftSaaSTabsSize.small ? 13 : 14;

  @override
  Widget build(BuildContext context) {
    final brightness = widget.brightness;
    final activeBg = SoftSaaSTokens.primaryBackground(brightness);
    final hoverBg = brightness == Brightness.light
        ? const Color(0x0A000000)
        : const Color(0x14FFFFFF);
    final borderColor = SoftSaaSTokens.primaryBorder(brightness);
    final activeText = SoftSaaSTokens.primaryText(brightness);
    final inactiveText = SoftSaaSTokens.secondaryText(brightness);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Tooltip(
          message: widget.tab.subtitle ?? '',
          waitDuration: const Duration(milliseconds: 400),
          child: Container(
            padding: _padding,
            decoration: BoxDecoration(
              color: widget.active
                  ? activeBg
                  : (_hovered ? hoverBg : Colors.transparent),
              borderRadius: BorderRadius.circular(7),
              border: widget.active
                  ? Border.all(color: borderColor, width: 1)
                  : null,
              boxShadow: widget.active ? _elevatedShadow(brightness) : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.tab.icon != null) ...[
                  Icon(
                    widget.tab.icon,
                    size: _iconSize,
                    color: widget.active ? activeText : inactiveText,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  widget.tab.label,
                  style: TextStyle(
                    fontSize: _fontSize,
                    fontWeight: widget.active
                        ? FontWeight.w600
                        : FontWeight.w500,
                    letterSpacing: -0.1,
                    color: widget.active ? activeText : inactiveText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Matches `SoftSaaSDropdown._getDefaultShadow` — subtle 4-layer elevation.
  List<BoxShadow> _elevatedShadow(Brightness brightness) {
    return brightness == Brightness.light
        ? const [
            BoxShadow(
              color: Color(0x0F000000),
              offset: Offset(0, 2),
              blurRadius: 4,
              spreadRadius: -1,
            ),
            BoxShadow(
              color: Color(0x0A000000),
              offset: Offset(0, 1),
              blurRadius: 2,
              spreadRadius: -1,
            ),
            BoxShadow(
              color: Color(0x0AFFFFFF),
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
            BoxShadow(
              color: Color(0x03000000),
              offset: Offset(0, -1),
              blurRadius: 2,
            ),
          ]
        : const [
            BoxShadow(
              color: Color(0x33000000),
              offset: Offset(0, 2),
              blurRadius: 4,
              spreadRadius: -1,
            ),
            BoxShadow(
              color: Color(0x26000000),
              offset: Offset(0, 1),
              blurRadius: 2,
              spreadRadius: -1,
            ),
            BoxShadow(
              color: Color(0x05FFFFFF),
              offset: Offset(0, 1),
              blurRadius: 2,
            ),
            BoxShadow(
              color: Color(0x1A000000),
              offset: Offset(0, -1),
              blurRadius: 2,
            ),
          ];
  }
}
