import 'model.dart';

// ============================================================================
// MOCK METRIC GENERATORS
// ============================================================================

AgentPerformanceData getDmMetrics() {
  return const AgentPerformanceData(
    fyp: FypMetric(
      totalFyp: 145.0,
      initialFyp: 110.0,
      subsequentFyp: 35.0,
      weightedFyp: 128.0,
      momGrowth: 14.2,
    ),
    ape: 168.5,
    apeMomGrowth: 14.2,
    policyCount: PolicyCountMetric(
      totalCount: 340,
      newPolicyCount: 48,
      existingActiveCount: 292,
    ),
    dueCollection: DueCollectionMetric(
      numberOfDues: 185,
      dueAmount: 152.0,
      collectedAmount: 138.0,
      collectionRatio: 90.8,
    ),
    commission: CommissionMetric(
      standardCommission: 22.5,
      ulAdditionalCommission: 6.0,
      totalCommission: 28.5,
    ),
    mdrt: MdrtTracker(
      eligiblePremium: 120.0,
      targetThreshold: 150.0,
      commissionTracker: 24.0,
    ),
    k1Persistency: PersistencyMetric(
      policyRetentionRate: 91.5,
      gracePeriodStatus: 'Optimal',
      policyCountRatio: 92.3,
      premiumAmountRatio: 90.8,
    ),
    k2Persistency: PersistencyMetric(
      policyRetentionRate: 88.0,
      gracePeriodStatus: 'Normal',
      policyCountRatio: 89.1,
      premiumAmountRatio: 87.5,
    ),
    isRedFlag: false,
    targetVariance: 3.5,
    target: 160.0,
    actual: 125.4,
  );
}

AgentPerformanceData getSamMetrics() {
  return const AgentPerformanceData(
    fyp: FypMetric(
      totalFyp: 68.0,
      initialFyp: 52.0,
      subsequentFyp: 16.0,
      weightedFyp: 58.5,
      momGrowth: 9.8,
    ),
    ape: 79.2,
    apeMomGrowth: 9.8,
    policyCount: PolicyCountMetric(
      totalCount: 155,
      newPolicyCount: 22,
      existingActiveCount: 133,
    ),
    dueCollection: DueCollectionMetric(
      numberOfDues: 82,
      dueAmount: 70.5,
      collectedAmount: 62.0,
      collectionRatio: 87.9,
    ),
    commission: CommissionMetric(
      standardCommission: 10.2,
      ulAdditionalCommission: 2.6,
      totalCommission: 12.8,
    ),
    mdrt: MdrtTracker(
      eligiblePremium: 58.0,
      targetThreshold: 75.0,
      commissionTracker: 11.6,
    ),
    k1Persistency: PersistencyMetric(
      policyRetentionRate: 89.0,
      gracePeriodStatus: 'Optimal',
      policyCountRatio: 90.2,
      premiumAmountRatio: 88.5,
    ),
    k2Persistency: PersistencyMetric(
      policyRetentionRate: 84.5,
      gracePeriodStatus: 'Watchlist',
      policyCountRatio: 85.8,
      premiumAmountRatio: 83.2,
    ),
    isRedFlag: false,
    targetVariance: -2.1,
    target: 85.0,
    actual: 68.0,
  );
}

AgentPerformanceData getAmMetrics() {
  return const AgentPerformanceData(
    fyp: FypMetric(
      totalFyp: 22.5,
      initialFyp: 18.0,
      subsequentFyp: 4.5,
      weightedFyp: 19.8,
      momGrowth: -4.5,
    ),
    ape: 26.4,
    apeMomGrowth: -4.5,
    policyCount: PolicyCountMetric(
      totalCount: 52,
      newPolicyCount: 6,
      existingActiveCount: 46,
    ),
    dueCollection: DueCollectionMetric(
      numberOfDues: 28,
      dueAmount: 24.0,
      collectedAmount: 19.2,
      collectionRatio: 80.0,
    ),
    commission: CommissionMetric(
      standardCommission: 3.5,
      ulAdditionalCommission: 0.7,
      totalCommission: 4.2,
    ),
    mdrt: MdrtTracker(
      eligiblePremium: 18.5,
      targetThreshold: 30.0,
      commissionTracker: 3.7,
    ),
    k1Persistency: PersistencyMetric(
      policyRetentionRate: 82.0,
      gracePeriodStatus: 'Requires Review',
      policyCountRatio: 83.5,
      premiumAmountRatio: 80.8,
    ),
    k2Persistency: PersistencyMetric(
      policyRetentionRate: 77.5,
      gracePeriodStatus: 'Attention Needed',
      policyCountRatio: 78.9,
      premiumAmountRatio: 76.2,
    ),
    isRedFlag: true,
    targetVariance: -12.4,
    target: 35.0,
    actual: 22.5,
  );
}

