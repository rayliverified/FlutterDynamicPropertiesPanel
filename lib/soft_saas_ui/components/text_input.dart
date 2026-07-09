// Soft SaaS UI Text Input Component
//
// Production-ready text input fields with flat, border-first styling.
// The default constructor matches the DialogTextField pattern from
// Flat, compact text input with radius 7 and no shadow.
//
// Use [SoftSaaSTextInput.elevated] for the neumorphic shadow style.

import 'package:flutter/material.dart';
import '../design_tokens.dart';
import '../neumorphic_shadows.dart';
import '../typography.dart';

/// Text input size — matches [SoftSaaSSelectSize] for visual consistency.
enum SoftSaaSTextInputSize {
  /// 32px perceived height — dense, for compact forms and toolbars.
  small,

  /// 36px perceived height — standard, for dialogs and settings.
  medium,

  /// 44px perceived height — spacious, for prominent standalone fields.
  large,
}

/// Text input style variants (internal)
enum _SoftSaaSTextInputStyle { defaultStyle, elevated }

/// Text input component with production-ready flat styling
///
/// The default constructor provides a dense, border-first field matching
/// the production DialogTextField pattern:
/// - radius 7
/// - compact padding (10h × 12v)
/// - no shadow
/// - focus via border color shift + width change
///
/// Use [SoftSaaSTextInput.elevated] for the older neumorphic shadow style.
///
/// Example:
/// ```dart
/// SoftSaaSTextInput(
///   label: 'Email',
///   hintText: 'Enter your email',
///   onChanged: (value) => print(value),
/// )
/// ```
class SoftSaaSTextInput extends StatefulWidget {
  const SoftSaaSTextInput({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.suffix,
    this.suffixIconConstraints,
    this.autofocus = false,
    this.readOnly = false,
    this.onTap,
    this.size = SoftSaaSTextInputSize.medium,
  }) : _style = _SoftSaaSTextInputStyle.defaultStyle;

  /// Neumorphic variant with shadow elevation and animated focus state.
  ///
  /// Use this for showcase/decorative contexts where the soft tactile
  /// appearance is desired. For production form fields, prefer the
  /// default constructor.
  const SoftSaaSTextInput.elevated({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.suffix,
    this.suffixIconConstraints,
    this.autofocus = false,
    this.readOnly = false,
    this.onTap,
    this.size = SoftSaaSTextInputSize.medium,
  }) : _style = _SoftSaaSTextInputStyle.elevated;

  /// Label displayed above input
  final String? label;

  /// Placeholder text
  final String? hintText;

  /// Helper text displayed below input
  final String? helperText;

  /// Error text displayed below input (overrides helperText)
  final String? errorText;

  /// Text controller
  final TextEditingController? controller;

  /// Called when text changes
  final ValueChanged<String>? onChanged;

  /// Called when user submits
  final ValueChanged<String>? onSubmitted;

  /// Whether to obscure text (for passwords)
  final bool obscureText;

  /// Whether input is enabled
  final bool enabled;

  /// Maximum number of lines (1 for single-line, null for unlimited)
  final int? maxLines;

  /// Keyboard type
  final TextInputType? keyboardType;

  /// Icon displayed at start of input
  final IconData? prefixIcon;

  /// Icon displayed at end of input
  final IconData? suffixIcon;

  /// Arbitrary widget displayed at end of input (takes precedence over [suffixIcon])
  final Widget? suffix;

  /// Constraints for the suffix icon area
  final BoxConstraints? suffixIconConstraints;

  /// Whether to autofocus this input
  final bool autofocus;

  /// Whether the text field is read-only
  final bool readOnly;

  /// Called when the text field is tapped (useful for read-only fields)
  final VoidCallback? onTap;

  /// Input size variant.
  final SoftSaaSTextInputSize size;

  final _SoftSaaSTextInputStyle _style;

  @override
  State<SoftSaaSTextInput> createState() => _SoftSaaSTextInputState();
}

