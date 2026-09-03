import 'package:flutter_riverpod/legacy.dart';

class ProductScreenController extends StateNotifier<ProductScreenState> {
  ProductScreenController() : super(const ProductScreenState());

  void setCategory(String category) =>
      state = state.copyWith(selectedCategory: category);
  void setSearchQuery(String query) =>
      state = state.copyWith(searchQuery: query);
}

class ProductScreenState {
  final String selectedCategory;
  final String searchQuery;

  const ProductScreenState({
    this.selectedCategory = 'All',
    this.searchQuery = '',
  });

  ProductScreenState copyWith({String? selectedCategory, String? searchQuery}) {
    return ProductScreenState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

final productScreenProvider =
    StateNotifierProvider<ProductScreenController, ProductScreenState>(
      (ref) => ProductScreenController(),
    );
