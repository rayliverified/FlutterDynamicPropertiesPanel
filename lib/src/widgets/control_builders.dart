part of 'dynamic_properties_panel.dart';

// ══════════════════════════════════════════════════════════════════════
// Control builder methods (extension on state)
// ══════════════════════════════════════════════════════════════════════

extension _DppStateControlBuilders on _DynamicPropertiesPanelState {
  // ── Control Switch ─────────────────────────────────────────────────

  Widget _buildControl(DynamicPropertyDefinition property, dynamic value) {
    switch (property.kind) {
      case DynamicPropertyKind.string:
        return _buildStringControl(property, value);
      case DynamicPropertyKind.integer:
      case DynamicPropertyKind.double:
        return _buildNumberControl(property, value);
      case DynamicPropertyKind.boolean:
        return const SizedBox.shrink(); // handled in _buildPropertyRow
      case DynamicPropertyKind.enumValue:
        return _buildEnumControl(property, value);
      case DynamicPropertyKind.multiEnum:
        return _buildMultiEnumControl(property, value);
      case DynamicPropertyKind.object:
        return _buildObjectControl(property, value);
      case DynamicPropertyKind.array:
        return _buildArrayControl(property, value);
      case DynamicPropertyKind.map:
        return _buildMapControl(property, value);
      case DynamicPropertyKind.icon:
        return _buildIconControl(property, value);
      case DynamicPropertyKind.iconSwatch:
        return _buildIconSwatchControl(property, value);
      case DynamicPropertyKind.color:
        return _buildColorControl(property, value);
      case DynamicPropertyKind.colorSwatch:
        return _buildColorSwatchControl(property, value);
      case DynamicPropertyKind.date:
        return _buildDateControl(property, value);
      case DynamicPropertyKind.duration:
        return _buildDurationControl(property, value);
      case DynamicPropertyKind.slider:
        return _buildSliderControl(property, value);
      case DynamicPropertyKind.alignment:
        return _buildAlignmentControl(property, value);
      case DynamicPropertyKind.edgeInsets:
        return _buildEdgeInsetsControl(property, value);
      case DynamicPropertyKind.borderRadius:
        return _buildBorderRadiusControl(property, value);
      case DynamicPropertyKind.boxConstraints:
        return _buildBoxConstraintsControl(property, value);
      case DynamicPropertyKind.textStyle:
        return _buildTextStyleControl(property, value);
      case DynamicPropertyKind.mainAxisAlignment:
        return _buildMainAxisAlignmentControl(property, value);
      case DynamicPropertyKind.crossAxisAlignment:
        return _buildCrossAxisAlignmentControl(property, value);
      case DynamicPropertyKind.mainAxisSize:
        return _buildMainAxisSizeControl(property, value);
      case DynamicPropertyKind.axis:
        return _buildAxisControl(property, value);
      case DynamicPropertyKind.textAlign:
        return _buildTextAlignControl(property, value);
      case DynamicPropertyKind.size:
        return _buildSizeControl(property, value);
      case DynamicPropertyKind.rotation:
        return _buildRotationControl(property, value);
      case DynamicPropertyKind.widget:
        return _buildWidgetSlotControl(property, value);
      case DynamicPropertyKind.widgetList:
        return _buildWidgetListSlotControl(property, value);
      case DynamicPropertyKind.json:
      case DynamicPropertyKind.unknown:
        return _buildJsonControl(property, value);
    }
  }

  // ── String ───────────────────────────────────────────────────────

  Widget _buildStringControl(
    DynamicPropertyDefinition property,
    dynamic value,
  ) {
    final maxLength = property.bounds?['maxLength'] as int?;
    final suggestions = property.suggestions;

    void commit(String next) {
      String validated = next;
      if (maxLength != null && validated.length > maxLength) {
        validated = validated.substring(0, maxLength);
      }
      _setValue(property.name, validated);
    }

    if (suggestions != null && suggestions.isNotEmpty) {
      return SuggestionsComboControl(
        initialValue: value?.toString() ?? '',
        suggestions: suggestions,
        hintText: 'Enter ${property.label.toLowerCase()}',
        onChanged: commit,
      );
    }

    return BoundTextInput(
      value: value?.toString() ?? '',
      hintText: 'Enter ${property.label.toLowerCase()}',
      onChanged: commit,
    );
  }

