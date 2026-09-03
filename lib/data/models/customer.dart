/// FR — CRM: a Customer starts as a Lead and can be converted to a Client.
/// Stages follow the pipeline used on the Lead detail screen (doc 101):
/// New → Contacted → Qualified → Proposal → Converted, with Dropped as a
/// terminal state reachable from any stage via the "drop lead" flow (103).
enum CustomerStage { newLead, contacted, qualified, proposal, converted, dropped }

extension CustomerStageX on CustomerStage {
  String get label => switch (this) {
        CustomerStage.newLead => 'New',
        CustomerStage.contacted => 'Contacted',
        CustomerStage.qualified => 'Qualified',
        CustomerStage.proposal => 'Proposal',
        CustomerStage.converted => 'Converted',
        CustomerStage.dropped => 'Dropped',
      };
}

/// BRD Section 1 — CRM Lead/Client field spec: a single tag entry
/// (field name + value), free-form and not mandatory.
class LeadTag {
  const LeadTag({required this.field, required this.value});
  final String field;
  final String value;
}

class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.stage,
    this.isClient = false,
    this.source,
    this.notes,
    this.dropReason,
    this.lastContactedAt,
    this.nrc,
    this.saleAttachment,
    this.companyName,
    this.headCounts,
    this.policyType,
    this.premiumAmountEstimated,
    this.realizationOfInsuranceNeed,
    this.priority,
    this.leadType,
    this.jobTitle,
    this.industry,
    this.affordability,
    this.productNames = const [],
    this.maritalStatus,
    this.remark,
    this.roomNo,
    this.buildingNo,
    this.houseNo,
    this.streetNo,
    this.wardNo,
    this.stateRegion,
    this.township,
    this.tags = const [],
  });

  final String id;
  final String name;
  final String phone;
  final String email;
  final CustomerStage stage;

  /// A Client is a converted Lead — the tab a customer shows under.
  final bool isClient;
  final String? source;
  final String? notes;

  /// Set when [stage] is [CustomerStage.dropped] — the reason message
  /// captured by the drop-lead flow (doc 103).
  final String? dropReason;
  final DateTime? lastContactedAt;

  // --- BRD Section 1 additions ---------------------------------------
  final String? nrc;
  final String? saleAttachment;
  final String? companyName;
  final int? headCounts;
  final String? policyType;
  final double? premiumAmountEstimated;
  final String? realizationOfInsuranceNeed;

  /// Mandatory when Qualified AND when default-Unqualified.
  final String? priority;
  final String? leadType;
  final String? jobTitle;
  final String? industry;
  final String? affordability;

  /// Multi-product support with a sub child table (BRD note).
  final List<String> productNames;
  final String? maritalStatus;
  final String? remark;
  final String? roomNo;
  final String? buildingNo;
  final String? houseNo;
  final String? streetNo;
  final String? wardNo;
  final String? stateRegion;
  final String? township;
  final List<LeadTag> tags;

  /// BRD rule: once Status = Qualified, the whole record becomes
  /// read-only in the app.
  bool get isLocked => stage == CustomerStage.qualified;

  Customer copyWith({
    CustomerStage? stage,
    bool? isClient,
    String? dropReason,
    DateTime? lastContactedAt,
    String? name,
    String? email,
    String? nrc,
    String? saleAttachment,
    String? companyName,
    int? headCounts,
    String? policyType,
    double? premiumAmountEstimated,
    String? realizationOfInsuranceNeed,
    String? priority,
    String? leadType,
    String? jobTitle,
    String? industry,
    String? affordability,
    List<String>? productNames,
    String? maritalStatus,
    String? remark,
    String? roomNo,
    String? buildingNo,
    String? houseNo,
    String? streetNo,
    String? wardNo,
    String? stateRegion,
    String? township,
    List<LeadTag>? tags,
  }) =>
      Customer(
        id: id,
        name: name ?? this.name,
        phone: phone,
        email: email ?? this.email,
        stage: stage ?? this.stage,
        isClient: isClient ?? this.isClient,
        source: source,
        notes: notes,
        dropReason: dropReason ?? this.dropReason,
        lastContactedAt: lastContactedAt ?? this.lastContactedAt,
        nrc: nrc ?? this.nrc,
        saleAttachment: saleAttachment ?? this.saleAttachment,
        companyName: companyName ?? this.companyName,
        headCounts: headCounts ?? this.headCounts,
        policyType: policyType ?? this.policyType,
        premiumAmountEstimated: premiumAmountEstimated ?? this.premiumAmountEstimated,
        realizationOfInsuranceNeed: realizationOfInsuranceNeed ?? this.realizationOfInsuranceNeed,
        priority: priority ?? this.priority,
        leadType: leadType ?? this.leadType,
        jobTitle: jobTitle ?? this.jobTitle,
        industry: industry ?? this.industry,
        affordability: affordability ?? this.affordability,
        productNames: productNames ?? this.productNames,
        maritalStatus: maritalStatus ?? this.maritalStatus,
        remark: remark ?? this.remark,
        roomNo: roomNo ?? this.roomNo,
        buildingNo: buildingNo ?? this.buildingNo,
        houseNo: houseNo ?? this.houseNo,
        streetNo: streetNo ?? this.streetNo,
        wardNo: wardNo ?? this.wardNo,
        stateRegion: stateRegion ?? this.stateRegion,
        township: township ?? this.township,
        tags: tags ?? this.tags,
      );
}
