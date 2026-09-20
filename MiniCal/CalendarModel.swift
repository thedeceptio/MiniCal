import Foundation
import Combine

struct Day: Identifiable {
    let id = UUID()
    let date: Date
    let dayNumber: Int
    let isToday: Bool
}

final class CalendarModel: ObservableObject {
    @Published private(set) var weeks: [[Day?]] = []
    @Published private(set) var weekdaySymbols: [String] = []
    @Published private(set) var displayedMonthTitle: String = ""
    @Published private(set) var isShowingCurrentMonth: Bool = true

    /// Keyboard cursor. nil until the user starts navigating with the arrow keys.
    @Published var selectedDate: Date?

    private let calendar = Calendar.current

    /// Read live rather than stored, so the app stays correct across midnight.
    private var today: Date { calendar.startOfDay(for: Date()) }

    private var displayedFirstOfMonth: Date

    init() {
        displayedFirstOfMonth = Calendar.current.startOfMonth(for: Date())
        buildWeekdaySymbols()
        recompute()
    }

    // MARK: - Navigation

    func goToPreviousMonth() { shiftMonth(by: -1) }
    func goToNextMonth() { shiftMonth(by: 1) }

    func goToToday() {
        displayedFirstOfMonth = calendar.startOfMonth(for: Date())
        selectedDate = today
        recompute()
    }

    /// Moves the keyboard cursor, following it into an adjacent month when it crosses a boundary.
    func moveSelection(byDays days: Int) {
        let anchor = selectedDate ?? (isShowingCurrentMonth ? today : displayedFirstOfMonth)
        guard let next = calendar.date(byAdding: .day, value: days, to: anchor) else { return }
        selectedDate = next

        if !calendar.isDate(next, equalTo: displayedFirstOfMonth, toGranularity: .month) {
            displayedFirstOfMonth = calendar.startOfMonth(for: next)
            recompute()
        }
    }

    private func shiftMonth(by value: Int) {
        guard let shifted = calendar.date(byAdding: .month, value: value, to: displayedFirstOfMonth) else { return }
        displayedFirstOfMonth = shifted
        selectedDate = nil
        recompute()
    }

    // MARK: - Grid generation

    private func recompute() {
        let year = calendar.component(.year, from: displayedFirstOfMonth)
        let month = calendar.component(.month, from: displayedFirstOfMonth)

        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        displayedMonthTitle = formatter.string(from: displayedFirstOfMonth)

        isShowingCurrentMonth = calendar.isDate(displayedFirstOfMonth, equalTo: today, toGranularity: .month)

        guard let dayRange = calendar.range(of: .day, in: .month, for: displayedFirstOfMonth) else { return }
        let dayCount = dayRange.count

        // How many cells sit before day 1, honouring the locale's first weekday.
        let firstWeekday = calendar.component(.weekday, from: displayedFirstOfMonth)
        let leadingBlanks = (firstWeekday - calendar.firstWeekday + 7) % 7

        var flat: [Day?] = Array(repeating: nil, count: leadingBlanks)
        for dayNumber in 1...dayCount {
            var components = DateComponents()
            components.year = year
            components.month = month
            components.day = dayNumber
            if let date = calendar.date(from: components) {
                flat.append(Day(date: date, dayNumber: dayNumber, isToday: calendar.isDateInToday(date)))
            }
        }

        // Only pad out the final row — a month needing 5 rows never renders a 6th.
        let rowCount = Int(ceil(Double(flat.count) / 7.0))
        while flat.count < rowCount * 7 { flat.append(nil) }

        weeks = (0..<rowCount).map { row in
            Array(flat[(row * 7)..<(row * 7 + 7)])
        }
    }

    private func buildWeekdaySymbols() {
        // shortWeekdaySymbols is always Sun-first; rotate so index 0 is the locale's first weekday.
        var symbols = calendar.shortWeekdaySymbols
        let shift = calendar.firstWeekday - 1
        if shift > 0 {
            symbols = Array(symbols[shift...] + symbols[..<shift])
        }
        weekdaySymbols = symbols.map { String($0.prefix(2)) }
    }
}

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        self.date(from: dateComponents([.year, .month], from: date))!
    }
}
