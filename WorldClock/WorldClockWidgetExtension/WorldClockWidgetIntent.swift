import AppIntents
import WidgetKit

// The widget offers every zone the system knows, because a signature without a Team ID
// cannot open an app group, so the widget has no way to read the app's list. The choices are
// plain identifiers rather than an AppEntity: without a Team ID, AppIntents cannot build an
// entity identifier, and a widget configuration holding entities is never saved.
struct TimezoneOptionsProvider: DynamicOptionsProvider {
  func results() async throws -> [String] {
    TimeZone.knownTimeZoneIdentifiers
  }
}

struct WorldClockWidgetIntent: WidgetConfigurationIntent {
  static var title: LocalizedStringResource = "Select Timezones"
  static var description = IntentDescription("Choose which timezones to display in this widget.")

  @Parameter(title: "Timezones", optionsProvider: TimezoneOptionsProvider())
  var timezones: [String]?

  func selectedTimezones(at date: Date) -> [TimezoneSelection] {
    (timezones ?? [])
      .map { TimezoneSelection(timezoneIdentifier: $0) }
      .sortedByOffset(at: date)
  }
}
