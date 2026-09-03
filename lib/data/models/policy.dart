/// FR-06 Policy list/details — status of an in-force (or lapsed) policy.
enum PolicyStatus { active, lapsed, matured, pendingRenewal }

extension PolicyStatusX on PolicyStatus {
  String get label => switch (this) {
        PolicyStatus.active => 'Active',
        PolicyStatus.lapsed => 'Lapsed',
        PolicyStatus.matured => 'Matured',
        PolicyStatus.pendingRenewal => 'Renewal due',
      };
}

class Policy {
  const Policy({
    required this.policyNo,
    required this.productName,
    required this.productCode,
    required this.holderName,
    required this.status,
    required this.premium,
    required this.sumInsured,
    required this.renewalDate,
    this.riders = const [],
  });

  final String policyNo;
  final String productName;
  final String productCode;
  final String holderName;
  final PolicyStatus status;
  final int premium;
  final int sumInsured;
  final DateTime renewalDate;

  /// Additional cover / riders attached at issue or a later renewal.
  final List<String> riders;
}
