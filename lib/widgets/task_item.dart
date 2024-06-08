import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maids/models/task.dart';
import 'package:maids/providers/task_provider.dart';

class TaskItem extends StatelessWidget {
  final Task task;

  TaskItem({required this.task});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(task.todo),
      trailing: Checkbox(
        value: task.completed,
        onChanged: (value) {
          Provider.of<TaskProvider>(context, listen: false)
              .toggleTaskStatus(task.id);
        },
      ),
    );
  }
}
