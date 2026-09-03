import 'package:flutter_riverpod/legacy.dart';

class PolicyListController extends StateNotifier<PolicyListState> {
  PolicyListController() : super(const PolicyListState());

  void setFilter(String filter) => state = state.copyWith(selectedFilter: filter);
  void setSearchQuery(String query) =>
      state = state.copyWith(searchQuery: query);
}

class PolicyListState {
  final String selectedFilter;
  final String searchQuery;

  const PolicyListState({
    this.selectedFilter = 'All',
    this.searchQuery = '',
  });

  PolicyListState copyWith({String? selectedFilter, String? searchQuery}) {
    return PolicyListState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final policyListProvider =
    StateNotifierProvider<PolicyListController, PolicyListState>(
  (ref) => PolicyListController(),
);

final policyOverviewPeriodProvider = StateProvider<String>((ref) => 'Monthly');
