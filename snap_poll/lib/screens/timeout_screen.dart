import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snap_poll/routes/app_pages.dart';

// Define the global key for the TimeoutScreen
GlobalKey<_TimeoutScreenState> timeoutScreenKey =
    GlobalKey<_TimeoutScreenState>();

class TimeoutScreen extends StatefulWidget {
  const TimeoutScreen({Key? key}) : super(key: key);

  @override
  _TimeoutScreenState createState() => _TimeoutScreenState();
}

class _TimeoutScreenState extends State<TimeoutScreen> {
  Timer? _timeoutTimer;
  DateTime? _lastActivityTime;

  @override
  void initState() {
    super.initState();
    _lastActivityTime = DateTime.now();
    _startTimeoutTimer();
    print("Reached timeout page!");
  }

  void _startTimeoutTimer() {
    final timeoutDuration = Duration(minutes: 10);
    _timeoutTimer = Timer(timeoutDuration, _showTimeoutMessage);
  }

  void _resetTimeoutTimer() {
    _timeoutTimer?.cancel();
    _startTimeoutTimer();
  }

  void _showTimeoutMessage() {
    print("Timeout ended!");
    if (mounted) {
      final currentTime = DateTime.now();
      final inactivityDuration = currentTime.difference(_lastActivityTime!);
      if (inactivityDuration >= Duration(minutes: 10)) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Session Timeout'),
              content: Text('Your session has timed out due to inactivity.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Get.toNamed(Routes.INITIAL_SCREEN);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timeout Demo'),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          // Reset the timer on user interaction and use the global key to reset timer in TimeoutScreen
          timeoutScreenKey.currentState?.resetTimerFromOtherScreen();
        },
        child: Center(
          child: Text('Perform some action to reset the timeout.'),
        ),
      ),
    );
  }

  // Method to reset the timer from other screens
  void resetTimerFromOtherScreen() {
    print("Reached reset timer!");
    setState(() {
      _lastActivityTime = DateTime.now();
    });
    _resetTimeoutTimer();
  }
}

void main() {
  runApp(MaterialApp(
    home: TimeoutScreen(),
  ));
}
