import Flutter
import UIKit
import EventKitUI

public class SwiftEditCalendarEventViewPlugin: NSObject, FlutterPlugin, EKEventEditViewDelegate {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "edit_calendar_event_view", binaryMessenger: registrar.messenger())
        let instance = SwiftEditCalendarEventViewPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    struct Arguments: Codable {
        var allDay: Bool?
        var title: String?
        var startDate: Int64?
        var description: String?
        var calendarId: String?
        var eventId: String?
        var endDate: Int64?
        
        static func createArguments(from dictionary: [String: Any]) -> Arguments? {
            do {
                let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .millisecondsSince1970
                let args = try decoder.decode(Arguments.self, from: data)
                return args
            } catch {
                print("Error creating event: \(error)")
                return nil
            }
        }
    }
    
    var result: FlutterResult?
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let dict = call.arguments as? [String: Any] ?? [:]
        
        let arguments = Arguments.createArguments(from: dict)
        
        self.result = result
        
        switch EKEventStore.authorizationStatus(for: .event) {
        case .notDetermined:
            let eventStore = EKEventStore()
            eventStore.requestAccess(to: .event) { (granted, error) in
                if granted {
                    // do stuff
                    DispatchQueue.main.async {
                        self.showEventViewController(arguments: arguments)
                    }
                }
            }
        case .authorized:
            // do stuff
            DispatchQueue.main.async {
                self.showEventViewController(arguments: arguments)
            }
        default:
            break
        }
    }
    
    
    func showEventViewController(arguments: Arguments?) {
        let eventVC = EKEventEditViewController()
        eventVC.editViewDelegate = self
        eventVC.eventStore = EKEventStore()
        
        if let arguments = arguments {
            var event = EKEvent(eventStore: eventVC.eventStore)
            if let eventId = arguments.eventId {
                if let loadedEvent = eventVC.eventStore.event(withIdentifier: eventId) {
                    // Event with matching identifier found, use it
                    event = loadedEvent
                }
            }
            if let title = arguments.title {
                event.title = title
            }
            if let description = arguments.description {
                event.notes = description
            }
            if let allDay = arguments.allDay {
                event.isAllDay = allDay
            }
            if let calendarId = arguments.calendarId {
                if let loadedCalendar = eventVC.eventStore.calendar(withIdentifier: calendarId) {
                    // Calendar with matching identifier found, use it
                    event.calendar = loadedCalendar
                }
            }
                if let startDate = arguments.startDate  {
                    event.startDate = Date(timeIntervalSince1970: Double(startDate) / 1000)
                }
                if let endDate = arguments.endDate  {
                    event.endDate = Date(timeIntervalSince1970: Double(endDate) / 1000)
                }
                
                eventVC.event = event
            }
            
            if let rootVC = UIApplication.shared.windows.first?.rootViewController {
                rootVC.present(eventVC, animated: true)
            }
        }
        
    public func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        if let rootVC = UIApplication.shared.windows.first?.rootViewController {
            rootVC.dismiss(animated: true, completion: nil)
        }
        
        var eventData: [String: Any]? // Используем словарь для хранения данных события и календаря
        
        switch(action) {
        case .saved:
            if let event = controller.event, let calendar = event.calendar {
                eventData = [
                    "eventId": event.eventIdentifier,
                    "calendarId": calendar.calendarIdentifier
                ]
            }
        case .deleted:
            eventData = ["eventId": "deleted"]
        case .canceled:
            eventData = nil
        @unknown default:
            eventData = nil
        }
        
        result?(eventData) // Возвращаем словарь с данными в Flutter
        self.result = nil
    }
        
    }