  // ── Number ───────────────────────────────────────────────────────

  Widget _buildNumberControl(
    DynamicPropertyDefinition property,
    dynamic value,
  ) {
    final isInteger = property.kind == DynamicPropertyKind.integer;
    final minimum = _toDouble(property.bounds?['minimum']);
    final maximum = _toDouble(property.bounds?['maximum']);
    final step = _toDouble(property.bounds?['step']) ?? (isInteger ? 1 : 1);
    final decimalPlaces = property.bounds?['decimalPlaces'] as int?;
    final suffix = property.bounds?['suffix'] as String?;
    return SoftSaaSNumberInput(
      value: _toDouble(value),
      min: minimum,
      max: maximum,
      step: step,
      decimalPlaces: isInteger ? 0 : decimalPlaces,
      suffix: suffix,
      width: double.infinity,
      size: SoftSaaSNumberInputSize.small,
      // Both drag ticks and commits write through — every change fires
      // listeners and the commits stream. Hosts that persist should debounce.
      onDragUpdate: (next) =>
          _setValue(property.name, isInteger ? next?.round() : next),
      onChanged: (next) =>
          _setValue(property.name, isInteger ? next?.round() : next),
    );
  }

  // ── Enum ─────────────────────────────────────────────────────────

  Widget _buildEnumControl(DynamicPropertyDefinition property, dynamic value) {
    final options = property.enumValues ?? const [];
    final selected = options.contains(value)
        ? value
        : (options.isNotEmpty ? options.first : null);
    return SoftSaaSDropdown(
      value: selected?.toString(),
      options: options
          .map(
            (o) => SelectOption(
              value: o.toString(),
              label: property.enumLabels?[o.toString()] ?? o.toString(),
            ),
          )
          .toList(),
      placeholder: 'Select...',
      size: SoftSaaSSelectSize.small,
      onChanged: (next) {
        final original = options.cast<dynamic>().firstWhere(
          (o) => o.toString() == next,
          orElse: () => next as dynamic,
        );
        _setValue(property.name, original);
      },
    );
  }

  // ── Multi-Enum ───────────────────────────────────────────────────

  Widget _buildMultiEnumControl(
    DynamicPropertyDefinition property,
    dynamic value,
  ) {
    final listValue = value is List ? List<dynamic>.from(value) : <dynamic>[];
    return MultiSelectControl(
      values: listValue,
      options: property.enumValues ?? const [],
      labels: property.enumLabels,
      iconNames: property.enumIconNames,
      manager: _manager,
      onChanged: (updated) => _setValue(property.name, updated),
    );
  }

  // ── Object ───────────────────────────────────────────────────────

  Widget _buildObjectControl(
    DynamicPropertyDefinition property,
    dynamic value,
  ) {
    final objectValue = value is Map
        ? _deepCopyMap(Map<String, dynamic>.from(value))
        : <String, dynamic>{};

    final nestedDefinitions =
        property.properties ??
        objectValue.entries
            .map(
              (entry) => DynamicPropertyDefinition(
                name: entry.key,
                kind: _inferKindFromRuntime(entry.value),
                defaultValue: entry.value,
              ),
            )
            .toList();

    if (nestedDefinitions.isEmpty || widget.depth >= 3) {
      return JsonTextBox(
        value: objectValue,
        onChanged: (next) => _setValue(property.name, next),
      );
    }

    return DynamicPropertiesPanel(
      values: objectValue,
      properties: nestedDefinitions,
      isDark: _isDark,
      showContainer: false,
      showResetButtons: widget.showResetButtons,
      showBreadcrumbs: false,
      smartLayout: widget.smartLayout,
      padding: const EdgeInsets.only(left: 16, top: 8),
      onChanged: (updated) => _setValue(property.name, updated),
      manager: _manager,
      depth: widget.depth + 1,
    );
  }

  // ── Array ────────────────────────────────────────────────────────

