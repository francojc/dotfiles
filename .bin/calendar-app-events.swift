import EventKit
import Foundation

func usage() -> Never {
    FileHandle.standardError.write(Data("Usage: calendar-app-events YYYY-MM-DD calendar [calendar ...]\n".utf8))
    exit(2)
}

let arguments = CommandLine.arguments.dropFirst()
guard arguments.count >= 2 else { usage() }
let target = String(arguments.first!)
let requestedTitles = Array(arguments.dropFirst())

let dateParser = DateFormatter()
dateParser.locale = Locale(identifier: "en_US_POSIX")
dateParser.timeZone = TimeZone.current
dateParser.dateFormat = "yyyy-MM-dd"
guard let dayStart = dateParser.date(from: target),
      let dayEnd = Calendar.current.date(byAdding: .day, value: 1, to: dayStart) else {
    FileHandle.standardError.write(Data("Invalid date: \(target)\n".utf8))
    exit(2)
}

let store = EKEventStore()
let access = DispatchSemaphore(value: 0)
var granted = false
var accessError: Error?
if #available(macOS 14.0, *) {
    store.requestFullAccessToEvents { ok, error in
        granted = ok
        accessError = error
        access.signal()
    }
} else {
    store.requestAccess(to: .event) { ok, error in
        granted = ok
        accessError = error
        access.signal()
    }
}
_ = access.wait(timeout: .now() + 30)
guard granted else {
    let detail = accessError.map { ": \($0.localizedDescription)" } ?? ""
    FileHandle.standardError.write(Data("Calendar.app access denied or timed out\(detail). Grant Calendar access to calendar-app-events.\n".utf8))
    exit(1)
}

let allCalendars = store.calendars(for: .event)
var selected: [EKCalendar] = []
var status = 0
for title in requestedTitles {
    let matches = allCalendars.filter { $0.title == title }
    if matches.isEmpty {
        FileHandle.standardError.write(Data("Calendar.app unavailable: \(title): calendar not found\n".utf8))
        status = 1
    } else {
        selected.append(contentsOf: matches)
    }
}

let timeFormatter = DateFormatter()
timeFormatter.locale = Locale(identifier: "en_US_POSIX")
timeFormatter.timeZone = TimeZone.current
timeFormatter.dateFormat = "HH:mm"

func escaped(_ text: String) -> String {
    text.replacingOccurrences(of: "\\", with: "\\\\")
        .replacingOccurrences(of: "\r\n", with: "\\n")
        .replacingOccurrences(of: "\n", with: "\\n")
        .replacingOccurrences(of: "\r", with: "\\n")
        .replacingOccurrences(of: "\t", with: "\\t")
}

let predicate = store.predicateForEvents(withStart: dayStart, end: dayEnd, calendars: selected)
let events = store.events(matching: predicate).sorted {
    if $0.startDate != $1.startDate { return $0.startDate < $1.startDate }
    if $0.calendar.title != $1.calendar.title { return $0.calendar.title < $1.calendar.title }
    return ($0.title ?? "") < ($1.title ?? "")
}
var seen = Set<String>()
for event in events {
    let key = "\(event.calendar.calendarIdentifier)|\(event.eventIdentifier ?? event.calendarItemIdentifier)"
    guard seen.insert(key).inserted else { continue }
    let start = event.isAllDay ? "all-day" : timeFormatter.string(from: event.startDate)
    let end = event.isAllDay ? "all-day" : timeFormatter.string(from: event.endDate)
    print("\(event.calendar.title): \(start) - \(end): \(escaped(event.title ?? "(untitled)"))")
}
exit(Int32(status))
