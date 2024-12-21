import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:reminder/create_task_page.dart';


class Reminder extends StatefulWidget {
  const Reminder({super.key});

  @override
  State<Reminder> createState() => _ReminderState();
}

class _ReminderState extends State<Reminder> {
  bool isEditing = false;
  Set<String> selectedTasks = {}; // Track selected task IDs

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFA8CD89),
      appBar: AppBar(
        backgroundColor: const Color(0xFF355F2E),
        leading: isEditing
            ? IconButton(
          icon: const Icon(Icons.close),
          color: const Color(0xFFE8ECD7),
          onPressed: () {
            setState(() {
              isEditing = false;
              selectedTasks.clear(); // Clear selection when exiting edit mode
            });
          },
        )
            : null, // No leading icon if not editing
        title: Text(
          isEditing ? 'Select Tasks' : 'Reminder',
          style: const TextStyle(color: Color(0xFFE8ECD7)),
        ),
        centerTitle: true,
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              color: const Color(0xFFE8ECD7),
              onPressed: () async {
                if (selectedTasks.isNotEmpty) {
                  await deleteSelectedTasks();
                  setState(() {
                    selectedTasks.clear(); // Clear selection after deletion
                    isEditing = false; // Exit edit mode
                  });
                }
              },
            ),
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              color: const Color(0xFFE8ECD7),
              onPressed: () {
                setState(() {
                  isEditing = true;
                });
              },
            ),
        ],
      ),
      body: Container(
        color: const Color(0xFFE8ECD7), // Light beige background
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('Task').orderBy('createdAt', descending: true).snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data?.docs ?? [];
            if (data.isEmpty) {
              return const Center(
                child: Text('No tasks yet. Click the "+" button to add a task!'),
              );
            }
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final task = data[index];
                final taskId = task.id; // Unique ID of the task
                final title = task['Title'] ?? 'No Title';
                final description = task['Description'] ?? 'No Description';
                final dueDate = task['SelectedDate'] ?? 'No Date';
                final time = task['SelectedTime'] ?? 'No Time';

                DateTime selectedDateTime =
                (dueDate as Timestamp).toDate();
                Duration remainingDuration =
                selectedDateTime.difference(DateTime.now());

                String remainingTime = "";
                Color remainingTimeColor = Colors.red;
                if (remainingDuration.inDays > 0) {
                  remainingTime = '${remainingDuration.inDays} days left';
                  if (remainingDuration.inDays > 5) {
                    remainingTimeColor = Colors.green;
                  }
                } else if (remainingDuration.inHours > 0) {
                  remainingTime = '${remainingDuration.inHours} hours left';
                } else if (remainingDuration.inMinutes > 0) {
                  remainingTime = '${remainingDuration.inMinutes} minutes left';
                } else {
                  remainingTime = 'Due now';
                }

                final isSelected = selectedTasks.contains(taskId);

                return GestureDetector(
                  onTap: isEditing
                      ? () {
                    setState(() {
                      if (isSelected) {
                        selectedTasks.remove(taskId);
                      } else {
                        selectedTasks.add(taskId);
                      }
                    });
                  }
                      : null, // Allow tapping only in edit mode
                  child: Card(
                    margin: const EdgeInsets.all(10),
                    color: isSelected
                        ? Colors.green.shade300 // Highlight selected card
                        : remainingTime == 'Due now'
                        ? Colors.grey.shade600
                        : const Color(0xFFF1E7E7),
                    child: ListTile(
                      title: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(description),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                              const SizedBox(width: 5),
                              Text(
                                selectedDateTime.toLocal().toString().split(' ')[0],
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.access_time,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 5),
                              Text(time,
                                  style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                      trailing: Text(
                        remainingTime,
                        style: TextStyle(
                          color: remainingTimeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 17.0,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF355F2E),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateTaskPage(),
            ),
          );
        },
        child: const Icon(
          Icons.add,
          color: Color(0xFFE8ECD7),
        ),
      ),
    );
  }

  Future<void> deleteSelectedTasks() async {
    for (String taskId in selectedTasks) {
      await FirebaseFirestore.instance
          .collection('Task')
          .doc(taskId)
          .delete();
    }
  }
}
