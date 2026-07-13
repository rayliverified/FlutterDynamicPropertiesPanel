// Soft SaaS UI Button Components
//
// This file implements all button variants from the Soft SaaS UI design system:
// - SoftSaaSButton: Main button component (Primary, Secondary, Tertiary, Outline, Ghost, Destructive)
// - SoftSaaSIconButton: Icon-only button variant
//
// All buttons feature neumorphic shadows, smooth transitions, and full dark mode support.

import 'package:flutter/material.dart';
import '../design_tokens.dart';
import '../neumorphic_shadows.dart';
import '../typography.dart';

/// Button variant types
enum SoftSaaSButtonVariant {
  /// Primary button - filled with primary color (blue)
  primary,

  /// Secondary button - filled with neutral gray
  secondary,

  /// Tertiary button - filled with lighter gray
  tertiary,

  /// Outline button - transparent with border
  outline,

  /// Ghost button - transparent, no border
  ghost,

  /// Destructive button - filled with error/red color
  destructive,
}

/// Button size variants
enum SoftSaaSButtonSize {
  /// Small button: px-2 py-1 text-xs
  small,

  /// Medium button: px-3 py-1.5 text-xs (default)
  medium,

  /// Large button: px-4 py-2 text-sm
  large,
}

/// Soft SaaS UI Button Component
///
/// A highly customizable button with multiple variants, sizes, and states.
/// Supports neumorphic shadows, icons, loading states, and full dark mode.
///
/// Example:
/// ```dart
/// SoftSaaSButton(
///   variant: SoftSaaSButtonVariant.primary,
///   size: SoftSaaSButtonSize.medium,
///   onPressed: () => print('Pressed'),
///   child: Text('Click Me'),
/// )
/// ```
class SoftSaaSButton extends StatefulWidget {
  const SoftSaaSButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = SoftSaaSButtonVariant.primary,
    this.size = SoftSaaSButtonSize.medium,
    this.icon,
    this.iconPosition = IconPosition.left,
    this.isLoading = false,
    this.fullWidth = false,
  });

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Button content (usually Text widget)
  final Widget child;

  /// Button visual variant
  final SoftSaaSButtonVariant variant;

  /// Button size
  final SoftSaaSButtonSize size;

  /// Optional icon to display
  final IconData? icon;

  /// Icon position relative to child
  final IconPosition iconPosition;

  /// Whether button is in loading state
  final bool isLoading;

  /// Whether button should take full width
  final bool fullWidth;

  @override
  State<SoftSaaSButton> createState() => _SoftSaaSButtonState();
}

