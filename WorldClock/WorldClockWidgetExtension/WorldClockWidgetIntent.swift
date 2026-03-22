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

struct TimezoneEntityQuery: EntityQuery {
  func entities(for identifiers: [String]) async throws -> [TimezoneEntity] {
    let store = TimezoneStore.shared
    let all = store.selectedTimezones()
    return identifiers.compactMap { identifier in
      all.first(where: { $0.timezoneIdentifier == identifier })
        .map { TimezoneEntity(from: $0) }
    }
  }

  func suggestedEntities() async throws -> [TimezoneEntity] {
    TimezoneStore.shared.selectedTimezones().map { TimezoneEntity(from: $0) }
  }

  func defaultResult() async -> TimezoneEntity? {
    nil
  }
}

struct WorldClockWidgetIntent: WidgetConfigurationIntent {
  static var title: LocalizedStringResource = "Select Timezones"
  static var description = IntentDescription("Choose which timezones to display in this widget.")

  @Parameter(title: "Timezones")
  var timezones: [TimezoneEntity]?

  func selectedTimezones() -> [TimezoneSelection] {
    let store = TimezoneStore.shared
    let allTimezones = store.selectedTimezones()

    guard let selected = timezones, !selected.isEmpty else {
      return allTimezones
    }

    let selectedIds = selected.map(\.id)
    return selectedIds.compactMap { id in
      allTimezones.first(where: { $0.timezoneIdentifier == id })
    }
  }
}
