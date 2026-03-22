//
//  TimezonePickerView.swift
//  WorldClock
//

import Combine
import SwiftUI

struct TimezonePickerView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var searchText = ""
  @State private var now = Date()

  private let store = TimezoneStore.shared
  private let selectedIdentifiers: Set<String>
  private let groupedTimezones: [(region: String, identifiers: [String])]

  init(selectedIdentifiers: Set<String>) {
    self.selectedIdentifiers = selectedIdentifiers
    self.groupedTimezones = Self.buildGroupedTimezones()
  }

  var body: some View {
    VStack(spacing: 0) {
      HStack {
        Text("Add Timezone")
          .font(.system(size: 16, weight: .semibold, design: .rounded))
        Spacer()
        Button("Done") { dismiss() }
          .keyboardShortcut(.cancelAction)
      }
      .padding()

      Divider()

      List {
        ForEach(filteredGroups, id: \.region) { group in
          Section(group.region) {
            ForEach(group.identifiers, id: \.self) { identifier in
              timezoneRow(identifier)
            }
          }
        }
      }
      .listStyle(.inset)
      .searchable(text: $searchText, placement: .toolbar, prompt: "Search cities")
    }
    .frame(width: 420, height: 500)
    .preferredColorScheme(.dark)
    .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) {
      now = $0
    }
  }

  private var filteredGroups: [(region: String, identifiers: [String])] {
    let query = searchText.lowercased()
    if query.isEmpty { return groupedTimezones }

    return groupedTimezones.compactMap { group in
      let filtered = group.identifiers.filter { identifier in
        let city = Self.cityName(from: identifier).lowercased()
        let region = group.region.lowercased()
        return city.contains(query) || region.contains(query) || identifier.lowercased().contains(query)
      }
      return filtered.isEmpty ? nil : (region: group.region, identifiers: filtered)
    }
  }

  private func timezoneRow(_ identifier: String) -> some View {
    let isSelected = selectedIdentifiers.contains(identifier)
    let tz = TimeZone(identifier: identifier)
    let city = Self.cityName(from: identifier)
    let offset = tz.map { DateFormatters.gmtOffset(for: $0, date: now) } ?? ""
    let time = tz.map { DateFormatters.formattedTime(for: $0, date: now) } ?? ""

    return Button {
      if !isSelected {
        store.addTimezone(identifier)
        dismiss()
      }
    } label: {
      HStack {
        VStack(alignment: .leading, spacing: 2) {
          Text(city)
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundStyle(isSelected ? Color.wcTertiary : Color.wcPrimary)
          Text(offset)
            .font(.system(size: 12, weight: .regular, design: .rounded))
            .foregroundStyle(isSelected ? Color.wcTertiary : Color.wcSecondary)
        }

        Spacer()

        if isSelected {
          Image(systemName: "checkmark")
            .foregroundStyle(Color.wcAccentBlue)
            .font(.system(size: 12, weight: .semibold))
        } else {
          Text(time)
            .font(.system(size: 14, weight: .light, design: .rounded))
            .foregroundStyle(Color.wcSecondary)
        }
      }
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .disabled(isSelected)
  }

  private static func cityName(from identifier: String) -> String {
    let components = identifier.split(separator: "/")
    let city = components.last ?? Substring(identifier)
    return city.replacingOccurrences(of: "_", with: " ")
  }

  private static func buildGroupedTimezones() -> [(region: String, identifiers: [String])] {
    var groups: [String: [String]] = [:]

    for identifier in TimeZone.knownTimeZoneIdentifiers {
      let components = identifier.split(separator: "/")
      guard components.count >= 2 else { continue }
      let region = String(components[0])
      groups[region, default: []].append(identifier)
    }

    return groups.keys.sorted().map { region in
      let sorted = groups[region]!.sorted { a, b in
        Self.cityName(from: a) < Self.cityName(from: b)
      }
      return (region: region, identifiers: sorted)
    }
  }
}
