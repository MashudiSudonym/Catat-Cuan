import WidgetKit
import SwiftUI

/**
 * Timeline provider for widget updates
 *
 * Manages when and how often the widget refreshes its content
 */
struct ExpenseProvider: TimelineProvider {
    func placeholder(in context: Context) -> ExpenseEntry {
        ExpenseEntry(date: Date(), data: placeholderData())
    }

    func getSnapshot(in context: Context, completion: @escaping (ExpenseEntry) -> ()) {
        let data = loadWidgetData()
        let entry = ExpenseEntry(date: Date(), data: data)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        getSnapshot(in: context) { entry in
            // Update every 30 minutes
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }

    /**
     * Load widget data from shared UserDefaults
     */
    private func loadWidgetData() -> WidgetData {
        let sharedDefaults = UserDefaults(suiteName: "group.com.tigasatudesember.catatCuan")

        guard let dataString = sharedDefaults?.string(forKey: "widget_data"),
              let data = dataString.data(using: .utf8) else {
            return placeholderData()
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            let widgetData = try decoder.decode(WidgetData.self, from: data)
            return widgetData
        } catch {
            print("Failed to decode widget data: \(error)")
            return placeholderData()
        }
    }

    /**
     * Create placeholder data for widget preview
     */
    private func placeholderData() -> WidgetData {
        WidgetData(
            currentMonthExpenses: 0,
            currentMonthIncome: 0,
            transactionCount: 0,
            recentTransactions: [],
            lastUpdated: Date(),
            currency: "IDR"
        )
    }
}

/**
 * Timeline entry for widget
 */
struct ExpenseEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}
