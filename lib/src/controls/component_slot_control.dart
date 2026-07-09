import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

import '../core/component_registry.dart';
import '../core/dynamic_properties_panel_manager.dart';
import '../core/navigation_controller.dart';

/// Control for selecting a component to fill a widget slot parameter.
///
/// Inspector-style: compact trigger with component icon + name,
/// searchable overlay dropdown for component selection.
/// When a component with [ComponentInfo.properties] is selected,
/// an arrow button appears to drill into the component's configuration.
class ComponentSlotControl extends StatefulWidget {
  const ComponentSlotControl({
    super.key,
    required this.value,
    required this.onChanged,
    this.allowNull = true,
    this.manager,
    this.parameterName,
  });

  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final bool allowNull;
  final DynamicPropertiesPanelManager? manager;
  final String? parameterName;

  @override
  State<ComponentSlotControl> createState() => _ComponentSlotControlState();
}

class _ComponentSlotControlState extends State<ComponentSlotControl> {
  bool _isOpen = false;
  String _searchQuery = '';
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  DynamicPropertiesPanelManager get _managerInstance =>
      widget.manager ?? DynamicPropertiesPanelManager.instance;

  ComponentRegistry get _registry => _managerInstance.componentRegistry;

  NavigationController get _nav => _managerInstance.navigationController;

  String? get _currentId {
    if (widget.value is Map) {
      return (widget.value as Map)['componentId'] as String?;
    }
    return null;
  }

  Map<String, dynamic> get _currentConfig {
    if (widget.value is Map) {
      final config = (widget.value as Map)['config'];
      if (config is Map) return Map<String, dynamic>.from(config);
    }
    return {};
  }

  List<ComponentInfo> get _filtered {
    var components = _registry.all
        .where((c) => !c.id.startsWith('__builtin_'))
        .toList();
    if (_searchQuery.isNotEmpty) {
      final lower = _searchQuery.toLowerCase();
      components = components
          .where(
            (c) =>
                c.name.toLowerCase().contains(lower) ||
                (c.description?.toLowerCase().contains(lower) ?? false) ||
                c.tags.any((t) => t.toLowerCase().contains(lower)),
          )
          .toList();
    }
    return components;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen = false;
  }

  void _toggle() {
    if (_isOpen) {
      _removeOverlay();
    } else {
      _showOverlay();
    }
    setState(() {});
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    _overlayEntry = OverlayEntry(builder: (_) => _buildOverlay(renderBox.size));
    overlay.insert(_overlayEntry!);
    _isOpen = true;
  }

