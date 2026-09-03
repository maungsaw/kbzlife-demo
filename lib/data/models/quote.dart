class QuoteInput {
  const QuoteInput({
    required this.dateOfBirth,
    required this.sumInsured,
    required this.policyTermMonths,
    required this.highRiskIndustry,
  });

  final DateTime? dateOfBirth;
  final int sumInsured;
  final int policyTermMonths;
  final bool highRiskIndustry;

  QuoteInput copyWith({
    DateTime? dateOfBirth,
    int? sumInsured,
    int? policyTermMonths,
    bool? highRiskIndustry,
  }) {
    return QuoteInput(
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      sumInsured: sumInsured ?? this.sumInsured,
      policyTermMonths: policyTermMonths ?? this.policyTermMonths,
      highRiskIndustry: highRiskIndustry ?? this.highRiskIndustry,
    );
  }

  static QuoteInput initial() => QuoteInput(
        dateOfBirth: DateTime(1995, 8, 17),
        sumInsured: 1000000,
        policyTermMonths: 12,
        highRiskIndustry: false,
      );
}

class QuoteResult {
  const QuoteResult({
    required this.productName,
    required this.sumInsured,
    required this.termLabel,
    required this.premium,
    required this.stampDuty,
  });

  final String productName;
  final int sumInsured;
  final String termLabel;
  final int premium;
  final int stampDuty;

  int get total => premium + stampDuty;
}
