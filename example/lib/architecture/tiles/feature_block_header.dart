import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:dynamic_properties_panel/soft_saas_ui/soft_saas_ui.dart';

class FeatureBlockHeader extends StatelessWidget {
  const FeatureBlockHeader({
    super.key,
    required this.title,
    required this.variant,
    required this.themeColor,
    this.iconName,
    required this.rollout,
    this.language,
    this.expiresAt,
    required this.brightness,
  });

  final String title;
  final String variant;
  final Color themeColor;
  final String? iconName;
  final bool rollout;
  final String? language;
  final String? expiresAt;
  final Brightness brightness;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: SoftSaaSTokens.primaryBorder(brightness)),
        ),
      ),
      child: Row(
        children: [
          _brandIcon(),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: SoftSaaSTokens.primaryText(brightness),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Wrap(
                  spacing: 4,
                  runSpacing: 3,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Feature block',
                      style: TextStyle(
                        fontSize: 10,
                        color: SoftSaaSTokens.tertiaryText(brightness),
                      ),
                    ),
                    Text(
                      '·',
                      style: TextStyle(
                        fontSize: 10,
                        color: SoftSaaSTokens.tertiaryText(brightness),
                      ),
                    ),
                    _variantPill(),
                    if (language != null && language!.isNotEmpty) _langPill(),
                    if (expiresAt != null && expiresAt!.isNotEmpty)
                      _expiryPill(),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _liveChip(),
        ],
      ),
    );
  }

  Widget _brandIcon() {
    final c = themeColor;
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [c.withValues(alpha: 0.22), c.withValues(alpha: 0.08)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withValues(alpha: 0.25)),
      ),
      child: Icon(LucideIcons.flag, size: 16, color: c),
    );
  }

  Widget _variantPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: SoftSaaSTokens.tertiaryBackground(brightness),
        borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusFull),
        border: Border.all(color: SoftSaaSTokens.primaryBorder(brightness)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.sparkles, size: 9, color: themeColor),
          const SizedBox(width: 3),
          Text(
            variant,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: SoftSaaSTokens.secondaryText(brightness),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _langPill() {
    final code = language!.length > 2
        ? language!.substring(0, 2).toUpperCase()
        : language!.toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: SoftSaaSTokens.tertiaryBackground(brightness),
        borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusFull),
        border: Border.all(color: SoftSaaSTokens.primaryBorder(brightness)),
      ),
      child: Text(
        code,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: SoftSaaSTokens.secondaryText(brightness),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _expiryPill() {
    final date = DateTime.tryParse(expiresAt!);
    if (date == null) return const SizedBox.shrink();
    final expired = date.isBefore(DateTime.now());
    final color = expired
        ? const Color(0xFFEF4444)
        : SoftSaaSTokens.tertiaryText(brightness);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: expired
            ? const Color(0xFFEF4444).withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Text(
        '${date.month}/${date.day}/${date.year}',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _liveChip() {
    final color = rollout
        ? const Color(0xFF10B981)
        : SoftSaaSTokens.warningColor(brightness);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(SoftSaaSTokens.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: rollout
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            rollout ? 'Live' : 'Paused',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
