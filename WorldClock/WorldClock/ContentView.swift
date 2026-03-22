//
//  ContentView.swift
//  WorldClock
//
//  Created by Marius on 22/3/26.
//

import Combine
import SwiftUI

struct ContentView: View {
  @State private var timezones: [TimezoneSelection] = []
  @State private var showingTimezonePicker = false
  @State private var now = Date()

  private let store = TimezoneStore.shared
  private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  private let localTimeZone = TimeZone.current

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        localTimeHero
          .padding(.horizontal, 20)
          .padding(.top, 20)
          .padding(.bottom, 16)

        Divider()

        if timezones.isEmpty {
          emptyState
        } else {
          timezoneList
        }
      }
      .frame(minWidth: 400, minHeight: 500)
      .background(Color(nsColor: .windowBackgroundColor))
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button {
            showingTimezonePicker = true
          } label: {
            Label("Add Timezone", systemImage: "plus")
          }
        }
      }
      .navigationTitle("WorldClock")
    }
    .preferredColorScheme(.dark)
    .onAppear { timezones = store.selectedTimezones() }
    .onReceive(timer) { now = $0 }
    .sheet(isPresented: $showingTimezonePicker) {
      TimezonePickerView(
        selectedIdentifiers: Set(timezones.map(\.timezoneIdentifier))
      )
    }
    .onChange(of: showingTimezonePicker) {
      if !showingTimezonePicker {
        timezones = store.selectedTimezones()
      }
    }
  }

  private var localTimeHero: some View {
    HStack(alignment: .top, spacing: 0) {
      VStack(alignment: .leading, spacing: 2) {
        Text(DateFormatters.formattedTime(for: localTimeZone, date: now))
          .font(.system(size: 48, weight: .regular, design: .default))
          .foregroundStyle(Color.wcPrimary)

        Text("\(localTimeZone.displayName) \(DateFormatters.gmtOffset(for: localTimeZone, date: now))")
          .font(.system(size: 13, weight: .regular, design: .default))
          .foregroundStyle(Color.wcTertiary)
      }

      Spacer()

      VStack(alignment: .trailing, spacing: 0) {
        Text(DateFormatters.formattedDayName(for: localTimeZone, date: now))
          .font(.system(size: 13, weight: .bold, design: .default))
          .foregroundStyle(Color.wcAccentOrange)

        Text(DateFormatters.formattedDayNumber(for: localTimeZone, date: now))
          .font(.system(size: 44, weight: .thin, design: .default))
          .foregroundStyle(Color.wcPrimary)
      }
    }
    .frame(maxWidth: .infinity)
  }

  private var emptyState: some View {
    VStack(spacing: 12) {
      Spacer()
      Image(systemName: "clock.fill")
        .font(.system(size: 40))
        .foregroundStyle(Color.wcTertiary)
      Text("Click + to add timezones")
        .font(.system(size: 14, weight: .medium, design: .default))
        .foregroundStyle(Color.wcSecondary)
      Spacer()
    }
    .frame(maxWidth: .infinity)
  }

  private var timezoneList: some View {
    List {
      ForEach(timezones) { selection in
        timezoneRow(selection)
          .listRowSeparator(.visible)
      }
      .onMove { source, destination in
        store.reorder(from: source, to: destination)
        timezones = store.selectedTimezones()
      }
      .onDelete { offsets in
        for index in offsets {
          store.removeTimezone(id: timezones[index].id)
        }
        timezones = store.selectedTimezones()
      }
    }
    .listStyle(.inset)
  }

  private func timezoneRow(_ selection: TimezoneSelection) -> some View {
    HStack {
      VStack(alignment: .leading, spacing: 2) {
        Text(selection.fullDisplayLabel)
          .font(.system(size: 14, weight: .medium, design: .default))
          .foregroundStyle(Color.wcPrimary)

        let dayLabel = selection.timeZone.map {
          DateFormatters.dayRelation(from: localTimeZone, to: $0, date: now)
        } ?? ""
        if !dayLabel.isEmpty {
          Text(dayLabel)
            .font(.system(size: 11, weight: .medium, design: .default))
            .foregroundStyle(dayLabel == "Tomorrow" ? Color.wcAccentOrange : Color.wcAccentBlue)
        }
      }

      Spacer()

      if let tz = selection.timeZone {
        let isNight = DateFormatters.isNightTime(for: tz, date: now)

        Text(DateFormatters.timeDifference(from: localTimeZone, to: tz, date: now))
          .font(.system(size: 12, weight: .regular, design: .default))
          .foregroundStyle(Color.wcSecondary)

        Text(DateFormatters.formattedTime(for: tz, date: now))
          .font(.system(size: 20, weight: .medium, design: .default))
          .foregroundStyle(isNight ? Color.wcNightTime : Color.wcPrimary)
      }
    }
    .padding(.vertical, 4)
  }
}

private extension TimeZone {
  var displayName: String {
    let components = identifier.split(separator: "/")
    let city = components.last ?? Substring(identifier)
    return city.replacingOccurrences(of: "_", with: " ")
  }
}

#Preview {
  ContentView()
}
