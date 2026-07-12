import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

import '../models/dynamic_property_definition.dart';
import 'icon_control.dart';

/// Control for editing `Map<String, dynamic>` values.
///
/// Inspector-style: compact bordered container with header row,
/// key-value pairs, and add/remove actions.
class MapControl extends StatefulWidget {
  const MapControl({
    super.key,
    required this.value,
    required this.onChanged,
    this.valueDefinition,
  });

  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final DynamicPropertyDefinition? valueDefinition;

  @override
  State<MapControl> createState() => _MapControlState();
}

class _MapControlState extends State<MapControl> {
  late Map<String, dynamic> _entries;

  @override
  void initState() {
    super.initState();
    _entries = _parseMap(widget.value);
  }

  @override
  void didUpdateWidget(covariant MapControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _entries = _parseMap(widget.value);
    }
  }

  void _emit() {
    widget.onChanged(Map<String, dynamic>.from(_entries));
  }

  void _addEntry() {
    setState(() {
      var key = 'key${_entries.length}';
      var i = 1;
      while (_entries.containsKey(key)) {
        key = 'key${_entries.length + i}';
        i++;
      }
      _entries[key] = widget.valueDefinition?.defaultValue;
    });
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final border = SoftSaaSTokens.primaryBorder(brightness);

    return Container(
      decoration: BoxDecoration(
        color: SoftSaaSTokens.primaryBackground(brightness),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(10, 5, 6, 5),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: border)),
            ),
            child: Row(
              children: [
                Text(
                  'Map',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: SoftSaaSTokens.secondaryText(brightness),
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: SoftSaaSTokens.tertiaryBackground(brightness),
                    borderRadius: BorderRadius.circular(
                      SoftSaaSTokens.radiusFull,
                    ),
                  ),
                  child: Text(
                    '${_entries.length}',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: SoftSaaSTokens.fontWeightSemibold,
                      color: SoftSaaSTokens.secondaryText(brightness),
                    ),
                  ),
                ),
                const Spacer(),
                SoftSaaSIconButton(
                  icon: Icons.add,
                  size: SoftSaaSButtonSize.small,
                  variant: SoftSaaSIconButtonVariant.ghost,
                  iconColor: SoftSaaSTokens.tertiaryText(brightness),
                  onPressed: _addEntry,
                ),
              ],
            ),
          ),

          // Entries
          if (_entries.isEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'Empty',
                style: TextStyle(
                  fontSize: 11,
                  color: SoftSaaSTokens.tertiaryText(brightness),
                ),
              ),
            )
          else
            ..._entries.entries.map(
              (entry) => _buildEntry(entry.key, entry.value),
            ),
        ],
      ),
    );
  }

  Widget _buildEntry(String key, dynamic value) {
    final brightness = Theme.of(context).brightness;
    final border = SoftSaaSTokens.primaryBorder(brightness);

    return Container(
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: _MapEntryTextField(
              key: ValueKey('map-key-$key'),
              text: key,
              hintText: 'key',
              onChanged: (newKey) {
                if (newKey.isEmpty || newKey == key) return;
                if (_entries.containsKey(newKey)) return;

                final val = _entries.remove(key);
                setState(() {
                  _entries[newKey] = val;
                });
                _emit();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              ':',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: SoftSaaSTokens.tertiaryText(brightness),
              ),
            ),
          ),
          Expanded(child: _buildValueControl(key, value)),
          SoftSaaSIconButton(
            icon: Icons.close,
            size: SoftSaaSButtonSize.small,
            variant: SoftSaaSIconButtonVariant.ghost,
            iconColor: SoftSaaSTokens.tertiaryText(brightness),
            onPressed: () {
              setState(() => _entries.remove(key));
              _emit();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildValueControl(String key, dynamic value) {
    final definition = widget.valueDefinition;
    if (definition?.kind == DynamicPropertyKind.icon ||
        definition?.kind == DynamicPropertyKind.iconSwatch) {
      final allowedIcons = definition?.bounds?['allowedIcons'];
      return Align(
        alignment: Alignment.centerLeft,
        child: IconControl(
          key: ValueKey('map-value-$key'),
          value: value?.toString(),
          allowedIcons: allowedIcons is List
              ? allowedIcons.map((icon) => icon.toString()).toList()
              : null,
          onChanged: (newValue) {
            _entries[key] = newValue;
            _emit();
          },
        ),
      );
    }

    return _MapEntryTextField(
      key: ValueKey('map-value-$key'),
      text: value is String ? value : (value?.toString() ?? ''),
      hintText: 'value',
      onChanged: (newVal) {
        _entries[key] = newVal;
        _emit();
      },
    );
  }

  static Map<String, dynamic> _parseMap(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }
}

class _MapEntryTextField extends StatefulWidget {
  const _MapEntryTextField({
    super.key,
    required this.text,
    required this.hintText,
    required this.onChanged,
  });

  final String text;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  State<_MapEntryTextField> createState() => _MapEntryTextFieldState();
}

class _MapEntryTextFieldState extends State<_MapEntryTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  void didUpdateWidget(covariant _MapEntryTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text && widget.text != _controller.text) {
      _controller.text = widget.text;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SoftSaaSTextInput(
      controller: _controller,
      hintText: widget.hintText,
      size: SoftSaaSTextInputSize.small,
      onChanged: widget.onChanged,
    );
  }
}
