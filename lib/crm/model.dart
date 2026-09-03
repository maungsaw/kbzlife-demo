import 'package:flutter/material.dart';

// ==========================================
// 1. ENUMS & MODELS
// ==========================================

/// Overall dynamic classification derived from assigned product stages
enum ContactType {
  lead, // All products are unqualified/pending/lost
  halfQualified, // At least 1 product is qualified AND at least 1 product is unqualified/pending
  client, // All active products are qualified
}

enum ProductStage { unqualified, pending, qualified, lost }

enum UserRole { dm, sam, am, fa }

enum GroupScope { personalGroup, totalGroup }

extension GroupScopeExtension on GroupScope {
  String get label {
    switch (this) {
      case GroupScope.personalGroup:
        return 'Personal Group';
      case GroupScope.totalGroup:
        return 'Total Group';
    }
  }
}

extension UserRoleExtension on UserRole {
  String get label {
    switch (this) {
      case UserRole.dm:
        return 'DM';
      case UserRole.sam:
        return 'SAM';
      case UserRole.am:
        return 'AM';
      case UserRole.fa:
        return 'FA';
    }
  }
}

class CRMUser {
  final String id;
  final String name;
  final UserRole role;
  final String? managerId;

  CRMUser({
    required this.id,
    required this.name,
    required this.role,
    this.managerId,
  });
}

class ActivityLog {
  final String title;
  final DateTime timestamp;
  final String note;
  final IconData icon;

  ActivityLog({
    required this.title,
    required this.timestamp,
    required this.note,
    required this.icon,
  });
}

/// Product Opportunity nested under a Contact
class CRMProductOpportunity {
  final String id;
  final String productName;
  final ProductStage stage;
  final double estimatedValue;

  CRMProductOpportunity({
    required this.id,
    required this.productName,
    required this.stage,
    required this.estimatedValue,
  });
}

class CRMContactModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String assignedAgentId;
  final List<CRMProductOpportunity> products;
  final List<ActivityLog> activities;
  final String timeAgo;

  CRMContactModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.assignedAgentId,
    required this.products,
    required this.activities,
    required this.timeAgo,
  });

  /// Evaluates product stages to derive overall classification
  ContactType get contactType {
    if (products.isEmpty) return ContactType.lead;

    final hasQualified = products.any((p) => p.stage == ProductStage.qualified);
    final hasUnqualified = products.any(
      (p) =>
          p.stage == ProductStage.unqualified ||
          p.stage == ProductStage.pending,
    );

    if (hasQualified && hasUnqualified) {
      return ContactType.halfQualified;
    } else if (hasQualified) {
      return ContactType.client;
    } else {
      return ContactType.lead;
    }
  }

  /// Aggregated financial estimate across all products
  double get totalEstimatedValue {
    return products.fold(0.0, (sum, item) => sum + item.estimatedValue);
  }

  /// Consolidated string summary of products for UI list views
  String get productSummary {
    if (products.isEmpty) return 'No Products';
    return products.map((p) => p.productName).join(', ');
  }

  String get typeLabel {
    switch (contactType) {
      case ContactType.lead:
        return 'Unqualified';
      case ContactType.halfQualified:
        return 'Half-Qualified';
      case ContactType.client:
        return 'Qualified';
    }
  }

  Color get typeColor {
    switch (contactType) {
      case ContactType.lead:
        return Colors.orange.shade800;
      case ContactType.halfQualified:
        return Colors.purple.shade700;
      case ContactType.client:
        return Colors.green.shade700;
    }
  }
}

// ==========================================
// 2. REPOSITORY & MOCK DATA
// ==========================================
class CRMRepository {
  final List<CRMUser> users = [
    CRMUser(id: 'usr_dm', name: 'U San Lwin', role: UserRole.dm),
    CRMUser(
      id: 'usr_sam1',
      name: 'Ko Thura',
      role: UserRole.sam,
      managerId: 'usr_dm',
    ),
    CRMUser(
      id: 'usr_sam2',
      name: 'Daw Nu Nu',
      role: UserRole.sam,
      managerId: 'usr_dm',
    ),
    CRMUser(
      id: 'usr_am1',
      name: 'Aung Hein',
      role: UserRole.am,
      managerId: 'usr_sam1',
    ),
    CRMUser(
      id: 'usr_am2',
      name: 'Khin Than',
      role: UserRole.am,
      managerId: 'usr_sam2',
    ),
    CRMUser(
      id: 'usr_fa1',
      name: 'Ma Zin Mar',
      role: UserRole.fa,
      managerId: 'usr_am1',
    ),
    CRMUser(
      id: 'usr_fa2',
      name: 'U Min Thu',
      role: UserRole.fa,
      managerId: 'usr_am1',
    ),
    CRMUser(
      id: 'usr_fa3',
      name: 'Ko Htet Naing',
      role: UserRole.fa,
      managerId: 'usr_am2',
    ),
  ];

