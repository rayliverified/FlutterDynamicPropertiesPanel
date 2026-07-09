import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

/// A collapsible section wrapper for complex property controls.
///
/// Delegates to [SoftSaaSExpandable] for consistent panel styling.
class PropertySection extends StatefulWidget {
  const PropertySection({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.isModified = false,
    this.defaultOpen = true,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool isModified;
  final bool defaultOpen;
  final Widget child;

  @override
  State<PropertySection> createState() => _PropertySectionState();
}

class _PropertySectionState extends State<PropertySection> {
  late bool _isOpen;

  @override
  void initState() {
    super.initState();
    _isOpen = widget.defaultOpen;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return SoftSaaSExpandable(
      isOpen: _isOpen,
      onToggle: () => setState(() => _isOpen = !_isOpen),
      title: widget.title,
      trailing: widget.isModified
          ? Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: SoftSaaSTokens.primaryColor(brightness),
                shape: BoxShape.circle,
              ),
            )
          : null,
      child: widget.child,
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// LABELED FIELD
// ══════════════════════════════════════════════════════════════════════

/// A labeled field with optional hint text.
///
/// Inspector-style: compact label above, child below.
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.child,
    this.hint,
  });

  final String label;
  final Widget child;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: SoftSaaSTokens.secondaryText(brightness),
              ),
            ),
            if (hint != null) ...[
              const SizedBox(width: 4),
              Text(
                hint!,
                style: TextStyle(
                  fontSize: 9,
                  color: SoftSaaSTokens.tertiaryText(brightness),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// NUMBER FIELD — Inspector-style labeled number input with stepper
// ══════════════════════════════════════════════════════════════════════

/// A compact labeled number input row.
///
/// Inspector-style: label on left, [SoftSaaSNumberInput] on right.
/// This is the primary numeric input pattern for property panels.
class NumberField extends StatelessWidget {
  const NumberField({
    super.key,
    required this.label,
    required this.value,
    this.min,
    this.max,
    this.step,
    this.suffix,
    this.onChanged,
  });

  final String label;
  final double? value;
  final double? min;
  final double? max;
  final double? step;
  final String? suffix;
  final ValueChanged<double?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            suffix != null ? '$label ($suffix)' : label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: SoftSaaSTokens.secondaryText(brightness),
            ),
          ),
        ),
        Expanded(
          child: SoftSaaSNumberInput(
            value: value,
            min: min,
            max: max,
            step: step ?? 1,
            width: double.infinity,
            size: SoftSaaSNumberInputSize.small,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// PRESET BUTTON GROUP
// ══════════════════════════════════════════════════════════════════════

/// A row of preset buttons for quick value selection.
///
/// Inspector-style: compact pill buttons with selected state highlight.
class PresetButtonGroup extends StatelessWidget {
  const PresetButtonGroup({
    super.key,
    required this.presets,
    required this.currentValue,
    required this.onSelected,
  });

  final List<PresetOption> presets;
  final dynamic currentValue;
  final ValueChanged<dynamic> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: presets.map((preset) {
        final isSelected =
            preset.matches?.call(currentValue) ?? preset.value == currentValue;
        return _PresetChip(
          label: preset.label,
          icon: preset.icon,
          isSelected: isSelected,
          onPressed: () => onSelected(preset.value),
        );
      }).toList(),
    );
  }
}

/// A single preset option.
class PresetOption {
  const PresetOption({
    required this.label,
    required this.value,
    this.icon,
    this.matches,
  });

  final String label;
  final dynamic value;
  final IconData? icon;
  final bool Function(dynamic)? matches;
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onPressed,
  });

  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    final bgColor = isSelected
        ? SoftSaaSTokens.primaryColor(brightness).withValues(alpha: 0.12)
        : SoftSaaSTokens.tertiaryBackground(brightness);
    final fgColor = isSelected
        ? SoftSaaSTokens.primaryColor(brightness)
        : SoftSaaSTokens.secondaryText(brightness);
    final borderColor = isSelected
        ? SoftSaaSTokens.primaryColor(brightness).withValues(alpha: 0.3)
        : SoftSaaSTokens.primaryBorder(brightness);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 11, color: fgColor),
              const SizedBox(width: 3),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: fgColor,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// TOGGLE CHIP
// ══════════════════════════════════════════════════════════════════════

/// A compact toggle button for bold, italic, underline, etc.
///
/// Inspector-style: icon-first toggle with optional label.
class ToggleChip extends StatelessWidget {
  const ToggleChip({
    super.key,
    required this.label,
    this.icon,
    required this.isActive,
    required this.onPressed,
  });

  final String label;
  final IconData? icon;
  final bool isActive;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    final bgColor = isActive
        ? SoftSaaSTokens.primaryColor(brightness).withValues(alpha: 0.12)
        : SoftSaaSTokens.tertiaryBackground(brightness);
    final fgColor = isActive
        ? SoftSaaSTokens.primaryColor(brightness)
        : SoftSaaSTokens.secondaryText(brightness);
    final borderColor = isActive
        ? SoftSaaSTokens.primaryColor(brightness).withValues(alpha: 0.3)
        : SoftSaaSTokens.primaryBorder(brightness);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: fgColor),
              if (label.isNotEmpty) const SizedBox(width: 3),
            ],
            if (label.isNotEmpty)
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: fgColor,
                  height: 1.0,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// INLINE NUMBER INPUT
// ══════════════════════════════════════════════════════════════════════

/// A compact number input for use in grid layouts.
///
/// Used by border_radius and edge_insets for per-corner/edge inputs.
class InlineNumberInput extends StatelessWidget {
  const InlineNumberInput({
    super.key,
    this.label,
    required this.value,
    this.onChanged,
  });

  final String? label;
  final double value;
  final ValueChanged<double?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SoftSaaSNumberInput(
          value: value,
          width: double.infinity,
          size: SoftSaaSNumberInputSize.small,
          onChanged: onChanged,
        ),
        if (label != null) ...[
          const SizedBox(height: 1),
          Text(
            label!,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: SoftSaaSTokens.tertiaryText(brightness),
              height: 1.0,
            ),
          ),
        ],
      ],
    );
  }
}
