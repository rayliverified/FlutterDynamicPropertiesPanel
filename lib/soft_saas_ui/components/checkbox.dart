// Soft SaaS UI Checkbox Component
//
// Checkbox form control with keyboard support, hover states, and accessibility

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../design_tokens.dart';
import '../typography.dart';

/// Checkbox color variant
enum SoftSaaSCheckboxColor { primary, success, warning, error }

/// Checkbox size variant
enum SoftSaaSCheckboxSize {
  small, // 16px
  medium, // 20px
  large, // 24px
}

/// Soft SaaS UI Checkbox Component
class SoftSaaSCheckbox extends StatefulWidget {
  const SoftSaaSCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.color = SoftSaaSCheckboxColor.primary,
    this.size = SoftSaaSCheckboxSize.medium,
    this.label,
    this.indeterminate = false,
  });

  final bool value;
  final ValueChanged<bool?>? onChanged;
  final SoftSaaSCheckboxColor color;
  final SoftSaaSCheckboxSize size;
  final String? label;
  final bool indeterminate;

  @override
  State<SoftSaaSCheckbox> createState() => _SoftSaaSCheckboxState();
}

class _SoftSaaSCheckboxState extends State<SoftSaaSCheckbox> {
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final checkboxColor = _getCheckboxColor(brightness);
    final boxSize = _getBoxSize();
    final iconSize = _getIconSize();
    final isDisabled = widget.onChanged == null;

    Widget checkbox = Semantics(
      checked: widget.value,
      mixed: widget.indeterminate,
      enabled: !isDisabled,
      child: Focus(
        onKeyEvent: (node, event) {
          if (isDisabled) return KeyEventResult.ignored;
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.space)) {
            widget.onChanged?.call(!widget.value);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        onFocusChange: (focused) => setState(() => _isFocused = focused),
        child: MouseRegion(
          onEnter: isDisabled ? null : (_) => setState(() => _isHovered = true),
          onExit: isDisabled ? null : (_) => setState(() => _isHovered = false),
          cursor: isDisabled
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
          child: GestureDetector(
            onTap: isDisabled
                ? null
                : () => widget.onChanged?.call(!widget.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              width: boxSize,
              height: boxSize,
              decoration: BoxDecoration(
                color: widget.value
                    ? (_isHovered
                          ? Color.lerp(checkboxColor, Colors.black, 0.1)!
                          : checkboxColor)
                    : (_isHovered
                          ? (brightness == Brightness.light
                                ? SoftSaaSTokens.gray100
                                : SoftSaaSTokens.gray850)
                          : SoftSaaSTokens.primaryBackground(brightness)),
                border: Border.all(
                  color: _isFocused
                      ? checkboxColor
                      : (widget.value
                            ? checkboxColor
                            : SoftSaaSTokens.secondaryBorder(brightness)),
                  width: _isFocused ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusSmall),
                boxShadow: widget.value
                    ? _getCheckedShadow(brightness, _isHovered)
                    : _getUncheckedShadow(brightness, _isHovered),
              ),
              child: widget.value || widget.indeterminate
                  ? Icon(
                      widget.indeterminate
                          ? LucideIcons.minus
                          : LucideIcons.check,
                      size: iconSize,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );

    if (widget.label != null) {
      return GestureDetector(
        onTap: isDisabled ? null : () => widget.onChanged?.call(!widget.value),
        child: MouseRegion(
          cursor: isDisabled
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              checkbox,
              SizedBox(width: SoftSaaSTokens.spacing2),
              Text(
                widget.label!,
                style:
                    (widget.size == SoftSaaSCheckboxSize.small
                            ? SoftSaaSTypography.bodySmall(brightness)
                            : SoftSaaSTypography.bodyMedium(brightness))
                        .copyWith(
                          color: isDisabled
                              ? (brightness == Brightness.light
                                    ? SoftSaaSTokens.gray400
                                    : SoftSaaSTokens.gray600)
                              : null,
                        ),
              ),
            ],
          ),
        ),
      );
    }

    return checkbox;
  }

  Color _getCheckboxColor(Brightness brightness) {
    switch (widget.color) {
      case SoftSaaSCheckboxColor.primary:
        return SoftSaaSTokens.primaryColor(brightness);
      case SoftSaaSCheckboxColor.success:
        return SoftSaaSTokens.successColor(brightness);
      case SoftSaaSCheckboxColor.warning:
        return SoftSaaSTokens.warningColor(brightness);
      case SoftSaaSCheckboxColor.error:
        return SoftSaaSTokens.errorColor(brightness);
    }
  }

  double _getBoxSize() {
    switch (widget.size) {
      case SoftSaaSCheckboxSize.small:
        return 16.0;
      case SoftSaaSCheckboxSize.large:
        return 24.0;
      case SoftSaaSCheckboxSize.medium:
      default:
        return 20.0;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case SoftSaaSCheckboxSize.small:
        return 14.0;
      case SoftSaaSCheckboxSize.large:
        return 18.0;
      case SoftSaaSCheckboxSize.medium:
      default:
        return 16.0;
    }
  }

  List<BoxShadow> _getUncheckedShadow(Brightness brightness, bool hovered) {
    if (brightness == Brightness.light) {
      return hovered
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                offset: const Offset(0, 2),
                blurRadius: 3,
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.15),
                offset: const Offset(0, 1),
                blurRadius: 1,
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.1),
                offset: const Offset(0, 1),
                blurRadius: 1,
              ),
            ];
    } else {
      return hovered
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                offset: const Offset(0, 3),
                blurRadius: 5,
                spreadRadius: -1,
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                offset: const Offset(0, 2),
                blurRadius: 4,
                spreadRadius: -1,
              ),
            ];
    }
  }

  List<BoxShadow> _getCheckedShadow(Brightness brightness, bool hovered) {
    if (brightness == Brightness.light) {
      return hovered
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                offset: const Offset(0, 1),
                blurRadius: 3,
              ),
            ];
    } else {
      return hovered
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                offset: const Offset(0, 3),
                blurRadius: 5,
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ];
    }
  }
}
