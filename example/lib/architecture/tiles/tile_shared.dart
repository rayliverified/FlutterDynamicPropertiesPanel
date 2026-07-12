import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

/// Shared shell, label, and parsing helpers for the Feature Block tiles.

Color? parsePreviewColor(dynamic value) {
  if (value is Color) return value;
  if (value is String) {
    final hex = value.replaceAll('#', '');
    if (hex.length == 6) {
      final v = int.tryParse(hex, radix: 16);
      if (v != null) return Color(0xFF000000 | v);
    }
    if (hex.length == 8) {
      final v = int.tryParse(hex, radix: 16);
      if (v != null) return Color(v);
    }
  }
  return null;
}

double? toDoubleOrNull(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

List<String> asStringList(dynamic v) {
  if (v is List) return v.map((e) => e.toString()).toList();
  return const [];
}

class PreviewTile extends StatelessWidget {
  const PreviewTile({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: -10,
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}

class TileLabel extends StatelessWidget {
  const TileLabel(this.label, this.icon, this.brightness, {super.key});

  final String label;
  final IconData icon;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 11, color: SoftSaaSTokens.tertiaryText(brightness)),
        const SizedBox(width: 5),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: SoftSaaSTokens.tertiaryText(brightness),
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class EmptyHint extends StatelessWidget {
  const EmptyHint(this.icon, this.text, this.brightness, {super.key});

  final IconData icon;
  final String text;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: SoftSaaSTokens.tertiaryText(brightness)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: SoftSaaSTokens.tertiaryText(brightness),
            ),
          ),
        ),
      ],
    );
  }
}
