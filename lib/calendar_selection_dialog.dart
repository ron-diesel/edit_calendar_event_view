import 'package:device_calendar/device_calendar.dart';
import 'package:edit_calendar_event_view/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CalendarSelectionDialog {
  static Future<Calendar?> showCalendarDialog(
    BuildContext context,
    String title,
    String? notSetString,
    List<Calendar> calendars,
    Calendar? selected,
  ) async {

    return showDialog<Calendar>(
      context: context,
      builder: (BuildContext context) {
        final startIndex = notSetString == null ? 0 : 1;
        return AlertDialog(
          title: Text(title),
          contentPadding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: calendars.length + startIndex,
              itemBuilder: (BuildContext context, int index) {
                final calendar = calendars.atIndexOrNull(index - startIndex);
                return RadioListTile<Calendar?>.adaptive(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity:  VisualDensity(
                    horizontal: VisualDensity.minimumDensity,
                    vertical: VisualDensity.comfortable.vertical,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  title: Text(calendar?.name ?? notSetString ?? ''),
                  value: calendar,
                  groupValue: selected,
                  onChanged: (Calendar? value) {
                    if (value == null) {
                      Navigator.pop(context, Calendar());
                    } else {
                      Navigator.pop(context, value);
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
