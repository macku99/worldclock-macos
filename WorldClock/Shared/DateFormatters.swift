import Foundation

enum DateFormatters {
  private static let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
  }()

  private static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEE, MMM d"
    return formatter
  }()

  static func formattedTime(for timeZone: TimeZone, date: Date = Date()) -> String {
    let formatter = timeFormatter.copy() as! DateFormatter
    formatter.timeZone = timeZone
    return formatter.string(from: date)
  }

  static func formattedDate(for timeZone: TimeZone, date: Date = Date()) -> String {
    let formatter = dateFormatter.copy() as! DateFormatter
    formatter.timeZone = timeZone
    return formatter.string(from: date)
  }

  static func gmtOffset(for timeZone: TimeZone, date: Date = Date()) -> String {
    let seconds = timeZone.secondsFromGMT(for: date)
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

  static func timeDifference(from local: TimeZone, to remote: TimeZone, date: Date = Date()) -> String {
    let localOffset = local.secondsFromGMT(for: date)
    let remoteOffset = remote.secondsFromGMT(for: date)
    let diffSeconds = remoteOffset - localOffset

    if diffSeconds == 0 { return "+0h" }

    let sign = diffSeconds >= 0 ? "+" : "-"
    let totalSeconds = abs(diffSeconds)
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60

    if minutes == 0 {
      return "\(sign)\(hours)h"
    }
    return "\(sign)\(hours):\(String(format: "%02d", minutes))h"
  }

  static func dayRelation(from local: TimeZone, to remote: TimeZone, date: Date = Date()) -> String {
    var localCalendar = Calendar.current
    localCalendar.timeZone = local
    var remoteCalendar = Calendar.current
    remoteCalendar.timeZone = remote

    let localDayInGMT = localCalendar.dateComponents([.year, .month, .day], from: date)
    let remoteDayInGMT = remoteCalendar.dateComponents([.year, .month, .day], from: date)

    guard let localDate = Calendar.current.date(from: localDayInGMT),
          let remoteDate = Calendar.current.date(from: remoteDayInGMT) else {
      return ""
    }

    let dayDiff = Calendar.current.dateComponents([.day], from: localDate, to: remoteDate).day ?? 0

    if dayDiff == 1 { return "Tomorrow" }
    if dayDiff == -1 { return "Yesterday" }
    return ""
  }
}
