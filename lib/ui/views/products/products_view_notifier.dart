import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:tech_gadol/models/product.dart';
import 'package:tech_gadol/models/product_category.dart';
import 'package:tech_gadol/ui/views/products/products_view_state.dart';

import '../../../providers/product/products_provider.dart';

class ProductsViewNotifier extends StateNotifier<ProductsViewState> {
  ProductsViewNotifier(this.ref) : super(const ProductsViewState.initial()) {
    _initialize();
  }

  final Ref ref;
  static const int _limit = 5;

  Future<void> _initialize() async {
    _setState(const ProductsViewState.loading());

    final provider = ref.read(productsProvider.notifier);

    // Fetch categories and initial products in parallel
    try {
      final results = await Future.wait([
        provider.getCategories(),
        provider.getProducts(
          limit: _limit,
          skip: 0, // In original code state.searchQuery and state.selectedCategory?.slug was used but we start fresh on init
          searchQuery: null,
          category: null,
        ),
      ]);

      final categories = results[0] as List<ProductCategory>;
      final products = results[1] as List<Product>;

      if (products.isEmpty) {
        _setState(ProductsViewState.empty(
          categories: categories,
          selectedCategory: null,
          searchQuery: null,
          selectedProductId: null,
        ));
      } else {
        _setState(
          ProductsViewState.loaded(
            categories: categories,
            products: products,
            hasMore: products.length == _limit,
            selectedCategory: null,
            searchQuery: null,
            selectedProductId: null,
          ),
        );
      }
    } catch (e) {
      _setState(ProductsViewState.error('Failed to initialize: $e'));
    }
  }

  Future<void> loadMore() async {
    await state.maybeWhen(
      loaded: (products, categories, selectedCategory, searchQuery,
          selectedProductId, isFetchingMore, hasMore) async {
        if (isFetchingMore || !hasMore) return;

        _setState(ProductsViewState.loaded(
          products: products,
          categories: categories,
          selectedCategory: selectedCategory,
          searchQuery: searchQuery,
          selectedProductId: selectedProductId,
          isFetchingMore: true,
          hasMore: hasMore,
        ));

        final provider = ref.read(productsProvider.notifier);

        try {
          final newProducts = await provider.getProducts(
            limit: _limit,
            skip: products.length,
            searchQuery: searchQuery,
            category: selectedCategory?.slug,
          );

          _setState(
            ProductsViewState.loaded(
              products: [...products, ...newProducts],
              categories: categories,
              selectedCategory: selectedCategory,
              searchQuery: searchQuery,
              selectedProductId: selectedProductId,
              isFetchingMore: false,
              hasMore: newProducts.length == _limit,
            ),
          );
        } catch (e) {
           _setState(ProductsViewState.error('Failed to load more products: $e'));
        }
      },
      orElse: () {},
    );
  }

  Future<void> setSearchQuery(String query) async {
    final currentSearchQuery = state.maybeWhen(
      loaded: (_, __, ___, sq, ____, _____, ______) => sq,
      empty: (_, __, sq, ___) => sq,
      orElse: () => null,
    );
    if (currentSearchQuery == query) return;

    await _fetchProductsForCurrentState(searchQuery: query);
  }

  Future<void> setCategory(ProductCategory? category) async {
    final currentCategory = state.maybeWhen(
      loaded: (_, __, cat, ____, _____, ______, _______) => cat,
      empty: (_, cat, ___, ____) => cat,
      orElse: () => null,
    );
    if (currentCategory == category) return;

    await _fetchProductsForCurrentState(category: category);
  }

  void setSelectedProductId(String? id) {
    state.maybeWhen(
      loaded: (products, categories, selectedCategory, searchQuery,
          _, isFetchingMore, hasMore) {
        _setState(ProductsViewState.loaded(
          products: products,
          categories: categories,
          selectedCategory: selectedCategory,
          searchQuery: searchQuery,
          selectedProductId: id,
          isFetchingMore: isFetchingMore,
          hasMore: hasMore,
        ));
      },
      empty: (categories, selectedCategory, searchQuery, _) {
       _setState(ProductsViewState.empty(
          categories: categories,
          selectedCategory: selectedCategory,
          searchQuery: searchQuery,
          selectedProductId: id,
        ));
      },
      orElse: () {}
    );
  }

  Future<void> retry() async {
    await state.maybeWhen(
      initial: () => _initialize(),
      error: (_) => _initialize(), // Retry fetches completely
      orElse: () => _initialize(), 
    );
  }

  Future<void> _fetchProductsForCurrentState({
    String? searchQuery,
    ProductCategory? category,
  }) async {
     // Retrieve base categories
     final categories = state.maybeMap(
        loaded: (s) => s.categories,
        empty: (s) => s.categories,
        orElse: () => <ProductCategory>[],
     );

    // Keep old values if not passed
    final newSearchQuery = searchQuery ?? state.maybeMap(
      loaded: (s) => s.searchQuery,
      empty: (s) => s.searchQuery,
      orElse: () => null,
    );

    final newCategory = category ?? state.maybeMap(
      loaded: (s) => s.selectedCategory,
      empty: (s) => s.selectedCategory,
      orElse: () => null,
    );

    _setState(const ProductsViewState.loading());
    final provider = ref.read(productsProvider.notifier);

    try {
      final products = await provider.getProducts(
        limit: _limit,
        skip: 0,
        searchQuery: newSearchQuery,
        category: newCategory?.slug,
      );

      if (products.isEmpty) {
        _setState(ProductsViewState.empty(
          categories: categories,
          selectedCategory: newCategory,
          searchQuery: newSearchQuery,
          selectedProductId: null,
        ));
      } else {
        _setState(
          ProductsViewState.loaded(
            products: products,
            categories: categories,
            selectedCategory: newCategory,
            searchQuery: newSearchQuery,
            selectedProductId: null,
            isFetchingMore: false,
            hasMore: products.length == _limit,
          ),
        );
      }
    } catch (e) {
      _setState(ProductsViewState.error('Error fetching products: $e'));
    }
  }

  void _setState(ProductsViewState newState) => state = newState;
}

final StateNotifierProvider<ProductsViewNotifier, ProductsViewState>
productsViewProvider =
    StateNotifierProvider<ProductsViewNotifier, ProductsViewState>(
      ProductsViewNotifier.new,
    );
