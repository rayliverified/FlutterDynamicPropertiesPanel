// Soft SaaS UI Panel Component
//
// Flat bordered container for compact inspector layouts. White background,
// 1px primaryBorder, no shadow.
//
// Use [SoftSaaSPanel] for a static container with optional title header.
// Use [SoftSaaSPanel.expandable] for a collapsible panel with toggle.

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../design_tokens.dart';
import '../neumorphic_shadows.dart';

// ══════════════════════════════════════════════════════════════════════
// PANEL
// ══════════════════════════════════════════════════════════════════════

/// Soft SaaS UI Panel — flat bordered container.
///
/// Production Panel/Card pattern: white background, 1px primaryBorder,
/// 10px radius corners, no shadow.
class SoftSaaSPanel extends StatelessWidget {
  const SoftSaaSPanel({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.icon,
    this.borderRadius,
    this.backgroundColor,
    this.expandBody = true,
    this.trailing,
  }) : _isExpandable = false,
       _isElevated = false,
       defaultOpen = false,
       onToggleOpen = null;

  /// Collapsible panel with a clickable header row.
  const SoftSaaSPanel.expandable({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.icon,
    this.borderRadius,
    this.backgroundColor,
    this.expandBody = true,
    this.defaultOpen = false,
    this.onToggleOpen,
    this.trailing,
  }) : _isExpandable = true,
       _isElevated = false;

  /// Neumorphic shadow variant.
  const SoftSaaSPanel.elevated({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.icon,
    this.borderRadius,
    this.backgroundColor,
    this.expandBody = true,
  }) : _isExpandable = false,
       _isElevated = true,
       defaultOpen = false,
       onToggleOpen = null,
       trailing = null;

  final Widget child;
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final double? borderRadius;
  final Color? backgroundColor;
  final bool expandBody;
  final bool defaultOpen;
  final ValueChanged<bool>? onToggleOpen;
  final Widget? trailing;
  final bool _isExpandable;
  final bool _isElevated;

  @override
  Widget build(BuildContext context) {
    if (_isExpandable) {
      return _ExpandablePanel(panel: this);
    }
    return _PanelBody(panel: this);
  }
}

// ══════════════════════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════════════════════

Widget _wrapBody(Widget child, bool expandBody) =>
    expandBody ? Flexible(fit: FlexFit.loose, child: child) : child;

// ══════════════════════════════════════════════════════════════════════
// STATIC PANEL
// ══════════════════════════════════════════════════════════════════════

class _PanelBody extends StatelessWidget {
  const _PanelBody({required this.panel});
  final SoftSaaSPanel panel;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final radius = panel.borderRadius ?? 10;
    final bg =
        panel.backgroundColor ?? SoftSaaSTokens.primaryBackground(brightness);
    final border = SoftSaaSTokens.primaryBorder(brightness);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border, width: 1),
        color: bg,
        boxShadow: panel._isElevated
            ? NeumorphicShadows.getLevel2(brightness)
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (panel.title != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: border, width: 1)),
              ),
              child: Row(
                children: [
                  if (panel.icon != null) ...[
                    Icon(
                      panel.icon,
                      size: SoftSaaSTokens.iconSizeMedium,
                      color: SoftSaaSTokens.secondaryText(brightness),
                    ),
                    const SizedBox(width: SoftSaaSTokens.spacing2),
                  ],
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          panel.title!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.0,
                            color: SoftSaaSTokens.primaryText(brightness),
                          ),
                        ),
                        if (panel.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            panel.subtitle!,
                            style: TextStyle(
                              fontSize: 10.5,
                              color: SoftSaaSTokens.tertiaryText(brightness),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (panel.trailing != null) ...[
                    const SizedBox(width: SoftSaaSTokens.spacing2),
                    panel.trailing!,
                  ],
                ],
              ),
            ),
          _wrapBody(panel.child, panel.expandBody),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// EXPANDABLE PANEL
// ══════════════════════════════════════════════════════════════════════

class _ExpandablePanel extends StatefulWidget {
  const _ExpandablePanel({required this.panel});
  final SoftSaaSPanel panel;

  @override
  State<_ExpandablePanel> createState() => _ExpandablePanelState();
}

class _ExpandablePanelState extends State<_ExpandablePanel> {
  late bool _isOpen;

  @override
  void initState() {
    super.initState();
    _isOpen = widget.panel.defaultOpen;
  }

  @override
  void didUpdateWidget(covariant _ExpandablePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.panel.defaultOpen != widget.panel.defaultOpen) {
      _isOpen = widget.panel.defaultOpen;
    }
  }

  void _toggle() {
    setState(() => _isOpen = !_isOpen);
    widget.panel.onToggleOpen?.call(_isOpen);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final radius = widget.panel.borderRadius ?? 10;
    final bg =
        widget.panel.backgroundColor ??
        SoftSaaSTokens.primaryBackground(brightness);
    final border = SoftSaaSTokens.primaryBorder(brightness);
    final headerRadius = _isOpen
        ? const BorderRadius.vertical(top: Radius.circular(9))
        : BorderRadius.circular(9);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border, width: 1),
        color: bg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggle,
              borderRadius: headerRadius,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              hoverColor: Colors.transparent,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: _isOpen
                    ? BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: border, width: 1),
                        ),
                      )
                    : null,
                child: Row(
                  children: [
                    if (widget.panel.icon != null) ...[
                      Icon(
                        widget.panel.icon,
                        size: SoftSaaSTokens.iconSizeMedium,
                        color: SoftSaaSTokens.secondaryText(brightness),
                      ),
                      const SizedBox(width: SoftSaaSTokens.spacing2),
                    ],
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.panel.title ?? 'Section',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              height: 1.0,
                              color: SoftSaaSTokens.primaryText(brightness),
                            ),
                          ),
                          if (widget.panel.subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.panel.subtitle!,
                              style: TextStyle(
                                fontSize: 10.5,
                                color: SoftSaaSTokens.tertiaryText(brightness),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (widget.panel.trailing != null) ...[
                      widget.panel.trailing!,
                      const SizedBox(width: 8),
                    ],
                    AnimatedRotation(
                      turns: _isOpen ? 0.25 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: Icon(
                        LucideIcons.chevron_right,
                        size: 15,
                        color: SoftSaaSTokens.tertiaryText(brightness),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isOpen) _wrapBody(widget.panel.child, widget.panel.expandBody),
        ],
      ),
    );
  }
}
