import Foundation

struct TimezoneSelection: Codable, Identifiable, Hashable {
  let id: UUID
  var timezoneIdentifier: String
  var customLabel: String?
  var sortOrder: Int

  init(id: UUID = UUID(), timezoneIdentifier: String, customLabel: String? = nil, sortOrder: Int = 0) {
    self.id = id
    self.timezoneIdentifier = timezoneIdentifier
    self.customLabel = customLabel
    self.sortOrder = sortOrder
  }

  var timeZone: TimeZone? {
    TimeZone(identifier: timezoneIdentifier)
  }

  var displayName: String {
    if let customLabel, !customLabel.isEmpty {
      return customLabel
    }
    let components = timezoneIdentifier.split(separator: "/")
    let city = components.last ?? Substring(timezoneIdentifier)
    return city.replacingOccurrences(of: "_", with: " ")
  }

  var gmtOffsetLabel: String {
    guard let timeZone else { return "" }
    let seconds = timeZone.secondsFromGMT()
    if seconds == 0 { return "GMT" }

    let sign = seconds >= 0 ? "+" : "-"
    let totalSeconds = abs(seconds)
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60

    if minutes == 0 {
      return "GMT\(sign)\(hours)"
    }
    return "GMT\(sign)\(hours):\(String(format: "%02d", minutes))"
  }

  var fullDisplayLabel: String {
    "\(displayName) \(gmtOffsetLabel)"
  }
}

extension Array where Element == TimezoneSelection {
  /// West to east by the offset in effect at `date`, so the list reads like a map; zones with
  /// the same offset go by name, and an identifier the system doesn't know goes last.
  func sortedByOffset(at date: Date) -> [TimezoneSelection] {
    sorted { lhs, rhs in
      switch (lhs.timeZone?.secondsFromGMT(for: date), rhs.timeZone?.secondsFromGMT(for: date)) {
      case let (left?, right?) where left != right:
        return left < right
      case (.some, .some):
        return lhs.displayName.localizedStandardCompare(rhs.displayName) == .orderedAscending
      case (.some, nil):
        return true
      case (nil, _):
        return false
      }
    }
    .enumerated()
    .map { index, selection in
      var selection = selection
      selection.sortOrder = index
      return selection
    }
  }
}
