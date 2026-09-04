import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Money and counts, grouped the way they are read aloud: 1,000,000.
///
/// One place for both halves of the problem — what the FA types
/// ([ThousandsFormatter]) and what the app prints back ([AppNumber.format]
/// / [AppNumber.money]) — so an amount never appears grouped on one screen
/// and bare on the next.
abstract final class AppNumber {
  static final NumberFormat _grouped = NumberFormat('#,##0', 'en_US');
  static final NumberFormat _grouped2dp = NumberFormat('#,##0.00', 'en_US');

  /// 1000000 -> "1,000,000".
  static String format(num value) => _grouped.format(value);

  /// 1000000 -> "1,000,000.00" — for premiums, fees and totals.
  static String money(num value) => _grouped2dp.format(value);

  /// Strips the grouping back out, for anything that has to parse a field
  /// the user typed into.
  static num? parse(String text) {
    final digits = text.replaceAll(',', '').trim();
    if (digits.isEmpty) return null;
    return num.tryParse(digits);
  }
}

/// Groups digits as they are typed: "1000000" becomes "1,000,000" without
/// the caret jumping to the end of the field.
class ThousandsFormatter extends TextInputFormatter {
  const ThousandsFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    final formatted = AppNumber.format(int.parse(digitsOnly));

    // Keep the caret where the user is typing: count the digits to its
    // left and put it back after that many digits in the grouped string.
    final digitsBeforeCaret = newValue.text
        .substring(0, newValue.selection.end.clamp(0, newValue.text.length))
        .replaceAll(RegExp(r'[^0-9]'), '')
        .length;

    var seen = 0;
    var offset = formatted.length;
    for (var i = 0; i < formatted.length; i++) {
      if (seen == digitsBeforeCaret) {
        offset = i;
        break;
      }
      if (formatted[i] != ',') seen++;
    }
    if (seen == digitsBeforeCaret && offset == formatted.length) {
      offset = formatted.length;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
