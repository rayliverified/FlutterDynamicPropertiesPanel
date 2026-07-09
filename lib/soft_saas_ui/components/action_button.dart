/// Soft SaaS UI Action Button Component
///
/// An icon button that shows a checkmark confirmation after pressing.
/// Used for clipboard copy, download, and other action-confirmation patterns.

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../design_tokens.dart';

/// An icon button that shows a checkmark confirmation after the async
/// action completes.
///
/// ```dart
/// SoftSaaSActionButton(
///   icon: LucideIcons.copy,
///   tooltip: 'Copy to clipboard',
///   onPressed: () async {
///     await Clipboard.setData(ClipboardData(text: '...'));
///   },
/// )
/// ```
class SoftSaaSActionButton extends StatefulWidget {
  const SoftSaaSActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.size = 14,
    this.buttonSize = 28,
  });

  /// Icon to display (swaps to checkmark after action).
  final IconData icon;

  /// Async action to perform on press.
  final Future<void> Function() onPressed;

  /// Tooltip text.
  final String tooltip;

  /// Icon size. Defaults to 14.
  final double size;

  /// Button constraint size. Defaults to 28.
  final double buttonSize;

  @override
  State<SoftSaaSActionButton> createState() => _SoftSaaSActionButtonState();
}

class _SoftSaaSActionButtonState extends State<SoftSaaSActionButton> {
  bool _showCheckmark = false;

  Future<void> _handlePressed() async {
    await widget.onPressed();
    if (!mounted) return;
    setState(() => _showCheckmark = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _showCheckmark = false);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return IconButton(
      onPressed: _handlePressed,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(
          _showCheckmark ? LucideIcons.check : widget.icon,
          key: ValueKey(_showCheckmark),
          size: widget.size,
          color: _showCheckmark
              ? SoftSaaSTokens.successColor(brightness)
              : SoftSaaSTokens.tertiaryText(brightness),
        ),
      ),
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(
        minWidth: widget.buttonSize,
        minHeight: widget.buttonSize,
      ),
      tooltip: widget.tooltip,
    );
  }
}
