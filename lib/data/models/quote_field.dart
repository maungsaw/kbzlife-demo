/// Field schema powering the dynamic, per-product calculator form.
/// Mirrors the input layouts captured in the source
/// "KBZ Life Premium Calculator.xlsx" mockups (one screenshot per
/// product) — each product asks for a different set of inputs.
enum QuoteFieldType { date, number, singleSelect, multiSelect, computed }

class QuoteOption {
  const QuoteOption(this.label, this.value);
  final String label;
  final String value;
}

class QuoteFieldSpec {
  const QuoteFieldSpec({
    required this.key,
    required this.label,
    required this.type,
    this.options = const [],
    this.suffix,
    this.defaultNumber,
    this.helperText,
  });

  final String key;
  final String label;
  final QuoteFieldType type;
  final List<QuoteOption> options;
  final String? suffix;
  final num? defaultNumber;
  final String? helperText;
}
