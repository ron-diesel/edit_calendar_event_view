import 'package:edit_calendar_event_view/edit_calendar_event_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());


}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  String? eventId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Add/Edit Event Example'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final eventId = await EditCalendarEventView.addOrEditCalendarEvent(title: "exampleTitle");
                    setState(() {
                      this.eventId = eventId;
                    });
                  },
                  child: Text('Add event'),
                ),
                if (eventId != null)
                ElevatedButton(
                  onPressed: () async {
                    final eventId = await EditCalendarEventView.addOrEditCalendarEvent(eventId: this.eventId);
                    setState(() {
                      this.eventId = eventId;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text('Edit event\n$eventId',
                    textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),
          ),
      ),
    ));
  }
}
