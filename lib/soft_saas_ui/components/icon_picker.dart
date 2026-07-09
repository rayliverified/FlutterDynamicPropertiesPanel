// Soft SaaS UI Icon Picker.
//
// A button-style trigger that opens a popover containing an optional search
// field and a scrollable icon grid. Backed by [lucideIconRegistry] — a
// curated const map of ~180 Lucide icons that preserves Flutter's icon
// tree-shaking.
//
// When no search query is active and [showPresetsOnEmpty] is true, the
// popover opens on a 3×4 grid of [lucideIconPresetNames] to give the
// "just give me a common icon" experience. Typing in the search expands
// to the full registry (or the caller-supplied [allowedIcons] subset).
library;

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../design_tokens.dart';
import '../icons/lucide_icon_registry.dart';
import '../typography.dart';
import 'icon_picker_inspector.dart';

enum SoftSaaSIconPickerSize { small, medium, large }

class SoftSaaSIconPicker extends StatefulWidget {
  const SoftSaaSIconPicker({
    super.key,
    required this.iconName,
    this.onChanged,
    this.allowedIcons,
    this.label,
    this.placeholder = 'Select icon',
    this.size = SoftSaaSIconPickerSize.medium,
    this.enabled = true,
    this.showPresetsOnEmpty = true,
    this.errorText,
  });

  /// Current selected icon name. `null` means unset.
  final String? iconName;

  /// Called when the user picks a new icon from the popover.
  final ValueChanged<String>? onChanged;

  /// Restricts the available icon set to the intersection of
  /// [lucideIconRegistry] and this list. Useful for context-specific
  /// pickers (e.g. "status icons only").
  final List<String>? allowedIcons;

  final String? label;
  final String placeholder;
  final SoftSaaSIconPickerSize size;
  final bool enabled;
  final bool showPresetsOnEmpty;
  final String? errorText;

  @override
  State<SoftSaaSIconPicker> createState() => _SoftSaaSIconPickerState();
}

class _SoftSaaSIconPickerState extends State<SoftSaaSIconPicker> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlay;
  bool _open = false;
  bool _hovered = false;

  List<String> get _availableNames {
    final allowed = widget.allowedIcons;
    if (allowed == null) return lucideIconNames;
    final allowedSet = allowed.toSet();
    return lucideIconNames.where(allowedSet.contains).toList(growable: false);
  }

  double _height() {
    switch (widget.size) {
      case SoftSaaSIconPickerSize.small:
        return 32;
      case SoftSaaSIconPickerSize.medium:
        return 36;
      case SoftSaaSIconPickerSize.large:
        return 44;
    }
  }

  double _iconSize() {
    switch (widget.size) {
      case SoftSaaSIconPickerSize.small:
        return 14;
      case SoftSaaSIconPickerSize.medium:
        return 16;
      case SoftSaaSIconPickerSize.large:
        return 18;
    }
  }

  double _fontSize() {
    switch (widget.size) {
      case SoftSaaSIconPickerSize.small:
      case SoftSaaSIconPickerSize.medium:
        return 13;
      case SoftSaaSIconPickerSize.large:
        return 15;
    }
  }

  void _toggle() {
    if (!widget.enabled) return;
    if (_open) {
      _close();
    } else {
      _openPopover();
    }
  }

  void _openPopover() {
    _overlay = _buildOverlay();
    Overlay.of(context).insert(_overlay!);
    setState(() => _open = true);
  }

  void _close() {
    _overlay?.remove();
    _overlay = null;
    if (mounted) setState(() => _open = false);
  }

  @override
  void dispose() {
    _overlay?.remove();
    super.dispose();
  }

  OverlayEntry _buildOverlay() {
    final renderBox = context.findRenderObject() as RenderBox;
    final width = renderBox.size.width;
    final names = _availableNames;
    final entries = [
      for (final name in names)
        if (lucideIconRegistry[name] != null)
          SoftSaaSIconPickerInspectorEntry(
            name: name,
            icon: lucideIconRegistry[name]!,
          ),
    ];
    return OverlayEntry(
      builder: (_) => SoftSaaSIconGridPopover(
        link: _layerLink,
        width: width,
        icons: entries,
        selectedValue: widget.iconName,
        allowNone: false,
        onClose: _close,
        onPick: (name) {
          if (name != null) widget.onChanged?.call(name);
          _close();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final hasError = widget.errorText != null;
    final selectedIcon = widget.iconName != null
        ? lookupLucideIcon(widget.iconName!)
        : null;
    final showFocusRing = _open;
    final borderColor = hasError
        ? SoftSaaSTokens.errorColor(brightness)
        : showFocusRing
        ? SoftSaaSTokens.primaryColor(brightness).withValues(alpha: 0.5)
        : (_hovered
              ? SoftSaaSTokens.primaryBorder(brightness).withValues(alpha: 0.9)
              : SoftSaaSTokens.primaryBorder(brightness));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: SoftSaaSTypography.label(brightness)),
          const SizedBox(height: 6),
        ],
        CompositedTransformTarget(
          link: _layerLink,
          child: MouseRegion(
            cursor: widget.enabled
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            onEnter: (_) => setState(() => _hovered = true),
            onExit: (_) => setState(() => _hovered = false),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _toggle,
              child: AnimatedContainer(
                duration: SoftSaaSTokens.transitionDuration,
                curve: SoftSaaSTokens.transitionCurve,
                height: _height(),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: SoftSaaSTokens.primaryBackground(brightness),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: Row(
                  children: [
                    Icon(
                      selectedIcon ?? LucideIcons.square_dashed,
                      size: _iconSize() + 2,
                      color: selectedIcon == null
                          ? SoftSaaSTokens.tertiaryText(brightness)
                          : SoftSaaSTokens.primaryText(brightness),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.iconName ?? widget.placeholder,
                        style: TextStyle(
                          fontSize: _fontSize(),
                          color: widget.iconName == null
                              ? SoftSaaSTokens.tertiaryText(brightness)
                              : SoftSaaSTokens.primaryText(brightness),
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    AnimatedRotation(
                      duration: SoftSaaSTokens.transitionDuration,
                      turns: _open ? 0.5 : 0,
                      child: Icon(
                        LucideIcons.chevron_down,
                        size: 16,
                        color: SoftSaaSTokens.tertiaryText(brightness),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            widget.errorText!,
            style: SoftSaaSTypography.bodySmallSecondary(
              brightness,
            ).copyWith(color: SoftSaaSTokens.errorColor(brightness)),
          ),
        ],
      ],
    );
  }
}
