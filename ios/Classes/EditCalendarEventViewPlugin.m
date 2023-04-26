#import "EditCalendarEventViewPlugin.h"
#if __has_include(<edit_calendar_event_view/edit_calendar_event_view-Swift.h>)
#import <edit_calendar_event_view/edit_calendar_event_view-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "edit_calendar_event_view-Swift.h"
#endif

@implementation EditCalendarEventViewPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftEditCalendarEventViewPlugin registerWithRegistrar:registrar];
}
@end
