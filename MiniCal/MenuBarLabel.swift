import SwiftUI

struct MenuBarLabel: View {
    @State private var now: Date = .now

    // Fires every 60s — the date only changes once a day so 60s staleness is fine
    private let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        Text(labelText(for: now))
            .onReceive(timer) { date in now = date }
    }

    private func labelText(for date: Date) -> String {
        let cal = Calendar.current
        let weekdayIndex = cal.component(.weekday, from: date) - 1
        let weekday = cal.shortWeekdaySymbols[weekdayIndex]
        let day = cal.component(.day, from: date)
        return "\(weekday) \(day)"
    }
}
