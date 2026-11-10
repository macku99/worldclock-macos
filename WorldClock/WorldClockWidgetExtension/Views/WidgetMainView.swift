import SwiftUI
import WidgetKit

struct WidgetMainView: View {
  let entry: WorldClockEntry

  var body: some View {
    if entry.selectedTimezones.isEmpty {
      emptyState
        .glassBackground()
    } else {
      clockLayout
        .glassBackground()
    }
  }

  private var clockLayout: some View {
    VStack(alignment: .leading, spacing: 8) {
      LocalClockView(date: entry.date, timeZone: entry.localTimezone)

      Divider()
        .background(Color.wcDivider)

      VStack(alignment: .leading, spacing: 6) {
        ForEach(entry.selectedTimezones) { selection in
          WorldClockRowView(
            selection: selection,
            localTimeZone: entry.localTimezone,
            date: entry.date
          )

          if selection.id != entry.selectedTimezones.last?.id {
            Divider()
              .background(Color.wcDivider)
          }
        }
      }
    }
    .padding(.top, 16)
    .padding(.horizontal, 14)
    .padding(.bottom, 14)
  }

  private var emptyState: some View {
    VStack(spacing: 12) {
      Image(systemName: "clock.fill")
        .font(.system(size: 32, weight: .light))
        .foregroundStyle(Color.wcTertiary)

      Text("Open WorldClock to add timezones")
        .font(.system(size: 13, weight: .medium, design: .default))
        .foregroundStyle(Color.wcSecondary)
        .multilineTextAlignment(.center)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }
}
