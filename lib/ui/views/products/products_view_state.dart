import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tech_gadol/models/product_category.dart';
import '../../../models/product.dart';

part 'products_view_state.freezed.dart';

@freezed
sealed class ProductsViewState with _$ProductsViewState {
  const factory ProductsViewState.initial() = _Initial;
  const factory ProductsViewState.loading() = _Loading;
  
  const factory ProductsViewState.loaded({
    required List<Product> products,
    required List<ProductCategory> categories,
    ProductCategory? selectedCategory,
    String? searchQuery,
    String? selectedProductId,
    @Default(false) bool isFetchingMore,
    @Default(true) bool hasMore,
  }) = _Loaded;

  const factory ProductsViewState.empty({
    required List<ProductCategory> categories,
    ProductCategory? selectedCategory,
    String? searchQuery,
    String? selectedProductId,
  }) = _Empty;

  const factory ProductsViewState.error(String message) = _Error;
}
