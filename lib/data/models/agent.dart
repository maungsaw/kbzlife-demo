/// Role hierarchy per BRD §4.2 — FA up to HOA, plus Super Admin.
enum AgentRole { fa, am, sam, dm, aadm, adm, sadm, radm, hoa, superAdmin }

extension AgentRoleX on AgentRole {
  String get label => switch (this) {
        AgentRole.fa => 'FA',
        AgentRole.am => 'AM',
        AgentRole.sam => 'SAM',
        AgentRole.dm => 'DM',
        AgentRole.aadm => 'AADM',
        AgentRole.adm => 'ADM',
        AgentRole.sadm => 'SADM',
        AgentRole.radm => 'RADM',
        AgentRole.hoa => 'HOA',
        AgentRole.superAdmin => 'Admin',
      };

  /// FR-02.3: managers (AM and above) also see the Freelance Management /
  /// Team Pulse view; a plain FA only sees personal performance.
  bool get isManager => this != AgentRole.fa;
}

class Agent {
  const Agent({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
    this.photoUrl,
  });

  final String id;
  final String name;
  final AgentRole role;
  final String phone;
  final String? photoUrl;
}
