import 'package:flutter_riverpod/legacy.dart';

class TrackerListController extends StateNotifier<TrackerListState> {
  TrackerListController() : super(const TrackerListState());

  void setFilter(String filter) => state = state.copyWith(selectedFilter: filter);
  void setSearchQuery(String query) =>
      state = state.copyWith(searchQuery: query);
}

class TrackerListState {
  final String selectedFilter;
  final String searchQuery;

  const TrackerListState({
    this.selectedFilter = 'All',
    this.searchQuery = '',
  });

  TrackerListState copyWith({String? selectedFilter, String? searchQuery}) {
    return TrackerListState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final trackerListProvider =
    StateNotifierProvider<TrackerListController, TrackerListState>(
  (ref) => TrackerListController(),
);
