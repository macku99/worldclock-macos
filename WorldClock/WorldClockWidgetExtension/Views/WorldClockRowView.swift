import SwiftUI
import WidgetKit

struct WorldClockRowView: View {
  let selection: TimezoneSelection
  let localTimeZone: TimeZone
  let date: Date

  var body: some View {
    if let remoteTimeZone = selection.timeZone {
      let isNight = DateFormatters.isNightTime(for: remoteTimeZone, date: date)

      HStack(alignment: .center) {
        Text("\(selection.displayName) \(DateFormatters.gmtOffset(for: remoteTimeZone, date: date))")
          .cityNameStyle()

        Spacer()

        HStack(alignment: .firstTextBaseline, spacing: 6) {
          Text(DateFormatters.timeDifference(from: localTimeZone, to: remoteTimeZone, date: date))
            .captionStyle()

          Text(DateFormatters.formattedTime(for: remoteTimeZone, date: date))
            .rowTimeStyle(isNight: isNight)
        }
      }
    }
  }
}
