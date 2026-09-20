import SwiftUI

struct CalendarView: View {
    @EnvironmentObject private var model: CalendarModel
    @FocusState private var isFocused: Bool

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 7)

    var body: some View {
        VStack(spacing: 10) {
            header

            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(model.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .accessibilityHidden(true)
                }

                ForEach(Array(model.weeks.flatMap { $0 }.enumerated()), id: \.offset) { _, day in
                    DayCell(
                        day: day,
                        isToday: day?.isToday == true && model.isShowingCurrentMonth,
                        isSelected: isSelected(day)
                    )
                }
            }

            footer
        }
        .padding(16)
        .frame(width: 320)
        .focusable()
        .focused($isFocused)
        .focusEffectDisabled()
        .onAppear { isFocused = true }
        .onKeyPress(.leftArrow) { model.moveSelection(byDays: -1); return .handled }
        .onKeyPress(.rightArrow) { model.moveSelection(byDays: 1); return .handled }
        .onKeyPress(.upArrow) { model.moveSelection(byDays: -7); return .handled }
        .onKeyPress(.downArrow) { model.moveSelection(byDays: 7); return .handled }
        .onKeyPress(.pageUp) { model.goToPreviousMonth(); return .handled }
        .onKeyPress(.pageDown) { model.goToNextMonth(); return .handled }
        .onKeyPress(KeyEquivalent("t")) { model.goToToday(); return .handled }
    }

    private var header: some View {
        HStack {
            Button(action: model.goToPreviousMonth) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 12, weight: .semibold))
                    .frame(width: 28, height: 28)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Previous month")

            Spacer(minLength: 0)

            Text(model.displayedMonthTitle)
                .font(.system(size: 15, weight: .semibold))
                .accessibilityAddTraits(.isHeader)

            Spacer(minLength: 0)

            Button(action: model.goToNextMonth) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .frame(width: 28, height: 28)
                    .contentShape(.rect)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Next month")
        }
    }

    private var footer: some View {
        Button("Today", action: model.goToToday)
            .buttonStyle(.plain)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(model.isShowingCurrentMonth ? Color.secondary : Color.accentColor)
            .disabled(model.isShowingCurrentMonth)
            .accessibilityLabel("Go to today")
            .accessibilityHint("Returns the calendar to the current month")
    }

    private func isSelected(_ day: Day?) -> Bool {
        guard let day, let selected = model.selectedDate else { return false }
        return Calendar.current.isDate(day.date, inSameDayAs: selected)
    }
}

private struct DayCell: View {
    let day: Day?
    let isToday: Bool
    let isSelected: Bool

    var body: some View {
        ZStack {
            if isToday {
                Circle().fill(Color.accentColor)
            } else if isSelected {
                Circle().strokeBorder(Color.accentColor, lineWidth: 1.5)
            }

            if let day {
                Text("\(day.dayNumber)")
                    .font(.system(size: 13))
                    .foregroundStyle(isToday ? Color.white : Color.primary)
            }
        }
        .frame(width: 36, height: 36)
        .frame(maxWidth: .infinity)
        .accessibilityElement()
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHidden(day == nil)
    }

    private var accessibilityLabel: String {
        guard let day else { return "" }
        if isToday { return "Today, \(day.dayNumber)" }
        if isSelected { return "Selected, \(day.dayNumber)" }
        return "\(day.dayNumber)"
    }
}
