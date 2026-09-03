import 'package:flutter_riverpod/legacy.dart';

class NotificationListController extends StateNotifier<NotificationListState> {
  NotificationListController() : super(const NotificationListState());

  void setTab(String tab) => state = state.copyWith(selectedTab: tab);
  void setSearchQuery(String query) =>
      state = state.copyWith(searchQuery: query);
  void toggleRead(String id) {
    state = state.copyWith(
      readIds: {...state.readIds, if (state.readIds.contains(id)) ...[]},
    );
  }
}

class NotificationListState {
  final String selectedTab;
  final String searchQuery;
  final Set<String> readIds;

  const NotificationListState({
    this.selectedTab = 'All',
    this.searchQuery = '',
    this.readIds = const {},
  });

  NotificationListState copyWith({
    String? selectedTab,
    String? searchQuery,
    Set<String>? readIds,
  }) {
    return NotificationListState(
      selectedTab: selectedTab ?? this.selectedTab,
      searchQuery: searchQuery ?? this.searchQuery,
      readIds: readIds ?? this.readIds,
    );
  }
}

final notificationListProvider =
    StateNotifierProvider<NotificationListController, NotificationListState>(
      (ref) => NotificationListController(),
    );
