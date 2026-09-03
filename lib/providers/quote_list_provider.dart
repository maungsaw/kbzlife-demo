import 'package:flutter_riverpod/legacy.dart';

class SavedQuotesListController extends StateNotifier<SavedQuotesListState> {
  SavedQuotesListController() : super(const SavedQuotesListState());

  void setSearchQuery(String query) =>
      state = state.copyWith(searchQuery: query);
  void setFilter(String filter) => state = state.copyWith(selectedFilter: filter);
}

class SavedQuotesListState {
  final String searchQuery;
  final String selectedFilter;

  const SavedQuotesListState({
    this.searchQuery = '',
    this.selectedFilter = 'All',
  });

  SavedQuotesListState copyWith({String? searchQuery, String? selectedFilter}) {
    return SavedQuotesListState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

final savedQuotesListProvider =
    StateNotifierProvider<SavedQuotesListController, SavedQuotesListState>(
  (ref) => SavedQuotesListController(),
);
