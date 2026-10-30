import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// Renders Bengali and English text with inline KaTeX formulas natively.
/// Parses '$...$' and automatically normalizes raw LaTeX commands like \frac, \sqrt, \log, \le, ^2, ^\circ.
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

  static String normalizeMathInput(String raw) {
    if (raw.isEmpty) return raw;
    String s = raw;

    // 0. Auto-heal literal \n into real newlines (while safely protecting LaTeX commands like \neq, \nabla, \nu, \notin)
    s = s.replaceAll(RegExp(r'\\n(?![a-zA-Z])'), '\n');

    // 0.1 Auto-heal double-escaped LaTeX commands (\\frac -> \frac, \\implies -> \implies, etc.)
    s = s.replaceAllMapped(RegExp(r'\\\\([a-zA-Z]+)'), (m) => '\\${m.group(1)}');

    // 1. Repair false English word macros (\sin{gular} -> singular, \sec{ond} -> second)
    s = s.replaceAllMapped(
      RegExp(r'\\(sin|sec|tan|cos|log)\{([a-z]{2,})\}'),
      (m) => '${m.group(1)}${m.group(2)}',
    );
    s = s.replaceAllMapped(
      RegExp(r'\$?\\frac\{a\}\{an(-?)\}\$?', caseSensitive: false),
      (m) => 'a/an${m.group(1) ?? ''}',
    );

    // 2. Fix \frac{\sqrt{A}{B}} -> \sqrt{\frac{A}{B}}
    s = s.replaceAllMapped(
      RegExp(r'\\frac\{\\sqrt\{([^{}]+)\}\{([^{}]+)\}\}'),
      (m) => '\\sqrt{\\frac{${m.group(1)}}{${m.group(2)}}}',
    );

    // 3. Convert ^\circ and \circ to clean Unicode degree symbol °
    s = s.replaceAllMapped(RegExp(r'\^\s*\\circ\s*([CFN])'), (m) => '°${m.group(1)}');
    s = s.replaceAllMapped(RegExp(r'\\circ\s*([CFN])'), (m) => '°${m.group(1)}');
    s = s.replaceAll(RegExp(r'\^\s*\\circ'), '°');
    s = s.replaceAll(r'\circ', '°');
    s = s.replaceAllMapped(RegExp(r'°([\u0980-\u09FF])'), (m) => '° ${m.group(1)}');

    // 4. Repair broken $ inside \frac${ or \sqrt${
    if (RegExp(r'\\(frac|sqrt)\$\{').hasMatch(s)) {
      s = s.replaceAll(r'$', '');
    }

    // 5. Fix \angle\text{A} -> \angle A
    s = s.replaceAllMapped(
      RegExp(r'\\angle\\text\{([^{}]+)\}'),
      (m) => '\\angle ${m.group(1)}',
    );

    return s;
  }

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();

    final defaultStyle = style ?? Theme.of(context).textTheme.bodyMedium!;
    final effectiveMathColor = mathColor ?? defaultStyle.color;

    final normalized = normalizeMathInput(text);

    // Fast path if no math tokens exist
    if (!normalized.contains(r'$') &&
        !normalized.contains(r'\') &&
        !normalized.contains('^')) {
      return Text(
        normalized,
        style: defaultStyle,
        textAlign: textAlign,
      );
    }

    final spans = _parseSpans(normalized, defaultStyle, effectiveMathColor);

    return Text.rich(
      TextSpan(children: spans),
      textAlign: textAlign,
    );
  }

  List<InlineSpan> _parseUnwrappedSegment(
    String segment,
    TextStyle defaultStyle,
    Color? mathColor,
  ) {
    final tokenRegex = RegExp(
      r'(\([ \t]*\\frac\{[^{}]*\}\{[^{}]*\}[ \t]*\)(?:\^(?:\{[^{}]*\}|[0-9a-zA-Z+\-]+))?|\\(?:frac|sqrt)(?:\[[^\]]*\])?\{[^{}]*\}(?:\{[^{}]*\})?|\\(?:le|ge|ne|pm|times|div|cdot|cup|cap)|\\angle\s*[A-Za-z]+|\\log(?:_\{[^{}]*\}|_[a-zA-Z0-9]+)?(?:\{[^{}]*\})?|[a-zA-Z0-9)]+\^(?:\{[^{}]*\}|[0-9a-zA-Z+\-]+))',
    );

    if (!tokenRegex.hasMatch(segment)) {
      return [TextSpan(text: segment, style: defaultStyle)];
    }

    final spans = <InlineSpan>[];
    int lastEnd = 0;

    for (final match in tokenRegex.allMatches(segment)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: segment.substring(lastEnd, match.start),
          style: defaultStyle,
        ));
      }
      final formula = match.group(0)?.trim() ?? '';
      if (formula.isNotEmpty) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Math.tex(
              formula,
              textStyle: defaultStyle.copyWith(color: mathColor),
              onErrorFallback: (err) => Text(formula, style: defaultStyle),
            ),
          ),
        );
      }
      lastEnd = match.end;
    }

    if (lastEnd < segment.length) {
      spans.add(TextSpan(
        text: segment.substring(lastEnd),
        style: defaultStyle,
      ));
    }

    return spans;
  }

  List<InlineSpan> _parseSpans(
    String raw,
    TextStyle defaultStyle,
    Color? mathColor,
  ) {
    final spans = <InlineSpan>[];
    final dollarRegex = RegExp(r'\$([^\$]+)\$');
    int lastMatchEnd = 0;

    for (final match in dollarRegex.allMatches(raw)) {
      if (match.start > lastMatchEnd) {
        final plainText = raw.substring(lastMatchEnd, match.start);
        spans.addAll(_parseUnwrappedSegment(plainText, defaultStyle, mathColor));
      }

      final formula = match.group(1)?.trim() ?? '';
      if (formula.isNotEmpty) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Math.tex(
              formula,
              textStyle: defaultStyle.copyWith(color: mathColor),
              onErrorFallback: (err) => Text(formula, style: defaultStyle),
            ),
          ),
        );
      }

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < raw.length) {
      spans.addAll(
        _parseUnwrappedSegment(raw.substring(lastMatchEnd), defaultStyle, mathColor),
      );
    }

    return spans;
  }
}
