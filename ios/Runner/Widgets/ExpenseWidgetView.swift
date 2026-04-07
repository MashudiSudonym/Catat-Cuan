import SwiftUI
import WidgetKit

/**
 * Main widget view for iOS home screen
 *
 * Displays:
 * - Current month expenses summary
 * - Recent transactions (1-3 items)
 * - Quick add action
 */
struct ExpenseWidgetView: View {
    var entry: ExpenseProvider.Entry

    @Environment(\.widgetFamily) var widgetFamily

    var body: some View {
        ZStack {
            // Glassmorphism background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.orange.opacity(0.15),
                    Color.orange.opacity(0.05)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .background(Color.white.opacity(0.8))

            VStack(alignment: .leading, spacing: 8) {
                // Header
                Text("Pengeluaran Bulan Ini")
                    .font(.caption)
                    .foregroundColor(.secondary)

                // Amount
                Text(formatCurrency(entry.data.currentMonthExpenses))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)

                // Recent transactions (shown in medium and large widgets)
                if widgetFamily != .systemSmall && entry.data.recentTransactions.isNotEmpty {
                    Divider()
                        .background(Color.orange.opacity(0.3))

                    ForEach(entry.data.recentTransactions.prefix(3), id: \.id) { transaction in
                        TransactionRow(transaction: transaction)
                    }
                }

                Spacer()

                // Footer
                Text("Tap untuk tambah")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }

    /**
     * Format currency for display
     */
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = entry.data.currency
        formatter.locale = Locale(identifier: "id_ID")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "Rp 0"
    }
}

/**
 * Row component for displaying a single transaction
 */
struct TransactionRow: View {
    var transaction: TransactionPreview

    var body: some View {
        HStack(spacing: 8) {
            // Category indicator
            Circle()
                .fill(Color(hex: transaction.categoryColor))
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title)
                    .font(.caption)
                    .lineLimit(1)
                Text(transaction.category)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Text(formatCurrency(transaction.amount))
                .font(.caption)
                .foregroundColor(transaction.isExpense ? .red : .green)
        }
    }

    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "IDR"
        formatter.locale = Locale(identifier: "id_ID")
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "Rp 0"
    }
}

/**
 * Extension for Color to support hex values
 */
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
