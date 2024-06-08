import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maids/providers/task_provider.dart';
import 'package:maids/models/task.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _todoController = TextEditingController();

  void _submitData() {
    if (_formKey.currentState?.validate() ?? false) {
      final newTask = Task(
        id: DateTime.now().millisecondsSinceEpoch, // Unique ID
        todo: _todoController.text,
        completed: false,
        userId: 0, // Assuming a placeholder user ID
      );
      Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Task'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _todoController,
                decoration: InputDecoration(labelText: 'Task'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitData,
                child: Text('Add Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