  Future<List<CRMContactModel>> fetchContacts() async {
    await Future.delayed(const Duration(milliseconds: 150));

    return [
      // 1. Half-Qualified Lead: 2 products (1 Qualified + 1 Unqualified)
      CRMContactModel(
        id: 'CONTACT-2024-001',
        name: 'Aung Kyaw Moe',
        phone: '09-123-456-789',
        email: 'aung.kyaw@example.com',
        assignedAgentId: 'usr_fa1',
        timeAgo: '2h ago',
        activities: [],
        products: [
          CRMProductOpportunity(
            id: 'PROD-001',
            productName: 'Life Insurance',
            stage: ProductStage.qualified,
            estimatedValue: 500000.0,
          ),
          CRMProductOpportunity(
            id: 'PROD-002',
            productName: 'Health Insurance',
            stage: ProductStage.unqualified,
            estimatedValue: 200000.0,
          ),
        ],
      ),

      // 2. Fully Qualified Client: 1 product (Qualified)
      CRMContactModel(
        id: 'CONTACT-2024-002',
        name: 'Daw Su Su',
        phone: '09-222-333-444',
        email: 'susu@example.com',
        assignedAgentId: 'usr_fa1',
        timeAgo: '1d ago',
        activities: [],
        products: [
          CRMProductOpportunity(
            id: 'PROD-003',
            productName: 'Education Plan',
            stage: ProductStage.qualified,
            estimatedValue: 1200000.0,
          ),
        ],
      ),

      // 3. Unqualified Lead: 1 product (Unqualified)
      CRMContactModel(
        id: 'CONTACT-2024-003',
        name: 'Thida Win',
        phone: '09-987-654-321',
        email: 'thida.win@example.com',
        assignedAgentId: 'usr_fa2',
        timeAgo: '5h ago',
        activities: [],
        products: [
          CRMProductOpportunity(
            id: 'PROD-004',
            productName: 'Health Insurance',
            stage: ProductStage.unqualified,
            estimatedValue: 300000.0,
          ),
        ],
      ),

      // 4. Fully Qualified Client: 2 products (Both Qualified)
      CRMContactModel(
        id: 'CONTACT-2024-004',
        name: 'Daw Khin Moe',
        phone: '09-777-888-999',
        email: 'khinmoe@example.com',
        assignedAgentId: 'usr_fa3',
        timeAgo: '3d ago',
        activities: [],
        products: [
          CRMProductOpportunity(
            id: 'PROD-005',
            productName: 'Income Protection Plan',
            stage: ProductStage.qualified,
            estimatedValue: 2500000.0,
          ),
          CRMProductOpportunity(
            id: 'PROD-006',
            productName: 'Property Protection',
            stage: ProductStage.qualified,
            estimatedValue: 1000000.0,
          ),
        ],
      ),

      // 5. Unqualified Lead: 2 products (Both Pending/Unqualified)
      CRMContactModel(
        id: 'CONTACT-2024-005',
        name: 'Kyaw Zayar',
        phone: '09-555-666-777',
        email: 'kyaw.zayar@example.com',
        assignedAgentId: 'usr_am1',
        timeAgo: '10m ago',
        activities: [],
        products: [
          CRMProductOpportunity(
            id: 'PROD-007',
            productName: 'Property Protection',
            stage: ProductStage.unqualified,
            estimatedValue: 800000.0,
          ),
          CRMProductOpportunity(
            id: 'PROD-008',
            productName: 'Motor Insurance',
            stage: ProductStage.qualified,
            estimatedValue: 400000.0,
          ),
        ],
      ),
    ];
  }
}
