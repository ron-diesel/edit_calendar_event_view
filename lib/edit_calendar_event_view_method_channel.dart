import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'edit_calendar_event_view_platform_interface.dart';

enum ResultType {
  saved,
  deleted,
  unknown,
  canceled
}

/// An implementation of [EditCalendarEventViewPlatform] that uses method channels.
class MethodChannelEditCalendarEventView extends EditCalendarEventViewPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('edit_calendar_event_view');


  @override
  Future<({ResultType resultType, String? eventId})> addOrEditCalendarEvent({String? calendarId, String? eventId, String? title, String? description, int? startDate, int? endDate, bool?  allDay}) async {
    final result = await methodChannel.invokeMethod<String?>(
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
    if (Platform.isAndroid) { // android intent doesn't give an result so we don't know the result
      return (resultType: ResultType.unknown, eventId: null);
    } else {
      if (result == null) {
        return (resultType: ResultType.canceled, eventId: null);
      } else if (result == "deleted") {
        return (resultType: ResultType.deleted, eventId: null);
      } else {
        return (resultType: ResultType.saved, eventId: result);
      }
    }
  }
}
