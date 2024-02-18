import 'dart:async';

import 'package:collection/collection.dart';
import 'package:edit_calendar_event_view/string_extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:macos_ui/macos_ui.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:sprintf/sprintf.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'calendar_selection_dialog.dart';
import 'edit_calendar_event_view_method_channel.dart';
import 'multi_platform_dialog.dart';
import 'multi_platform_scaffold.dart';

class EditCalendarEventPage extends StatefulWidget {

  static Future<dynamic> show(BuildContext context,
      {String? calendarId,
      String? eventId,
      String? title,
      String? description,
      int? startDate,
      int? endDate,
      bool? allDay}) async {

    List<Calendar> calendars = (await DeviceCalendarPlugin().retrieveCalendars())
        .data?.toList() ?? [];
    Event? event;
    if (eventId != null) {
      if (calendarId != null) {
        event = (await DeviceCalendarPlugin().retrieveEvents(
            calendarId, RetrieveEventsParams(eventIds: [eventId]))).data?.firstOrNull;
      }
      if (event == null) {
        for (final cal in calendars) {
          final events = await DeviceCalendarPlugin().retrieveEvents(
              cal.id, RetrieveEventsParams(eventIds: [eventId]));
          final evnt = events.data?.firstOrNull;
          if (evnt != null) {
            event = evnt;
            break;
          }
        }
      }
    }
    calendars = calendars.where((element) => element.isReadOnly == false)
            .toList();

    Calendar? calendar;

    if (calendarId != null) {
      calendar =
          calendars.firstWhereOrNull((element) => element.id == calendarId);
    }
    if (calendar == null && event?.calendarId != null) {
      calendar = calendars
          .firstWhereOrNull((element) => element.id == event?.calendarId);
    }
    calendar ??= calendars.firstWhereOrNull((element) =>
        !(element.isReadOnly ?? true) && (element.isDefault ?? false));
    calendar ??=
        calendars?.firstWhereOrNull((element) => !(element.isReadOnly ?? true));
    if (!context.mounted) {
      return;
    }
    final page = EditCalendarEventPage(
      event: event,
      calendar: calendar,
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      allDay: allDay,
    );
    if (MacosTheme.maybeOf(context) != null) {
      return MultiPlatformDialog.show(
          context, page,
          barrierDismissible: true, maxWidth: 500, maxHeight: 548);
    } else {
      return Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => page),
      );
    }
  }

  final Event? event;
  final Calendar? calendar;
  final String? title;
  final String? description;
  final int? startDate;
  final int? endDate;
  final bool? allDay;

  const EditCalendarEventPage(
      {super.key,
      this.event,
      this.calendar,
      this.title,
      this.description,
      this.startDate,
      this.endDate,
      this.allDay});

  @override
  _EditCalendarEventPageState createState() => _EditCalendarEventPageState();
}

