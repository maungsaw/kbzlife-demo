import 'package:flutter_riverpod/legacy.dart';

class EappController extends StateNotifier<EappState> {
  EappController() : super(const EappState());

  void setTab(int index) => state = state.copyWith(selectedTab: index);
  void setFormField(String key, dynamic value) {
    state = state.copyWith(formData: {...state.formData, key: value});
  }
}

class EappState {
  final int selectedTab;
  final Map<String, dynamic> formData;

  const EappState({
    this.selectedTab = 0,
    this.formData = const {},
  });

  EappState copyWith({int? selectedTab, Map<String, dynamic>? formData}) {
    return EappState(
      selectedTab: selectedTab ?? this.selectedTab,
      formData: formData ?? this.formData,
    );
  }
}

final eappProvider = StateNotifierProvider<EappController, EappState>(
  (ref) => EappController(),
);
