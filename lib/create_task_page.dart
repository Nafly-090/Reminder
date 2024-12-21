import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({super.key});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {

  final TextEditingController TitleController = TextEditingController();
  final TextEditingController DescController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void SaveData() async {
    try {


      await _firestore.collection('Task').add({
        'Title': TitleController.text,
        'Description': DescController.text,
        'SelectedDate' : selectedDate,
        'SelectedTime' : selectedTime.format(context),
        'createdAt': FieldValue.serverTimestamp(),


      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data saved successfully!')),
      );

      // Clear form after saving
      setState(() {
        TitleController.clear();
        DescController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save data: $e')),
      );
    }
  }


  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Task',style: TextStyle(color: Color(0xFFE8ECD7)),),
        backgroundColor: const Color(0xFF355F2E), // Dark green
      ),
      body: Container(
        color: const Color(0xFFE8ECD7), // Light beige background
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: TitleController,
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  labelStyle: const TextStyle(color: Color(0xFF355F2E)),
                  filled: true,
                  fillColor: const Color(0xFFA8CD89), // Light green
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: DescController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Task Description',
                  labelStyle: const TextStyle(color: Color(0xFF355F2E)),
                  filled: true,
                  fillColor: const Color(0xFFA8CD89), // Light green
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Date Picker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Due Date: ${selectedDate.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(
                      color: Color(0xFF355F2E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              primaryColor: const Color(0xFF355F2E), // Header background color
                              colorScheme: ColorScheme.light(
                                primary: const Color(0xFF355F2E), // Selected date circle color
                                onPrimary: Colors.white, // Text color on selected date
                                onSurface: const Color(0xFF355F2E), // Dates text color
                              ),
                              dialogBackgroundColor: const Color(0xFFE8ECD7), // Background color
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF355F2E), // Button color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Icon(Icons.date_range_rounded, color: Colors.white),
                  ),

                ],
              ),
              const SizedBox(height: 16),

              // Time Picker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Due Time: ${selectedTime.format(context)}',
                    style: const TextStyle(
                      color: Color(0xFF355F2E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTime,
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData.light().copyWith(
                              timePickerTheme: TimePickerThemeData(
                                backgroundColor: const Color(0xFFE8ECD7), // Light beige background
                                hourMinuteColor: const Color(0xFF355F2E), // Dark green hour/minute box
                                hourMinuteTextColor: Colors.white, // Text inside hour/minute box
                                dialBackgroundColor: const Color(0xFFA8CD89), // Light green dial background
                                dialHandColor: const Color(0xFF355F2E), // Dark green hand color
                                dialTextColor: Colors.black, // Numbers on the dial
                                entryModeIconColor: const Color(0xFF355F2E), // Icon color in manual entry mode
                              ),
                              colorScheme: ColorScheme.light(
                                primary: const Color(0xFF355F2E), // Selected time circle color
                                onPrimary: Colors.white, // Text color on selected time
                                onSurface: const Color(0xFF355F2E), // Unselected text color
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedTime != null) {
                        setState(() {
                          selectedTime = pickedTime;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF355F2E), // Dark green button
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const  Icon(Icons.access_time_rounded, color: Colors.white),
                  ),

                ],
              ),
              const Spacer(),

              // Save Task Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async{
                    if(TitleController.text.isNotEmpty && DescController.text.isNotEmpty) {
                      SaveData();
                      await Future.delayed(const Duration(seconds: 3));
                      Navigator.pop(context, {
                        'title': TitleController.text,
                        'description': DescController.text,
                        'date': '${selectedDate.toLocal().toString().split(' ')[0]}',
                        'time': selectedTime.format(context),
                      });
                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF355F2E), // Dark green
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Task',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
