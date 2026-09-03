// ==========================================
// 1. ENUMS & CONSTANTS
// ==========================================

enum ContactType { lead, client }

enum LeadType { individual, corporate }

enum PolicyType { newPolicy, renewal }

enum LeadPriority { low, medium, high }

enum LeadStatus { newLead, contacted, qualified, negotiation, won, lost }

enum ActivityType { call, meeting, note, email }

// ==========================================
// 2. ENUM EXTENSIONS
// ==========================================

extension LeadTypeExtension on LeadType {
  String get label {
    switch (this) {
      case LeadType.individual:
        return 'Individual';
      case LeadType.corporate:
        return 'Corporate';
    }
  }
}

extension PolicyTypeExtension on PolicyType {
  String get label {
    switch (this) {
      case PolicyType.newPolicy:
        return 'New';
      case PolicyType.renewal:
        return 'Renewal';
    }
  }
}

extension LeadPriorityExtension on LeadPriority {
  String get label {
    switch (this) {
      case LeadPriority.low:
        return 'Low';
      case LeadPriority.medium:
        return 'Medium';
      case LeadPriority.high:
        return 'High';
    }
  }
}

extension LeadStatusExtension on LeadStatus {
  String get label {
    switch (this) {
      case LeadStatus.newLead:
        return 'New Lead';
      case LeadStatus.contacted:
        return 'Contacted';
      case LeadStatus.qualified:
        return 'Qualified';
      case LeadStatus.negotiation:
        return 'Negotiation';
      case LeadStatus.won:
        return 'Won';
      case LeadStatus.lost:
        return 'Lost';
    }
  }
}

// ==========================================
// 2. DATA MODELS
// ==========================================

/// Model representing product or service items available for leads/clients
class ProductModel {
  final String id;
  final String name;
  final String? category;
  final double? price;

  ProductModel({
    required this.id,
    required this.name,
    this.category,
    this.price,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String?,
      price: (json['price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (category != null) 'category': category,
      if (price != null) 'price': price,
    };
  }
}

/// Model representing log history or interactions attached to a contact
class ActivityModel {
  final String id;
  final ActivityType type;
  final String title;
  final String dateText;

  ActivityModel({
    required this.id,
    required this.type,
    required this.title,
    required this.dateText,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] as String,
      type: ActivityType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ActivityType.note,
      ),
      title: json['title'] as String,
      dateText: json['dateText'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'type': type.name, 'title': title, 'dateText': dateText};
  }
}

/// Core model for CRM Leads and Clients
class CRMContactModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final ContactType type;
  final String timeAgo;
  final String assignedAgentId;
  final List<ActivityModel> activities;
  final List<ProductModel> products;

  // Personal Information
  final String? nrc;
  final String? maritalStatus;
  final String? jobTitle;

  // Address Information
  final String? roomNo;
  final String? buildingNo;
  final String? houseNo;
  final String? streetNo;
  final String? wardNo;
  final String? town;
  final String? township;
  final String? stateRegion;

  // Company Information
  final String? companyName;
  final String? headcounts;
  final String? industry;

  // Lead Specific Fields
  final LeadType? leadType;
  final String? saleAttachment;
  final PolicyType? policyType;
  final double? premiumAmountEstimated;
  final String? realizationOfInsuranceNeed;
  final LeadStatus? leadStatus;
  final LeadPriority? priority;
  final String? affordability;
  final String? remark;
  final String? tags;

  CRMContactModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.type = ContactType.lead,
    required this.timeAgo,
    required this.assignedAgentId,
    this.activities = const [],
    this.products = const [],
    this.nrc,
    this.maritalStatus,
    this.jobTitle,
    this.roomNo,
    this.buildingNo,
    this.houseNo,
    this.streetNo,
    this.wardNo,
    this.town,
    this.township,
    this.stateRegion,
    this.companyName,
    this.headcounts,
    this.industry,
    this.leadType,
    this.saleAttachment,
    this.policyType,
    this.premiumAmountEstimated,
    this.realizationOfInsuranceNeed,
    this.leadStatus,
    this.priority,
    this.affordability,
    this.remark,
    this.tags,
  });

  factory CRMContactModel.fromJson(Map<String, dynamic> json) {
    return CRMContactModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      type: ContactType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ContactType.lead,
      ),
      timeAgo: json['timeAgo'] as String? ?? 'Just now',
      assignedAgentId: json['assignedAgentId'] as String? ?? '',
      activities:
          (json['activities'] as List<dynamic>?)
              ?.map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      products:
          (json['products'] as List<dynamic>?)
              ?.map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      nrc: json['nrc'] as String?,
      maritalStatus: json['maritalStatus'] as String?,
      jobTitle: json['jobTitle'] as String?,
      roomNo: json['roomNo'] as String?,
      buildingNo: json['buildingNo'] as String?,
      houseNo: json['houseNo'] as String?,
      streetNo: json['streetNo'] as String?,
      wardNo: json['wardNo'] as String?,
      town: json['town'] as String?,
      township: json['township'] as String?,
      stateRegion: json['stateRegion'] as String?,
      companyName: json['companyName'] as String?,
      headcounts: json['headcounts'] as String?,
      industry: json['industry'] as String?,
      leadType: json['leadType'] != null
          ? LeadType.values.firstWhere(
              (e) => e.name == json['leadType'],
              orElse: () => LeadType.individual,
            )
          : null,
      saleAttachment: json['saleAttachment'] as String?,
      policyType: json['policyType'] != null
          ? PolicyType.values.firstWhere(
              (e) => e.name == json['policyType'],
              orElse: () => PolicyType.newPolicy,
            )
          : null,
      premiumAmountEstimated: (json['premiumAmountEstimated'] as num?)?.toDouble(),
      realizationOfInsuranceNeed: json['realizationOfInsuranceNeed'] as String?,
      leadStatus: json['leadStatus'] != null
          ? LeadStatus.values.firstWhere(
              (e) => e.name == json['leadStatus'],
              orElse: () => LeadStatus.newLead,
            )
          : null,
      priority: json['priority'] != null
          ? LeadPriority.values.firstWhere(
              (e) => e.name == json['priority'],
              orElse: () => LeadPriority.medium,
            )
          : null,
      affordability: json['affordability'] as String?,
      remark: json['remark'] as String?,
      tags: json['tags'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'type': type.name,
      'timeAgo': timeAgo,
      'assignedAgentId': assignedAgentId,
      'activities': activities.map((e) => e.toJson()).toList(),
      'products': products.map((e) => e.toJson()).toList(),
      if (nrc != null) 'nrc': nrc,
      if (maritalStatus != null) 'maritalStatus': maritalStatus,
      if (jobTitle != null) 'jobTitle': jobTitle,
      if (roomNo != null) 'roomNo': roomNo,
      if (buildingNo != null) 'buildingNo': buildingNo,
      if (houseNo != null) 'houseNo': houseNo,
      if (streetNo != null) 'streetNo': streetNo,
      if (wardNo != null) 'wardNo': wardNo,
      if (town != null) 'town': town,
      if (township != null) 'township': township,
      if (stateRegion != null) 'stateRegion': stateRegion,
      if (companyName != null) 'companyName': companyName,
      if (headcounts != null) 'headcounts': headcounts,
      if (industry != null) 'industry': industry,
      if (leadType != null) 'leadType': leadType!.name,
      if (saleAttachment != null) 'saleAttachment': saleAttachment,
      if (policyType != null) 'policyType': policyType!.name,
      if (premiumAmountEstimated != null) 'premiumAmountEstimated': premiumAmountEstimated,
      if (realizationOfInsuranceNeed != null) 'realizationOfInsuranceNeed': realizationOfInsuranceNeed,
      if (leadStatus != null) 'leadStatus': leadStatus!.name,
      if (priority != null) 'priority': priority!.name,
      if (affordability != null) 'affordability': affordability,
      if (remark != null) 'remark': remark,
      if (tags != null) 'tags': tags,
    };
  }
}

// ==========================================
// 3. REPOSITORY SETUP
// ==========================================

class CRMRepository {
  final List<CRMContactModel> _mockContacts = [
    CRMContactModel(
      id: 'LEAD-2026-001',
      name: 'U Kyaw Swar',
      phone: '09791234567',
      email: 'kyawswar@example.com',
      type: ContactType.lead,
      timeAgo: '10 mins ago',
      assignedAgentId: 'AGENT-01',
      leadType: LeadType.corporate,
      companyName: 'Apex Logistics Co., Ltd',
      jobTitle: 'Managing Director',
      headcounts: '50',
      industry: 'Logistics',
      township: 'Kamayut',
      stateRegion: 'Yangon',
      leadStatus: LeadStatus.newLead,
      priority: LeadPriority.high,
      policyType: PolicyType.newPolicy,
      premiumAmountEstimated: 500000,
      products: [
        ProductModel(
          id: 'P01',
          name: 'Group Life',
          category: 'Group Insurance',
        ),
        ProductModel(
          id: 'P02',
          name: 'Credit Life',
          category: 'Protections',
        ),
      ],
      activities: [
        ActivityModel(
          id: 'ACT-01',
          type: ActivityType.call,
          title: 'Initial Discovery Call Completed',
          dateText: 'Today, 10:30 AM',
        ),
      ],
    ),
    CRMContactModel(
      id: 'CLIENT-2026-102',
      name: 'Daw Aye Thida',
      phone: '09450098765',
      email: 'ayethida@techhub.mm',
      type: ContactType.client,
      timeAgo: '2 hours ago',
      assignedAgentId: 'AGENT-02',
      leadType: LeadType.individual,
      nrc: '12/KaMaYa(N)334455',
      maritalStatus: 'Single',
      companyName: 'TechHub Retail Group',
      jobTitle: 'Head of Operations',
      headcounts: '25',
      industry: 'Technology',
      township: 'Bahan',
      stateRegion: 'Yangon',
      leadStatus: LeadStatus.won,
      priority: LeadPriority.medium,
      policyType: PolicyType.newPolicy,
      premiumAmountEstimated: 250000,
      products: [
        ProductModel(
          id: 'P04',
          name: 'Universal Life',
          category: 'Savings',
        ),
      ],
      activities: [],
    ),
  ];

  Future<List<CRMContactModel>> fetchContacts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockContacts);
  }

  Future<bool> addContact(CRMContactModel contact) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockContacts.insert(0, contact);
    return true;
  }
}
