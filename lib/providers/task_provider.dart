import 'package:flutter_riverpod/legacy.dart';

import '../../data/models/task_item.dart';

// Task list controller
class TaskListController extends StateNotifier<TaskListState> {
  TaskListController() : super(TaskListState());

  void setSelectedDate(DateTime date) =>
      state = state.copyWith(selectedDate: date);
  void setStatusFilter(TaskStatus? status) =>
      state = state.copyWith(statusFilter: status);
  void setViewMode(String mode) => state = state.copyWith(viewMode: mode);
}

class TaskListState {
  final DateTime selectedDate;
  final TaskStatus? statusFilter;
  final String viewMode;

  TaskListState({
    DateTime? selectedDate,
    this.statusFilter,
    this.viewMode = 'calendar',
  }) : selectedDate = selectedDate ?? DateTime.now();

  TaskListState copyWith({
    DateTime? selectedDate,
    TaskStatus? statusFilter,
    String? viewMode,
    bool clearStatusFilter = false,
  }) {
    return TaskListState(
      selectedDate: selectedDate ?? this.selectedDate,
      statusFilter: clearStatusFilter
          ? null
          : (statusFilter ?? this.statusFilter),
      viewMode: viewMode ?? this.viewMode,
    );
  }
}

final taskListProvider =
    StateNotifierProvider<TaskListController, TaskListState>(
      (ref) => TaskListController(),
    );

// Task form controller
class TaskFormController extends StateNotifier<TaskFormState> {
  TaskFormController() : super(const TaskFormState());

  void setType(TaskType type) => state = state.copyWith(selectedType: type);
  void setPriority(TaskPriority priority) =>
      state = state.copyWith(selectedPriority: priority);
  void setStatus(TaskStatus status) =>
      state = state.copyWith(selectedStatus: status);
}

class TaskFormState {
  final TaskType selectedType;
  final TaskPriority selectedPriority;
  final TaskStatus selectedStatus;

  const TaskFormState({
    this.selectedType = TaskType.followUp,
    this.selectedPriority = TaskPriority.medium,
    this.selectedStatus = TaskStatus.pending,
  });

  TaskFormState copyWith({
    TaskType? selectedType,
    TaskPriority? selectedPriority,
    TaskStatus? selectedStatus,
  }) {
    return TaskFormState(
      selectedType: selectedType ?? this.selectedType,
      selectedPriority: selectedPriority ?? this.selectedPriority,
      selectedStatus: selectedStatus ?? this.selectedStatus,
    );
  }
}

final taskFormProvider =
    StateNotifierProvider<TaskFormController, TaskFormState>(
      (ref) => TaskFormController(),
    );
