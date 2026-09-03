import 'package:flutter_riverpod/legacy.dart';

class RolebaseDashboardController extends StateNotifier<RolebaseDashboardState> {
  RolebaseDashboardController() : super(const RolebaseDashboardState());

  void setTab(int index) => state = state.copyWith(selectedTab: index);
  void setTeamFilter(String filter) =>
      state = state.copyWith(selectedTeamFilter: filter);
  void toggleFilter() =>
      state = state.copyWith(isFilterOpen: !state.isFilterOpen);
  void pushBreadcrumb(String name) {
    state = state.copyWith(
      breadcrumb: [...state.breadcrumb, name],
    );
  }

  void popBreadcrumb() {
    if (state.breadcrumb.length > 1) {
      state = state.copyWith(
        breadcrumb:
            state.breadcrumb.sublist(0, state.breadcrumb.length - 1),
      );
    }
  }
}

class RolebaseDashboardState {
  final int selectedTab;
  final List<String> breadcrumb;
  final String selectedTeamFilter;
  final bool isFilterOpen;

  const RolebaseDashboardState({
    this.selectedTab = 0,
    this.breadcrumb = const ['Dashboard'],
    this.selectedTeamFilter = 'All',
    this.isFilterOpen = false,
  });

  RolebaseDashboardState copyWith({
    int? selectedTab,
    List<String>? breadcrumb,
    String? selectedTeamFilter,
    bool? isFilterOpen,
  }) {
    return RolebaseDashboardState(
      selectedTab: selectedTab ?? this.selectedTab,
      breadcrumb: breadcrumb ?? this.breadcrumb,
      selectedTeamFilter: selectedTeamFilter ?? this.selectedTeamFilter,
      isFilterOpen: isFilterOpen ?? this.isFilterOpen,
    );
  }
}

final rolebaseDashboardProvider =
    StateNotifierProvider<RolebaseDashboardController, RolebaseDashboardState>(
  (ref) => RolebaseDashboardController(),
);
