import SwiftUI
import WidgetKit

struct WorldClockRowView: View {
  let selection: TimezoneSelection
  let localTimeZone: TimeZone
  let date: Date

  var body: some View {
    if let remoteTimeZone = selection.timeZone {
      HStack(alignment: .center) {
        VStack(alignment: .leading, spacing: 2) {
          Text("\(selection.displayName) \(DateFormatters.gmtOffset(for: remoteTimeZone, date: date))")
            .cityNameStyle()

          let dayLabel = DateFormatters.dayRelation(from: localTimeZone, to: remoteTimeZone, date: date)
          if !dayLabel.isEmpty {
            Text(dayLabel)
              .font(.system(size: 11, weight: .medium, design: .rounded))
              .foregroundStyle(Color.wcAccentBlue)
          }
        }

        Spacer()

        HStack(alignment: .firstTextBaseline, spacing: 8) {
          Text(DateFormatters.timeDifference(from: localTimeZone, to: remoteTimeZone, date: date))
            .captionStyle()

          Text(DateFormatters.formattedTime(for: remoteTimeZone, date: date))
            .rowTimeStyle()
        }
      }
    }
  }
}
