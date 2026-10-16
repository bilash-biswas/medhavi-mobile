import 'package:intl/intl.dart';

/// Bengali Numeral & Ordinal Utility
class BengaliNumeralConverter {
  static const Map<String, String> _bnDigits = {
    '0': '০',
    '1': '১',
    '2': '২',
    '3': '৩',
    '4': '৪',
    '5': '৫',
    '6': '৬',
    '7': '৭',
    '8': '৮',
    '9': '৯',
  };

  /// Converts any integer or number string to Bengali digits (e.g., 50 -> ৫০, 5423 -> ৫,৪২৩)
  static String toBengaliNumber(dynamic number, {bool useGrouping = true}) {
    String str;
    if (number is num && useGrouping && number >= 1000) {
      str = NumberFormat('#,##,###').format(number);
    } else {
      str = number.toString();
    }

    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final char = str[i];
      buffer.write(_bnDigits[char] ?? char);
    }
    return buffer.toString();
  }

  /// Converts BCS batch string to readable Bengali ordinal (e.g., "50th BCS" -> "৫০তম বিসিএস")
  static String toBengaliBcsTitle(String batchStr) {
    final numPart = batchStr
        .replaceAll(RegExp(r'[^0-9]'), '')
        .trim();
    if (numPart.isEmpty) return batchStr;

    final num = int.tryParse(numPart) ?? 0;
    final bnNum = toBengaliNumber(num, useGrouping: false);

    String suffix;
    if (num == 1) {
      suffix = 'ম';
    } else if (num == 2 || num == 3) {
      suffix = 'য়';
    } else if (num == 4) {
      suffix = 'র্থ';
    } else if (num == 5 || num == 6) {
      suffix = 'ষ্ঠ';
    } else if (num >= 7 && num <= 10) {
      suffix = 'ম';
    } else {
      suffix = 'তম';
    }

    return '$bnNum$suffix বিসিএস';
  }
}
