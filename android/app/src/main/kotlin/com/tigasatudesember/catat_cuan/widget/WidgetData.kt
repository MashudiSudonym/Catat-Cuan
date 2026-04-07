package com.tigasatudesember.catat_cuan.widget

import kotlinx.serialization.Serializable

/**
 * Data model for widget data transferred from Flutter
 *
 * This mirrors the WidgetDataEntity from Flutter side
 */
@Serializable
data class WidgetData(
    val currentMonthExpenses: Double,
    val currentMonthIncome: Double,
    val transactionCount: Int,
    val recentTransactions: List<TransactionPreview>,
    val lastUpdated: Long,
    val currency: String
)

/**
 * Preview data for a single transaction
 *
 * This mirrors the TransactionPreviewEntity from Flutter side
 */
@Serializable
data class TransactionPreview(
    val id: Int,
    val title: String,
    val amount: Double,
    val category: String,
    val categoryColor: String,
    val date: Long,
    val isExpense: Boolean
)

/**
 * Placeholder data when widget data is not available
 */
val placeholderWidgetData = WidgetData(
    currentMonthExpenses = 0.0,
    currentMonthIncome = 0.0,
    transactionCount = 0,
    recentTransactions = emptyList(),
    lastUpdated = System.currentTimeMillis(),
    currency = "IDR"
)
