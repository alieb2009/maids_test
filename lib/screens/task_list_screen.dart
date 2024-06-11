import 'package:flutter/material.dart';
import 'package:maids/screens/task_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:maids/providers/task_provider.dart';
import 'package:maids/models/task.dart';
import 'package:maids/screens/task_edit_screen.dart';
import 'package:maids/screens/addtaskscreen.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final ScrollController _scrollController = ScrollController();
  late int _tasksPerPage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tasksPerPage = _calculateTasksPerPage(context);
      Provider.of<TaskProvider>(context, listen: false).fetchTasks(limit: _tasksPerPage).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tasks: $error')),
        );
      });

      _scrollController.addListener(() {
        if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
          _loadMoreTasks();
        }
      });
    });
  }

  int _calculateTasksPerPage(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    const taskItemHeight = 70.0; // Approximate height of each ListTile
    return (height / taskItemHeight).ceil();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMoreTasks() async {
    try {
      await Provider.of<TaskProvider>(context, listen: false).fetchTasks(loadMore: true, limit: _tasksPerPage);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading more tasks: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text('Tasks'),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.tasks.isEmpty) {
            return Center(child: Text('No tasks available'));
          }

          return Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                itemCount: taskProvider.tasks.length,
                itemBuilder: (context, index) {
                  Task task = taskProvider.tasks[index];
                  return ListTile(
                    title: Text(task.todo),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskEditScreen(task: task),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            Provider.of<TaskProvider>(context, listen: false).deleteTask(task.id);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              if (taskProvider.isLoading)
                Positioned(
                  bottom: 16,
                  left: MediaQuery.of(context).size.width * 0.5 - 16,
                  child: CircularProgressIndicator(),
                ),
            ],
          );
        },
      ),
    );
  }
}
