import 'package:flutter/material.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

/// Control shown for unsupported or error-producing property types.
class ErrorControl extends StatelessWidget {
  const ErrorControl({super.key, this.typeName, this.error, this.value});

  final String? typeName;
  final String? error;
  final dynamic value;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: SoftSaaSTokens.errorColor(brightness).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: SoftSaaSTokens.errorColor(brightness).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 13,
                color: SoftSaaSTokens.errorColor(brightness),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  error ?? 'Unsupported type: ${typeName ?? 'unknown'}',
                  style: TextStyle(
                    fontSize: SoftSaaSTokens.fontSizeXS,
                    color: SoftSaaSTokens.errorColor(brightness),
                  ),
                ),
              ),
            ],
          ),
          if (value != null) ...[
            const SizedBox(height: 4),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 10,
                color: SoftSaaSTokens.tertiaryText(brightness),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
