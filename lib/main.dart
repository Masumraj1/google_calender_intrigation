import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'google_sign_in_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ///============================Google Sign in method ======================
  Future<void> googleSignIn() async {
    try {
      final user = await GoogleSignInService.login();
      final GoogleSignInAuthentication? googleAuth = await user?.authentication;

      log('User name: ===================${user!.displayName}, Email:====================== ${user.email}');

      final httpClient = await obtainAuthenticatedClient(googleAuth!);
      if (httpClient != null) {
        log("====================Authentication successful!==================");
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddEventScreen(client: httpClient),
          ),
        );
      }
    } catch (exception) {
      log(exception.toString());
    }
  }

  Future<http.Client?> obtainAuthenticatedClient(
      GoogleSignInAuthentication googleAuth) async {
    try {
      return authenticatedClient(
        http.Client(),
        AccessCredentials(
          AccessToken('Bearer', googleAuth.accessToken!,
              DateTime.now().toUtc().add(const Duration(hours: 1))),
          null,
          ['https://www.googleapis.com/auth/calendar'],
        ),
      );
    } catch (e) {
      log('==============Client authentication failed:================== $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          'Google Calendar Integration',
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
        ),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: GestureDetector(
          onTap: googleSignIn,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/google.png',
                  height: 24,
                  width: 24,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Sign in with Google',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AddEventScreen extends StatefulWidget {
  final http.Client client;

  const AddEventScreen({Key? key, required this.client}) : super(key: key);

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _noteController = TextEditingController();
  DateTime? _selectedDateTime;

  Future<void> _pickDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> addEventToGoogleCalendar() async {
    if (_selectedDateTime == null || _noteController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a note and select a date and time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      var calendarApi = calendar.CalendarApi(widget.client);

      final eventStart = _selectedDateTime!;
      final eventEnd = eventStart.add(const Duration(hours: 1));

      var event = calendar.Event()
        ..summary = _noteController.text
        ..description = 'Event created from Flutter app'
        ..start = calendar.EventDateTime(dateTime: eventStart)
        ..end = calendar.EventDateTime(dateTime: eventEnd);

      final insertedEvent = await calendarApi.events.insert(event, 'primary');
      log('==================Event added to calendar with ID: =================${insertedEvent.id}');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
          Text('Event added successfully for ${_selectedDateTime!.toLocal()}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      log('Error adding event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add event to Google Calendar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          'Add Event to Calendar',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Event Note',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _pickDateTime,
                child: const Text('Select Date & Time'),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              style: const TextStyle(
                  color: Colors.blue, fontWeight: FontWeight.w500),
              _selectedDateTime == null
                  ? 'No date and time selected'
                  : 'Selected Date & Time: ${_selectedDateTime!.toLocal()}',
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: addEventToGoogleCalendar,
                child: const Text('Add to Google Calendar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
