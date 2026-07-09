import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

import '../models/property_preset.dart';

/// Toolbar for managing configuration presets.
///
/// Provides a dropdown selector for switching between presets, plus
/// save, reset, and delete actions. A blue modification dot indicates
/// unsaved changes relative to the selected preset.
///
/// Styled to match [BreadcrumbBar] — full-width strip with matching
/// background and bottom border.
class PresetToolbar extends StatelessWidget {
  const PresetToolbar({
    super.key,
    required this.presets,
    required this.selectedPresetId,
    required this.onPresetChanged,
    this.onSave,
    this.onReset,
    this.onDelete,
    required this.hasModifications,
  });

  final List<PropertyPreset> presets;
  final String? selectedPresetId;
  final ValueChanged<String?> onPresetChanged;
  final VoidCallback? onSave;
  final VoidCallback? onReset;
  final VoidCallback? onDelete;
  final bool hasModifications;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final dark = brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, right: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(
        // Match BreadcrumbBar background exactly
        color: dark ? const Color(0xFF0A0A0A) : const Color(0xFFF9FAFB),
        border: Border(
          bottom: BorderSide(
            color: dark ? const Color(0xFF2A2A2A) : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Row(
        children: [
          // Preset dropdown
          Expanded(child: _buildDropdown(context)),
          const SizedBox(width: 6),

          // Save
          SoftSaaSIconButton(
            icon: LucideIcons.bookmark_plus,
            tooltip: onSave == null ? 'No changes to save' : 'Save as preset',
            variant: SoftSaaSIconButtonVariant.ghost,
            onPressed: onSave,
          ),

          // Reset
          SoftSaaSIconButton(
            icon: LucideIcons.rotate_ccw,
            tooltip: onReset == null
                ? 'No changes to reset'
                : 'Reset to preset values',
            variant: SoftSaaSIconButtonVariant.ghost,
            onPressed: onReset,
          ),

          // Delete — gray by default, always red on hover
          SoftSaaSIconButton(
            icon: LucideIcons.trash_2,
            tooltip: _canDelete
                ? 'Delete current preset'
                : 'Cannot delete default preset',
            variant: SoftSaaSIconButtonVariant.ghost,
            hoverIconColor: const Color(0xFFEF4444),
            onPressed: _canDelete ? onDelete : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(BuildContext context) {
    final options = presets
        .map(
          (p) => SelectOption(
            value: p.id,
            label: p.name,
            labelStyle: p.id == 'default'
                ? const TextStyle(fontWeight: FontWeight.w600)
                : null,
          ),
        )
        .toList();

    return SoftSaaSDropdown(
      value: selectedPresetId,
      options: options,
      selectedLeading: hasModifications
          ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: _ModifiedDot(),
            )
          : null,
      placeholder: 'Select preset',
      size: SoftSaaSSelectSize.small,
      onChanged: (id) => onPresetChanged(id),
    );
  }

  bool get _canDelete =>
      selectedPresetId != null && selectedPresetId != 'default';
}

class _ModifiedDot extends StatelessWidget {
  const _ModifiedDot();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: SoftSaaSTokens.primaryColor(brightness),
        shape: BoxShape.circle,
      ),
    );
  }
}
