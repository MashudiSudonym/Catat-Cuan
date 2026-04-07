import Foundation

/**
 * Widget data model received from Flutter
 *
 * Mirrors WidgetDataEntity from Flutter side
 */
struct WidgetData: Codable {
    let currentMonthExpenses: Double
    let currentMonthIncome: Double
    let transactionCount: Int
    let recentTransactions: [TransactionPreview]
    let lastUpdated: Date
    let currency: String
}

/**
 * Preview data for a single transaction
 *
 * Mirrors TransactionPreviewEntity from Flutter side
 */
struct TransactionPreview: Codable {
    let id: Int
    let title: String
    let amount: Double
    let category: String
    let categoryColor: String
    let date: Date
    let isExpense: Bool
}

/**
 * Placeholder data when widget data is not available
 */
let placeholderWidgetData = WidgetData(
    currentMonthExpenses: 0.0,
    currentMonthIncome: 0.0,
    transactionCount: 0,
    recentTransactions: [],
    lastUpdated: Date(),
    currency: "IDR"
)