class _EditCalendarEventPageState extends State<EditCalendarEventPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late Event event;

  final horizontalPadding = 16.0;
  Calendar? calendar;

  @override
  void initState() {
    super.initState();
    calendar = widget.calendar;
    if (widget.event != null) {
      event = widget.event!;
    } else {
      event = Event(widget.calendar?.id,
          start: TZDateTime.from(DateTime.now(), tz.local),
          end: TZDateTime.from(
              DateTime.now().add(Duration(hours: 1)), tz.local));
    }
    if (widget.title != null) {
      event.title = widget.title;
    }
    if (widget.description != null) {
      event.description = widget.description;
    }
    if (widget.allDay != null) {
      event.allDay = widget.allDay;
    }
    if (widget.startDate != null) {
      event.start = epochMillisToTZDateTime(widget.startDate!);
    }
    if (widget.endDate != null) {
      event.end = epochMillisToTZDateTime(widget.endDate!);
    }
    if (calendar != null) {
      event.calendarId = calendar?.id;
    }
    _titleController.text = event.title ?? '';
    _descriptionController.text = event.description ?? '';
  }

  TZDateTime epochMillisToTZDateTime(int epochMillis) {
    // Initialize timezone data; required if you haven't done it elsewhere in your app.
    tz.initializeTimeZones();
    // Convert epoch milliseconds to a DateTime object.
    final dateTime = DateTime.fromMillisecondsSinceEpoch(epochMillis);
    // Convert DateTime to TZDateTime in the local timezone.
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  @override
  Widget build(BuildContext context) {
    final title =
        (widget.event == null ? 'add_event' : 'edit_event')
            .localize();
    return MultiPlatformScaffold(
        title: title,
        macOsLeading: MacosIconButton(
          icon: const Icon(Icons.close, color: Color(0xff808080)),
          onPressed: () => Navigator.pop(context),
          padding: const EdgeInsets.all(5.0),
        ),
        actions: [
          if (widget.event != null)
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: IconButton(
                icon: const Icon(
                  Icons.delete,
                ),
                tooltip: 'delete'.localize(),
                onPressed: () async {
                  await deleteEvent(context);
                },
              ),
            ),
        ],
        macOsActions: [
          if (widget.event != null)
            ToolBarIconButton(
                label: 'delete'.localize(),
                icon: const MacosIcon(
                  CupertinoIcons.delete,
                ),
                onPressed: () {
                  deleteEvent(context);
                },
                showLabel: false),
        ],
        body: Stack(
          children: [
            content(),
            if (MacosTheme.maybeOf(context) != null)
              Positioned(
                right: 16.0,
                bottom: 16.0,
                child: PushButton(
                  controlSize: ControlSize.large,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 5.0),
                  child: Text('save'.localize()),
                  onPressed: () {
                    confirmPress(context);
                  },
                ),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'save'.localize(),
          onPressed: () async {
            await confirmPress(context);
          },
          backgroundColor: Colors.green,
          child: const Icon(
            Icons.check,
            color: Colors.white,
          ),
        ));
  }

  Future<void> deleteEvent(BuildContext context) async {
    final event = widget.event;
    if (event != null) {
      DeviceCalendarPlugin().deleteEvent(event.calendarId, event.eventId);
      Navigator.pop(context, (resultType: ResultType.deleted, eventId: event.eventId));
    }
  }

  static FocusNode node = FocusNode();
  FocusNode descriptionNode = FocusNode();

  DateTime startDate() {
    return DateTime.fromMillisecondsSinceEpoch(
        event.start?.millisecondsSinceEpoch ??
            DateTime.now().millisecondsSinceEpoch);
  }

  DateTime endDate() {
    return DateTime.fromMillisecondsSinceEpoch(
        event.end?.millisecondsSinceEpoch ??
            startDate().add(const Duration(hours: 1)).millisecondsSinceEpoch);
  }

  bool allDay() {
    return event.allDay ?? false;
  }

  Widget content() {
    return RawKeyboardListener(
        onKey: (RawKeyEvent event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.enter) {
              if (descriptionNode.hasFocus == false) {
                confirmPress(context);
              }
            }
          }
        },
        focusNode: node,
        child: Builder(builder: (context) {
          return Container(
            constraints: const BoxConstraints.expand(),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
              children: <Widget>[
                Card(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(horizontalPadding),
                        child: TextFormField(
                          controller: _titleController,
                          maxLines: 1,
                          decoration: InputDecoration.collapsed(
                              hintText: 'event_title'.localize(),
                              hintStyle: const TextStyle(color: Colors.grey),
                              border: InputBorder.none),
                        ),
                      ),
                      divider(),
                      Padding(
                        padding: EdgeInsets.all(horizontalPadding),
                        child: TextFormField(
                          focusNode: descriptionNode,
                          controller: _descriptionController,
                          maxLines: 100,
                          minLines: 1,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          decoration: InputDecoration.collapsed(
                              hintText:
                                  'event_description'.localize(),
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none),
                        ),
                      )
                    ],
                  ),
                ),
                Card(

                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0))),
                  child:
                      Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: Icon(Icons.access_time_rounded),
                                title: Row(
                                  children: <Widget>[
                                    Expanded(
                                        child: Text('all_day'.localize())),
                                    Switch.adaptive(
                                      value: allDay(),
                                      onChanged: (bool value) {
                                        setState(() {
                                          event.allDay = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    event.allDay = !allDay();
                                  });
                                }),
                            ListTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                      onPressed: () async {
                                        await setStartDate(context);
                                      },
                                      child: Text(DateFormat('EEE, MMM d, yyyy')
                                          .format(startDate()))),
                                  if (allDay() == false)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16.0),
                                      child: ElevatedButton(
                                          onPressed: () {
                                            setStartTime(context);
                                          },
                                          child: Text(DateFormat('h:mm a')
                                              .format(startDate()))),
                                    ),
                                ],
                              ),
                              onTap: () async {
                                await setStartDate(context);
                              },
                            ),
                            ListTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                      onPressed: () async {
                                        await setEndDate(context);
                                      },
                                      child: Text(DateFormat('EEE, MMM d, yyyy')
                                          .format(endDate()))),
                                  if (allDay() == false)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16.0),
                                      child: ElevatedButton(
                                          onPressed: () {
                                            setEndTime(context);
                                          },
                                          child: Text(DateFormat('h:mm a')
                                              .format(endDate()))),
                                    ),
                                ],
                              ),
                              onTap: () async {
                                await setEndDate(context);
                              },
                            ),
                          ],
                        ),
                ),
                Card(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8.0))),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(
                                    child: const Align(
                                        alignment: Alignment.centerLeft,
                                        child: Icon(Icons.calendar_month)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 4.0),
                                    child: Container(
                                      alignment: Alignment.center,
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(calendar?.color ?? 0)),
                                    ),
                                  ),
                                  Text(calendar?.name ??
                                      'no_calendar'.localize()),
                                ],
                              ),
                              onTap: () async {
                                final calendars = (await DeviceCalendarPlugin()
                                            .retrieveCalendars())
                                        .data
                                        ?.where(
                                            (element) => element.isReadOnly == false)
                                        .toList() ??
                                    [];
                                if (!context.mounted) {
                                  return;
                                }
                                var result =
                                    await CalendarSelectionDialog.showCalendarDialog(
                                        context,
                                        'calendar'.localize(),
                                        null,
                                        calendars,
                                        calendars.firstWhereOrNull((element) => element.id == calendar?.id));
                                if (result?.id != null ) {
                                  setState(() {
                                    calendar = result;
                                    event.calendarId = result?.id;
                                  });
                                  }
                              },
                            ),
                          ),
                        ],
                      ),
                      divider(),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16,16,0,20),
                          child: Icon(Icons.alarm),
                        ),
                        Expanded(
                          child: Column(children: [
                            for (final reminder in event.reminders ?? [])
                              ListTile(
                                title: Text(reminderString(reminder)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    List<Reminder> newReminders = [
                                      ...(event.reminders ?? [])
                                    ];
                                    newReminders.remove(reminder);
                                    setState(() {
                                      event.reminders = newReminders;
                                    });
                                  },
                                ),
                              ),
                            ListTile(
                              title: Text('add_reminder'.localize()),
                              onTap: () async {
                                Reminder? reminder = (await showDialog<Reminder>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return SimpleDialog(
                                        children: <Widget>[
                                          for (final reminder in defaultAlarmOptions
                                              .map((mins) => Reminder(minutes: mins))
                                              .where((element) =>
                                          event.reminders?.none((p0) =>
                                          p0.minutes ==
                                              element.minutes) ??
                                              true))
                                            SimpleDialogOption(
                                              onPressed: () {
                                                Navigator.pop(context, reminder);
                                              },
                                              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                                              child: Text(reminderString(reminder)),
                                            ),
                                          SimpleDialogOption(
                                            onPressed: () {
                                              Navigator.pop(context, Reminder(minutes: 0));
                                            },
                                            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                                            child: Text(
                                                'custom_reminder'.localize()),
                                          ),
                                        ],
                                      );
                                    }));
                                if (!context.mounted) {
                                  return;
                                }
                                if (reminder?.minutes == 0) {
                                  reminder = reminder = (await showDialog<Reminder>(
                                    context: context,
                                    builder: (BuildContext context) {
                                      TextEditingController numberController =
                                      TextEditingController(text: '10');
                                      int currentIndex = 0;
                                      return AlertDialog(
                                        title:
                                        Text('custom_reminder'.localize()),
                                        content: StatefulBuilder(
                                          builder: (BuildContext context,
                                              void Function(void Function())
                                              setState) {
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextField(
                                                  controller: numberController,
                                                  keyboardType: TextInputType.number,
                                                ),
                                                for (final timeUnit
                                                in TimeUnit.values)
                                                  RadioListTile(
                                                    title: Text(
                                                        sprintf(
                                                            'n_before'.localize(),
                                                            [
                                                              sprintf(
                                                                  "n_${timeUnit.name}"
                                                                      .localize(),
                                                                  [0])
                                                            ])
                                                            .replaceAll('0', '')
                                                            .trim()),
                                                    value: TimeUnit.values
                                                        .indexOf(timeUnit),
                                                    groupValue: currentIndex,
                                                    onChanged: (int? value) {
                                                      setState(() =>
                                                      currentIndex = value ?? 0);
                                                    },
                                                  ),
                                              ],
                                            );
                                          },
                                        ),
                                        actions: <Widget>[
                                          TextButton(
                                            child: Text('confirm'.localize()),
                                            onPressed: () {
                                              int number = int.tryParse(
                                                  numberController.text) ??
                                                  0;
                                              Navigator.of(context).pop(Reminder(
                                                  minutes: number *
                                                      TimeUnit.values[currentIndex].inMinutes()));
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  ));
                                }
                                if (reminder != null) {
                                  setState(() {
                                    event.reminders = (event.reminders ?? [])
                                      ..add(reminder!);
                                  });
                                }
                              },
                            ),
                          ],),
                        )
                      ],)

                    ],
                  ),
                ),
              ],
            ),
          );
        }));
  }

  String reminderString(Reminder reminder) {
    String resultString = "";
    int minutes = reminder.minutes ?? 0;
    for (final timeUnit in TimeUnit.values.reversed) {
      final timeUnitMinutes = timeUnit.inMinutes();
      if (minutes >= timeUnitMinutes) {
        resultString += sprintf("n_${timeUnit.name}".localize(),
            [minutes ~/ timeUnitMinutes]);
        minutes = minutes % timeUnitMinutes;
      }
    }
    return sprintf('n_before'.localize(), [resultString.trim()]);
  }

  void setEndTime(BuildContext context) {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(endDate()),
    ).then((time) {
      if (time != null) {
        setState(() {
          event.end = event.end?.add(Duration(
              hours: time.hour - endDate().hour,
              minutes: time.minute - endDate().minute));
          if (endDate().isBefore(startDate())) {
            event.start = event.end;
          }
        });
      }
    });
  }

  void setStartTime(BuildContext context) {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(startDate()),
    ).then((time) {
      if (time != null) {
        setState(() {
          event.start = event.start?.add(Duration(
              hours: time.hour - startDate().hour,
              minutes: time.minute - startDate().minute));
          if (startDate().isAfter(endDate())) {
            event.end = event.start;
          }
        });
      }
    });
  }

  Future<void> setEndDate(BuildContext context) async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: endDate(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
            data: Theme.of(context).copyWith(useMaterial3: true),
            child: child!);
      },
    );
    if (newDate != null) {
      setState(() {
        event.end = epochMillisToTZDateTime(newDate.millisecondsSinceEpoch);
        if (endDate().isBefore(startDate())) {
          event.end = event.start;
        }
      });
    }
  }

  Future<void> setStartDate(BuildContext context) async {
    final newDate = await showDatePicker(
      context: context,
      initialDate: endDate(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
            data: Theme.of(context).copyWith(useMaterial3: true),
            child: child!);
      },
    );
    if (newDate != null) {
      setState(() {
        event.end = epochMillisToTZDateTime(newDate.millisecondsSinceEpoch);
        if (endDate().isBefore(startDate())) {
          event.start = event.end;
        }
      });
    }
  }

  Widget divider() {
    return Container(
      padding: const EdgeInsets.only(left: 12),
      height: 1,
      width: double.infinity,
      child:  ColoredBox(color: Colors.grey.shade300),
    );
  }

  Future confirmPress(BuildContext context) async {
    event.title = _titleController.text;
    event.description = _descriptionController.text;
    final eventId = await DeviceCalendarPlugin().createOrUpdateEvent(event);
    if (context.mounted) {
      Navigator.pop(context, (resultType: ResultType.saved, eventId: eventId?.data));
    }
  }


  static const defaultAlarmOptions = [
    30,
    1 * 60,
    3 * 60,
    12 * 60,
    24 * 60,
    48 * 60,
    7 * 24 * 60
  ];
}

enum TimeUnit { minutes, hours, days, weeks }

extension TimeUnitExtension on TimeUnit {
  int inMinutes() {
    switch (this) {
      case TimeUnit.minutes:
        return 1;
      case TimeUnit.hours:
        return 60; // 60 minutes in an hour
      case TimeUnit.days:
        return 1440; // 24 hours * 60 minutes
      case TimeUnit.weeks:
        return 10080; // 7 days * 24 hours * 60 minutes
    }
  }
}
