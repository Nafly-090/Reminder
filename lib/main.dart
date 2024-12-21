import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart/home.dart';
import 'create_task_page.dart';
void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyA5ObDwRjRfM_QZlqrovC_gyYdgrmvhmmw",
            appId: "1:1051085406523:android:912c4ebcfb82052f18771e",
            messagingSenderId: "",
            projectId: "reminder-45081",
        ),
    );
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Flutter Reminder',
            theme: ThemeData(
                primarySwatch: Colors.green,
            ),
            home: const Reminder(),
            debugShowCheckedModeBanner: false,
        );
    }
}

