import SwiftUI
import ServiceManagement

@main
struct MiniCalApp: App {
    @StateObject private var model = CalendarModel()

    init() {
        registerLoginItem()
    }

    var body: some Scene {
        MenuBarExtra {
            CalendarView()
                .environmentObject(model)
        } label: {
            MenuBarLabel()
        }
        .menuBarExtraStyle(.window)
    }

    private func registerLoginItem() {
        do {
            try SMAppService.mainApp.register()
        } catch {
            // SMAppService throws if already registered — that's expected and harmless
        }
    }			
}
