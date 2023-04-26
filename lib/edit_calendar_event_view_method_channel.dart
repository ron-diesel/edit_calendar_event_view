import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'edit_calendar_event_view_platform_interface.dart';

/// An implementation of [EditCalendarEventViewPlatform] that uses method channels.
class MethodChannelEditCalendarEventView extends EditCalendarEventViewPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('edit_calendar_event_view');


  @override
  Future<String?> addOrEditCalendarEvent({String? calendarId, String? eventId, String? title, String? description, DateTime? startDate, DateTime? endDate, bool?  allDay}) async {
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
    return result;
  }
}
