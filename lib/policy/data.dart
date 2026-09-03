import 'package:flutter/material.dart';

enum UserRole { dm, sam, am, fa }

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

  Color get color {
    switch (this) {
      case UserRole.dm:
        return Colors.purple;
      case UserRole.sam:
        return Colors.indigo;
      case UserRole.am:
        return Colors.teal;
      case UserRole.fa:
        return Colors.blueGrey;
    }
  }
}

class CRMUser {
  final String id;
  final String name;
  final UserRole role;
  final String? managerId;

  const CRMUser({
    required this.id,
    required this.name,
    required this.role,
    this.managerId,
  });
}

class PolicyModel {
  final String policyNo;
  final String clientName;
  final String plan;
  final String nextDue;
  final String premium;
  final String status;
  final String assignedAgentId;

  const PolicyModel({
    required this.policyNo,
    required this.clientName,
    required this.plan,
    required this.nextDue,
    required this.premium,
    required this.status,
    required this.assignedAgentId,
  });
}

class PolicyRepository {
  final List<CRMUser> users = const [
    CRMUser(id: 'usr_md', name: 'U San Lwin', role: UserRole.dm),
    CRMUser(
      id: 'usr_sam1',
      name: 'Ko Thura',
      role: UserRole.sam,
      managerId: 'usr_md',
    ),
    CRMUser(
      id: 'usr_sam2',
      name: 'Daw Nu Nu',
      role: UserRole.sam,
      managerId: 'usr_md',
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

  List<PolicyModel> fetchPolicies = const [
    PolicyModel(
      policyNo: 'POL12345681',
      clientName: 'Daw Su Su',
      plan: 'Education Plan',
      nextDue: '05 Nov 2025',
      premium: 'MMK 60,000',
      status: 'Active',
      assignedAgentId: 'usr_fa1',
    ),
    PolicyModel(
      policyNo: 'POL12345685',
      clientName: 'U Kyaw Swar',
      plan: 'Health Shield',
      nextDue: '12 Dec 2025',
      premium: 'MMK 95,000',
      status: 'Active',
      assignedAgentId: 'usr_fa1',
    ),
    PolicyModel(
      policyNo: 'POL12345688',
      clientName: 'Daw Aye Aye',
      plan: 'Life Protect',
      nextDue: '18 Jan 2026',
      premium: 'MMK 110,000',
      status: 'Pending',
      assignedAgentId: 'usr_fa2',
    ),
    PolicyModel(
      policyNo: 'POL12345679',
      clientName: 'Daw Khin Moe',
      plan: 'Income Protection Plan',
      nextDue: '01 Oct 2025',
      premium: 'MMK 80,000',
      status: 'Active',
      assignedAgentId: 'usr_fa3',
    ),
    PolicyModel(
      policyNo: 'POL12345690',
      clientName: 'U San Lwin',
      plan: 'Executive Life Shield',
      nextDue: '15 Dec 2025',
      premium: 'MMK 250,000',
      status: 'Active',
      assignedAgentId: 'usr_md',
    ),
  ];
}
