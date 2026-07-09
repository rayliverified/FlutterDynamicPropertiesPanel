import 'package:flutter/material.dart';

import '../models/property_preset.dart';

/// Shows a dialog to save the current configuration as a preset.
///
/// If [selectedPresetId] refers to a non-default preset, the dialog
/// pre-populates with that preset's name and description for easy overwrite.
/// Otherwise it auto-generates "Preset N" as the default name.
Future<void> showSavePresetDialog(
  BuildContext context, {
  required String? selectedPresetId,
  required List<PropertyPreset>? presets,
  required void Function(String name, String description) onSave,
}) async {
  final presetCount = (presets ?? []).where((p) => p.id != 'default').length;
  String defaultName = 'Preset ${presetCount + 1}';
  String defaultDesc = '';

  if (selectedPresetId != null && selectedPresetId != 'default') {
    final preset = presets?.firstWhere(
      (p) => p.id == selectedPresetId,
      orElse: () => PropertyPreset(id: '', name: defaultName, values: const {}),
    );
    if (preset != null && preset.id.isNotEmpty) {
      defaultName = preset.name;
      defaultDesc = preset.description ?? '';
    }
  }

  return showDialog(
    context: context,
    builder: (context) {
      final nameController = TextEditingController(text: defaultName);
      final descController = TextEditingController(text: defaultDesc);

      return AlertDialog(
        title: const Text('Save Preset'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Preset Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                Navigator.pop(context);
                onSave(nameController.text, descController.text);
              }
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}

/// Shows a confirmation dialog before deleting a preset.
Future<void> showDeletePresetDialog(
  BuildContext context, {
  required PropertyPreset preset,
  required VoidCallback onDelete,
}) async {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Preset'),
      content: Text('Delete "${preset.name}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            onDelete();
          },
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
          ),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
