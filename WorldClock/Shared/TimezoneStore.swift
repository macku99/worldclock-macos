import Foundation
import OSLog
import SwiftUI
import WidgetKit

// The app and the widget share the list through a file in the real home folder, which each
// target's sandbox opens with a temporary exception. An app group would be the usual way, but
// macOS refuses a group container to a signature without a Team ID.
final class TimezoneStore {
  static let shared = TimezoneStore()

  static let sharedFileURL = realHomeDirectory
    .appendingPathComponent("Library/Application Support/WorldClock/timezones.json")

  private let fileURL: URL
  private let logger = Logger(subsystem: "app.itfrombit.worldclockapp", category: "TimezoneStore")

  init(fileURL: URL = TimezoneStore.sharedFileURL) {
    self.fileURL = fileURL
  }

  func selectedTimezones() -> [TimezoneSelection] {
    let data: Data
    do {
      data = try Data(contentsOf: fileURL)
    } catch CocoaError.fileReadNoSuchFile {
      return []
    } catch {
      logger.error("Could not read \(self.fileURL.path, privacy: .public): \(error.localizedDescription, privacy: .public)")
      return []
    }
    do {
      let timezones = try JSONDecoder().decode([TimezoneSelection].self, from: data)
      return timezones.sorted { $0.sortOrder < $1.sortOrder }
    } catch {
      logger.error("Could not decode \(self.fileURL.path, privacy: .public): \(error.localizedDescription, privacy: .public)")
      return []
    }
  }

  func save(_ timezones: [TimezoneSelection]) {
    do {
      let data = try JSONEncoder().encode(timezones)
      try FileManager.default.createDirectory(
        at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
      try data.write(to: fileURL, options: .atomic)
    } catch {
      logger.error("Could not save \(self.fileURL.path, privacy: .public): \(error.localizedDescription, privacy: .public)")
      return
    }
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

private extension TimezoneStore {
  // Inside the sandbox the home folder points into the app's container, so the shared file is
  // located from the account record instead.
  static var realHomeDirectory: URL {
    guard let record = getpwuid(getuid()), let directory = record.pointee.pw_dir else {
      return FileManager.default.homeDirectoryForCurrentUser
    }
    return URL(fileURLWithPath: String(cString: directory), isDirectory: true)
  }
}
