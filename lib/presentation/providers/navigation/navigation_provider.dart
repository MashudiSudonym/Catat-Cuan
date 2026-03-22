import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_provider.g.dart';

/// Provider untuk navigation state
/// Following SRP: Simple state management for navigation
/// Uses code generation for type safety and modern Riverpod patterns
@riverpod
class NavigationNotifier extends _$NavigationNotifier {
  @override
  NavigationState build() {
    // No constructor side effects - initialize state in build()
    return const NavigationState();
  }

  /// Ganti tab yang aktif
  void changeTab(int index) {
    if (index >= 0 && index < _tabCount) {
      state = state.copyWith(selectedIndex: index);
    }
  }

  /// Jumlah tab yang tersedia
  static const int _tabCount = 2; // Transaksi & Ringkasan saja
}

/// Navigation state untuk mengelola tab yang aktif di bottom navigation
/// Following SRP: Only manages navigation state
class NavigationState {
  final int selectedIndex;

  const NavigationState({
    this.selectedIndex = 0,
  });

  NavigationState copyWith({
    int? selectedIndex,
  }) {
    return NavigationState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavigationState &&
          runtimeType == other.runtimeType &&
          selectedIndex == other.selectedIndex;

  @override
  int get hashCode => selectedIndex.hashCode;
}
