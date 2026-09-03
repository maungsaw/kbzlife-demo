/// Doc 72 §6/§9 — one node in the group hierarchy (a SAM or AM "line"),
/// shown on Total Group (`s-group`). Each line rolls up a set of
/// [TeamMember] FAs; the prototype keeps mock lines flat rather than
/// inventing a real org-graph data layer.
class TeamLine {
  const TeamLine({
    required this.id,
    required this.name,
    required this.role,
    required this.region,
    required this.actual,
    required this.target,
    required this.memberIds,
  });

  final String id;
  final String name;

  /// e.g. "SAM" or "AM" — the level this line represents.
  final String role;
  final String region;
  final int actual;
  final int target;

  /// [TeamMember.id]s that roll up under this line — used to drill from
  /// Total Group into the line's own FA list (`s-line`).
  final List<String> memberIds;

  int get faCount => memberIds.length;
  double get achievement => target == 0 ? 0 : actual / target;
}
