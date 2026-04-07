/// Widget Local Data Source
///
/// Handles data storage and widget updates using the home_widget package.
/// This data source stores widget data in SharedPreferences (Android)
/// and UserDefaults (iOS) which are accessible by native widgets.
library;

import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:catat_cuan/domain/entities/widget/widget_data_entity.dart';
import 'package:catat_cuan/domain/entities/widget/widget_data_serializer.dart';

/// Key for storing widget data in shared storage
const String _widgetDataKey = 'widget_data';

/// Widget data source for local storage
///
/// Uses home_widget package to:
/// 1. Save data to shared storage (accessible by native widgets)
/// 2. Trigger widget updates on both platforms
class WidgetLocalDatasource {
  /// Save widget data to shared storage
  ///
  /// Converts [WidgetDataEntity] to JSON and stores it using
  /// home_widget package. Data will be accessible by native widgets.
  ///
  /// Throws [Exception] if save operation fails.
  Future<void> saveWidgetData(WidgetDataEntity data) async {
    try {
      // Convert entity to JSON using serializer
      final jsonMap = WidgetDataSerializer.toJson(data);
      final jsonString = jsonEncode(jsonMap);

      // Save using home_widget package
      // This stores data in SharedPreferences (Android) or
      // AppGroup UserDefaults (iOS)
      await HomeWidget.saveWidgetData<String>(_widgetDataKey, jsonString);
    } catch (e) {
      throw Exception('Failed to save widget data: $e');
    }
  }

  /// Get widget data from shared storage
  ///
  /// Retrieves JSON data and converts it back to [WidgetDataEntity].
  ///
  /// Returns null if no data exists.
  /// Throws [Exception] if retrieval or parsing fails.
  Future<WidgetDataEntity?> getWidgetData() async {
    try {
      // Get JSON string from shared storage
      final jsonString = await HomeWidget.getWidgetData<String>(_widgetDataKey);

      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }

      // Parse JSON back to entity using serializer
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return WidgetDataSerializer.fromJson(json);
    } catch (e) {
      throw Exception('Failed to get widget data: $e');
    }
  }

  /// Trigger widget update on both platforms
  ///
  /// Notifies native widgets to refresh their content.
  ///
  /// Android: Updates GlanceAppWidget
  /// iOS: Reloads widget timeline
  ///
  /// Throws [Exception] if update fails.
  Future<void> triggerWidgetUpdate() async {
    try {
      await HomeWidget.updateWidget(
        name: 'ExpenseWidgetProvider',
        androidName: 'ExpenseWidgetProvider',
        iOSName: 'ExpenseWidget',
      );
    } catch (e) {
      throw Exception('Failed to trigger widget update: $e');
    }
  }

  /// Clear widget data from shared storage
  ///
  /// Useful for logout or reset scenarios.
  Future<void> clearWidgetData() async {
    try {
      await HomeWidget.saveWidgetData<String>(_widgetDataKey, '');
    } catch (e) {
      throw Exception('Failed to clear widget data: $e');
    }
  }
}
