import 'dart:io';

import 'package:edit_calendar_event_view/edit_calendar_event_view.dart';
import 'package:edit_calendar_event_view/edit_calendar_event_view_method_channel.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = Platform.localeName;
  await initializeDateFormatting();
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
      body: StatefulBuilder(builder: (context, setState) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final result =
                        await EditCalendarEventView.addOrEditCalendarEvent(
                            context,
                            title: "exampleTitle");
                    setState(() {
                      switch (result.resultType) {
                        case ResultType.saved:
                          eventId = result.eventId;
                          break;
                        case ResultType.deleted:
                          eventId = null;
                          break;
                        case ResultType.unknown:
                          break;
                        case ResultType.canceled:
                          break;
                      }
                    });
                  },
                  child: const Text('Add event'),
                ),
                if (eventId != null)
                  ElevatedButton(
                    onPressed: () async {
                      final result =
                          await EditCalendarEventView.addOrEditCalendarEvent(
                              context,
                              eventId: eventId);
                      setState(() {
                        switch (result.resultType) {
                          case ResultType.saved:
                            eventId = result.eventId;
                            break;
                          case ResultType.deleted:
                            eventId = null;
                            break;
                          case ResultType.unknown:
                            break;
                          case ResultType.canceled:
                            break;
                        }
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
        );
      }),
    ));
  }
}