  Widget _buildArrayControl(DynamicPropertyDefinition property, dynamic value) {
    final listValue = value is List ? List<dynamic>.from(value) : <dynamic>[];
    final itemKind = property.item?.kind;

    final isPrimitive =
        itemKind == null ||
        itemKind == DynamicPropertyKind.string ||
        itemKind == DynamicPropertyKind.integer ||
        itemKind == DynamicPropertyKind.double ||
        itemKind == DynamicPropertyKind.boolean;

    if (!isPrimitive) {
      return JsonTextBox(
        value: listValue,
        onChanged: (next) => _setValue(property.name, next),
      );
    }

    return ReorderableListEditor(
      items: listValue,
      itemKind: itemKind ?? DynamicPropertyKind.string,
      onChanged: (updated) => _setValue(property.name, updated),
    );
  }

  // ── Map ──────────────────────────────────────────────────────────

  Widget _buildMapControl(DynamicPropertyDefinition property, dynamic value) {
    return MapControl(
      value: value,
      onChanged: (updated) => _setValue(property.name, updated),
    );
  }

  // ── Color ────────────────────────────────────────────────────────

  Widget _buildColorControl(DynamicPropertyDefinition property, dynamic value) {
    final showOpacity = property.bounds?['showOpacity'] as bool? ?? false;
    final colorValue = _parseColor(value);
    return ColorControl(
      value: colorValue,
      showOpacity: showOpacity,
      onChanged: (color) {
        if (color != null) {
          _setValue(property.name, _colorToHex(color));
        }
      },
    );
  }

  // ── Icon ─────────────────────────────────────────────────────────

  Widget _buildIconControl(DynamicPropertyDefinition property, dynamic value) {
    final allowedIcons = property.bounds?['allowedIcons']?.cast<String>();
    final iconName = value is String ? value : property.iconName;

    // Standard selector row (dropdown-style trigger). The underlying
    // SoftSaaSIconPicker popover is already the shared Inspector grid variant.
    return IconControl(
      value: iconName,
      allowedIcons: allowedIcons,
      manager: _manager,
      onChanged: (name) => _setValue(property.name, name),
    );
  }

  Widget _buildIconSwatchControl(
    DynamicPropertyDefinition property,
    dynamic value,
  ) {
    final allowedIcons = property.bounds?['allowedIcons']?.cast<String>();
    final iconName = value is String ? value : property.iconName;
    final registry = _manager.iconRegistry;
    final names = allowedIcons ?? registry.allNames;
    final entries = <SoftSaaSIconPickerInspectorEntry>[];
    for (final name in names) {
      final icon = registry.getIcon(name);
      if (icon != null) {
        entries.add(SoftSaaSIconPickerInspectorEntry(name: name, icon: icon));
      }
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: SoftSaaSIconSwatchInspector(
        value: iconName,
        icons: entries,
        onChanged: (name) => _setValue(property.name, name),
      ),
    );
  }

  Widget _buildColorSwatchControl(
    DynamicPropertyDefinition property,
    dynamic value,
  ) {
    final colorValue = _parseColor(value);
    return Align(
      alignment: Alignment.centerLeft,
      child: ColorSwatchControl(
        value: colorValue,
        onChanged: (color) {
          if (color != null) {
            _setValue(property.name, _colorToHex(color));
          }
        },
      ),
    );
  }

  // ── Widget Slot ──────────────────────────────────────────────────

  Widget _buildWidgetSlotControl(
    DynamicPropertyDefinition property,
    dynamic value,
  ) {
    return ComponentSlotControl(
      value: value,
      parameterName: property.name,
      allowNull: true,
      manager: _manager,
      onChanged: (updated) => _setValue(property.name, updated),
    );
  }

  // ── Widget List Slot ─────────────────────────────────────────────

