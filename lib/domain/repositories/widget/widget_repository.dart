/// Widget Repository Interface
///
/// This interface defines operations for managing widget data
/// that will be displayed on home screen widgets (Android/iOS).
library;

import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/widget/widget_data_entity.dart';

/// Repository interface for widget data operations
abstract class WidgetRepository {
  /// Update widget data with latest summary and transactions
  ///
  /// This will:
  /// 1. Save data to shared storage (SharedPreferences/AppGroup)
  /// 2. Trigger native widget update
  ///
  /// Returns Result.success(null) if update succeeded
  Future<Result<void>> updateWidgetData(WidgetDataEntity data);

  /// Get current widget data from shared storage
  ///
  /// Returns Result with widget data if found, failure if not found
  Future<Result<WidgetDataEntity>> getWidgetData();

  /// Trigger widget refresh without updating data
  ///
  /// Use this when you want to force widget to reload
  /// existing data from shared storage.
  Future<Result<void>> refreshWidget();
}
