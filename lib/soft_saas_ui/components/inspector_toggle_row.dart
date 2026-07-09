/// Generic Inspector-style icon toggle row.
///
/// Renders primary options as inline white-chip toggles inside a gray
/// container. Optional overflow options live behind a vertical-ellipsis chip
/// that becomes selected (with their icon) when one is active.
library;

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../design_tokens.dart';
import 'dropdown.dart' as ssd;

class SoftSaaSInspectorToggleOption<T> {
  const SoftSaaSInspectorToggleOption({
    required this.value,
    required this.icon,
    required this.tooltip,
  });

  final T value;
  final IconData icon;
  final String tooltip;
}

class SoftSaaSInspectorToggleRow<T> extends StatelessWidget {
  const SoftSaaSInspectorToggleRow({
    super.key,
    required this.value,
    required this.primaryOptions,
    required this.onChanged,
    this.overflowOptions = const [],
    this.enabled = true,
  });

  final T value;
  final List<SoftSaaSInspectorToggleOption<T>> primaryOptions;
  final List<SoftSaaSInspectorToggleOption<T>> overflowOptions;
  final ValueChanged<T> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final overflowMatch = overflowOptions
        .where((o) => o.value == value)
        .firstOrNull;
    final overflowSelected = overflowMatch != null;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: SoftSaaSTokens.secondaryBackground(brightness),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: SoftSaaSTokens.primaryBorder(brightness)),
        ),
        padding: const EdgeInsets.all(2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final o in primaryOptions)
              _ToggleChip(
                icon: o.icon,
                tooltip: o.tooltip,
                selected: o.value == value,
                enabled: enabled,
                brightness: brightness,
                onTap: () => onChanged(o.value),
              ),
            if (overflowOptions.isNotEmpty)
              _OverflowChip(
                icon: overflowMatch?.icon ?? LucideIcons.ellipsis_vertical,
                tooltip: overflowMatch?.tooltip ?? 'More options',
                selected: overflowSelected,
                enabled: enabled,
                brightness: brightness,
                overflowOptions: overflowOptions,
                currentValue: value,
                onSelected: onChanged,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Primary toggle chip ────────────────────────────────────────────────

class _ToggleChip extends StatefulWidget {
  const _ToggleChip({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.enabled,
    required this.brightness,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool selected;
  final bool enabled;
  final Brightness brightness;
  final VoidCallback onTap;

  @override
  State<_ToggleChip> createState() => _ToggleChipState();
}

class _ToggleChipState extends State<_ToggleChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return _chipShell(
      selected: widget.selected,
      hovered: _hovered,
      brightness: widget.brightness,
      enabled: widget.enabled,
      tooltip: widget.tooltip,
      onEnter: () => setState(() => _hovered = true),
      onExit: () => setState(() => _hovered = false),
      onTap: widget.onTap,
      child: Icon(
        widget.icon,
        size: 14,
        color: widget.selected
            ? (widget.brightness == Brightness.dark
                  ? SoftSaaSTokens.primaryText(widget.brightness)
                  : SoftSaaSTokens.secondaryText(widget.brightness))
            : SoftSaaSTokens.secondaryText(widget.brightness),
      ),
    );
  }
}

// ── Overflow chip ──────────────────────────────────────────────────────

class _OverflowChip<T> extends StatefulWidget {
  const _OverflowChip({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.enabled,
    required this.brightness,
    required this.overflowOptions,
    required this.currentValue,
    required this.onSelected,
  });

  final IconData icon;
  final String tooltip;
  final bool selected;
  final bool enabled;
  final Brightness brightness;
  final List<SoftSaaSInspectorToggleOption<T>> overflowOptions;
  final T currentValue;
  final ValueChanged<T> onSelected;

  @override
  State<_OverflowChip<T>> createState() => _OverflowChipState<T>();
}

class _OverflowChipState<T> extends State<_OverflowChip<T>> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return ssd.SoftSaaSMenuDropdown(
      alignment: ssd.SoftSaaSMenuDropdownAlignment.end,
      width: 140,
      verticalOffset: 4,
      items: [
        for (final o in widget.overflowOptions)
          ssd.DropdownMenuItem(
            label: o.tooltip,
            icon: o.icon,
            onTap: () => widget.onSelected(o.value),
          ),
      ],
      trigger: _chipShell(
        selected: widget.selected,
        hovered: _hovered,
        brightness: widget.brightness,
        enabled: widget.enabled,
        tooltip: widget.tooltip,
        onEnter: () => setState(() => _hovered = true),
        onExit: () => setState(() => _hovered = false),
        onTap: null,
        // When nothing from the overflow menu is selected the chip shows
        // the vertical 3-dots — a visually neutral affordance. Drop it to
        // 20px and let the icon carry the width so the row stays compact.
        width: widget.selected ? 32 : 20,
        child: Icon(
          widget.icon,
          size: 14,
          color: widget.selected
              ? (widget.brightness == Brightness.dark
                    ? SoftSaaSTokens.primaryText(widget.brightness)
                    : SoftSaaSTokens.secondaryText(widget.brightness))
              : SoftSaaSTokens.secondaryText(widget.brightness),
        ),
      ),
    );
  }
}

// ── Shared chip shell ──────────────────────────────────────────────────

Widget _chipShell({
  required bool selected,
  required bool hovered,
  required Brightness brightness,
  required bool enabled,
  required String tooltip,
  required VoidCallback onEnter,
  required VoidCallback onExit,
  required VoidCallback? onTap,
  required Widget child,
  double width = 32,
}) {
  final bg = selected
      ? (brightness == Brightness.dark
            ? SoftSaaSTokens.tertiaryBackground(brightness)
            : Colors.white)
      : (hovered
            ? SoftSaaSTokens.controlHoverOverlay(brightness)
            : Colors.transparent);

  final border = selected
      ? Border.all(color: SoftSaaSTokens.primaryBorder(brightness))
      : null;

  Widget chip = Container(
    width: width,
    height: double.infinity,
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(6),
      border: border,
      boxShadow: selected
          ? (brightness == Brightness.dark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ])
          : null,
    ),
    alignment: Alignment.center,
    child: child,
  );

  if (onTap != null) {
    chip = GestureDetector(onTap: enabled ? onTap : null, child: chip);
  }

  return Tooltip(
    message: tooltip,
    child: MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => onEnter(),
      onExit: (_) => onExit(),
      child: chip,
    ),
  );
}
