import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_provider.g.dart';

/// Navigation state untuk mengelola tab yang aktif di bottom navigation
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

/// Provider untuk NavigationNotifier
/// Following SRP: Simple state management for navigation
@riverpod
class Navigation extends _$Navigation {
  /// Jumlah tab yang tersedia
  static const int _tabCount = 2; // Transaksi & Ringkasan

  @override
  NavigationState build() {
    return const NavigationState();
  }

  /// Ganti tab yang aktif
  void changeTab(int index) {
    if (index >= 0 && index < _tabCount) {
      state = state.copyWith(selectedIndex: index);
    }
  }
}
