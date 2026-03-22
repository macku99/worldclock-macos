import Foundation
import SwiftUI
import WidgetKit

final class TimezoneStore {
  static let shared = TimezoneStore()

  private let defaults: UserDefaults?
  private let storageKey = "selectedTimezones"

  init(suiteName: String = "group.app.itfrombit.worldclock") {
    self.defaults = UserDefaults(suiteName: suiteName)
  }

  func selectedTimezones() -> [TimezoneSelection] {
    guard let data = defaults?.data(forKey: storageKey),
          let timezones = try? JSONDecoder().decode([TimezoneSelection].self, from: data)
    else { return [] }
    return timezones.sorted { $0.sortOrder < $1.sortOrder }
  }

  func save(_ timezones: [TimezoneSelection]) {
    guard let data = try? JSONEncoder().encode(timezones) else { return }
    defaults?.set(data, forKey: storageKey)
    WidgetCenter.shared.reloadAllTimelines()
  }

  func addTimezone(_ identifier: String, label: String? = nil) {
    var timezones = selectedTimezones()
    let nextOrder = (timezones.map(\.sortOrder).max() ?? -1) + 1
    let selection = TimezoneSelection(
      timezoneIdentifier: identifier,
      customLabel: label,
      sortOrder: nextOrder
    )
    timezones.append(selection)
    save(timezones)
  }

  func removeTimezone(id: UUID) {
    var timezones = selectedTimezones()
    timezones.removeAll { $0.id == id }
    for i in timezones.indices {
      timezones[i].sortOrder = i
    }
    save(timezones)
  }

  func reorder(from source: IndexSet, to destination: Int) {
    var timezones = selectedTimezones()
    timezones.move(fromOffsets: source, toOffset: destination)
    for i in timezones.indices {
      timezones[i].sortOrder = i
    }
    save(timezones)
  }
}