class _SoftSaaSButtonState extends State<SoftSaaSButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDisabled = widget.onPressed == null || widget.isLoading;

    final buttonColors = _getButtonColors(brightness);
    final buttonPadding = _getButtonPadding();
    final textStyle = _getTextStyle(brightness, buttonColors.textColor);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: isDisabled ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: SoftSaaSTokens.transitionDuration,
          curve: SoftSaaSTokens.transitionCurve,
          width: widget.fullWidth ? double.infinity : null,
          padding: buttonPadding,
          decoration: BoxDecoration(
            color: isDisabled
                ? buttonColors.backgroundColor.withValues(
                    alpha: SoftSaaSTokens.opacityDisabled,
                  )
                : buttonColors.backgroundColor,
            border: widget.variant == SoftSaaSButtonVariant.outline
                ? Border.all(
                    color: isDisabled
                        ? buttonColors.borderColor!.withValues(
                            alpha: SoftSaaSTokens.opacityDisabled,
                          )
                        : buttonColors.borderColor!,
                    width: 1,
                  )
                : null,
            borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusLarge),
            boxShadow: isDisabled
                ? null
                : _isPressed
                ? NeumorphicShadows.insetShadow(brightness)
                : _getShadow(brightness),
          ),
          child: Opacity(
            opacity: isDisabled ? SoftSaaSTokens.opacityDisabled : 1.0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isLoading) ...[
                  SizedBox(
                    width: _getIconSize(),
                    height: _getIconSize(),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                        buttonColors.textColor,
                      ),
                    ),
                  ),
                  SizedBox(width: SoftSaaSTokens.spacing2),
                ] else if (widget.icon != null &&
                    widget.iconPosition == IconPosition.left) ...[
                  Icon(
                    widget.icon,
                    size: _getIconSize(),
                    color: buttonColors.textColor,
                  ),
                  SizedBox(width: SoftSaaSTokens.spacing2),
                ],
                Flexible(
                  child: DefaultTextStyle(
                    style: textStyle,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    child: widget.child,
                  ),
                ),
                if (widget.icon != null &&
                    widget.iconPosition == IconPosition.right) ...[
                  SizedBox(width: SoftSaaSTokens.spacing2),
                  Icon(
                    widget.icon,
                    size: _getIconSize(),
                    color: buttonColors.textColor,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  ButtonColors _getButtonColors(Brightness brightness) {
    switch (widget.variant) {
      case SoftSaaSButtonVariant.primary:
        return ButtonColors(
          backgroundColor: SoftSaaSTokens.primaryColor(brightness),
          textColor: Colors.white,
        );

      case SoftSaaSButtonVariant.secondary:
        if (brightness == Brightness.light) {
          return ButtonColors(
            backgroundColor: SoftSaaSTokens.gray700,
            textColor: Colors.white,
          );
        } else {
          return ButtonColors(
            backgroundColor: SoftSaaSTokens.gray600,
            textColor: Colors.white,
          );
        }

      case SoftSaaSButtonVariant.tertiary:
        return ButtonColors(
          backgroundColor: SoftSaaSTokens.tertiaryBackground(brightness),
          textColor: SoftSaaSTokens.primaryText(brightness),
        );

      case SoftSaaSButtonVariant.outline:
        return ButtonColors(
          backgroundColor: Colors.transparent,
          textColor: SoftSaaSTokens.primaryText(brightness),
          borderColor: SoftSaaSTokens.secondaryBorder(brightness),
        );

      case SoftSaaSButtonVariant.ghost:
        return ButtonColors(
          backgroundColor: Colors.transparent,
          textColor: SoftSaaSTokens.primaryText(brightness),
        );

      case SoftSaaSButtonVariant.destructive:
        return ButtonColors(
          backgroundColor: SoftSaaSTokens.errorColor(brightness),
          textColor: Colors.white,
        );
    }
  }

  EdgeInsets _getButtonPadding() {
    switch (widget.size) {
      case SoftSaaSButtonSize.small:
        return SoftSaaSTokens.buttonPaddingSmall;
      case SoftSaaSButtonSize.large:
        return SoftSaaSTokens.buttonPaddingLarge;
      case SoftSaaSButtonSize.medium:
      default:
        return SoftSaaSTokens.buttonPaddingMedium;
    }
  }

  TextStyle _getTextStyle(Brightness brightness, Color textColor) {
    switch (widget.size) {
      case SoftSaaSButtonSize.small:
        return SoftSaaSTypography.buttonSmall(textColor);
      case SoftSaaSButtonSize.large:
        return SoftSaaSTypography.buttonLarge(textColor);
      case SoftSaaSButtonSize.medium:
      default:
        return SoftSaaSTypography.buttonMedium(textColor);
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case SoftSaaSButtonSize.small:
        return SoftSaaSTokens.iconSizeSmall;
      case SoftSaaSButtonSize.large:
        return SoftSaaSTokens.iconSizeLarge;
      case SoftSaaSButtonSize.medium:
      default:
        return SoftSaaSTokens.iconSizeMedium;
    }
  }

  List<BoxShadow> _getShadow(Brightness brightness) {
    // Ghost and outline buttons don't have shadows
    if (widget.variant == SoftSaaSButtonVariant.ghost) {
      return [];
    }
    if (widget.variant == SoftSaaSButtonVariant.outline) {
      return [];
    }

    // Use color-tinted shadows for colored buttons in light mode
    if (brightness == Brightness.light) {
      switch (widget.variant) {
        case SoftSaaSButtonVariant.primary:
          return NeumorphicShadows.blueTintedLight;
        case SoftSaaSButtonVariant.destructive:
          return NeumorphicShadows.redTintedLight;
        default:
          return NeumorphicShadows.level2Light;
      }
    }

    // Dark mode uses standard shadows
    return NeumorphicShadows.level2Dark;
  }
}

/// Icon-only button component
///
/// A compact button that displays only an icon, perfect for action buttons
/// like close, menu, settings, etc.
///
/// Example:
/// ```dart
/// SoftSaaSIconButton(
///   icon: Icons.close,
///   onPressed: () => Navigator.pop(context),
/// )
/// ```
class SoftSaaSIconButton extends StatefulWidget {
  const SoftSaaSIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.size = SoftSaaSButtonSize.medium,
    this.variant = SoftSaaSIconButtonVariant.ghost,
    this.tooltip,
    this.iconColor,
    this.hoverIconColor,
  });

  /// Icon to display
  final IconData icon;

  /// Callback when button is pressed
  final VoidCallback? onPressed;

  /// Button size
  final SoftSaaSButtonSize size;

  /// Button visual variant
  final SoftSaaSIconButtonVariant variant;

  /// Optional tooltip text
  final String? tooltip;

  /// Optional icon color override.
  ///
  /// When provided, this takes precedence over variant-based icon coloring.
  final Color? iconColor;

  /// Optional icon color shown on hover.
  ///
  /// When provided, overrides [iconColor] while the button is hovered.
  final Color? hoverIconColor;

  @override
  State<SoftSaaSIconButton> createState() => _SoftSaaSIconButtonState();
}

