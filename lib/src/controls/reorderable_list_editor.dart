library;

import 'bound_text_input.dart';
import '../models/dynamic_property_definition.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

class ReorderableListEditor extends StatelessWidget {
  const ReorderableListEditor({
    super.key,
    required this.items,
    required this.itemKind,
    required this.onChanged,
  });

  final List<dynamic> items;
  final DynamicPropertyKind itemKind;
  final ValueChanged<List<dynamic>> onChanged;

  static dynamic _defaultValueForKind(DynamicPropertyKind kind) {
    switch (kind) {
      case DynamicPropertyKind.integer:
        return 0;
      case DynamicPropertyKind.double:
        return 0.0;
      case DynamicPropertyKind.boolean:
        return false;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SoftSaaSReorderableList(
      itemCount: items.length,
      onReorder: (oldIndex, newIndex) {
        final updated = List<dynamic>.from(items);
        if (newIndex > oldIndex) newIndex--;
        final item = updated.removeAt(oldIndex);
        updated.insert(newIndex, item);
        onChanged(updated);
      },
      onAdd: () => onChanged([...items, _defaultValueForKind(itemKind)]),
      itemBuilder: (context, index) {
        return SoftSaaSReorderableListItem(
          key: ValueKey('item_$index'),
          index: index,
          onRemove: () {
            final updated = List<dynamic>.from(items)..removeAt(index);
            onChanged(updated);
          },
          child: _buildInput(items[index], index),
        );
      },
    );
  }

  Widget _buildInput(dynamic item, int index) {
    void updateItem(dynamic next) {
      final updated = List<dynamic>.from(items);
      updated[index] = next;
      onChanged(updated);
    }

    switch (itemKind) {
      case DynamicPropertyKind.boolean:
        return Align(
          alignment: Alignment.centerLeft,
          child: SoftSaaSSwitch(
            value: item is bool ? item : false,
            size: SoftSaaSCheckboxSize.small,
            onChanged: updateItem,
          ),
        );
      case DynamicPropertyKind.integer:
      case DynamicPropertyKind.double:
        return SoftSaaSNumberInput(
          value: item is num ? item.toDouble() : 0,
          width: double.infinity,
          size: SoftSaaSNumberInputSize.small,
          onChanged: (next) => updateItem(
            itemKind == DynamicPropertyKind.integer ? next?.round() : next,
          ),
        );
      default:
        return BoundTextInput(
          value: item?.toString() ?? '',
          hintText: 'Item value',
          onChanged: (next) => updateItem(next),
        );
    }
  }
}
