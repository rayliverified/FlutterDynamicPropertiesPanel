/// Soft SaaS UI Badge Component
///
/// Badge labels with variants, sizes, shapes, interactive capabilities,
/// and animations.

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../design_tokens.dart';
import '../neumorphic_shadows.dart';
import '../typography.dart';

// ══════════════════════════════════════════════════════════════════════
// BADGE
// ══════════════════════════════════════════════════════════════════════

/// Badge variant types
enum SoftSaaSBadgeVariant {
  defaultBadge,
  primary,
  success,
  warning,
  error,
  info,
}

/// Badge size variants
enum SoftSaaSBadgeSize { small, medium, large }

/// Badge shape variants
enum SoftSaaSBadgeShape {
  rounded, // rounded-md (6px)
  pill, // rounded-full
  square, // rounded-sm (2px)
}

/// Soft SaaS UI Badge Component
class SoftSaaSBadge extends StatefulWidget {
  const SoftSaaSBadge({
    super.key,
    required this.label,
    this.variant = SoftSaaSBadgeVariant.defaultBadge,
    this.size = SoftSaaSBadgeSize.medium,
    this.shape = SoftSaaSBadgeShape.rounded,
    this.icon,
    this.onTap,
    this.onDismiss,
    this.showDot = false,
    this.animate = true,
  });

  final String label;
  final SoftSaaSBadgeVariant variant;
  final SoftSaaSBadgeSize size;
  final SoftSaaSBadgeShape shape;
  final IconData? icon;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final bool showDot;
  final bool animate;

  @override
  State<SoftSaaSBadge> createState() => _SoftSaaSBadgeState();
}