AgentPerformanceData getFaMetrics() {
  return const AgentPerformanceData(
    fyp: FypMetric(
      totalFyp: 7.2,
      initialFyp: 6.0,
      subsequentFyp: 1.2,
      weightedFyp: 6.5,
      momGrowth: 18.3,
    ),
    ape: 8.5,
    apeMomGrowth: 18.3,
    policyCount: PolicyCountMetric(
      totalCount: 16,
      newPolicyCount: 3,
      existingActiveCount: 13,
    ),
    dueCollection: DueCollectionMetric(
      numberOfDues: 8,
      dueAmount: 7.5,
      collectedAmount: 6.8,
      collectionRatio: 90.7,
    ),
    commission: CommissionMetric(
      standardCommission: 1.2,
      ulAdditionalCommission: 0.3,
      totalCommission: 1.5,
    ),
    mdrt: MdrtTracker(
      eligiblePremium: 8.5,
      targetThreshold: 10.0,
      commissionTracker: 1.7,
    ),
    k1Persistency: PersistencyMetric(
      policyRetentionRate: 95.0,
      gracePeriodStatus: 'Excellent',
      policyCountRatio: 96.2,
      premiumAmountRatio: 94.5,
    ),
    k2Persistency: PersistencyMetric(
      policyRetentionRate: 92.0,
      gracePeriodStatus: 'Optimal',
      policyCountRatio: 93.1,
      premiumAmountRatio: 91.8,
    ),
    isRedFlag: false,
    targetVariance: 8.2,
    target: 8.0,
    actual: 7.2,
  );
}

// ============================================================================
// ADDITIONAL FA METRICS FOR TEAM MEMBERS
// ============================================================================

AgentPerformanceData getFaMetrics2() {
  return const AgentPerformanceData(
    fyp: FypMetric(
      totalFyp: 5.8,
      initialFyp: 4.5,
      subsequentFyp: 1.3,
      weightedFyp: 5.2,
      momGrowth: -2.1,
    ),
    ape: 6.8,
    apeMomGrowth: -2.1,
    policyCount: PolicyCountMetric(
      totalCount: 12,
      newPolicyCount: 2,
      existingActiveCount: 10,
    ),
    dueCollection: DueCollectionMetric(
      numberOfDues: 6,
      dueAmount: 6.2,
      collectedAmount: 5.5,
      collectionRatio: 88.7,
    ),
    commission: CommissionMetric(
      standardCommission: 0.9,
      ulAdditionalCommission: 0.2,
      totalCommission: 1.1,
    ),
    mdrt: MdrtTracker(
      eligiblePremium: 5.8,
      targetThreshold: 10.0,
      commissionTracker: 1.16,
    ),
    k1Persistency: PersistencyMetric(
      policyRetentionRate: 88.0,
      gracePeriodStatus: 'Normal',
      policyCountRatio: 89.5,
      premiumAmountRatio: 87.2,
    ),
    k2Persistency: PersistencyMetric(
      policyRetentionRate: 85.0,
      gracePeriodStatus: 'Normal',
      policyCountRatio: 86.3,
      premiumAmountRatio: 84.1,
    ),
    isRedFlag: false,
    targetVariance: -5.2,
    target: 8.0,
    actual: 5.8,
  );
}

