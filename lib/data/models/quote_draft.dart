/// A saved/draft quote (FR-04.4) — a parked calculator session the agent
/// can resume later instead of Start e-App immediately.
class QuoteDraft {
  const QuoteDraft({
    required this.id,
    required this.productCode,
    required this.productName,
    required this.premium,
    required this.savedAt,
  });

  final String id;
  final String productCode;
  final String productName;
  final int premium;
  final DateTime savedAt;
}
