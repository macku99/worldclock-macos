import WidgetKit
import SwiftUI

struct WorldClockProvider: TimelineProvider {
  private let store = TimezoneStore.shared

  func placeholder(in context: Context) -> WorldClockEntry {
    WorldClockEntry(
      date: Date(),
      localTimezone: .current,
      selectedTimezones: [
        TimezoneSelection(timezoneIdentifier: "America/New_York", sortOrder: 0),
        TimezoneSelection(timezoneIdentifier: "Europe/London", sortOrder: 1),
        TimezoneSelection(timezoneIdentifier: "Asia/Tokyo", sortOrder: 2),
      ]
    )
  }

  func getSnapshot(in context: Context, completion: @escaping (WorldClockEntry) -> Void) {
    let now = Date()
    completion(
      WorldClockEntry(
        date: now,
        localTimezone: .current,
        selectedTimezones: store.selectedTimezones().sortedByOffset(at: now)
      )
    )
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<WorldClockEntry>) -> Void) {
    let now = Date()
    let calendar = Calendar.current
    let timezones = store.selectedTimezones().sortedByOffset(at: now)

    let startOfMinute = calendar.dateInterval(of: .minute, for: now)?.start ?? now

    var entries: [WorldClockEntry] = []

    for minuteOffset in 0..<60 {
      guard let entryDate = calendar.date(byAdding: .minute, value: minuteOffset, to: startOfMinute) else {
        continue
      }
      entries.append(
        WorldClockEntry(
          date: entryDate,
          localTimezone: .current,
          selectedTimezones: timezones
        )
      )
    }

    completion(Timeline(entries: entries, policy: .atEnd))
  }
}

@main
struct WorldClockWidget: Widget {
  let kind: String = "WorldClockWidgetExtension"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: WorldClockProvider()) { entry in
      WidgetMainView(entry: entry)
    }
    .supportedFamilies([.systemLarge])
    .contentMarginsDisabled()
    .configurationDisplayName("World Clock")
    .description("Display your local time alongside world clocks.")
  }
}
