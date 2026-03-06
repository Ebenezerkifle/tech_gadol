import 'package:freezed_annotation/freezed_annotation.dart';

import '../../models/product.dart';
part 'products_state.freezed.dart';

@freezed
sealed class ProductsState with _$ProductsState {
  const factory ProductsState({
    @Default(false) bool isLoading,
    Product? selectedProduct,
    String? errorMessage,
    @Default(0) int total,
    @Default(0) int skip,
    @Default(5) int limit,
  }) = _ProductsState;
}
