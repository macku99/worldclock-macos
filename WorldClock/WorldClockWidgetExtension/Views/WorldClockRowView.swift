import SwiftUI
import WidgetKit

struct WorldClockRowView: View {
  let selection: TimezoneSelection
  let localTimeZone: TimeZone
  let date: Date

  var body: some View {
    if let remoteTimeZone = selection.timeZone {
      let isNight = DateFormatters.isNightTime(for: remoteTimeZone, date: date)
      let offset = TimeInterval(remoteTimeZone.secondsFromGMT(for: date) - localTimeZone.secondsFromGMT(for: date))
      let offsetDate = date.addingTimeInterval(offset)

      HStack(alignment: .center) {
        Text("\(selection.displayName) \(DateFormatters.gmtOffset(for: remoteTimeZone, date: date))")
          .cityNameStyle()

        Spacer()

        HStack(alignment: .firstTextBaseline, spacing: 6) {
          Text(DateFormatters.timeDifference(from: localTimeZone, to: remoteTimeZone, date: date))
            .captionStyle()

          Text(offsetDate, style: .time)
            .rowTimeStyle(isNight: isNight)
        }
      }
    }
  }
}
