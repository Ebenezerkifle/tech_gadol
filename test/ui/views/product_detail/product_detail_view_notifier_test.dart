import 'package:flutter_test/flutter_test.dart';
import 'package:tech_gadol/models/product.dart';
import 'package:tech_gadol/services/api_service/product_api_service.dart';
import 'package:tech_gadol/ui/views/product_detail/product_detail_view_notifier.dart';
import 'package:tech_gadol/ui/views/product_detail/product_detail_view_state.dart';
import 'package:dio/dio.dart';

class FakeProductApiServiceSuccess extends ProductApiService {
  @override
  Future<Response> getProductById(String id) async {
    return Response(
      requestOptions: RequestOptions(path: ''),
      statusCode: 200,
      data: {
        "id": 1,
        "title": "Test Product",
        "description": "Desc",
        "category": "cat",
        "price": 10.0,
        "discountPercentage": 0.0,
        "rating": 5.0,
        "stock": 10,
        "tags": [],
        "sku": "123",
        "weight": 1,
        "dimensions": {"width": 1, "height": 1, "depth": 1},
        "warrantyInformation": "None",
        "shippingInformation": "None",
        "availabilityStatus": "In Stock",
        "reviews": [],
        "returnPolicy": "None",
        "minimumOrderQuantity": 1,
        "images": [],
        "thumbnail": ""
      },
    );
  }
}

class FakeProductApiServiceFailure extends ProductApiService {
  @override
  Future<Response> getProductById(String id) async {
    return Response(
      requestOptions: RequestOptions(path: ''),
      statusCode: 404,
      data: {"message": "Not found"},
    );
  }
}

class FakeProductApiServiceException extends ProductApiService {
  @override
  Future<Response> getProductById(String id) async {
    throw Exception('Network error');
  }
}

void main() {
  group('ProductDetailViewNotifier Tests', () {
    test('initial state is correct', () {
      final notifier = ProductDetailViewNotifier(
          apiService: FakeProductApiServiceSuccess());

      final isInitial = notifier.state.maybeWhen(
        initial: () => true,
        orElse: () => false,
      );
      expect(isInitial, isTrue);
    });

    test('loadProduct handles success correctly', () async {
      final notifier = ProductDetailViewNotifier(
          apiService: FakeProductApiServiceSuccess());

      // Let the Future resolve
      await notifier.loadProduct('1');

      notifier.state.maybeWhen(
        loaded: (product) {
          expect(product.id, 1);
          expect(product.title, 'Test Product');
        },
        orElse: () => fail('Expected state to be loaded'),
      );
    });

    test('loadProduct handles failure response correctly', () async {
      final notifier = ProductDetailViewNotifier(
          apiService: FakeProductApiServiceFailure());

      await notifier.loadProduct('1');

      notifier.state.maybeWhen(
        error: (errorMessage) {
          expect(errorMessage, 'Failed to load product details');
        },
        orElse: () => fail('Expected state to be error'),
      );
    });

    test('loadProduct handles exceptions correctly', () async {
      final notifier = ProductDetailViewNotifier(
          apiService: FakeProductApiServiceException());

      await notifier.loadProduct('1');

      notifier.state.maybeWhen(
        error: (errorMessage) {
          expect(errorMessage, contains('Error loading product'));
        },
        orElse: () => fail('Expected state to be error'),
      );
    });
  });
}
