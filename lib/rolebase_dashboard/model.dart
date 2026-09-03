// ============================================================================
// ENUMS & HELPERS
// ============================================================================

enum UserRole {
  dm, // District Manager
  sam, // Senior Agency Manager
  am, // Agency Manager
  fa, // Financial Advisor
}

enum DashboardTab {
  overview,
  teamStructure,
}

String pluralRoleLabel(UserRole role) {
  switch (role) {
    case UserRole.dm:
      return 'District Managers';
    case UserRole.sam:
      return 'Senior Agency Managers';
    case UserRole.am:
      return 'Agency Managers';
    case UserRole.fa:
      return 'Financial Advisors';
  }
}

bool canDirectAccess({
  required UserRole parentRole,
  required UserRole childRole,
}) {
  switch (parentRole) {
    case UserRole.dm:
      return childRole == UserRole.sam;
    case UserRole.sam:
      return childRole == UserRole.am;
    case UserRole.am:
      return childRole == UserRole.fa;
    case UserRole.fa:
      return false;
  }
}

// ============================================================================
// METRIC DATA MODELS (BRD ALIGNED)
// ============================================================================

class FypMetric {
  final double totalFyp;
  final double initialFyp;
  final double subsequentFyp;
  final double weightedFyp;
  final double momGrowth;

  const FypMetric({
    required this.totalFyp,
    required this.initialFyp,
    required this.subsequentFyp,
    required this.weightedFyp,
    required this.momGrowth,
  });
}

class PolicyCountMetric {
  final int totalCount;
  final int newPolicyCount;
  final int existingActiveCount;

  const PolicyCountMetric({
    required this.totalCount,
    required this.newPolicyCount,
    required this.existingActiveCount,
  });
}

class DueCollectionMetric {
  final int numberOfDues;
  final double dueAmount;
  final double collectedAmount;
  final double collectionRatio;

  const DueCollectionMetric({
    required this.numberOfDues,
    required this.dueAmount,
    required this.collectedAmount,
    required this.collectionRatio,
  });
}

class CommissionMetric {
  final double standardCommission;
  final double ulAdditionalCommission;
  final double totalCommission;

  const CommissionMetric({
    required this.standardCommission,
    required this.ulAdditionalCommission,
    required this.totalCommission,
  });
}

class MdrtTracker {
  final double eligiblePremium;
  final double targetThreshold;
  final double commissionTracker;

  const MdrtTracker({
    required this.eligiblePremium,
    required this.targetThreshold,
    required this.commissionTracker,
  });

  double get progressPercentage {
    if (targetThreshold == 0) return 0.0;
    final ratio = eligiblePremium / targetThreshold;
    return ratio > 1.0 ? 1.0 : ratio;
  }
}

class PersistencyMetric {
  final double policyRetentionRate;
  final String gracePeriodStatus;
  final double policyCountRatio;
  final double premiumAmountRatio;

  const PersistencyMetric({
    required this.policyRetentionRate,
    required this.gracePeriodStatus,
    required this.policyCountRatio,
    required this.premiumAmountRatio,
  });
}

class AgentPerformanceData {
  final FypMetric fyp;
  final double ape;
  final double apeMomGrowth;
  final PolicyCountMetric policyCount;
  final DueCollectionMetric dueCollection;
  final CommissionMetric commission;
  final MdrtTracker mdrt;
  final PersistencyMetric k1Persistency;
  final PersistencyMetric k2Persistency;
  final bool isRedFlag;
  final double targetVariance;
  final double target;
  final double actual;

  const AgentPerformanceData({
    required this.fyp,
    required this.ape,
    required this.apeMomGrowth,
    required this.policyCount,
    required this.dueCollection,
    required this.commission,
    required this.mdrt,
    required this.k1Persistency,
    required this.k2Persistency,
    required this.isRedFlag,
    required this.targetVariance,
    required this.target,
    required this.actual,
  });
}

// ============================================================================
// HIERARCHY NODE MODEL
// ============================================================================

class HierarchyNodeModel {
  final String id;
  final String name;
  final String designation;
  final UserRole role;
  final AgentPerformanceData metrics;
  final List<HierarchyNodeModel> directTeam;
  final List<HierarchyNodeModel> indirectTeam;

  const HierarchyNodeModel({
    required this.id,
    required this.name,
    required this.designation,
    required this.role,
    required this.metrics,
    this.directTeam = const [],
    this.indirectTeam = const [],
  });

  bool get hasDirectTeam => directTeam.isNotEmpty;
  bool get hasIndirectTeam => indirectTeam.isNotEmpty;

  bool get isFA => role == UserRole.fa;
  bool get isLeader => role != UserRole.fa;
}