class _SoftSaaSTextInputState extends State<SoftSaaSTextInput> {
  FocusNode? _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    if (widget._style == _SoftSaaSTextInputStyle.elevated) {
      _focusNode = FocusNode();
      _focusNode!.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    _focusNode?.removeListener(_onFocusChange);
    _focusNode?.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode!.hasFocus;
    });
  }

  // ══════════════════════════════════════════════════════════════════════
  // SIZE HELPERS
  // ══════════════════════════════════════════════════════════════════════

  EdgeInsets _getContentPadding() {
    switch (widget.size) {
      case SoftSaaSTextInputSize.small:
        return const EdgeInsets.symmetric(horizontal: 10, vertical: 10);
      case SoftSaaSTextInputSize.medium:
        return const EdgeInsets.symmetric(horizontal: 10, vertical: 12);
      case SoftSaaSTextInputSize.large:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 16);
    }
  }

  double _getFontSize() {
    switch (widget.size) {
      case SoftSaaSTextInputSize.small:
        return 13.0;
      case SoftSaaSTextInputSize.medium:
        return 13.0;
      case SoftSaaSTextInputSize.large:
        return 15.0;
    }
  }

  EdgeInsets _getElevatedContentPadding() {
    switch (widget.size) {
      case SoftSaaSTextInputSize.small:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      case SoftSaaSTextInputSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
      case SoftSaaSTextInputSize.large:
        return const EdgeInsets.symmetric(horizontal: 18, vertical: 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (widget.label != null) ...[
          Text(widget.label!, style: SoftSaaSTypography.label(brightness)),
          const SizedBox(height: 6),
        ],

        // Input field
        if (widget._style == _SoftSaaSTextInputStyle.elevated)
          _buildElevatedField(brightness, hasError)
        else
          _buildDefaultField(brightness, hasError),

        // Helper or error text
        if (widget.errorText != null || widget.helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText ?? widget.helperText!,
            style: SoftSaaSTypography.bodySmallSecondary(brightness).copyWith(
              color: hasError
                  ? SoftSaaSTokens.errorColor(brightness)
                  : SoftSaaSTokens.secondaryText(brightness),
            ),
          ),
        ],
      ],
    );
  }

  /// Production-ready flat field matching DialogTextField pattern.
  ///
  /// - radius 7
  /// - compact padding (10h × 12v)
  /// - no shadow
  /// - OutlineInputBorder on InputDecoration
  /// - focus = border color shift + 1.5px width
  Widget _buildDefaultField(Brightness brightness, bool hasError) {
    final bg = SoftSaaSTokens.primaryBackground(brightness);
    final border = SoftSaaSTokens.primaryBorder(brightness);
    final textPrimary = SoftSaaSTokens.primaryText(brightness);
    final textTertiary = SoftSaaSTokens.tertiaryText(brightness);
    final secondaryText = SoftSaaSTokens.secondaryText(brightness);

    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      obscureText: widget.obscureText,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType,
      autofocus: widget.autofocus,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      style: TextStyle(fontSize: _getFontSize()).copyWith(color: textPrimary),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          fontSize: _getFontSize(),
        ).copyWith(color: textTertiary),
        filled: true,
        fillColor: bg,
        isDense: true,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        contentPadding: _getContentPadding(),
        prefixIcon: widget.prefixIcon != null
            ? Icon(
                widget.prefixIcon,
                color: secondaryText,
                size: SoftSaaSTokens.iconSizeMedium,
              )
            : null,
        prefixIconConstraints: widget.prefixIcon != null
            ? BoxConstraints(
                minWidth: switch (widget.size) {
                  SoftSaaSTextInputSize.small => 32,
                  SoftSaaSTextInputSize.medium => 36,
                  SoftSaaSTextInputSize.large => 44,
                },
                minHeight: switch (widget.size) {
                  SoftSaaSTextInputSize.small => 32,
                  SoftSaaSTextInputSize.medium => 36,
                  SoftSaaSTextInputSize.large => 44,
                },
              )
            : null,
        suffixIcon:
            widget.suffix ??
            (widget.suffixIcon != null
                ? Icon(
                    widget.suffixIcon,
                    color: secondaryText,
                    size: SoftSaaSTokens.iconSizeMedium,
                  )
                : null),
        suffixIconConstraints:
            (widget.suffix != null || widget.suffixIcon != null)
            ? (widget.suffixIconConstraints ??
                  BoxConstraints(
                    minWidth: switch (widget.size) {
                      SoftSaaSTextInputSize.small => 32,
                      SoftSaaSTextInputSize.medium => 36,
                      SoftSaaSTextInputSize.large => 44,
                    },
                    minHeight: switch (widget.size) {
                      SoftSaaSTextInputSize.small => 32,
                      SoftSaaSTextInputSize.medium => 36,
                      SoftSaaSTextInputSize.large => 44,
                    },
                  ))
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(
            color: SoftSaaSTokens.primaryColor(
              brightness,
            ).withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: border, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(
            color: SoftSaaSTokens.errorColor(brightness),
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(
            color: SoftSaaSTokens.errorColor(brightness),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  /// Neumorphic variant with shadow elevation and animated focus state.
  ///
  /// Preserves the original SoftSaaSTextInput visual treatment:
  /// - radius 12 (radiusXLarge)
  /// - padding 16h × 12v
  /// - Level 2 neumorphic shadow (unfocused)
  /// - Focus shadow (focused)
  Widget _buildElevatedField(Brightness brightness, bool hasError) {
    return AnimatedContainer(
      duration: SoftSaaSTokens.transitionDuration,
      curve: SoftSaaSTokens.transitionCurve,
      decoration: BoxDecoration(
        color: SoftSaaSTokens.primaryBackground(brightness),
        borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusXLarge),
        border: Border.all(
          color: hasError
              ? SoftSaaSTokens.errorColor(brightness)
              : _isFocused
              ? SoftSaaSTokens.primaryBorder(brightness)
              : SoftSaaSTokens.tertiaryBackground(brightness),
          width: 1,
        ),
        boxShadow: _isFocused
            ? NeumorphicShadows.getFocusShadow(brightness)
            : NeumorphicShadows.getLevel2(brightness),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        obscureText: widget.obscureText,
        enabled: widget.enabled,
        maxLines: widget.maxLines,
        keyboardType: widget.keyboardType,
        autofocus: widget.autofocus,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        style: SoftSaaSTypography.bodyMedium(brightness),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: SoftSaaSTypography.bodyMediumTertiary(brightness),
          border: InputBorder.none,
          contentPadding: _getElevatedContentPadding(),
          prefixIcon: widget.prefixIcon != null
              ? Icon(
                  widget.prefixIcon,
                  color: SoftSaaSTokens.secondaryText(brightness),
                  size: SoftSaaSTokens.iconSizeMedium,
                )
              : null,
          suffixIcon:
              widget.suffix ??
              (widget.suffixIcon != null
                  ? Icon(
                      widget.suffixIcon,
                      color: SoftSaaSTokens.secondaryText(brightness),
                      size: SoftSaaSTokens.iconSizeMedium,
                    )
                  : null),
        ),
      ),
    );
  }
}

