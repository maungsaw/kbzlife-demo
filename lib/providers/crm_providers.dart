import 'package:flutter_riverpod/legacy.dart';

import '../../crm/model.dart';

// CRM Dashboard state (for crm/crm.dart)
class CrmDashboardController extends StateNotifier<CrmDashboardState> {
  CrmDashboardController() : super(const CrmDashboardState());

  void setSearchQuery(String query) =>
      state = state.copyWith(searchQuery: query);

  void setTypeFilter(ContactType? type) =>
      state = state.copyWith(selectedTypeFilter: type);

  void setStageFilter(ProductStage? stage) =>
      state = state.copyWith(selectedStageFilter: stage);

  void setAgentFilter(String? agentId) =>
      state = state.copyWith(selectedAgentFilter: agentId);

  void setGroupScope(GroupScope scope) =>
      state = state.copyWith(selectedGroupScope: scope);

  void pushUser(CRMUser user) {
    state = state.copyWith(
      navigationStack: [...state.navigationStack, user],
    );
  }

  void popUser() {
    if (state.navigationStack.length > 1) {
      state = state.copyWith(
        navigationStack: state.navigationStack
            .sublist(0, state.navigationStack.length - 1),
      );
    }
  }

  void popToIndex(int index) {
    state = state.copyWith(
      navigationStack:
          state.navigationStack.sublist(0, index + 1),
    );
  }

  void resetFilters() {
    state = state.copyWith(
      selectedTypeFilter: null,
      selectedStageFilter: null,
      selectedAgentFilter: null,
      clearTypeFilter: true,
      clearStageFilter: true,
      clearAgentFilter: true,
    );
  }

  void setLoading(bool loading) =>
      state = state.copyWith(isLoading: loading);
}

class CrmDashboardState {
  final GroupScope selectedGroupScope;
  final String searchQuery;
  final ContactType? selectedTypeFilter;
  final ProductStage? selectedStageFilter;
  final String? selectedAgentFilter;
  final List<CRMUser> navigationStack;
  final bool isLoading;

  const CrmDashboardState({
    this.selectedGroupScope = GroupScope.totalGroup,
    this.searchQuery = '',
    this.selectedTypeFilter,
    this.selectedStageFilter,
    this.selectedAgentFilter,
    this.navigationStack = const [],
    this.isLoading = true,
  });

  bool get hasActiveFilters =>
      selectedTypeFilter != null ||
      selectedStageFilter != null ||
      selectedAgentFilter != null;

  CrmDashboardState copyWith({
    GroupScope? selectedGroupScope,
    String? searchQuery,
    ContactType? selectedTypeFilter,
    ProductStage? selectedStageFilter,
    String? selectedAgentFilter,
    List<CRMUser>? navigationStack,
    bool? isLoading,
    bool clearTypeFilter = false,
    bool clearStageFilter = false,
    bool clearAgentFilter = false,
  }) {
    return CrmDashboardState(
      selectedGroupScope: selectedGroupScope ?? this.selectedGroupScope,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedTypeFilter:
          clearTypeFilter ? null : (selectedTypeFilter ?? this.selectedTypeFilter),
      selectedStageFilter: clearStageFilter
          ? null
          : (selectedStageFilter ?? this.selectedStageFilter),
      selectedAgentFilter: clearAgentFilter
          ? null
          : (selectedAgentFilter ?? this.selectedAgentFilter),
      navigationStack: navigationStack ?? this.navigationStack,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final crmDashboardProvider =
    StateNotifierProvider<CrmDashboardController, CrmDashboardState>(
  (ref) => CrmDashboardController(),
);
