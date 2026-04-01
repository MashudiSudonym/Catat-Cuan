/// Export action enum
///
/// Defines the available actions for exporting transactions.
/// Used to determine whether to save to device storage or share via share_plus.
///
/// Following SOLID principles:
/// - Single Responsibility: Only represents export action type
/// - Open/Closed: Can be extended with new actions without modifying existing ones
library;

enum ExportAction {
  /// Save CSV file to public Downloads folder (Download/CatatCuan)
  saveToDevice,

  /// Share CSV file via share_plus (social media, email, cloud storage, etc.)
  share,
}

/// Export action extension for display properties
extension ExportActionExtension on ExportAction {
  /// Get display label for the action
  String get label {
    switch (this) {
      case ExportAction.saveToDevice:
        return 'Simpan ke Perangkat';
      case ExportAction.share:
        return 'Bagikan via...';
    }
  }

  /// Get icon for the action
  String get iconName {
    switch (this) {
      case ExportAction.saveToDevice:
        return 'download';
      case ExportAction.share:
        return 'share';
    }
  }

  /// Get description for the action
  String get description {
    switch (this) {
      case ExportAction.saveToDevice:
        return 'Simpan file CSV di folder Download';
      case ExportAction.share:
        return 'Bagikan file CSV ke aplikasi lain';
    }
  }
}
