import 'package:flutter/cupertino.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'edit_calendar_event_view_method_channel.dart';

abstract class EditCalendarEventViewPlatform extends PlatformInterface {
  /// Constructs a EditCalendarEventViewPlatform.
  EditCalendarEventViewPlatform() : super(token: _token);

  static final Object _token = Object();

  static EditCalendarEventViewPlatform _instance =
      MethodChannelEditCalendarEventView();

  /// The default instance of [EditCalendarEventViewPlatform] to use.
  ///
  /// Defaults to [MethodChannelEditCalendarEventView].
  static EditCalendarEventViewPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [EditCalendarEventViewPlatform] when
  /// they register themselves.
  static set instance(EditCalendarEventViewPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<
          ({
            ResultType resultType,
            String? eventId,
            String? calendarId,
          })>
      addOrEditCalendarEvent(BuildContext context,
          {String? calendarId,
          String? eventId,
          String? title,
          String? description,
          int? startDate,
          int? endDate,
          bool? allDay}) async {
    throw UnimplementedError(
        'addOrEditCalendarEvent() has not been implemented.');
  }
}
