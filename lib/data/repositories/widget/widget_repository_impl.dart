import 'package:catat_cuan/data/datasources/widget/widget_local_datasource.dart';
import 'package:catat_cuan/domain/core/result.dart';
import 'package:catat_cuan/domain/entities/widget/widget_data_entity.dart';
import 'package:catat_cuan/domain/failures/failures.dart';
import 'package:catat_cuan/domain/repositories/widget/widget_repository.dart';
import 'package:catat_cuan/presentation/utils/logger/app_logger.dart';

/// Implementation of WidgetRepository
///
/// Responsibility: Managing widget data storage and updates
/// Following SRP - only handles widget data operations
///
/// Uses home_widget package to:
/// - Store data in shared storage (SharedPreferences/AppGroup)
/// - Trigger native widget updates on Android/iOS
class WidgetRepositoryImpl implements WidgetRepository {
  final WidgetLocalDatasource _datasource;

  WidgetRepositoryImpl(this._datasource);

  @override
  Future<Result<void>> updateWidgetData(WidgetDataEntity data) async {
    AppLogger.d('Updating widget data');

    try {
      // Save data to shared storage
      await _datasource.saveWidgetData(data);

      // Trigger widget update on both platforms
      await _datasource.triggerWidgetUpdate();

      AppLogger.i('Widget data updated successfully');
      return Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to update widget data', e, stackTrace);
      return Result.failure(DatabaseFailure(
        'Gagal mengupdate data widget',
        exception: e,
      ));
    }
  }

  @override
  Future<Result<WidgetDataEntity>> getWidgetData() async {
    AppLogger.d('Getting widget data');

    try {
      final data = await _datasource.getWidgetData();

      if (data == null) {
        AppLogger.w('No widget data found');
        return Result.failure(NotFoundFailure('Data widget tidak ditemukan'));
      }

      AppLogger.i('Widget data retrieved successfully');
      return Result.success(data);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to get widget data', e, stackTrace);
      return Result.failure(DatabaseFailure(
        'Gagal mengambil data widget',
        exception: e,
      ));
    }
  }

  @override
  Future<Result<void>> refreshWidget() async {
    AppLogger.d('Refreshing widget');

    try {
      // Trigger widget update without modifying data
      await _datasource.triggerWidgetUpdate();

      AppLogger.i('Widget refreshed successfully');
      return Result.success(null);
    } catch (e, stackTrace) {
      AppLogger.e('Failed to refresh widget', e, stackTrace);
      return Result.failure(DatabaseFailure(
        'Gagal merefresh widget',
        exception: e,
      ));
    }
  }
}
