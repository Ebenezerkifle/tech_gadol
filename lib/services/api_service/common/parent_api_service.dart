import 'package:tech_gadol/services/api_service/common/common_api_service.dart';

abstract class Parent {
  // Post call in here.
  Future<dynamic> post(
    Map<String, dynamic> data, {
    bool isTokenRequired = true,
  });
  // Get call in here.
  Future<dynamic> get(String parameter, {bool isTokenRequired = true});
  // Path call in here.
  Future<dynamic> patch(
    String id,
    Map<String, dynamic> data, {
    bool isTokenRequired = true,
  });
  // Put call in here.
  Future<dynamic> put(
    String id,
    Map<String, dynamic> data, {
    bool isTokenRequired = true,
  });
  // delete call in here.
  Future<dynamic> delete(String id, {bool isTokenRequired = true});
}

class ParentApiService extends Parent {
  final String _baseUrl;
  final String _operation;

  ParentApiService(this._baseUrl, this._operation);

  @override
  Future<dynamic> delete(String id, {bool isTokenRequired = true}) {
    return ApiService.deleteCall(
      url: '$_baseUrl/$id',
      tokenNeeded: isTokenRequired,
      operationName: 'Delete $_operation',
    );
  }

  @override
  Future<dynamic> get(String parameter, {bool isTokenRequired = true}) {
    // TODO Check if parameter has leading back slash or not
    return ApiService.getCall(
      url: '$_baseUrl/$parameter',
      tokenNeeded: isTokenRequired,
      operationName: 'Get $_operation',
    );
  }

  @override
  Future<dynamic> patch(
    String id,
    Map<String, dynamic> data, {
    bool isTokenRequired = true,
  }) {
    return ApiService.patchCall(
      url: '$_baseUrl/$id',
      tokenNeeded: isTokenRequired,
      body: data,
      operationName: 'Patch $_operation',
    );
  }

  @override
  Future<dynamic> post(
    Map<String, dynamic> data, {
    bool isTokenRequired = true,
  }) {
    return ApiService.postCall(
      url: _baseUrl,
      body: data,
      tokenNeeded: isTokenRequired,
      operationName: 'Post $_operation',
    );
  }

  @override
  Future<dynamic> put(
    String id,
    Map<String, dynamic> data, {
    bool isTokenRequired = true,
  }) {
    return ApiService.patchCall(
      url: '$_baseUrl/$id',
      tokenNeeded: isTokenRequired,
      body: data,
      operationName: 'Put $_operation',
    );
  }
}
