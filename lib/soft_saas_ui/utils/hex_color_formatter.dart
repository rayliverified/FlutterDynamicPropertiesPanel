/// [TextInputFormatter] that enforces hex-color typing rules.
///
/// Hex input formatter used by the color control. Preserves:
///   - `#` prefix auto-management (any `#` typed anywhere gets collapsed to
///     a single leading `#`)
///   - Uppercase normalization
///   - `[A-F0-9]` filter
///   - Paste detection (bulk edits jump cursor to end)
///   - Length cap based on `allowAlpha` (6 or 8 hex digits)
library;

import 'package:flutter/services.dart';

class HexColorInputFormatter extends TextInputFormatter {
  HexColorInputFormatter({this.allowAlpha = false});

  final bool allowAlpha;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String next = newValue.text.toUpperCase();

    // Detect paste: bulk character changes, or selection already at end.
    final isPaste =
        (newValue.text.length - oldValue.text.length).abs() > 1 ||
        newValue.selection.baseOffset == newValue.text.length;

    next = next.replaceAll('#', '').replaceAll(RegExp(r'[^A-F0-9]'), '');

    final maxLength = allowAlpha ? 8 : 6;
    if (next.length > maxLength) {
      next = next.substring(0, maxLength);
    }

    if (next.isNotEmpty) {
      next = '#$next';
    }

    int selectionOffset;
    if (isPaste || next.isEmpty) {
      selectionOffset = next.length;
    } else {
      final nextWithoutHash = next.replaceFirst(RegExp(r'^#'), '');
      final oldHashLen = oldValue.text.startsWith('#') ? 1 : 0;
      final newHashLen = next.startsWith('#') ? 1 : 0;
      final oldSelection = newValue.selection.baseOffset;
      if (oldSelection <= oldHashLen) {
        selectionOffset = newHashLen;
      } else {
        final oldHexPos = oldSelection - oldHashLen;
        final newHexPos = oldHexPos.clamp(0, nextWithoutHash.length);
        selectionOffset = newHashLen + newHexPos;
      }
    }

    return TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: selectionOffset),
    );
  }
}