  void _navigateIntoComponent() {
    final currentId = _currentId;
    if (currentId == null) return;
    final component = _registry.getById(currentId);
    if (component == null ||
        component.properties == null ||
        component.properties!.isEmpty) {
      return;
    }

    _nav.navigateInto(
      label: widget.parameterName ?? 'child',
      type: component.name,
      value: _currentConfig,
      properties: component.properties!.cast<dynamic>(),
      schema: {
        'parameterName': widget.parameterName ?? 'child',
        'componentId': currentId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final border = SoftSaaSTokens.primaryBorder(brightness);
    final currentId = _currentId;
    final currentComponent = currentId != null
        ? _registry.getById(currentId)
        : null;
    final hasProperties =
        currentComponent?.properties != null &&
        currentComponent!.properties!.isNotEmpty;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: _isOpen
                ? SoftSaaSTokens.primaryColor(
                    brightness,
                  ).withValues(alpha: 0.45)
                : border,
            width: 1.5,
          ),
          color: SoftSaaSTokens.primaryBackground(brightness),
        ),
        child: Row(
          children: [
            // Main trigger area (opens dropdown)
            Expanded(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _toggle,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
                    child: Row(
                      children: [
                        Icon(
                          currentComponent?.icon ?? Icons.widgets,
                          size: 15,
                          color: currentComponent != null
                              ? SoftSaaSTokens.secondaryText(brightness)
                              : SoftSaaSTokens.tertiaryText(brightness),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            currentComponent?.name ?? 'None',
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.0,
                              fontWeight: SoftSaaSTokens.fontWeightNormal,
                              color: currentComponent != null
                                  ? SoftSaaSTokens.primaryText(brightness)
                                  : SoftSaaSTokens.tertiaryText(brightness),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AnimatedRotation(
                          turns: _isOpen ? 0.5 : 0.0,
                          duration: SoftSaaSTokens.transitionDuration,
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

            // Drill-in settings (only when component has properties)
            if (hasProperties) ...[
              Container(width: 1, height: 22, color: border),
              InkWell(
                onTap: _navigateIntoComponent,
                borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(6),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    LucideIcons.settings,
                    size: 14,
                    color: SoftSaaSTokens.tertiaryText(brightness),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay(Size anchorSize) {
    final brightness = Theme.of(context).brightness;
    final border = SoftSaaSTokens.primaryBorder(brightness);
    final filtered = _filtered;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              _removeOverlay();
              setState(() {});
            },
            behavior: HitTestBehavior.opaque,
            child: const SizedBox.expand(),
          ),
        ),
        CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, anchorSize.height + 4),
          child: Material(
            elevation: 0,
            borderRadius: BorderRadius.circular(7),
            color: SoftSaaSTokens.primaryBackground(brightness),
            child: Container(
              width: anchorSize.width,
              constraints: const BoxConstraints(maxHeight: 240),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                color: SoftSaaSTokens.primaryBackground(brightness),
                border: Border.all(color: border),
                boxShadow: [
                  BoxShadow(
                    color: brightness == Brightness.dark
                        ? const Color(0x52000000)
                        : const Color(0x14000000),
                    offset: brightness == Brightness.dark
                        ? const Offset(0, 10)
                        : const Offset(0, 8),
                    blurRadius: brightness == Brightness.dark ? 22 : 18,
                    spreadRadius: brightness == Brightness.dark ? -8 : -6,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: SoftSaaSTextInput(
                      hintText: 'Search...',
                      size: SoftSaaSTextInputSize.small,
                      onChanged: (q) => setState(() => _searchQuery = q),
                    ),
                  ),
                  Container(height: 1, color: border),

                  // Single scrollable list for all items
                  Flexible(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      children: [
                        if (widget.allowNull) _tile('None', Icons.block, null),

                        _sectionHeader('Built-in'),
                        _tile(
                          'Container',
                          Icons.crop_square,
                          '__builtin_container',
                        ),
                        _tile('Text', Icons.text_fields, '__builtin_text'),
                        _tile(
                          'SizedBox',
                          Icons.crop_square_outlined,
                          '__builtin_sizedbox',
                        ),

                        if (filtered.isNotEmpty) ...[
                          _sectionHeader('Project'),
                          ...filtered.map(
                            (c) => _tile(
                              c.name,
                              c.icon,
                              c.id,
                              description: c.description,
                            ),
                          ),
                        ],

                        if (filtered.isEmpty && _searchQuery.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              'No matches',
                              style: TextStyle(
                                fontSize: 11,
                                color: SoftSaaSTokens.tertiaryText(brightness),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    final brightness = Theme.of(context).brightness;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 2),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: SoftSaaSTokens.tertiaryText(brightness),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _tile(String name, IconData icon, String? id, {String? description}) {
    final brightness = Theme.of(context).brightness;
    final isSelected = id == _currentId;

    return InkWell(
      onTap: () {
        if (id == null) {
          widget.onChanged(null);
        } else {
          final component = _registry.getById(id);
          widget.onChanged({
            'componentId': id,
            'config': component?.defaultConfig ?? {},
          });
        }
        _removeOverlay();
        setState(() {});
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
        child: Row(
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? SoftSaaSTokens.primaryColor(brightness)
                  : SoftSaaSTokens.secondaryText(brightness),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.0,
                  fontWeight: isSelected
                      ? SoftSaaSTokens.fontWeightMedium
                      : SoftSaaSTokens.fontWeightNormal,
                  color: isSelected
                      ? SoftSaaSTokens.primaryColor(brightness)
                      : SoftSaaSTokens.primaryText(brightness),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
