import 'quote_field.dart';

enum ProductCategory { protection, saving, health }

class Product {
  const Product({
    required this.code,
    required this.name,
    required this.category,
    required this.tagline,
    required this.coverage,
    required this.calculatorFields,
    this.description,
    this.benefits = const [],
    this.eligibility = const [],
    this.exclusions = const [],
  });

  final String code;
  final String name;
  final ProductCategory category;
  final String tagline;
  final String coverage;

  /// Longer product-brochure copy, sourced from kbzlife.com's public
  /// product pages. Products without a published page fall back to
  /// [tagline]/[coverage] only.
  final String? description;
  final List<String> benefits;
  final List<String> eligibility;
  final List<String> exclusions;

  /// FR-04 Premium Calculator — the exact input fields for this product,
  /// taken from the approved calculator mockups (one per product in the
  /// source spreadsheet). Different products ask for genuinely different
  /// inputs, so the calculator screen renders this list, not a fixed form.
  final List<QuoteFieldSpec> calculatorFields;
}
