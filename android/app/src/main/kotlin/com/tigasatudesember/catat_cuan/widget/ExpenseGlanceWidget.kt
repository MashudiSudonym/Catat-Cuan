package com.tigasatudesember.catat_cuan.widget

import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Widget Provider for Expense Widget
 *
 * Simple implementation following home_widget 0.9.0 API
 */
class ExpenseWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: android.appwidget.AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        // Update each widget with loading view
        appWidgetIds.forEach { appWidgetId ->
            val packageName = context.packageName

            // Create remote views with text
            val views = RemoteViews(packageName, android.R.layout.simple_list_item_1)
            views.setTextViewText(android.R.id.text1, "Catat Cuan")
            views.setTextColor(android.R.id.text1, android.graphics.Color.parseColor("#FF6B35"))

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
