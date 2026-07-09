/// Soft SaaS UI Switch Component
///
/// Toggle switch form control with keyboard support, hover states, and accessibility

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design_tokens.dart';
import '../typography.dart';
import '../components/checkbox.dart';

/// Soft SaaS UI Switch Component
class SoftSaaSSwitch extends StatefulWidget {
  const SoftSaaSSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.color = SoftSaaSCheckboxColor.primary,
    this.size = SoftSaaSCheckboxSize.medium,
    this.label,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final SoftSaaSCheckboxColor color;
  final SoftSaaSCheckboxSize size;
  final String? label;

  @override
  State<SoftSaaSSwitch> createState() => _SoftSaaSSwitchState();
}

class _SoftSaaSSwitchState extends State<SoftSaaSSwitch> {
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final switchColor = _getSwitchColor(brightness);
    final trackWidth = _getTrackWidth();
    final trackHeight = _getTrackHeight();
    final thumbSize = _getThumbSize();
    final isDisabled = widget.onChanged == null;

    Widget switchWidget = Semantics(
      toggled: widget.value,
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
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: trackWidth,
              height: trackHeight,
              decoration: BoxDecoration(
                color: widget.value
                    ? (_isHovered
                          ? Color.lerp(switchColor, Colors.black, 0.1)!
                          : switchColor)
                    : (brightness == Brightness.light
                          ? (_isHovered
                                ? SoftSaaSTokens.gray400
                                : SoftSaaSTokens.gray300)
                          : (_isHovered
                                ? SoftSaaSTokens.gray500
                                : SoftSaaSTokens.gray600)),
                borderRadius: BorderRadius.circular(trackHeight / 2),
                border: _isFocused && !isDisabled
                    ? Border.all(color: switchColor, width: 2)
                    : null,
                boxShadow: _getTrackShadow(brightness, _isHovered),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: widget.value
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  width: thumbSize,
                  height: thumbSize,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: _getThumbShadow(brightness, _isHovered),
                  ),
                ),
              ),
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
              switchWidget,
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

    return switchWidget;
  }

  Color _getSwitchColor(Brightness brightness) {
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

  double _getTrackWidth() {
    switch (widget.size) {
      case SoftSaaSCheckboxSize.small:
        return 32.0;
      case SoftSaaSCheckboxSize.large:
        return 56.0;
      case SoftSaaSCheckboxSize.medium:
      default:
        return 44.0;
    }
  }

  double _getTrackHeight() {
    switch (widget.size) {
      case SoftSaaSCheckboxSize.small:
        return 16.0;
      case SoftSaaSCheckboxSize.large:
        return 28.0;
      case SoftSaaSCheckboxSize.medium:
      default:
        return 24.0;
    }
  }

  double _getThumbSize() {
    switch (widget.size) {
      case SoftSaaSCheckboxSize.small:
        return 12.0;
      case SoftSaaSCheckboxSize.large:
        return 20.0;
      case SoftSaaSCheckboxSize.medium:
      default:
        return 16.0;
    }
  }

  double _getTranslateX() {
    switch (widget.size) {
      case SoftSaaSCheckboxSize.small:
        return 16.0;
      case SoftSaaSCheckboxSize.large:
        return 28.0;
      case SoftSaaSCheckboxSize.medium:
      default:
        return 20.0;
    }
  }

  List<BoxShadow> _getTrackShadow(Brightness brightness, bool hovered) {
    if (brightness == Brightness.light) {
      return hovered
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                offset: const Offset(0, 3),
                blurRadius: 5,
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.15),
                offset: const Offset(0, -1),
                blurRadius: 2,
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.1),
                offset: const Offset(0, -1),
                blurRadius: 2,
              ),
            ];
    } else {
      return hovered
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                offset: const Offset(0, 3),
                blurRadius: 5,
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ];
    }
  }

  List<BoxShadow> _getThumbShadow(Brightness brightness, bool hovered) {
    if (brightness == Brightness.light) {
      return hovered
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                offset: const Offset(0, 3),
                blurRadius: 5,
                spreadRadius: -1,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                offset: const Offset(0, 1),
                blurRadius: 2,
                spreadRadius: -1,
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.25),
                offset: const Offset(0, 1),
                blurRadius: 1,
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                offset: const Offset(0, 2),
                blurRadius: 4,
                spreadRadius: -1,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                offset: const Offset(0, 1),
                blurRadius: 2,
                spreadRadius: -1,
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.2),
                offset: const Offset(0, 1),
                blurRadius: 1,
              ),
            ];
    } else {
      return hovered
          ? [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                offset: const Offset(0, 3),
                blurRadius: 5,
                spreadRadius: -1,
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.12),
                offset: const Offset(0, 1),
                blurRadius: 1,
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                offset: const Offset(0, 2),
                blurRadius: 4,
                spreadRadius: -1,
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.1),
                offset: const Offset(0, 1),
                blurRadius: 1,
              ),
            ];
    }
  }
}
