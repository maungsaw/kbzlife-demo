import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../const.dart';

class TaskDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? taskData;

  const TaskDetailScreen({super.key, this.taskData});

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {
  // Sample task details (can be passed dynamically via widget.taskData)
  late Map<String, dynamic> _task;

  @override
  void initState() {
    super.initState();
    _task =
        widget.taskData ??
        {
          'title': 'Meeting Appointment',
          'type': 'Meeting',
          'description':
              'Discuss customer policy requirements and prepare the proposal with the product team.',
          'embeddedLink': 'https://example.com/spec/policy-v2',
          'priority': 'High',
          'status': 'In Progress',
          'department': 'Engineering',
          'startDate': '24 Aug 2026',
          'startTime': '09:00 AM',
          'dueDate': '24 Aug 2026',
          'dueTime': '10:00 AM',
          'isAllDay': false,
          'assignees': ['Alex Morgan', 'Sarah Chen', 'David Miller'],
          'reporter': 'Sarah Chen',
          'createdDate': '23 Aug 2026',
          'updatedDate': '24 Aug 2026',
          'updatedBy': 'Alex Morgan',
        };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.accentNavy),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(
          'Task Details',
          style: TextStyle(
            color: context.colors.accentNavy,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: context.colors.primaryColor,
            ),
            onPressed: () {
              // Navigate back to Edit/Create view
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: context.colors.danger),
            onPressed: _showDeleteConfirmation,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        children: [
          // --- SECTION 1: HEADER & STATUS ---
          _buildSectionCard(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTypeBadge(_task['type']),
                  _buildStatusBadge(_task['status']),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _task['title'],
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: context.colors.accentNavy,
                ),
              ),
              const SizedBox(height: 8),
              if (_task['description'] != null &&
                  _task['description'].isNotEmpty)
                Text(
                  _task['description'],
                    style: TextStyle(
                    fontSize: 14,
                    color: context.colors.accentNavy,
                    height: 1.4,
                  ),
                ),
              if (_task['embeddedLink'] != null &&
                  _task['embeddedLink'].isNotEmpty) ...[
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {},
                  child: Row(
                    children: [
                      Icon(
                        Icons.link,
                        size: context.iconBase,
                        color: context.colors.primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _task['embeddedLink'],
                          style: TextStyle(
                            fontSize: 13,
                            color: context.colors.primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // --- SECTION 2: SCHEDULE ---
          _buildSectionCard(
            title: 'Schedule',
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildInfoTile(
                      icon: Icons.calendar_today_outlined,
                      label: 'Start Date & Time',
                      value: '${_task['startDate']} • ${_task['startTime']}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoTile(
                      icon: Icons.event_outlined,
                      label: 'Due Date & Time',
                      value: '${_task['dueDate']} • ${_task['dueTime']}',
                    ),
                  ),
                ],
              ),
              if (_task['isAllDay'] == true) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.surfaceBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                    child: Text(
                    'All Day Event',
                    style: TextStyle(fontSize: 12, color: context.colors.accentNavy),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // --- SECTION 3: PEOPLE & ASSIGNEES ---
          _buildSectionCard(
            title: 'Assignment',
            children: [
              _buildFieldLabel('Assignees'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...(_task['assignees'] as List<String>).map(
                    (user) => Chip(
                      avatar: CircleAvatar(
                        backgroundColor: context.colors.primaryColor,
                        child: Text(
                          user[0],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      label: Text(user, style: const TextStyle(fontSize: 12)),
                      backgroundColor: context.colors.cream,
                      side: BorderSide(color: context.colors.border),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoTile(
                      icon: Icons.person_outline,
                      label: 'Reporter / Requester',
                      value: _task['reporter'],
                    ),
                  ),
                  Expanded(
                    child: _buildInfoTile(
                      icon: Icons.business_outlined,
                      label: 'Department',
                      value: _task['department'],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- SECTION 4: TASK METADATA ---
          _buildSectionCard(
            title: 'Task Info',
            children: [
              Row(
                children: [
                  Expanded(child: _buildPriorityTile(_task['priority'])),
                  Expanded(
                    child: _buildInfoTile(
                      icon: Icons.history,
                      label: 'Updated By',
                      value: _task['updatedBy'],
                    ),
                  ),
                ],
              ),
              Divider(height: 24, color: context.colors.surfaceBg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Created: ${_task['createdDate']}',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colors.muted,
                    ),
                  ),
                  Text(
                    'Last Updated: ${_task['updatedDate']}',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colors.muted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // --- UI HELPER COMPONENTS ---

  Widget _buildSectionCard({String? title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: context.colors.primaryColor,
              ),
            ),
            const SizedBox(height: 14),
          ],
          ...children,
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: context.colors.accentNavy,
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: .start,
      children: [
        Icon(icon, size: context.iconLg, color: context.colors.muted),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: context.colors.muted),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.colors.accentNavy,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityTile(String priority) {
    Color dotColor = Colors.green;
    if (priority == 'Medium') dotColor = Colors.orange;
    if (priority == 'High' || priority == 'Urgent') dotColor = Colors.red;

    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: .start,
          children: [
            Text(
              'Priority',
              style: TextStyle(fontSize: 11, color: context.colors.muted),
            ),
            const SizedBox(height: 2),
            Text(
              priority,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: context.colors.accentNavy,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = context.colors.infoLight;
    Color text = context.colors.infoText;
    if (status == 'Done') {
      bg = context.colors.successAccentLight;
      text = context.colors.successAccent;
    } else if (status == 'In Progress') {
      bg = context.colors.warningLight;
      text = context.colors.statusLead;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }

  Widget _buildTypeBadge(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.colors.surfaceBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        type,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: context.colors.accentNavy,
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text(
          'Are you sure you want to delete this task? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
