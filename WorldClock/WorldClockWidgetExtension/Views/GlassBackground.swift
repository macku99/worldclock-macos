import SwiftUI
import WidgetKit

struct GlassBackground: ViewModifier {
  func body(content: Content) -> some View {
    content
      .containerBackground(for: .widget) {
        ZStack {
          Color.clear
            .background(.ultraThinMaterial)

          Color.black.opacity(0.35)

          RoundedRectangle(cornerRadius: 20)
            .stroke(Color.wcGlassBorder, lineWidth: 1)

          VStack(spacing: 0) {
            LinearGradient(
              colors: [Color.white.opacity(0.25), Color.clear],
              startPoint: .top,
              endPoint: .bottom
            )
            .frame(height: 2)
            .clipShape(
              RoundedRectangle(cornerRadius: 20)
            )
            Spacer()
          }
        }
      }
  }
}

extension View {
  func glassBackground() -> some View {
    modifier(GlassBackground())
  }
}
