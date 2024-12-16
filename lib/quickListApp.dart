import 'dart:core';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuickListApp extends StatelessWidget {
  const QuickListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: QuickListWidget(),
    );
  }
}

class ToDoController extends GetxController {
  var tasks = <Map<String, String>>[].obs;

  final String filePath = '${Directory.current.path}/tasks.json';

  @override
  void onInit() {
    super.onInit();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final file = File(filePath);
    if (await file.exists()) {
      String contents = await file.readAsString();
      tasks.value = List<Map<String, String>>.from(jsonDecode(contents));
    }
  }

  Future<void> saveTasks() async {
    final file = File(filePath);
    await file.writeAsString(jsonEncode(tasks));
  }

  void addTask(String title, String dueDate) {
    tasks.add({'title': title, 'dueDate': dueDate});
    saveTasks();
  }
}

class QuickListWidget extends StatelessWidget {
  final ToDoController controller = Get.put(ToDoController());

  void _showAddTaskDialog(BuildContext context) {
    String? title;
    String? dueDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Task Title'),
              onChanged: (value) => title = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Due Date'),
              onChanged: (value) => dueDate = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (title != null && dueDate != null) {
                controller.addTask(title!, dueDate!);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QuickList'),
      ),
      body: Obx(() {
        if (controller.tasks.isEmpty) {
          return const Center(child: Text('No tasks available.'));
        } else {
          return ListView.builder(
            itemCount: controller.tasks.length,
            itemBuilder: (context, index) {
              final task = controller.tasks[index];
              return ListTile(
                title: Text(task['title'] ?? ''),
                subtitle: Text('Due: ${task['dueDate']}'),
              );
            },
          );
        }
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
