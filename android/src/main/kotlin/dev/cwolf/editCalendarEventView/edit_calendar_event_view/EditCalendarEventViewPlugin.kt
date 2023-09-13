package dev.cwolf.editCalendarEventView.edit_calendar_event_view

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.content.ContentUris
import android.content.Intent
import android.provider.CalendarContract
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** EditCalendarEventViewPlugin */
class EditCalendarEventViewPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private var binding: ActivityPluginBinding? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "edit_calendar_event_view")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "addOrEditCalendarEvent") {
      val args = call.arguments as Map<String, Any>
      val calendarId = args["calendarId"] as String?
      val eventId = args["eventId"] as String?
      val title = args["title"] as String?
      val description = args["description"] as String?
      val startDate = args["startDate"] as Long?
      val endDate = args["endDate"] as Long?
      val allDay = args["allDay"] as Boolean?


      val intent =
        Intent(if (eventId == null) Intent.ACTION_INSERT else Intent.ACTION_EDIT)
      if (eventId == null) {
        intent.setData(CalendarContract.Events.CONTENT_URI)
      } else {
        intent.setData(
          ContentUris.withAppendedId(
            CalendarContract.Events.CONTENT_URI,
            eventId.toLong()
          )
        )
      }

      if (calendarId != null) {
        intent.putExtra(CalendarContract.Events.CALENDAR_ID, calendarId)
      }
      if (startDate != null) {
        intent.putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, startDate)
      }
      if (endDate != null) {
        intent.putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, endDate)
      }
      if (title != null) {
        intent.putExtra(CalendarContract.Events.TITLE, title)
      }
      if (description != null) {
        intent.putExtra(CalendarContract.Events.DESCRIPTION, description)
      }
      if (allDay == true) {
        intent.putExtra(CalendarContract.Events.ALL_DAY, allDay)
      }
      binding?.activity?.startActivity(intent)
      result.success(null)
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    this.binding = binding
  }

  override fun onDetachedFromActivityForConfigChanges() {
    TODO("Not yet implemented")
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    TODO("Not yet implemented")
  }

  override fun onDetachedFromActivity() {
    this.binding = null
  }
}
