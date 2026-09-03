import 'package:flutter_riverpod/legacy.dart';

class CommissionController extends StateNotifier<CommissionState> {
  CommissionController() : super(const CommissionState());

  void setMonth(String month) => state = state.copyWith(selectedMonth: month);
  void setPeriod(String period) =>
      state = state.copyWith(selectedPeriod: period);
  void toggleCategory(String label) {
    state = state.copyWith(
      expandedCategoryLabel: state.expandedCategoryLabel == label ? null : label,
    );
  }
}

class CommissionState {
  final String selectedMonth;
  final String selectedPeriod;
  final String? expandedCategoryLabel;

  const CommissionState({
    this.selectedMonth = 'March 2024',
    this.selectedPeriod = 'Monthly',
    this.expandedCategoryLabel,
  });

  CommissionState copyWith({
    String? selectedMonth,
    String? selectedPeriod,
    String? expandedCategoryLabel,
    bool clearExpanded = false,
  }) {
    return CommissionState(
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
      expandedCategoryLabel:
          clearExpanded ? null : (expandedCategoryLabel ?? this.expandedCategoryLabel),
    );
  }
}

final commissionProvider =
    StateNotifierProvider<CommissionController, CommissionState>(
  (ref) => CommissionController(),
);
