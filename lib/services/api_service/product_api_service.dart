import 'package:dio/dio.dart';
import 'package:tech_gadol/services/api_service/common/api_constants.dart';
import 'package:tech_gadol/services/api_service/common/common_api_service.dart';
import 'package:tech_gadol/services/api_service/common/parent_api_service.dart';

import '../utils/pagination_handler.dart';

final String productBaseUrl = '$baseUrl$productUrl';

class ProductApiService extends ParentApiService {
  ProductApiService() : super(productBaseUrl, "Products");

  Future<Response> getProducts({
    int limit = 10,
    int skip = 0,
    String? searchQuery,
    String? category,
  }) {
    String url = productBaseUrl;
    final queryParameters = <String, dynamic>{'limit': limit, 'skip': skip};
    if (category != null && category.isNotEmpty) {
      url += '/category/$category';
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      // url += '/search';
      queryParameters['q'] = searchQuery;
    }

    url = PaginationHandler.addQueryParameters(
      url,
      queryParameters: queryParameters,
    );

    return ApiService.getCall(url: url, operationName: "Get Products");
  }

  Future<Response> getCategories() {
    return ApiService.getCall(
      url: '$productBaseUrl/categories',
      operationName: "Get Product Categories",
    );
  }

  Future<Response> getProductById(String id) {
    return ApiService.getCall(
      url: '$productBaseUrl/$id',
      operationName: "Get Product Details",
    );
  }
}
