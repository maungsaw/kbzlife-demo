// ==========================================
// 1. ENUMS & CONSTANTS
// ==========================================

enum ContactType { lead, client }

enum ActivityType { call, meeting, note, email }

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

  // Additional detail fields
  final String? nrc;
  final String? maritalStatus;
  final String? roomNo;
  final String? buildingNo;
  final String? houseNo;
  final String? streetNo;
  final String? wardNo;
  final String? township;
  final String? stateRegion;
  final String? companyName;
  final String? headcounts;
  final String? jobTitle;

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
    this.roomNo,
    this.buildingNo,
    this.houseNo,
    this.streetNo,
    this.wardNo,
    this.township,
    this.stateRegion,
    this.companyName,
    this.headcounts,
    this.jobTitle,
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
      roomNo: json['roomNo'] as String?,
      buildingNo: json['buildingNo'] as String?,
      houseNo: json['houseNo'] as String?,
      streetNo: json['streetNo'] as String?,
      wardNo: json['wardNo'] as String?,
      township: json['township'] as String?,
      stateRegion: json['stateRegion'] as String?,
      companyName: json['companyName'] as String?,
      headcounts: json['headcounts'] as String?,
      jobTitle: json['jobTitle'] as String?,
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
      if (roomNo != null) 'roomNo': roomNo,
      if (buildingNo != null) 'buildingNo': buildingNo,
      if (houseNo != null) 'houseNo': houseNo,
      if (streetNo != null) 'streetNo': streetNo,
      if (wardNo != null) 'wardNo': wardNo,
      if (township != null) 'township': township,
      if (stateRegion != null) 'stateRegion': stateRegion,
      if (companyName != null) 'companyName': companyName,
      if (headcounts != null) 'headcounts': headcounts,
      if (jobTitle != null) 'jobTitle': jobTitle,
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
      companyName: 'Apex Logistics Co., Ltd',
      jobTitle: 'Managing Director',
      township: 'Kamayut',
      stateRegion: 'Yangon',
      products: [
        ProductModel(
          id: 'P01',
          name: 'ERP Software Suite',
          category: 'Software',
        ),
        ProductModel(
          id: 'P02',
          name: 'POS Terminal System',
          category: 'Hardware',
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
      companyName: 'TechHub Retail Group',
      jobTitle: 'Head of Operations',
      township: 'Bahan',
      stateRegion: 'Yangon',
      products: [
        ProductModel(
          id: 'P04',
          name: 'CRM Enterprise License',
          category: 'Software',
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
