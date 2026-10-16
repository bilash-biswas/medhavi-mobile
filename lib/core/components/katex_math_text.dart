import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// Renders Bengali and English text with inline KaTeX formulas natively.
/// Parses '$...$' or raw LaTeX commands like \frac, \sqrt, \log, ^2.
class KaTexMathText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final Color? mathColor;

  const KaTexMathText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
    this.mathColor,
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    final defaultStyle = style ?? Theme.of(context).textTheme.bodyMedium!;
    final effectiveMathColor = mathColor ?? defaultStyle.color;

    // Check if text contains math formulas
    if (!text.contains(r'$') && !text.contains(r'\frac') && !text.contains(r'\sqrt') && !text.contains(r'\log') && !text.contains(r'^\circ')) {
      return Text(
        text,
        style: defaultStyle,
        textAlign: textAlign,
      );
    }

    final spans = _parseSpans(text, defaultStyle, effectiveMathColor);

    return Text.rich(
      TextSpan(children: spans),
      textAlign: textAlign,
    );
  }

  List<InlineSpan> _parseSpans(
    String raw,
    TextStyle defaultStyle,
    Color? mathColor,
  ) {
    final spans = <InlineSpan>[];
    // Regex matching $...$
    final dollarRegex = RegExp(r'\$([^\$]+)\$');
    int lastMatchEnd = 0;

    for (final match in dollarRegex.allMatches(raw)) {
      if (match.start > lastMatchEnd) {
        final plainText = raw.substring(lastMatchEnd, match.start);
        spans.add(TextSpan(text: plainText, style: defaultStyle));
      }

      final formula = match.group(1)?.trim() ?? '';
      if (formula.isNotEmpty) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Math.tex(
              formula,
              textStyle: defaultStyle.copyWith(color: mathColor),
              onErrorFallback: (err) => Text('\$$formula\$', style: defaultStyle),
            ),
          ),
        );
      }

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < raw.length) {
      spans.add(TextSpan(text: raw.substring(lastMatchEnd), style: defaultStyle));
    }

    return spans;
  }
}
