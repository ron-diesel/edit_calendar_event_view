import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'edit_calendar_event_view_platform_interface.dart';

enum ResultType {
  saved,
  deleted,
  unknown
}

/// An implementation of [EditCalendarEventViewPlatform] that uses method channels.
class MethodChannelEditCalendarEventView extends EditCalendarEventViewPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('edit_calendar_event_view');


  @override
  Future<({ResultType resultType, String? eventId})> addOrEditCalendarEvent({String? calendarId, String? eventId, String? title, String? description, DateTime? startDate, DateTime? endDate, bool?  allDay}) async {
    final result = await methodChannel.invokeMethod<String?>(
      'addOrEditCalendarEvent',
      {
        'calendarId': calendarId,
        'eventId': eventId,
        'title': title,
        'description': description,
        'startDate': startDate?.millisecondsSinceEpoch,
        'endDate': endDate?.millisecondsSinceEpoch,
        'allDay': allDay,
      },
    );
    if (Platform.isAndroid) { // android intent doesn't give an result so we don't know the result
      return (resultType: ResultType.unknown, eventId: null);
    } else {
      if (result == "deleted") {
        return (resultType: ResultType.deleted, eventId: null);
      } else {
        return (resultType: ResultType.saved, eventId: result);
      }
    }
  }
}