AgentPerformanceData getFaMetrics3() {
  return const AgentPerformanceData(
    fyp: FypMetric(
      totalFyp: 8.5,
      initialFyp: 7.0,
      subsequentFyp: 1.5,
      weightedFyp: 7.8,
      momGrowth: 22.5,
    ),
    ape: 10.2,
    apeMomGrowth: 22.5,
    policyCount: PolicyCountMetric(
      totalCount: 18,
      newPolicyCount: 4,
      existingActiveCount: 14,
    ),
    dueCollection: DueCollectionMetric(
      numberOfDues: 10,
      dueAmount: 9.0,
      collectedAmount: 8.2,
      collectionRatio: 91.1,
    ),
    commission: CommissionMetric(
      standardCommission: 1.5,
      ulAdditionalCommission: 0.35,
      totalCommission: 1.85,
    ),
    mdrt: MdrtTracker(
      eligiblePremium: 8.5,
      targetThreshold: 10.0,
      commissionTracker: 1.7,
    ),
    k1Persistency: PersistencyMetric(
      policyRetentionRate: 93.0,
      gracePeriodStatus: 'Excellent',
      policyCountRatio: 94.2,
      premiumAmountRatio: 92.8,
    ),
    k2Persistency: PersistencyMetric(
      policyRetentionRate: 90.0,
      gracePeriodStatus: 'Optimal',
      policyCountRatio: 91.5,
      premiumAmountRatio: 89.2,
    ),
    isRedFlag: false,
    targetVariance: 6.3,
    target: 8.0,
    actual: 8.5,
  );
}

// ============================================================================
// SAMPLE HIERARCHY DATA
// ============================================================================

HierarchyNodeModel createFaNode({
  required String id,
  required String name,
  AgentPerformanceData? metrics,
}) {
  return HierarchyNodeModel(
    id: id,
    name: name,
    designation: 'Financial Advisor',
    role: UserRole.fa,
    metrics: metrics ?? getFaMetrics(),
    directTeam: const [],
    indirectTeam: const [],
  );
}

HierarchyNodeModel createAmNode({required String id, required String name}) {
  final fa001 = createFaNode(
    id: '$id-FA-001',
    name: 'Ko Tun Tun',
    metrics: getFaMetrics(),
  );
  final fa002 = createFaNode(
    id: '$id-FA-002',
    name: 'Ma San San',
    metrics: getFaMetrics2(),
  );
  final fa003 = createFaNode(
    id: '$id-FA-003',
    name: 'U Kyaw Swar',
    metrics: getFaMetrics3(),
  );

  return HierarchyNodeModel(
    id: id,
    name: name,
    designation: 'Agency Manager',
    role: UserRole.am,
    metrics: getAmMetrics(),
    directTeam: [fa001, fa002, fa003],
    indirectTeam: const [],
  );
}

HierarchyNodeModel createSamNode({required String id, required String name}) {
  final am001 = createAmNode(id: '$id-AM-001', name: 'Ko Min Aung');
  final am002 = createAmNode(id: '$id-AM-002', name: 'Ma Thandar');

  final allFAs = [...am001.directTeam, ...am002.directTeam];

  return HierarchyNodeModel(
    id: id,
    name: name,
    designation: 'Senior Agency Manager',
    role: UserRole.sam,
    metrics: getSamMetrics(),
    directTeam: [am001, am002],
    indirectTeam: allFAs,
  );
}

HierarchyNodeModel createDmNode() {
  final sam001 = createSamNode(id: 'SAM-001', name: 'Daw Aye Aye');
  final sam002 = createSamNode(id: 'SAM-002', name: 'U Tin Oo');

  final allAMs = [...sam001.directTeam, ...sam002.directTeam];
  final allFAs = [...sam001.indirectTeam, ...sam002.indirectTeam];

  return HierarchyNodeModel(
    id: 'DM-001',
    name: 'U Ba Than',
    designation: 'District Manager',
    role: UserRole.dm,
    metrics: getDmMetrics(),
    directTeam: [sam001, sam002],
    indirectTeam: [...allAMs, ...allFAs],
  );
}

/// Root instance to use across your app
final HierarchyNodeModel sampleHierarchy = createDmNode();
