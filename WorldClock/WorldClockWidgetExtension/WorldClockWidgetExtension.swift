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

  func getSnapshot(in context: Context, completion: @escaping (WorldClockEntry) -> ()) {
    let entry = WorldClockEntry(
      date: Date(),
      localTimezone: .current,
      selectedTimezones: store.selectedTimezones()
    )
    completion(entry)
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<WorldClockEntry>) -> ()) {
    let now = Date()
    let calendar = Calendar.current
    let timezones = store.selectedTimezones()

    var entries: [WorldClockEntry] = []

    for minuteOffset in 0..<60 {
      guard let entryDate = calendar.date(byAdding: .minute, value: minuteOffset, to: now) else {
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

    let timeline = Timeline(entries: entries, policy: .atEnd)
    completion(timeline)
  }
}

@main
struct WorldClockWidget: Widget {
  let kind: String = "WorldClockWidgetExtension"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: WorldClockProvider()) { entry in
      WidgetMainView(entry: entry)
    }
    .supportedFamilies([.systemExtraLarge])
    .configurationDisplayName("World Clock")
    .description("Display your local time alongside world clocks.")
  }
}