class _SoftSaaSBadgeState extends State<SoftSaaSBadge>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));

    if (widget.animate) {
      _scaleController.forward();
    } else {
      _scaleController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final colors = _getBadgeColors(brightness);
    final isInteractive = widget.onTap != null;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Semantics(
        button: isInteractive,
        label: widget.label,
        onTap: isInteractive ? widget.onTap : null,
        child: MouseRegion(
          onEnter: isInteractive
              ? (_) => setState(() => _isHovered = true)
              : null,
          onExit: isInteractive
              ? (_) => setState(() => _isHovered = false)
              : null,
          cursor: isInteractive
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeInOut,
              padding: _getPadding(),
              decoration: BoxDecoration(
                color: _isHovered
                    ? _getHoverColor(colors.backgroundColor)
                    : colors.backgroundColor,
                borderRadius: _getBorderRadius(),
                border: Border.all(
                  color: _isHovered
                      ? _getHoverBorderColor(colors.borderColor)
                      : colors.borderColor,
                  width: 1,
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: brightness == Brightness.light
                              ? Colors.black.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : NeumorphicShadows.getLevel1(brightness),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.showDot) ...[
                    _buildDotIndicator(colors.textColor),
                    SizedBox(width: SoftSaaSTokens.spacing1),
                  ],
                  if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      size: _getIconSize(),
                      color: colors.textColor,
                    ),
                    SizedBox(width: SoftSaaSTokens.spacing1),
                  ],
                  Text(
                    widget.label,
                    style: SoftSaaSTypography.badgeMedium(colors.textColor)
                        .copyWith(
                          fontSize: _getFontSize(),
                          letterSpacing: 0.2,
                          height: 1.2,
                        ),
                  ),
                  if (widget.onDismiss != null) ...[
                    SizedBox(width: SoftSaaSTokens.spacing1),
                    GestureDetector(
                      onTap: widget.onDismiss,
                      child: Icon(
                        LucideIcons.x,
                        size: _getIconSize(),
                        color: colors.textColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDotIndicator(Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: _getDotSize(),
            height: _getDotSize(),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        );
      },
      onEnd: () {
        // Reverse animation for pulse effect
        setState(() {});
      },
    );
  }

  Color _getHoverColor(Color baseColor) {
    return Color.lerp(baseColor, Colors.white, 0.1)!;
  }

  Color _getHoverBorderColor(Color baseColor) {
    return Color.lerp(baseColor, Colors.black, 0.1)!;
  }

  double _getDotSize() {
    switch (widget.size) {
      case SoftSaaSBadgeSize.small:
        return 4.0;
      case SoftSaaSBadgeSize.large:
        return 7.0;
      case SoftSaaSBadgeSize.medium:
      default:
        return 5.0;
    }
  }

  _BadgeColors _getBadgeColors(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    switch (widget.variant) {
      case SoftSaaSBadgeVariant.primary:
        return _BadgeColors(
          backgroundColor: isLight
              ? const Color(0xFFDBEAFE)
              : const Color(0x4D1E40AF),
          textColor: isLight
              ? const Color(0xFF1E40AF)
              : const Color(0xFF93C5FD),
          borderColor: isLight
              ? const Color(0xFFBFDBFE)
              : const Color(0x4D3B82F6),
        );
      case SoftSaaSBadgeVariant.success:
        return _BadgeColors(
          backgroundColor: isLight
              ? const Color(0xFFDCFCE7)
              : const Color(0x4D14532D),
          textColor: isLight
              ? const Color(0xFF15803D)
              : const Color(0xFF86EFAC),
          borderColor: isLight
              ? const Color(0xFFBBF7D0)
              : const Color(0x4D22C55E),
        );
      case SoftSaaSBadgeVariant.warning:
        return _BadgeColors(
          backgroundColor: isLight
              ? const Color(0xFFFEF3C7)
              : const Color(0x4D78350F),
          textColor: isLight
              ? const Color(0xFF92400E)
              : const Color(0xFFFDE68A),
          borderColor: isLight
              ? const Color(0xFFFDE68A)
              : const Color(0x4DFB923C),
        );
      case SoftSaaSBadgeVariant.error:
        return _BadgeColors(
          backgroundColor: isLight
              ? const Color(0xFFFEE2E2)
              : const Color(0x4D7F1D1D),
          textColor: isLight
              ? const Color(0xFF991B1B)
              : const Color(0xFFFCA5A5),
          borderColor: isLight
              ? const Color(0xFFFECACA)
              : const Color(0x4DEF4444),
        );
      case SoftSaaSBadgeVariant.info:
        return _BadgeColors(
          backgroundColor: isLight
              ? const Color(0xFFCFFAFE)
              : const Color(0x4D164E63),
          textColor: isLight
              ? const Color(0xFF155E75)
              : const Color(0xFF67E8F9),
          borderColor: isLight
              ? const Color(0xFFA5F3FC)
              : const Color(0x4D06B6D4),
        );
      case SoftSaaSBadgeVariant.defaultBadge:
      default:
        return _BadgeColors(
          backgroundColor: isLight
              ? SoftSaaSTokens.gray100
              : SoftSaaSTokens.gray800,
          textColor: isLight ? SoftSaaSTokens.gray700 : SoftSaaSTokens.gray300,
          borderColor: isLight
              ? SoftSaaSTokens.gray200
              : SoftSaaSTokens.gray600,
        );
    }
  }

  EdgeInsets _getPadding() {
    switch (widget.size) {
      case SoftSaaSBadgeSize.small:
        return SoftSaaSTokens.badgePaddingSmall;
      case SoftSaaSBadgeSize.large:
        return SoftSaaSTokens.badgePaddingLarge;
      case SoftSaaSBadgeSize.medium:
      default:
        return SoftSaaSTokens.badgePaddingMedium;
    }
  }

  BorderRadius _getBorderRadius() {
    switch (widget.shape) {
      case SoftSaaSBadgeShape.pill:
        return BorderRadius.circular(SoftSaaSTokens.radiusFull);
      case SoftSaaSBadgeShape.square:
        return BorderRadius.circular(SoftSaaSTokens.radiusSmall);
      case SoftSaaSBadgeShape.rounded:
      default:
        return BorderRadius.circular(SoftSaaSTokens.radiusMedium);
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case SoftSaaSBadgeSize.small:
        return SoftSaaSTokens.fontSizeXS;
      case SoftSaaSBadgeSize.large:
        return SoftSaaSTokens.fontSizeSM;
      case SoftSaaSBadgeSize.medium:
      default:
        return SoftSaaSTokens.fontSizeXS;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case SoftSaaSBadgeSize.small:
        return 10.0;
      case SoftSaaSBadgeSize.large:
        return 14.0;
      case SoftSaaSBadgeSize.medium:
      default:
        return 12.0;
    }
  }
}

/// Internal class for badge colors
class _BadgeColors {
  const _BadgeColors({
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });

  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
}
