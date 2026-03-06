import 'package:flutter_riverpod/legacy.dart';
import 'package:tech_gadol/models/product.dart';
import 'package:tech_gadol/services/api_service/common/common_api_service.dart';
import 'package:tech_gadol/services/api_service/product_api_service.dart';
import 'package:tech_gadol/ui/views/product_detail/product_detail_view_state.dart';

class ProductDetailViewNotifier extends StateNotifier<ProductDetailViewState> {
  final ProductApiService _apiService;

  ProductDetailViewNotifier({ProductApiService? apiService})
      : _apiService = apiService ?? ProductApiService(),
        super(const ProductDetailViewState.initial());

  Future<void> loadProduct(String id) async {
    _setState(const ProductDetailViewState.loading());
    try {
      final response = await _apiService.getProductById(id);
      if (statusCodeSuccess(response.statusCode)) {
        final product = Product.fromJson(response.data);
        _setState(ProductDetailViewState.loaded(product));
      } else {
        _setState(
          const ProductDetailViewState.error('Failed to load product details'),
        );
      }
    } catch (e) {
      _setState(
        ProductDetailViewState.error('Error loading product: $e'),
      );
    }
  }

  void _setState(ProductDetailViewState newState) => state = newState;
}

final StateNotifierProviderFamily<
  ProductDetailViewNotifier,
  ProductDetailViewState,
  String
>
productDetailProvider =
    StateNotifierProvider.family<
      ProductDetailViewNotifier,
      ProductDetailViewState,
      String
    >((ref, id) {
      final notifier = ProductDetailViewNotifier();
      notifier.loadProduct(id);
      return notifier;
    });
