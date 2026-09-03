import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../const.dart';
import '../widgets/app_text_field.dart';

class CreateTaskScreen extends ConsumerStatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  ConsumerState<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends ConsumerState<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final _titleController = TextEditingController(text: 'Meeting Appointment');
  final _descriptionController = TextEditingController(
    text: 'Discuss customer policy requirements and prepare the proposal.',
  );
  final _embeddedLinkController = TextEditingController();

  // Schedule States
  DateTime _startDate = DateTime(2026, 8, 24);
  TimeOfDay _startTime = const TimeOfDay(hour: 9, minute: 0);
  DateTime _dueDate = DateTime(2026, 8, 24);
  TimeOfDay _dueTime = const TimeOfDay(hour: 10, minute: 0);
  bool _isAllDay = false;

  // Dropdown Selections
  String _taskType = 'Meeting';
  String _priority = 'High';
  String _status = 'To Do';
  String _department = 'Engineering';

  // Multi-user Assignees
  final List<String> _availableUsers = [
    'Alex Morgan',
    'Sarah Chen',
    'David Miller',
    'Emma Watson',
    'James Wilson',
  ];
  final List<String> _selectedAssignees = ['Alex Morgan', 'Sarah Chen'];
  String _selectedReporter = 'Sarah Chen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.accentNavy),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Create Task',
          style: TextStyle(
            color: context.colors.accentNavy,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: [
            // --- SECTION 1: SCHEDULE ---
            _buildSectionCard(
              title: 'Schedule',
              children: [
                _buildFieldLabel('Start Date & Time'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildPickerTile(
                        icon: Icons.calendar_today_outlined,
                        text:
                            '${_startDate.day} ${_getMonthName(_startDate.month)} ${_startDate.year}',
                        onTap: () => _pickDate(isStart: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPickerTile(
                        icon: Icons.access_time_rounded,
                        text: _startTime.format(context),
                        onTap: () => _pickTime(isStart: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('End Date & Time'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildPickerTile(
                        icon: Icons.calendar_today_outlined,
                        text:
                            '${_dueDate.day} ${_getMonthName(_dueDate.month)} ${_dueDate.year}',
                        onTap: () => _pickDate(isStart: false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPickerTile(
                        icon: Icons.access_time_rounded,
                        text: _dueTime.format(context),
                        onTap: () => _pickTime(isStart: false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _isAllDay,
                        activeColor: context.colors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        onChanged: (v) =>
                            setState(() => _isAllDay = v ?? false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'All Day',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.colors.accentNavy,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- SECTION 2: BASIC INFORMATION ---
            _buildSectionCard(
              title: 'Basic Information',
              children: [
                _buildFieldLabel('Task Title', isRequired: true),
                const SizedBox(height: 8),
                _buildCustomTextField(
                  controller: _titleController,
                  hint: 'Enter task title',
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('Task Type', isRequired: true),
                const SizedBox(height: 8),
                _buildCustomDropdown(
                  value: _taskType,
                  items: ['Meeting', 'Bug', 'Feature', 'Improvement'],
                  onChanged: (v) => setState(() => _taskType = v!),
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('Description'),
                const SizedBox(height: 8),
                _buildCustomTextField(
                  controller: _descriptionController,
                  hint: 'Detailed description...',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('Embedded Link'),
                const SizedBox(height: 8),
                _buildCustomTextField(
                  controller: _embeddedLinkController,
                  hint: 'https://',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- SECTION 3: TASK MANAGEMENT & MULTI-ASSIGNEE ---
            _buildSectionCard(
              title: 'Task Management',
              children: [
                _buildFieldLabel('Priority', isRequired: true),
                const SizedBox(height: 8),
                _buildPriorityDropdown(),
                const SizedBox(height: 16),
                _buildFieldLabel('Status', isRequired: true),
                const SizedBox(height: 8),
                _buildCustomDropdown(
                  value: _status,
                  items: ['To Do', 'In Progress', 'In Review', 'Done'],
                  onChanged: (v) => setState(() => _status = v!),
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('Assignees', isRequired: true),
                const SizedBox(height: 8),
                _buildMultiAssigneeField(),
                const SizedBox(height: 16),
                _buildFieldLabel('Reporter / Requester', isRequired: true),
                const SizedBox(height: 8),
                _buildCustomDropdown(
                  value: _selectedReporter,
                  items: _availableUsers,
                  onChanged: (v) => setState(() => _selectedReporter = v!),
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('Department', isRequired: true),
                const SizedBox(height: 8),
                _buildCustomDropdown(
                  value: _department,
                  items: ['Engineering', 'Design', 'Marketing', 'Product'],
                  onChanged: (v) => setState(() => _department = v!),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Task Saved Successfully')),
                    );
                  }
                },
                child: const Text(
                  'Create Task',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: context.colors.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: context.colors.accentNavy,
        ),
        children: [
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  Widget _buildPickerTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: context.colors.surfaceBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: context.iconLg, color: context.colors.muted),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: context.colors.accentNavy,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return AppTextField(
      controller: controller,
      label: '',
      hint: hint,
      maxLines: maxLines,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  Widget _buildCustomDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: context.colors.surfaceBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: context.colors.muted,
          ),
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(fontSize: 14)),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildPriorityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: context.colors.surfaceBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _priority,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: context.colors.muted,
          ),
          items: ['Low', 'Medium', 'High', 'Urgent'].map((e) {
            Color dotColor = Colors.green;
            if (e == 'Medium') dotColor = Colors.orange;
            if (e == 'High' || e == 'Urgent') dotColor = Colors.red;

            return DropdownMenuItem(
              value: e,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(e, style: const TextStyle(fontSize: 14)),
                ],
              ),
            );
          }).toList(),
          onChanged: (v) => setState(() => _priority = v!),
        ),
      ),
    );
  }

  Widget _buildMultiAssigneeField() {
    return InkWell(
      onTap: _showAssigneePicker,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.colors.surfaceBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            ..._selectedAssignees.map(
              (user) => Chip(
                avatar: CircleAvatar(
                  backgroundColor: context.colors.primaryColor,
                  child: Text(
                    user[0],
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
                label: Text(user, style: const TextStyle(fontSize: 12)),
                deleteIcon: Icon(Icons.close, size: context.iconMd),
                onDeleted: () {
                  if (_selectedAssignees.length > 1) {
                    setState(() => _selectedAssignees.remove(user));
                  }
                },
                backgroundColor: Colors.white,
                side: BorderSide(color: context.colors.border),
                visualDensity: VisualDensity.compact,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Icon(Icons.add, size: context.iconLg, color: context.colors.primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  // --- DIALOGS & PICKERS ---

  void _showAssigneePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: .start,
                children: [
                  const Text(
                    'Select Assignees',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ..._availableUsers.map((user) {
                    final isSelected = _selectedAssignees.contains(user);
                    return CheckboxListTile(
                      activeColor: context.colors.primaryColor,
                      title: Text(user, style: const TextStyle(fontSize: 14)),
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedAssignees.add(user);
                          } else {
                            _selectedAssignees.remove(user);
                          }
                        });
                        setModalState(() {});
                      },
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _dueDate = picked;
        }
      });
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _dueTime,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _dueTime = picked;
        }
      });
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
