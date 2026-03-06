import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tech_gadol/models/product.dart';

part 'product_detail_view_state.freezed.dart';

@freezed
sealed class ProductDetailViewState with _$ProductDetailViewState {
  const factory ProductDetailViewState.initial() = _Initial;
  const factory ProductDetailViewState.loading() = _Loading;
  const factory ProductDetailViewState.loaded(Product product) = _Loaded;
  const factory ProductDetailViewState.error(String message) = _Error;
}
