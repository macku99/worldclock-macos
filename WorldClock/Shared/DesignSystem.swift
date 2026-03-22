import SwiftUI

// MARK: - Color Extensions

extension Color {
  init(hex: String) {
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&int)
    let a, r, g, b: UInt64
    switch hex.count {
    case 6:
      (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
    case 8:
      (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
    default:
      (a, r, g, b) = (255, 0, 0, 0)
    }
    self.init(
      .sRGB,
      red: Double(r) / 255,
      green: Double(g) / 255,
      blue: Double(b) / 255,
      opacity: Double(a) / 255
    )
  }

  static let wcPrimary = Color.white
  static let wcSecondary = Color.white.opacity(0.7)
  static let wcTertiary = Color.white.opacity(0.4)
  static let wcAccentBlue = Color(hex: "7EB6FF")
  static let wcAccentViolet = Color(hex: "B48EF0")
  static let wcDivider = Color.white.opacity(0.12)
  static let wcGlassBg = Color.black.opacity(0.35)
  static let wcGlassBorder = Color.white.opacity(0.15)
}

// MARK: - Typography

struct HeroTimeStyle: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(.system(size: 64, weight: .ultraLight, design: .rounded))
      .foregroundStyle(Color.wcPrimary)
  }
}

struct CityNameStyle: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(.system(size: 15, weight: .medium, design: .rounded))
      .foregroundStyle(Color.wcPrimary)
  }
}

struct RowTimeStyle: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(.system(size: 28, weight: .light, design: .rounded))
      .foregroundStyle(Color.wcPrimary)
  }
}

struct CaptionStyle: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(.system(size: 12, weight: .regular, design: .rounded))
      .foregroundStyle(Color.wcSecondary)
  }
}

extension View {
  func heroTimeStyle() -> some View {
    modifier(HeroTimeStyle())
  }

  func cityNameStyle() -> some View {
    modifier(CityNameStyle())
  }

  func rowTimeStyle() -> some View {
    modifier(RowTimeStyle())
  }

  func captionStyle() -> some View {
    modifier(CaptionStyle())
  }
}
