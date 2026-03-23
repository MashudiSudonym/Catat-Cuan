import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'currency_provider.g.dart';

/// Currency mode options
enum CurrencyOption {
  /// Indonesian Rupiah
  idr('Rupiah (IDR)', 'Rp ', '.'),
  /// US Dollar
  usd('US Dollar (USD)', r'US$ ', ',');

  final String label;
  final String symbol;
  final String thousandSeparator;

  const CurrencyOption(this.label, this.symbol, this.thousandSeparator);

  static CurrencyOption fromIndex(int index) {
    return CurrencyOption.values[index];
  }
}

/// Currency state
class CurrencyState {
  final CurrencyOption currencyOption;

  const CurrencyState({required this.currencyOption});

  CurrencyState copyWith({CurrencyOption? currencyOption}) {
    return CurrencyState(currencyOption: currencyOption ?? this.currencyOption);
  }

  static CurrencyState get initial => const CurrencyState(
        currencyOption: CurrencyOption.idr,
      );
}

/// Currency provider with persistence
@riverpod
class CurrencyNotifier extends _$CurrencyNotifier {
  static const String _currencyKey = 'currency_mode';

  @override
  CurrencyState build() {
    _loadCurrencyPreference();
    return CurrencyState.initial;
  }

  Future<void> _loadCurrencyPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final currencyIndex = prefs.getInt(_currencyKey) ?? 0;
    state = CurrencyState(currencyOption: CurrencyOption.fromIndex(currencyIndex));
  }

  Future<void> setCurrency(CurrencyOption option) async {
    state = CurrencyState(currencyOption: option);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currencyKey, option.index);
  }
}