/// Legacy neumorphic text input component.
///
/// This class preserves the original SoftSaaSTextInput implementation with
/// neumorphic shadow styling. Prefer [SoftSaaSTextInput.elevated] for new
/// code — it provides the same visual style with additional features
/// (readOnly, onTap, suffixIconConstraints).
@Deprecated('Use SoftSaaSTextInput.elevated() instead')
class SoftSaaSTextInputNeumorphic extends StatefulWidget {
  const SoftSaaSTextInputNeumorphic({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.autofocus = false,
  });

  /// Label displayed above input
  final String? label;

  /// Placeholder text
  final String? hintText;

  /// Helper text displayed below input
  final String? helperText;

  /// Error text displayed below input (overrides helperText)
  final String? errorText;

  /// Text controller
  final TextEditingController? controller;

  /// Called when text changes
  final ValueChanged<String>? onChanged;

  /// Called when user submits
  final ValueChanged<String>? onSubmitted;

  /// Whether to obscure text (for passwords)
  final bool obscureText;

  /// Whether input is enabled
  final bool enabled;

  /// Maximum number of lines (1 for single-line, null for unlimited)
  final int? maxLines;

  /// Keyboard type
  final TextInputType? keyboardType;

  /// Icon displayed at start of input
  final IconData? prefixIcon;

  /// Icon displayed at end of input
  final IconData? suffixIcon;

  /// Whether to autofocus this input
  final bool autofocus;

  @override
  State<SoftSaaSTextInputNeumorphic> createState() =>
      _SoftSaaSTextInputNeumorphicState();
}

class _SoftSaaSTextInputNeumorphicState
    extends State<SoftSaaSTextInputNeumorphic> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (widget.label != null) ...[
          Text(widget.label!, style: SoftSaaSTypography.label(brightness)),
          const SizedBox(height: 6),
        ],

        // Input field
        AnimatedContainer(
          duration: SoftSaaSTokens.transitionDuration,
          curve: SoftSaaSTokens.transitionCurve,
          decoration: BoxDecoration(
            color: SoftSaaSTokens.primaryBackground(brightness),
            borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusXLarge),
            border: Border.all(
              color: hasError
                  ? SoftSaaSTokens.errorColor(brightness)
                  : _isFocused
                  ? SoftSaaSTokens.primaryBorder(brightness)
                  : SoftSaaSTokens.tertiaryBackground(brightness),
              width: 1,
            ),
            boxShadow: _isFocused
                ? NeumorphicShadows.getFocusShadow(brightness)
                : NeumorphicShadows.getLevel2(brightness),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            obscureText: widget.obscureText,
            enabled: widget.enabled,
            maxLines: widget.maxLines,
            keyboardType: widget.keyboardType,
            autofocus: widget.autofocus,
            style: SoftSaaSTypography.bodyMedium(brightness),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: SoftSaaSTypography.bodyMediumTertiary(brightness),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: SoftSaaSTokens.secondaryText(brightness),
                      size: SoftSaaSTokens.iconSizeMedium,
                    )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? Icon(
                      widget.suffixIcon,
                      color: SoftSaaSTokens.secondaryText(brightness),
                      size: SoftSaaSTokens.iconSizeMedium,
                    )
                  : null,
            ),
          ),
        ),

        // Helper or error text
        if (widget.errorText != null || widget.helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText ?? widget.helperText!,
            style: SoftSaaSTypography.bodySmallSecondary(brightness).copyWith(
              color: hasError
                  ? SoftSaaSTokens.errorColor(brightness)
                  : SoftSaaSTokens.secondaryText(brightness),
            ),
          ),
        ],
      ],
    );
  }
}
