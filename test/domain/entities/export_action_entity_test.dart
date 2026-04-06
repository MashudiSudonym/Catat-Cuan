import 'package:flutter_test/flutter_test.dart';
import 'package:catat_cuan/domain/entities/export_action_entity.dart';

void main() {
  group('ExportAction enum', () {
    group('Enum values', () {
      test('should have saveToDevice value', () {
        expect(ExportAction.saveToDevice, isA<ExportAction>());
      });

      test('should have share value', () {
        expect(ExportAction.share, isA<ExportAction>());
      });

      test('should have exactly 2 values', () {
        expect(ExportAction.values.length, equals(2));
      });

      test('should contain all expected values', () {
        expect(ExportAction.values, contains(ExportAction.saveToDevice));
        expect(ExportAction.values, contains(ExportAction.share));
      });
    });
  });

  group('ExportActionExtension', () {
    group('label property', () {
      test('should return "Simpan ke Perangkat" for saveToDevice', () {
        expect(ExportAction.saveToDevice.label, equals('Simpan ke Perangkat'));
      });

      test('should return "Bagikan via..." for share', () {
        expect(ExportAction.share.label, equals('Bagikan via...'));
      });

      test('should return Indonesian labels', () {
        expect(ExportAction.saveToDevice.label, contains('Perangkat'));
        expect(ExportAction.share.label, contains('Bagikan'));
      });
    });

    group('iconName property', () {
      test('should return "download" for saveToDevice', () {
        expect(ExportAction.saveToDevice.iconName, equals('download'));
      });

      test('should return "share" for share', () {
        expect(ExportAction.share.iconName, equals('share'));
      });

      test('should return lowercase English icon names', () {
        expect(ExportAction.saveToDevice.iconName, equals('download'));
        expect(ExportAction.share.iconName, equals('share'));
      });
    });

    group('description property', () {
      test('should return correct description for saveToDevice', () {
        expect(
          ExportAction.saveToDevice.description,
          equals('Simpan file CSV di folder Download'),
        );
      });

      test('should return correct description for share', () {
        expect(
          ExportAction.share.description,
          equals('Bagikan file CSV ke aplikasi lain'),
        );
      });

      test('should return Indonesian descriptions', () {
        expect(ExportAction.saveToDevice.description, contains('folder'));
        expect(ExportAction.share.description, contains('aplikasi'));
      });

      test('should mention CSV in both descriptions', () {
        expect(ExportAction.saveToDevice.description, contains('CSV'));
        expect(ExportAction.share.description, contains('CSV'));
      });
    });
  });

  group('Real-world scenarios', () {
    test('should provide complete UI data for saveToDevice action', () {
      final action = ExportAction.saveToDevice;

      expect(action.label, equals('Simpan ke Perangkat'));
      expect(action.iconName, equals('download'));
      expect(action.description, equals('Simpan file CSV di folder Download'));
    });

    test('should provide complete UI data for share action', () {
      final action = ExportAction.share;

      expect(action.label, equals('Bagikan via...'));
      expect(action.iconName, equals('share'));
      expect(action.description, equals('Bagikan file CSV ke aplikasi lain'));
    });

    test('should distinguish between two actions', () {
      expect(ExportAction.saveToDevice.label, isNot(equals(ExportAction.share.label)));
      expect(ExportAction.saveToDevice.iconName, isNot(equals(ExportAction.share.iconName)));
      expect(ExportAction.saveToDevice.description, isNot(equals(ExportAction.share.description)));
    });
  });

  group('UI integration', () {
    test('should work in switch statement for action selection', () {
      ExportAction selectedAction = ExportAction.saveToDevice;

      String actionText;
      switch (selectedAction) {
        case ExportAction.saveToDevice:
          actionText = selectedAction.label;
          break;
        case ExportAction.share:
          actionText = selectedAction.label;
          break;
      }

      expect(actionText, equals('Simpan ke Perangkat'));
    });

    test('should be usable in list/map operations', () {
      final actions = ExportAction.values;

      final labels = actions.map((action) => action.label).toList();

      expect(labels, contains('Simpan ke Perangkat'));
      expect(labels, contains('Bagikan via...'));
    });

    test('should support icon lookup by action type', () {
      final iconMap = {
        ExportAction.saveToDevice: ExportAction.saveToDevice.iconName,
        ExportAction.share: ExportAction.share.iconName,
      };

      expect(iconMap[ExportAction.saveToDevice], equals('download'));
      expect(iconMap[ExportAction.share], equals('share'));
    });
  });

  group('Enum completeness', () {
    test('should provide all necessary properties for UI rendering', () {
      for (final action in ExportAction.values) {
        // Verify each action has all UI properties
        expect(action.label, isNotEmpty);
        expect(action.iconName, isNotEmpty);
        expect(action.description, isNotEmpty);
      }
    });

    test('should have unique labels for each action', () {
      final labels = ExportAction.values.map((e) => e.label).toSet();
      expect(labels.length, equals(ExportAction.values.length));
    });

    test('should have unique icons for each action', () {
      final icons = ExportAction.values.map((e) => e.iconName).toSet();
      expect(icons.length, equals(ExportAction.values.length));
    });
  });
}