class _SoftSaaSIconButtonState extends State<SoftSaaSIconButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDisabled = widget.onPressed == null;

    final buttonSize = _getButtonSize();
    final iconSize = _getIconSize();
    final iconColor = _getIconColor(brightness);

    Widget button = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: isDisabled ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: SoftSaaSTokens.transitionDuration,
          curve: SoftSaaSTokens.transitionCurve,
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: _getBackgroundColor(brightness),
            borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusLarge),
            boxShadow:
                widget.variant == SoftSaaSIconButtonVariant.elevated &&
                    !_isPressed
                ? NeumorphicShadows.getLevel2(brightness)
                : null,
          ),
          child: Center(
            child: Icon(
              widget.icon,
              size: iconSize,
              color: isDisabled
                  ? iconColor.withValues(alpha: SoftSaaSTokens.opacityDisabled)
                  : iconColor,
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }

    return button;
  }

  double _getButtonSize() {
    switch (widget.size) {
      case SoftSaaSButtonSize.small:
        return 28.0;
      case SoftSaaSButtonSize.large:
        return 44.0;
      case SoftSaaSButtonSize.medium:
      default:
        return 32.0;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case SoftSaaSButtonSize.small:
      case SoftSaaSButtonSize.medium:
        return SoftSaaSTokens.iconSizeSmall;
      case SoftSaaSButtonSize.large:
      default:
        return SoftSaaSTokens.iconSizeXL;
    }
  }

  Color _getIconColor(Brightness brightness) {
    if (_isHovered && widget.hoverIconColor != null) {
      return widget.hoverIconColor!;
    }
    if (widget.iconColor != null) return widget.iconColor!;

    switch (widget.variant) {
      case SoftSaaSIconButtonVariant.ghost:
      case SoftSaaSIconButtonVariant.elevated:
        return SoftSaaSTokens.secondaryText(brightness);
      case SoftSaaSIconButtonVariant.primary:
        return SoftSaaSTokens.primaryColor(brightness);
      case SoftSaaSIconButtonVariant.destructive:
        return SoftSaaSTokens.errorColor(brightness);
    }
  }

  Color _getBackgroundColor(Brightness brightness) {
    if (widget.variant == SoftSaaSIconButtonVariant.ghost) {
      // Ghost buttons have hover background
      if (_isHovered && !_isPressed) {
        if (brightness == Brightness.light) {
          return Colors.black.withValues(
            alpha: SoftSaaSTokens.opacityHoverLight,
          );
        } else {
          return Colors.white.withValues(
            alpha: SoftSaaSTokens.opacityHoverDark,
          );
        }
      }
      return Colors.transparent;
    }

    // Elevated buttons have solid background
    return SoftSaaSTokens.secondaryBackground(brightness);
  }
}

/// Icon button variants
enum SoftSaaSIconButtonVariant {
  /// Ghost - transparent, shows background on hover
  ghost,

  /// Elevated - has background and shadow
  elevated,

  /// Primary color icon
  primary,

  /// Destructive/error color icon
  destructive,
}

/// Icon position relative to button text
enum IconPosition { left, right }

/// Internal class for button color configuration
class ButtonColors {
  const ButtonColors({
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });

  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
}