  Widget _buildWidgetListSlotControl(
    DynamicPropertyDefinition property,
    dynamic value,
  ) {
    final listValue = value is List ? List<dynamic>.from(value) : <dynamic>[];
    final maximum = (property.bounds?['maximum'] as num?)?.toInt();

    // Editable List<Widget> values use the shared list shell. Reserve a plain
    // Column of ComponentSlotControls for a fixed set of distinct widget slots
    // that are not an editable list.
    return SoftSaaSReorderableList(
      itemCount: listValue.length,
      onAdd: maximum == null || listValue.length < maximum
          ? () => _setValue(property.name, [...listValue, null])
          : null,
      onReorder: (oldIndex, newIndex) {
        final updated = List<dynamic>.from(listValue);
        if (newIndex > oldIndex) newIndex--;
        final item = updated.removeAt(oldIndex);
        updated.insert(newIndex, item);
        _setValue(property.name, updated);
      },
      itemBuilder: (context, index) => SoftSaaSReorderableListItem(
        key: ValueKey('${property.name}_$index'),
        index: index,
        onRemove: () {
          final updated = List<dynamic>.from(listValue)..removeAt(index);
          _setValue(property.name, updated);
        },
        child: ComponentSlotControl(
          value: listValue[index],
          parameterName: '${property.name}[$index]',
          allowNull: true,
          manager: _manager,
          onChanged: (updatedValue) {
            final updated = List<dynamic>.from(listValue);
            updated[index] = updatedValue;
            _setValue(property.name, updated);
          },
        ),
      ),
    );
  }

  // ── Alignment ────────────────────────────────────────────────────

  Widget _buildAlignmentControl(
    DynamicPropertyDefinition property,
    dynamic value,
  ) {
    return AlignmentControl(
      value: value,
      onChanged: (next) => _setValue(property.name, next),
    );
  }

  // ── EdgeInsets ───────────────────────────────────────────────────

  Widget _buildEdgeInsetsControl(
    DynamicPropertyDefinition property,
    dynamic value,
  ) {
    return EdgeInsetsControl(
      value: value,
      onChanged: (next) => _setValue(property.name, next),
    );
  }

  // ── BorderRadius ─────────────────────────────────────────────────

  Widget _buildBorderRadiusControl(
    DynamicPropertyDefinition property,
    dynamic value,
  ) {
    return BorderRadiusControl(
      value: value,
      onChanged: (next) => _setValue(property.name, next),
    );
  }

  // ── BoxConstraints ───────────────────────────────────────────────

  Widget _buildBoxConstraintsControl(
    DynamicPropertyDefinition property,
    dynamic value,
  ) {
    return BoxConstraintsControl(
      value: value,
      onChanged: (next) => _setValue(property.name, next),
    );
  }

  // ── TextStyle ────────────────────────────────────────────────────

  Widget _buildTextStyleControl(
    DynamicPropertyDefinition property,
    dynamic value,
  ) {
    return TextStyleControl(
      value: value,
      onChanged: (next) => _setValue(property.name, next),
    );
  }

  // ── Date ─────────────────────────────────────────────────────────

  Widget _buildDateControl(DynamicPropertyDefinition property, dynamic value) {
    return DateControl(
      value: value,
      onChanged: (next) => _setValue(property.name, next),
    );
  }

  // ── Duration ─────────────────────────────────────────────────────

  Widget _buildDurationControl(
    DynamicPropertyDefinition property,
    dynamic value,
  ) {
    return DurationControl(
      value: value,
      onChanged: (next) => _setValue(property.name, next),
    );
  }

  // ── Slider ────────────────────────────────────────────────────────

  Widget _buildSliderControl(
    DynamicPropertyDefinition property,
    dynamic value,
  ) {
    final minimum = _toDouble(property.bounds?['minimum']) ?? 0.0;
    final maximum = _toDouble(property.bounds?['maximum']) ?? 100.0;
    final suffix = property.bounds?['suffix'] as String?;
    final decimalPlaces = property.bounds?['decimalPlaces'] as int?;
    return SliderControl(
      value: value,
      min: minimum,
      max: maximum,
      suffix: suffix,
      decimalPlaces: decimalPlaces,
      onChanged: (v) => _setValue(property.name, v),
    );
  }

  // ── JSON / Unknown ───────────────────────────────────────────────

