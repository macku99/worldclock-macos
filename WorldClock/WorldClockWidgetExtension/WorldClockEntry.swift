import WidgetKit
import Foundation

struct WorldClockEntry: TimelineEntry {
  let date: Date
  let localTimezone: TimeZone
  let selectedTimezones: [TimezoneSelection]
}
