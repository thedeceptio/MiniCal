import SwiftUI

struct CalendarView: View {
    @EnvironmentObject private var model: CalendarModel

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        VStack(spacing: 12) {
            // Month navigation header
            HStack {
                Button {
                    model.goToPreviousMonth()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .semibold))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Previous month")

                Spacer()

                Text(model.displayedMonthTitle)
                    .font(.system(size: 15, weight: .semibold))
                    .accessibilityAddTraits(.isHeader)

                Spacer()

                Button {
                    model.goToNextMonth()
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Next month")
            }
            .padding(.horizontal, 8)

            // Weekday symbols + day grid in one LazyVGrid
            LazyVGrid(columns: columns, spacing: 6) {
                // Weekday header row
                ForEach(model.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .accessibilityHidden(true)
                }

                // Day cells (6 rows × 7 cols)
                ForEach(Array(model.weeks.flatMap { $0 }.enumerated()), id: \.offset) { _, day in
                    DayCell(
                        day: day,
                        highlight: day?.isToday == true && model.isShowingCurrentMonth
                    )
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(16)
        .frame(width: 320, height: 360)
    }
}

private struct DayCell: View {
    let day: Day?
    let highlight: Bool

    var body: some View {
        ZStack {
            if highlight {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 30, height: 30)
            }

            if let day {
                Text("\(day.dayNumber)")
                    .font(.system(size: 13))
                    .foregroundStyle(highlight ? .white : .primary)
                    .frame(width: 30, height: 30)
                    .accessibilityLabel(highlight ? "Today, \(day.dayNumber)" : "\(day.dayNumber)")
            } else {
                Color.clear
                    .frame(width: 30, height: 30)
                    .accessibilityHidden(true)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
