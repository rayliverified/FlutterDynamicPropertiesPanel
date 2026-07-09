import 'dart:async';
import 'dart:convert';

import 'package:dynamic_properties_panel/dynamic_properties_panel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

/// JSON Output Card — displays current controller values via the shared
/// [JsonViewEditBox] (same control used by the `metadata` property, so
/// view/edit styling stays consistent across the app).
class JsonCard extends StatefulWidget {
  const JsonCard({
    super.key,
    required this.controller,
    required this.brightness,
    this.collapsible = false,
    this.expanded = true,
    this.onToggle,
    this.expandBody = true,
    this.maxHeight = 200.0,
    this.showContainer = true,
    this.values,
    this.onValuesChanged,
    this.subtitle,
  });

  final DynamicPropertiesController controller;
  final Brightness brightness;
  final bool collapsible;
  final bool expanded;
  final VoidCallback? onToggle;
  final bool expandBody;
  final double maxHeight;
  final bool showContainer;
  final Map<String, dynamic>? values;
  final ValueChanged<Map<String, dynamic>>? onValuesChanged;
  final String? subtitle;

  @override
  State<JsonCard> createState() => _JsonCardState();
}

class _JsonCardState extends State<JsonCard> {
  // Held snapshot reference — only replaced when content actually changes AND
  // the rapid-fire notification stream has settled. JsonView uses identity
  // to decide whether to wipe expansion state; a stable reference preserves
  // the user's expansion across slider drags and keystrokes.
  Map<String, dynamic> _snapshot = const {};
  Timer? _debounce;

  static const _debounceDuration = Duration(milliseconds: 120);

  @override
  void initState() {
    super.initState();
    _snapshot = widget.values ?? widget.controller.snapshotShallow();
    if (widget.values == null) {
      widget.controller.addListener(_onControllerChange);
    }
  }

  @override
  void didUpdateWidget(covariant JsonCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.values != widget.values) {
      if (oldWidget.values == null) {
        oldWidget.controller.removeListener(_onControllerChange);
      }
      if (widget.values == null) {
        widget.controller.addListener(_onControllerChange);
      }
      _snapshot = widget.values ?? widget.controller.snapshotShallow();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.values == null) {
      widget.controller.removeListener(_onControllerChange);
    }
    super.dispose();
  }

  void _onControllerChange() {
    // Coalesce bursts (slider drags, keystrokes) into one rebuild after the
    // user settles. Without this, JsonView's identity check fails on every
    // tick and expansion state is wiped 60x/sec.
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () {
      if (!mounted) return;
      final next = widget.controller.snapshotShallow();
      if (mapEquals(_snapshot, next)) return;
      setState(() => _snapshot = next);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body = JsonViewEditBox(
      value: _snapshot,
      onChanged: (decoded) {
        if (decoded is Map<String, dynamic>) {
          if (widget.onValuesChanged != null) {
            widget.onValuesChanged!(decoded);
          } else {
            widget.controller.applyAll(decoded);
          }
        }
      },
    );

    if (!widget.expandBody) {
      body = SizedBox(height: widget.maxHeight, child: body);
    }

    if (!widget.showContainer) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: body,
      );
    }

    return SoftSaaSPanel.expandable(
      title: 'JSON Output',
      subtitle:
          widget.subtitle ??
          'Current configuration payload (live via controller)',
      expandBody: widget.expandBody,
      defaultOpen: widget.expanded,
      onToggleOpen: widget.collapsible ? (_) => widget.onToggle?.call() : null,
      trailing: SoftSaaSActionButton(
        icon: LucideIcons.copy,
        tooltip: 'Copy JSON',
        onPressed: _copyJson,
      ),
      child: Padding(padding: const EdgeInsets.all(14), child: body),
    );
  }

  Future<void> _copyJson() async {
    // Read fresh from the controller at click time — no point caching the
    // encoded string since copy happens rarely.
    await Clipboard.setData(ClipboardData(text: _encode(_snapshot)));
  }

  static String _encode(Map<String, dynamic> values) =>
      const JsonEncoder.withIndent('  ').convert(values);
}
