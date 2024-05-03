import 'dart:io';

import 'package:device_calendar/device_calendar.dart';
import 'package:edit_calendar_event_view/edit_calendar_event_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'edit_calendar_event_view_platform_interface.dart';

enum ResultType { saved, deleted, unknown, canceled }

/// An implementation of [EditCalendarEventViewPlatform] that uses method channels.
class MethodChannelEditCalendarEventView extends EditCalendarEventViewPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('edit_calendar_event_view');

  @override
  Future<
      ({
        ResultType resultType,
        String? eventId,
        String? calendarId,
      })> addOrEditCalendarEvent(
    BuildContext context, {
    String? calendarId,
    String? eventId,
    String? title,
    String? description,
    int? startDate,
    int? endDate,
    bool? allDay,
  }) async {
    if (Platform.isAndroid) {
      if (((await DeviceCalendarPlugin().hasPermissions()).data == true ||
              (await DeviceCalendarPlugin().requestPermissions()).data ==
                  true) &&
          context.mounted) {
        var result = await EditCalendarEventPage.show(context,
            calendarId: calendarId,
            eventId: eventId,
            title: title,
            description: description,
            startDate: startDate,
            endDate: endDate,
            allDay: allDay);
        return result ??
            (
              resultType: ResultType.canceled,
              eventId: eventId,
              calendarId: calendarId
            );
      } else {
        return (
          resultType: ResultType.canceled,
          eventId: eventId,
          calendarId: calendarId
        );
      }
    } else {
      final result = await methodChannel.invokeMethod<Map<String, dynamic>>(
        'addOrEditCalendarEvent',
        {
          'calendarId': calendarId,
          'eventId': eventId,
          'title': title,
          'description': description,
          'startDate': startDate,
          'endDate': endDate,
          'allDay': allDay,
        },
      );
      if (result == null) {
        return (
          resultType: ResultType.canceled,
          eventId: eventId,
          calendarId: calendarId
        );
      } else if (result["eventId"] == "deleted") {
        return (
          resultType: ResultType.deleted,
          eventId: eventId,
          calendarId: calendarId
        );
      } else {
        return (
          resultType: ResultType.saved,
          eventId: result["eventId"] as String?,
          calendarId: result["calendarId"] as String?
        );
      }
    }
  }
}
