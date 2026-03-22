import SwiftUI
import WidgetKit

struct LocalClockView: View {
  let date: Date
  let timeZone: TimeZone

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(DateFormatters.formattedTime(for: timeZone, date: date))
        .heroTimeStyle()

      Text(DateFormatters.formattedDate(for: timeZone, date: date))
        .captionStyle()

      Text("\(timeZone.displayName) \(DateFormatters.gmtOffset(for: timeZone, date: date))")
        .font(.system(size: 13, weight: .regular, design: .rounded))
        .foregroundStyle(Color.wcTertiary)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

private extension TimeZone {
  var displayName: String {
    let components = identifier.split(separator: "/")
    let city = components.last ?? Substring(identifier)
    return city.replacingOccurrences(of: "_", with: " ")
  }
}
