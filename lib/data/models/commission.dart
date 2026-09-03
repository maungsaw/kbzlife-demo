import 'product.dart';

/// FR — Commission history: one payout line per policy per period.
enum CommissionStatus { pending, approved, paid }

extension CommissionStatusX on CommissionStatus {
  String get label => switch (this) {
        CommissionStatus.pending => 'Pending',
        CommissionStatus.approved => 'Approved',
        CommissionStatus.paid => 'Paid',
      };
}

class Commission {
  const Commission({
    required this.id,
    required this.period,
    required this.productName,
    required this.policyNo,
    required this.amount,
    required this.status,
    required this.paidAt,
    required this.category,
    this.clientName,
  });

  final String id;

  /// e.g. "Aug 2026" — the commission period this line falls under.
  final String period;
  final String productName;
  final String policyNo;
  final int amount;
  final CommissionStatus status;
  final DateTime paidAt;

  /// Doc 85 — Report charts by product **category**, not by SKU.
  final ProductCategory category;
  final String? clientName;
}
