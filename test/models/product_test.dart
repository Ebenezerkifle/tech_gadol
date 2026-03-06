import 'package:flutter_test/flutter_test.dart';
import 'package:tech_gadol/models/product.dart';

void main() {
  group('Product Model Tests', () {
    final Map<String, dynamic> validProductJson = {
      "id": 1,
      "title": "Essence Mascara Lash Princess",
      "description": "The Essence Mascara Lash Princess.",
      "category": "beauty",
      "price": 9.99,
      "discountPercentage": 7.17,
      "rating": 4.94,
      "stock": 5,
      "tags": ["beauty", "mascara"],
      "brand": "Essence",
      "sku": "RCH45Q1A",
      "weight": 2,
      "dimensions": {"width": 23.17, "height": 14.43, "depth": 28.01},
      "warrantyInformation": "1 month warranty",
      "shippingInformation": "Ships in 1 month",
      "availabilityStatus": "Low Stock",
      "reviews": [
        {
          "rating": 2,
          "comment": "Very unhappy with my purchase!",
          "date": "2024-05-23T08:56:21.618Z",
          "reviewerName": "John Doe",
          "reviewerEmail": "john.doe@x.dummyjson.com"
        }
      ],
      "returnPolicy": "30 days return policy",
      "minimumOrderQuantity": 24,
      "meta": {
        "createdAt": "2024-05-23T08:56:21.618Z",
        "updatedAt": "2024-05-23T08:56:21.618Z",
        "barcode": "9164035109868",
        "qrCode": "https://assets.dummyjson.com/public/qr-code.png"
      },
      "images": [
        "https://cdn.dummyjson.com/products/images/beauty/Essence%20Mascara%20Lash%20Princess/1.png"
      ],
      "thumbnail":
          "https://cdn.dummyjson.com/products/images/beauty/Essence%20Mascara%20Lash%20Princess/thumbnail.png"
    };

    test('fromJson parses correctly with all valid data', () {
      final product = Product.fromJson(validProductJson);

      expect(product.id, 1);
      expect(product.title, 'Essence Mascara Lash Princess');
      expect(product.description, 'The Essence Mascara Lash Princess.');
      expect(product.category, 'beauty');
      expect(product.price, 9.99);
      expect(product.discountPercentage, 7.17);
      expect(product.rating, 4.94);
      expect(product.stock, 5);
      expect(product.tags, ['beauty', 'mascara']);
      expect(product.brand, 'Essence');
      expect(product.sku, 'RCH45Q1A');
      expect(product.weight, 2);
      expect(product.dimensions.width, 23.17);
      expect(product.dimensions.height, 14.43);
      expect(product.dimensions.depth, 28.01);
      expect(product.warrantyInformation, '1 month warranty');
      expect(product.shippingInformation, 'Ships in 1 month');
      expect(product.availabilityStatus, 'Low Stock');
      expect(product.reviews.length, 1);
      expect(product.reviews[0].reviewerName, 'John Doe');
      expect(product.reviews[0].rating, 2);
      expect(product.returnPolicy, '30 days return policy');
      expect(product.minimumOrderQuantity, 24);
      expect(
          product.images,
          contains(
              'https://cdn.dummyjson.com/products/images/beauty/Essence%20Mascara%20Lash%20Princess/1.png'));
      expect(product.thumbnail,
          'https://cdn.dummyjson.com/products/images/beauty/Essence%20Mascara%20Lash%20Princess/thumbnail.png');
    });

    test('fromJson handles missing optional fields or null tags', () {
      final Map<String, dynamic> minimalJson = Map.of(validProductJson);
      minimalJson.remove('brand'); // Brand is nullable in our model
      minimalJson.remove('tags'); // Tags should default to [] if missing

      final product = Product.fromJson(minimalJson);

      expect(product.brand, isNull);
      expect(product.tags, isEmpty);
    });

    test('fromJson handles int conversion for double fields', () {
      final Map<String, dynamic> intTypeForDoubleJson =
          Map.of(validProductJson);
      intTypeForDoubleJson['price'] = 10; // Passing int where double is expected
      intTypeForDoubleJson['rating'] = 4;
      intTypeForDoubleJson['discountPercentage'] = 5;

      final product = Product.fromJson(intTypeForDoubleJson);

      expect(product.price, 10.0);
      expect(product.rating, 4.0);
      expect(product.discountPercentage, 5.0);
    });
  });
}
