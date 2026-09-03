import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kProductGridViewPrefKey = 'product_grid_view_enabled';

final productGridViewProvider =
    StateNotifierProvider<ProductGridViewController, bool>(
      (ref) => ProductGridViewController(),
    );

class ProductGridViewController extends StateNotifier<bool> {
  ProductGridViewController() : super(true) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_kProductGridViewPrefKey) ?? true;
  }

  Future<void> setGridView(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kProductGridViewPrefKey, enabled);
  }
}
