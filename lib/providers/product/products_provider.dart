import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:tech_gadol/models/product.dart';
import 'package:tech_gadol/models/product_category.dart';
import 'package:tech_gadol/models/product_response.dart';
import 'package:tech_gadol/providers/product/products_state.dart';
import 'package:tech_gadol/services/api_service/common/common_api_service.dart';
import 'package:tech_gadol/services/api_service/product_api_service.dart';
import 'package:tech_gadol/services/utils/logger.dart';

class ProductsNotifier extends StateNotifier<ProductsState> {
  final _apiService = ProductApiService();
  ProductsNotifier() : super(const ProductsState());

  // Get Products.
  Future<List<Product>> getProducts({
    int limit = 10,
    int skip = 0,
    String? searchQuery,
    String? category,
  }) async {
    try {
      Response response = await _apiService.getProducts(
        limit: limit,
        skip: skip,
        searchQuery: searchQuery,
        category: category,
      );
      if (statusCodeSuccess(response.statusCode)) {
        var data = response.data;
        ProductResponse productsResponse = ProductResponse.fromJson(data);
        _setState(
          state.copyWith(
            limit: productsResponse.limit,
            skip: productsResponse.skip,
            total: productsResponse.total,
          ),
        );
        return productsResponse.products;
      }
      _setState(state.copyWith(errorMessage: "Failed to fetch products"));
    } catch (e) {
      logger.e("Error Fetching Products: ${e.toString()}");
    }
    return [];
  }

  // Get Categories
  Future<List<ProductCategory>> getCategories() async {
    try {
      Response response = await _apiService.getCategories();
      if (statusCodeSuccess(response.statusCode)) {
        List<dynamic> data = response.data;
        return data.map((e) => ProductCategory.fromJson(e)).toList();
      }
    } catch (e) {
      logger.e("Error Fetching Categories: ${e.toString()}");
    }
    return [];
  }

  void _setState(ProductsState newState) => state = newState;
}

final StateNotifierProvider<ProductsNotifier, ProductsState> productsProvider =
    StateNotifierProvider<ProductsNotifier, ProductsState>(
      (Ref ref) => ProductsNotifier(),
    );
