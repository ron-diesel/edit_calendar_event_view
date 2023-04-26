<?code-excerpt path-base="excerpts/packages/edit_calendar_event_view"?>

# Add and edit calendar events

[![pub package](https://img.shields.io/pub/v/edit_calendar_event_view.svg)](https://pub.dev/packages/edit_calendar_event_view)

Opens native iOS event viewController to add or edit calendar events.

|             | iOS   |
|-------------|-------|
| **Support** | 11.0+ |

![The example app running in iOS](https://github.com/chris-wolf/edit_calendar_event_view/blob/main/example/videos/edit_calendar_event_view_preview.gif?raw=true)

## Installation

First, add `edit_calendar_event_view` as a [dependency in your pubspec.yaml file](https://flutter.dev/using-packages/).

### iOS

Add the `NSCalendarsUsageDescription` permissions to your app's _Info.plist_ file, located
in `<project root>/ios/Runner/Info.plist`. See
[Apple's documentation](https://developer.apple.com/documentation/bundleresources/information_property_list/nsapptransportsecurity)
to determine the right combination of entries for your use case and supported iOS versions.

##  Usage

```
import 'package:edit_calendar_event_view/edit_calendar_event_view.dart';

final newEventId = await EditCalendarEventView.addOrEditCalendarEvent(title: "exampleTitle", calendarId: "0123456789", description: "exampleDescription", startDate: DateTime.now(), endDate: DateTime.now().add(Duration(days: 1), allDay: true);
       
final editedEventId = await EditCalendarEventView.addOrEditCalendarEvent(eventId: this.eventId);
```

## Example

```
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
```