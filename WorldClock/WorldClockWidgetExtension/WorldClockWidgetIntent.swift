import AppIntents
import WidgetKit

struct TimezoneEntity: AppEntity {
  static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Timezone")
  static var defaultQuery = TimezoneEntityQuery()

  var id: String
  var displayName: String
  var gmtOffset: String

  var displayRepresentation: DisplayRepresentation {
    DisplayRepresentation(title: "\(displayName)", subtitle: "\(gmtOffset)")
  }

  init(from selection: TimezoneSelection) {
    self.id = selection.timezoneIdentifier
    self.displayName = selection.displayName
    self.gmtOffset = selection.gmtOffsetLabel
  }
}

// The widget offers every zone the system knows, because a signature without a Team ID
// cannot open an app group, so the widget has no way to read the app's list.
struct TimezoneEntityQuery: EntityStringQuery {
  func entities(for identifiers: [String]) async throws -> [TimezoneEntity] {
    let known = Set(TimeZone.knownTimeZoneIdentifiers)
    return identifiers
      .filter(known.contains)
      .map { TimezoneEntity(from: TimezoneSelection(timezoneIdentifier: $0)) }
  }

  func entities(matching string: String) async throws -> [TimezoneEntity] {
    allEntities().filter {
      $0.displayName.localizedCaseInsensitiveContains(string)
        || $0.id.localizedCaseInsensitiveContains(string)
    }
  }

  func suggestedEntities() async throws -> [TimezoneEntity] {
    allEntities()
  }

  func defaultResult() async -> TimezoneEntity? {
    nil
  }

  private func allEntities() -> [TimezoneEntity] {
    TimeZone.knownTimeZoneIdentifiers
      .map { TimezoneEntity(from: TimezoneSelection(timezoneIdentifier: $0)) }
      .sorted { $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending }
  }
}

struct WorldClockWidgetIntent: WidgetConfigurationIntent {
  static var title: LocalizedStringResource = "Select Timezones"
  static var description = IntentDescription("Choose which timezones to display in this widget.")

  @Parameter(title: "Timezones")
  var timezones: [TimezoneEntity]?

  func selectedTimezones() -> [TimezoneSelection] {
    (timezones ?? []).enumerated().map { index, entity in
      TimezoneSelection(timezoneIdentifier: entity.id, sortOrder: index)
    }
  }
}
