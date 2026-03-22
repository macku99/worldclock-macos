import SwiftUI
import WidgetKit

struct LocalClockView: View {
  let date: Date
  let timeZone: TimeZone

  var body: some View {
    HStack(alignment: .top, spacing: 0) {
      VStack(alignment: .leading, spacing: 2) {
        Text(DateFormatters.formattedTime(for: timeZone, date: date))
          .heroTimeStyle()

        Text("\(timeZone.displayName) \(DateFormatters.gmtOffset(for: timeZone, date: date))")
          .font(.system(size: 11, weight: .regular, design: .default))
          .foregroundStyle(Color.wcTertiary)
      }

      Spacer()

      VStack(alignment: .trailing, spacing: 0) {
        Text(DateFormatters.formattedDayName(for: timeZone, date: date))
          .font(.system(size: 11, weight: .bold, design: .default))
          .foregroundStyle(Color.wcAccentOrange)

        Text(DateFormatters.formattedDayNumber(for: timeZone, date: date))
          .font(.system(size: 34, weight: .thin, design: .default))
          .foregroundStyle(Color.wcPrimary)
      }
    }
    .frame(maxWidth: .infinity)
  }
}

private extension TimeZone {
  var displayName: String {
    let components = identifier.split(separator: "/")
    let city = components.last ?? Substring(identifier)
    return city.replacingOccurrences(of: "_", with: " ")
  }
}
