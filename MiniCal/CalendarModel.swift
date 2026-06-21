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

    private let calendar = Calendar.current
    private let today = Date()

    // The first day of the currently displayed month
    private var displayedFirstOfMonth: Date

    init() {
        displayedFirstOfMonth = Calendar.current.startOfMonth(for: Date())
        buildWeekdaySymbols()
        recompute()
    }

    func goToPreviousMonth() {
        guard let prev = calendar.date(byAdding: .month, value: -1, to: displayedFirstOfMonth) else { return }
        displayedFirstOfMonth = prev
        recompute()
    }

    func goToNextMonth() {
        guard let next = calendar.date(byAdding: .month, value: 1, to: displayedFirstOfMonth) else { return }
        displayedFirstOfMonth = next
        recompute()
    }

    private func recompute() {
        let year = calendar.component(.year, from: displayedFirstOfMonth)
        let month = calendar.component(.month, from: displayedFirstOfMonth)

        // Month title e.g. "June 2026"
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        displayedMonthTitle = formatter.string(from: displayedFirstOfMonth)

        isShowingCurrentMonth = calendar.isDate(displayedFirstOfMonth, equalTo: today, toGranularity: .month)

        // Number of days in this month
        guard let dayRange = calendar.range(of: .day, in: .month, for: displayedFirstOfMonth) else { return }
        let dayCount = dayRange.count

        // Leading blank count: how many cells before day 1
        let firstWeekday = calendar.component(.weekday, from: displayedFirstOfMonth)
        // calendar.firstWeekday is 1=Sun or 2=Mon depending on locale
        let leadingBlanks = (firstWeekday - calendar.firstWeekday + 7) % 7

        // Build flat array of 42 Day? (6 rows × 7 cols)
        var flat: [Day?] = Array(repeating: nil, count: leadingBlanks)
        for dayNum in 1...dayCount {
            var comps = DateComponents()
            comps.year = year
            comps.month = month
            comps.day = dayNum
            if let date = calendar.date(from: comps) {
                flat.append(Day(date: date, dayNumber: dayNum, isToday: calendar.isDateInToday(date)))
            }
        }
        // Pad to 42
        while flat.count < 42 { flat.append(nil) }

        // Split into 6 rows of 7
        weeks = (0..<6).map { row in
            Array(flat[(row * 7)..<(row * 7 + 7)])
        }
    }

    private func buildWeekdaySymbols() {
        // shortWeekdaySymbols is always Sun–Sat (index 0=Sun)
        // Rotate so index 0 = locale's first weekday
        var symbols = calendar.shortWeekdaySymbols // ["Sun","Mon",...,"Sat"]
        let shift = calendar.firstWeekday - 1      // 0 for Sun-first, 1 for Mon-first
        if shift > 0 {
            symbols = Array(symbols[shift...] + symbols[..<shift])
        }
        // Truncate to 2 chars for a compact display (e.g. "Su", "Mo")
        weekdaySymbols = symbols.map { String($0.prefix(2)) }
    }
}

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let comps = dateComponents([.year, .month], from: date)
        return self.date(from: comps)!
    }
}
