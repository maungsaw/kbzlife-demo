import '../models/team_line.dart';
import '../models/team_member.dart';

/// Mock downline for the Team Performance hub (doc 32/72/72-two-roles).
/// [members] is the viewer's direct ("Personal Team") FAs; [indirectMembers]
/// are FAs one level further down the SAM/AM lines, only surfaced under
/// "Total Group" — together they stand in for the SAM→AM→FA hierarchy
/// without inventing a real org-graph data layer.
class MockTeamData {
  MockTeamData._();

  static const myPerformance = TeamMember(
    id: 'ME',
    name: 'You',
    role: 'FA',
    actual: 8400000,
    target: 11800000,
    ape: 8400000,
    fyp: 6200000,
    subsequentFyp: 1800000,
    weightedFyp: 5100000,
    mdrtPercent: 0.71,
    newPolicies: 8,
    activePolicies: 12,
  );

  static const members = <TeamMember>[
    TeamMember(id: 'FA-1', name: 'U Win Naing', role: 'FA', actual: 12700000, target: 11800000, ape: 12700000, fyp: 9100000, subsequentFyp: 2400000, weightedFyp: 7800000, mdrtPercent: 1.08, newPolicies: 14, activePolicies: 20),
    TeamMember(id: 'FA-2', name: 'Daw Aye Aye', role: 'FA', actual: 6100000, target: 10000000, ape: 6100000, fyp: 4200000, subsequentFyp: 1100000, weightedFyp: 3600000, mdrtPercent: 0.52, newPolicies: 6, activePolicies: 9),
    TeamMember(id: 'FA-3', name: 'Ko Zaw Min', role: 'FA', actual: 3200000, target: 9500000, ape: 3200000, fyp: 2100000, subsequentFyp: 600000, weightedFyp: 1900000, mdrtPercent: 0.24, newPolicies: 3, activePolicies: 5),
    TeamMember(id: 'FA-4', name: 'Daw Su Mon', role: 'FA', actual: 9800000, target: 10200000, ape: 9800000, fyp: 6700000, subsequentFyp: 1900000, weightedFyp: 5900000, mdrtPercent: 0.83, newPolicies: 10, activePolicies: 16),
    TeamMember(id: 'FA-5', name: 'Ko Htet Aung', role: 'FA', actual: 1400000, target: 8000000, ape: 1400000, fyp: 900000, subsequentFyp: 200000, weightedFyp: 800000, mdrtPercent: 0.09, newPolicies: 1, activePolicies: 2),
  ];

  /// One level further down the tree than [members] — only visible under
  /// "Total Group" (doc 72 §1/§3: SAM sees AMs + their FAs, DM sees
  /// SAMs + AMs + FAs). Kept separate from [members] so Personal Team
  /// never accidentally mixes in indirect reports.
  static const indirectMembers = <TeamMember>[
    TeamMember(id: 'FA-6', name: 'Ma Thandar Hlaing', role: 'FA', actual: 10500000, target: 9800000, ape: 10500000, fyp: 7300000, subsequentFyp: 2000000, weightedFyp: 6100000, mdrtPercent: 1.15, newPolicies: 11, activePolicies: 17),
    TeamMember(id: 'FA-7', name: 'Ko Nay Lin', role: 'FA', actual: 4800000, target: 9200000, ape: 4800000, fyp: 3300000, subsequentFyp: 900000, weightedFyp: 2800000, mdrtPercent: 0.44, newPolicies: 5, activePolicies: 7),
    TeamMember(id: 'FA-8', name: 'Daw Khin Mya', role: 'FA', actual: 2100000, target: 8600000, ape: 2100000, fyp: 1400000, subsequentFyp: 300000, weightedFyp: 1200000, mdrtPercent: 0.17, newPolicies: 2, activePolicies: 3),
    TeamMember(id: 'FA-9', name: 'Ko Aung Kyaw', role: 'FA', actual: 700000, target: 7500000, ape: 700000, fyp: 450000, subsequentFyp: 100000, weightedFyp: 400000, mdrtPercent: 0.03, newPolicies: 0, activePolicies: 1),
  ];

  /// Every FA visible to this viewer once Total Group is toggled on.
  static const allMembers = <TeamMember>[...members, ...indirectMembers];

  /// Total Group hierarchy (doc 72 §3/§6 `s-group`): the AM/SAM lines
  /// under this viewer, each rolling up a slice of [allMembers].
  static const lines = <TeamLine>[
    TeamLine(id: 'AM-1', name: 'AM 01 · Yangon', role: 'AM', region: 'Yangon', actual: 29300000, target: 31600000, memberIds: ['FA-1', 'FA-2', 'FA-6']),
    TeamLine(id: 'AM-2', name: 'AM 02 · Mandalay', role: 'AM', region: 'Mandalay', actual: 22000000, target: 53000000, memberIds: ['FA-3', 'FA-4', 'FA-5', 'FA-7', 'FA-8', 'FA-9']),
  ];
}
