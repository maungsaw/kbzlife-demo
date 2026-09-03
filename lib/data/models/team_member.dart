/// Doc 72 — one row in a leader's downline (direct report), shaped like
/// the FR-02 §3.2 6-up mockups: achievement ring + APE/FYP/SFYP/WFYP bars.
class TeamMember {
  const TeamMember({
    required this.id,
    required this.name,
    required this.role,
    required this.actual,
    required this.target,
    required this.ape,
    required this.fyp,
    required this.subsequentFyp,
    required this.weightedFyp,
    required this.mdrtPercent,
    this.newPolicies = 0,
    this.activePolicies = 0,
  });

  final String id;
  final String name;
  final String role;
  final int actual;
  final int target;
  final int ape;
  final int fyp;
  final int subsequentFyp;
  final int weightedFyp;

  /// 0-1+ progress toward MDRT — used to badge Qualified / In progress / Not yet.
  final double mdrtPercent;
  final int newPolicies;
  final int activePolicies;

  double get achievement => target == 0 ? 0 : actual / target;

  String get mdrtBadge {
    if (mdrtPercent >= 1) return 'MDRT Qualified';
    if (mdrtPercent >= 0.4) return 'MDRT In Progress';
    return 'Not Yet';
  }
}
