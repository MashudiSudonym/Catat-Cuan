/// Base widgets for consistent UI components
///
/// This file re-exports from purpose-specific barrel files:
/// - Layout widgets (containers, FAB)
/// - State widgets (loading, empty, error, initial)
/// - Effect widgets (shimmer, animations)
///
/// For more focused imports, you can import from the specific barrel files:
/// - `layout/layout_base.dart`
/// - `states/state_base.dart`
/// - `effects/effect_base.dart`
library;

// Purpose-specific barrel exports
export 'layout/layout_base.dart';
export 'states/state_base.dart';
export 'effects/effect_base.dart';
