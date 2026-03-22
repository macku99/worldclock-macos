import WidgetKit
import SwiftUI

struct WorldClockProvider: AppIntentTimelineProvider {
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

  func snapshot(for configuration: WorldClockWidgetIntent, in context: Context) async -> WorldClockEntry {
    WorldClockEntry(
      date: Date(),
      localTimezone: .current,
      selectedTimezones: configuration.selectedTimezones()
    )
  }

  func timeline(for configuration: WorldClockWidgetIntent, in context: Context) async -> Timeline<WorldClockEntry> {
    let now = Date()
    let calendar = Calendar.current
    let timezones = configuration.selectedTimezones()

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

    return Timeline(entries: entries, policy: .atEnd)
  }
}

@main
struct WorldClockWidget: Widget {
  let kind: String = "WorldClockWidgetExtension"

  var body: some WidgetConfiguration {
    AppIntentConfiguration(kind: kind, intent: WorldClockWidgetIntent.self, provider: WorldClockProvider()) { entry in
      WidgetMainView(entry: entry)
    }
    .supportedFamilies([.systemLarge])
    .contentMarginsDisabled()
    .configurationDisplayName("World Clock")
    .description("Display your local time alongside world clocks.")
  }
}