  Widget _buildJsonControl(DynamicPropertyDefinition property, dynamic value) {
    return JsonViewEditBox(
      value: value,
      onChanged: (next) => _setValue(property.name, next),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Segmented / picker control builders (extension on state)
// ══════════════════════════════════════════════════════════════════════

extension _DppStateSegmentedControlBuilders on _DynamicPropertiesPanelState {
  Widget _buildMainAxisAlignmentControl(
    DynamicPropertyDefinition property,
    dynamic value,
  ) {
    return MainAxisAlignmentControl(
      value: value,
      onChanged: (next) => _setValue(property.name, next),
    );
  }

  Widget _buildCrossAxisAlignmentControl(
    DynamicPropertyDefinition property,
    dynamic value,
  ) {
    return CrossAxisAlignmentControl(
      value: value,
      onChanged: (next) => _setValue(property.name, next),
    );
  }

  Widget _buildMainAxisSizeControl(
    DynamicPropertyDefinition property,
    dynamic value,
  ) {
    return MainAxisSizeControl(
      value: value,
      onChanged: (next) => _setValue(property.name, next),
    );
  }

  Widget _buildAxisControl(DynamicPropertyDefinition property, dynamic value) {
    return AxisControl(
      value: value,
      onChanged: (next) => _setValue(property.name, next),
    );
  }

  Widget _buildTextAlignControl(
    DynamicPropertyDefinition property,
    dynamic value,
  ) {
    return TextAlignControl(
      value: value,
      onChanged: (next) => _setValue(property.name, next),
    );
  }

  Widget _buildSizeControl(DynamicPropertyDefinition property, dynamic value) {
    return SizeControl(
      value: value,
      onChanged: (next) => _setValue(property.name, next),
    );
  }

  Widget _buildRotationControl(
    DynamicPropertyDefinition property,
    dynamic value,
  ) {
    return RotationControl(
      value: value,
      onChanged: (next) => _setValue(property.name, next),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Private helpers
// ══════════════════════════════════════════════════════════════════════

class _ExpandablePropertyRow extends StatefulWidget {
  const _ExpandablePropertyRow({
    required this.title,
    this.subtitle,
    required this.isModified,
    this.onReset,
    required this.defaultOpen,
    required this.child,
  });

  final String title;
  final String? subtitle;
  final bool isModified;
  final VoidCallback? onReset;
  final bool defaultOpen;
  final Widget child;

  @override
  State<_ExpandablePropertyRow> createState() => _ExpandablePropertyRowState();
}

class _IndentLinePainter extends CustomPainter {
  const _IndentLinePainter({required this.color, required this.x});

  final Color color;
  final double x;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(x, 0),
      Offset(x, size.height),
      Paint()
        ..color = color
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_IndentLinePainter old) =>
      old.color != color || old.x != x;
}

class _ExpandablePropertyRowState extends State<_ExpandablePropertyRow> {
  late bool _isOpen;

  @override
  void initState() {
    super.initState();
    _isOpen = widget.defaultOpen;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final textPrimary = SoftSaaSTokens.primaryText(brightness);
    final textSecondary = SoftSaaSTokens.secondaryText(brightness);
    final textTertiary = SoftSaaSTokens.tertiaryText(brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _isOpen = !_isOpen),
          behavior: HitTestBehavior.opaque,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.isModified) ...[
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: SoftSaaSTokens.primaryColor(brightness),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: SoftSaaSTokens.fontSizeXS,
                  fontWeight: SoftSaaSTokens.fontWeightSemibold,
                  color: textPrimary,
                ),
              ),
              if (widget.onReset != null)
                GestureDetector(
                  onTap: widget.onReset,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.refresh, size: 10, color: textSecondary),
                  ),
                ),
              const Spacer(),
              if (widget.subtitle != null) ...[
                Text(
                  widget.subtitle!,
                  style: TextStyle(fontSize: 10, color: textTertiary),
                ),
                const SizedBox(width: 6),
              ],
              Transform.rotate(
                angle: _isOpen ? 3.14159 / 2 : 0,
                child: Icon(
                  LucideIcons.chevron_right,
                  size: 16,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (_isOpen)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: CustomPaint(
              painter: _IndentLinePainter(
                color: SoftSaaSTokens.primaryBorder(brightness),
                x: 12.75,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: widget.child,
              ),
            ),
          ),
      ],
    );
  }
}
