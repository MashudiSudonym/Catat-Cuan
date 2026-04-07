import WidgetKit
import SwiftUI

/**
 * Widget Bundle for Catat Cuan
 *
 * Registers all available widgets for the app
 */
@main
struct ExpenseWidgetBundle: WidgetBundle {
    var body: some Widget {
        ExpenseWidget()
    }
}

/**
 * Main widget configuration
 */
struct ExpenseWidget: Widget {
    let kind: String = "ExpenseWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ExpenseProvider()) { entry in
            ExpenseWidgetView(entry: entry)
        }
        .configurationDisplayName("Catat Cuan")
        .description("Ringkasan pengeluaran dan transaksi terakhir")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
