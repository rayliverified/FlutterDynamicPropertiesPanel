import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';
import 'tile_shared.dart';

class PreviewComponent extends StatelessWidget {
  const PreviewComponent({
    super.key,
    required this.componentId,
    required this.config,
    required this.brightness,
  });

  final String componentId;
  final Map<String, dynamic> config;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return switch (componentId) {
      'custom_button' => _button(),
      'avatar' => _avatar(),
      'badge' => _badge(),
      '__builtin_container' => _builtinContainer(),
      '__builtin_text' => _builtinText(),
      '__builtin_sizedbox' => _builtinSizedBox(),
      _ => Text(
        '$componentId (no preview)',
        key: ValueKey(componentId),
        style: TextStyle(
          fontSize: 11,
          color: SoftSaaSTokens.tertiaryText(brightness),
        ),
      ),
    };
  }

  Widget _builtinContainer() {
    final color =
        parsePreviewColor(config['color']) ??
        SoftSaaSTokens.primaryColor(brightness);
    final width = (toDoubleOrNull(config['width']) ?? 80)
        .clamp(8, 320)
        .toDouble();
    final height = (toDoubleOrNull(config['height']) ?? 80)
        .clamp(8, 320)
        .toDouble();
    final radius = (toDoubleOrNull(config['borderRadius']) ?? 8)
        .clamp(0, 80)
        .toDouble();
    final padding = (toDoubleOrNull(config['padding']) ?? 0)
        .clamp(0, 40)
        .toDouble();
    return AnimatedContainer(
      key: const ValueKey('__builtin_container'),
      duration: const Duration(milliseconds: 200),
      width: width,
      height: height,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Center(
        child: Text(
          '${width.toInt()}×${height.toInt()}',
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white,
            shadows: [Shadow(blurRadius: 2, color: Colors.black26)],
          ),
        ),
      ),
    );
  }

  Widget _builtinText() {
    final text = (config['text'] ?? 'Hello, world!').toString();
    final fontSize = (toDoubleOrNull(config['fontSize']) ?? 16)
        .clamp(8, 72)
        .toDouble();
    final color =
        parsePreviewColor(config['color']) ??
        SoftSaaSTokens.primaryText(brightness);
    final weight = switch ((config['fontWeight'] ?? 'normal').toString()) {
      'medium' => FontWeight.w500,
      'semibold' => FontWeight.w600,
      'bold' => FontWeight.w700,
      _ => FontWeight.w400,
    };
    return Text(
      text,
      key: const ValueKey('__builtin_text'),
      style: TextStyle(fontSize: fontSize, fontWeight: weight, color: color),
    );
  }

  Widget _builtinSizedBox() {
    final width = (toDoubleOrNull(config['width']) ?? 48)
        .clamp(0, 320)
        .toDouble();
    final height = (toDoubleOrNull(config['height']) ?? 48)
        .clamp(0, 320)
        .toDouble();
    return AnimatedContainer(
      key: const ValueKey('__builtin_sizedbox'),
      duration: const Duration(milliseconds: 200),
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: SoftSaaSTokens.primaryBorder(brightness),
          width: 1,
        ),
        color: SoftSaaSTokens.tertiaryBackground(brightness),
      ),
      child: Center(
        child: Text(
          '${width.toInt()}×${height.toInt()}',
          style: TextStyle(
            fontSize: 10,
            color: SoftSaaSTokens.tertiaryText(brightness),
          ),
        ),
      ),
    );
  }

  Widget _button() {
    final label = (config['label'] ?? 'Click Me').toString();
    final variant = (config['variant'] ?? 'primary').toString();
    final fs = toDoubleOrNull(config['fontSize']) ?? 14;
    final enabled = config['enabled'] != false;
    final v = switch (variant) {
      'secondary' => SoftSaaSButtonVariant.secondary,
      'ghost' => SoftSaaSButtonVariant.ghost,
      _ => SoftSaaSButtonVariant.primary,
    };
    return SoftSaaSButton(
      key: const ValueKey('custom_button'),
      variant: v,
      size: SoftSaaSButtonSize.medium,
      onPressed: enabled ? () {} : null,
      child: Text(
        label,
        style: TextStyle(fontSize: fs, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _avatar() {
    final initials = (config['initials'] ?? 'AB').toString();
    final size = (toDoubleOrNull(config['size']) ?? 40).clamp(16, 96).toDouble();
    final showStatus = config['showStatus'] == true;
    final statusColor = parsePreviewColor(config['statusColor']) ?? Colors.green;
    return Stack(
      key: const ValueKey('avatar'),
      clipBehavior: Clip.none,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: SoftSaaSTokens.primaryColor(
              brightness,
            ).withValues(alpha: 0.15),
            border: Border.all(
              color: SoftSaaSTokens.primaryColor(
                brightness,
              ).withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(
                fontSize: size * 0.38,
                fontWeight: FontWeight.w700,
                color: SoftSaaSTokens.primaryColor(brightness),
              ),
            ),
          ),
        ),
        if (showStatus)
          Positioned(
            right: 0,
            bottom: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: statusColor,
                border: Border.all(
                  color: SoftSaaSTokens.primaryBackground(brightness),
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _badge() {
    final text = (config['text'] ?? 'Active').toString();
    final bgColor = parsePreviewColor(config['color']) ?? Colors.blue;
    return Container(
      key: const ValueKey('badge'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusFull),
        border: Border.all(color: bgColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: bgColor,
        ),
      ),
    );
  }
}
