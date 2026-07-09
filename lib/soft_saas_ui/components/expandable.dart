// Soft SaaS UI Expandable Component
//
// Lightweight inline toggle with chevron and animated expand/collapse.
// The caller owns the open/closed state — no card chrome, no borders,
// no shadows. Designed to embed inside forms, dialogs, and panels.

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../design_tokens.dart';

/// Inline expandable section with animated chevron toggle.
///
/// Unlike [SoftSaaSAccordion] (a self-contained multi-item card container),
/// this is a zero-chrome structural primitive — just a chevron + label that
/// reveals arbitrary content. The caller controls [isOpen] state.
///
/// Example:
/// ```dart
/// SoftSaaSExpandable(
///   isOpen: _advancedOpen,
///   onToggle: () => setState(() => _advancedOpen = !_advancedOpen),
///   title: 'Advanced settings',
///   child: Column(children: [...]),
/// )
/// ```
class SoftSaaSExpandable extends StatelessWidget {
  const SoftSaaSExpandable({
    super.key,
    required this.isOpen,
    required this.onToggle,
    required this.title,
    required this.child,
    this.trailing,
  });

  /// Whether the section is expanded.
  final bool isOpen;

  /// Called when the header is tapped.
  final VoidCallback onToggle;

  /// Section label displayed next to the chevron.
  final String title;

  /// Content shown when expanded.
  final Widget child;

  /// Optional widget after the title (e.g., badge or subtitle).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textSecondary = SoftSaaSTokens.secondaryText(brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              AnimatedRotation(
                turns: isOpen ? 0.25 : 0,
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  LucideIcons.chevron_right,
                  size: 13,
                  color: textSecondary,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                    letterSpacing: -0.1,
                    height: 1.4,
                  ),
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 8), trailing!],
            ],
          ),
        ),
        ClipRect(
          child: AnimatedAlign(
            alignment: Alignment.topCenter,
            heightFactor: isOpen ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}
