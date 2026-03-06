import 'dart:io';
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../user_service.dart';

bool statusCodeSuccess(num? statusCode) {
  // status code success checker
  if (statusCode == null) return false;
  return statusCode >= 200 && statusCode <= 300;
}

class ApiService {
  static final _dio = Dio();
  static const _timeOut = Duration(seconds: 15);
  static bool _interceptorsConfigured = false;
  static bool _isRefreshing = false;
  static Completer<void>? _refreshCompleter;

  static Map<String, dynamic> _responseObj(message) => {"data": message};

  static Response _responseGenerator(int statusCode, var data) => Response(
    statusCode: statusCode,
    data: data,
    requestOptions: RequestOptions(),
  );

  // connection problem response.
  static const int _errorStatusCode = 500;

  // common methods
  static InterceptorsWrapper _requestAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = _getToken();
        if (token != null && (options.headers['Authorization'] == null)) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    );
  }

  static void _ensureInterceptors() {
    if (_interceptorsConfigured) return;
    _interceptorsConfigured = true;

    _dio.interceptors.add(_requestAuthInterceptor());

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          final response = error.response;
          final requestOptions = error.requestOptions;

          // Only handle 401s for requests not already retried
          final alreadyRetried = requestOptions.extra['retried'] == true;
          if (response?.statusCode == 401 && !alreadyRetried) {
            try {
              // Single-flight refresh
              if (!_isRefreshing) {
                _isRefreshing = true;
                _refreshCompleter = Completer<void>();

                final refreshed = await _refreshAccessToken();
                _isRefreshing = false;
                _refreshCompleter?.complete();
                _refreshCompleter = null;

                if (!refreshed) {
                  return handler.next(error);
                }
              } else {
                // Wait for ongoing refresh
                if (_refreshCompleter != null) {
                  await _refreshCompleter!.future;
                }
              }

              // Retry original request with updated token
              final newToken = _getToken();
              if (newToken != null) {
                final opts = Options(
                  method: requestOptions.method,
                  headers: Map<String, dynamic>.from(requestOptions.headers)
                    ..['Authorization'] = 'Bearer $newToken',
                  responseType: requestOptions.responseType,
                  contentType: requestOptions.contentType,
                  validateStatus: requestOptions.validateStatus,
                  followRedirects: requestOptions.followRedirects,
                  receiveDataWhenStatusError:
                      requestOptions.receiveDataWhenStatusError,
                  extra: Map<String, dynamic>.from(requestOptions.extra)
                    ..['retried'] = true,
                );

                try {
                  final cloneResponse = await _dio.request(
                    requestOptions.path,
                    data: requestOptions.data,
                    queryParameters: requestOptions.queryParameters,
                    options: opts,
                    cancelToken: requestOptions.cancelToken,
                    onReceiveProgress: requestOptions.onReceiveProgress,
                    onSendProgress: requestOptions.onSendProgress,
                  );
                  return handler.resolve(cloneResponse);
                } catch (e) {
                  return handler.next(error);
                }
              }
            } catch (_) {
              // Fallthrough to default error handling
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  // get token
  static String? _getToken() {
    final token = UserService.instance.accessToken;
    return token;
  }

  static Future<bool> _refreshAccessToken() async {
    try {
      // final refreshToken = UserService.instance.refreshToken;
      // if (refreshToken == null) return false;

      // // Using AuthApiService to fetch a new access token
      // final response = await AuthApiService.getAccessToken({
      //   'refreshToken': refreshToken,
      // });
      // if (statusCodeSuccess(response.statusCode)) {
      //   final data = response.data['data'];
      //   UserService.instance.storeTokens(data);
      //   return true;
      // }
    } catch (_) {}
    return false;
  }

  // exception handler
  static Response<dynamic> _exceptionHandler(var error) {
    if (error is DioException) {
      String errorMessage = '';
      switch (error.type) {
        case DioExceptionType.connectionError:
          return _responseGenerator(500, _responseObj(connectionError));
        case DioExceptionType.connectionTimeout:
          return _responseGenerator(
            _errorStatusCode,
            _responseObj(timeoutResponse),
          );
        case DioExceptionType.receiveTimeout:
          return _responseGenerator(
            _errorStatusCode,
            _responseObj(timeoutResponse),
          );
        case DioExceptionType.sendTimeout:
          return _responseGenerator(
            _errorStatusCode,
            _responseObj(timeoutResponse),
          );
        case DioExceptionType.badResponse:
          try {
            if (error.response != null) {
              // Extract status code and any error message from response body (if applicable)
              errorMessage =
                  '${error.response?.data['message'] ?? somethingWentWrong}';
              return _responseGenerator(
                error.response?.statusCode ?? 500,
                _responseObj(errorMessage),
              );
            } else {
              // If response is null, it likely indicates a network-level issue
              errorMessage = connectionError;
              return _responseGenerator(500, _responseObj(errorMessage));
            }
          } catch (e) {
            return _responseGenerator(500, _responseObj(somethingWentWrong));
          }
        default:
          errorMessage = somethingWentWrong;
          return _responseGenerator(500, _responseObj(errorMessage));
      }
    }
    return _responseGenerator(500, _responseObj(somethingWentWrong));
  }

  // post call
  static Future<Response> postCall({
    required String url,
    required body,
    bool tokenNeeded = false,
    String? operationName,
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      _ensureInterceptors();
      Response response = await _dio
          .post(
            url,
            data: body,
            options: Options(
              validateStatus: (_) => true,
              contentType: Headers.jsonContentType,
              responseType: ResponseType.json,
              headers: tokenNeeded
                  ? {'Authorization': 'Bearer ${_getToken()}'}
                  : null,
            ),
          )
          .timeout(
            _timeOut,
            onTimeout: () => _responseGenerator(
              _errorStatusCode,
              _responseObj(timeoutResponse),
            ),
          );
      stopwatch.stop();
      if (kDebugMode) {
        print(
          '⏱️  Network request for $operationName '
          'completed in: ${stopwatch.elapsedMilliseconds}ms,'
          ' Status Code: ${response.statusCode}',
        );
      }
      return _responseGenerator(response.statusCode ?? 201, response.data);
    } catch (e) {
      stopwatch.stop();
      if (kDebugMode) {
        print(
          '❌ Network request for $operationName '
          'failed after: ${stopwatch.elapsedMilliseconds}ms - $e',
        );
      }
      return _exceptionHandler(e);
    }
  }

  // get call
  static Future<Response> getCall({
    required String url,
    bool tokenNeeded = false,
    String? operationName,
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      _ensureInterceptors();
      Response response = await _dio
          .get(
            url,
            options: Options(
              validateStatus: (_) => true,
              contentType: Headers.jsonContentType,
              responseType: ResponseType.json,
              headers: tokenNeeded
                  ? {'Authorization': 'Bearer ${_getToken()}'}
                  : null,
            ),
          )
          .timeout(
            _timeOut,
            onTimeout: () => _responseGenerator(
              _errorStatusCode,
              _responseObj(timeoutResponse),
            ),
          );
      stopwatch.stop();
      if (kDebugMode) {
        print(
          '⏱️  Network request for $operationName '
          'completed in: ${stopwatch.elapsedMilliseconds}ms,'
          '  Status Code: ${response.statusCode}',
        );
      }
      return _responseGenerator(response.statusCode ?? 201, response.data);
    } catch (e) {
      stopwatch.stop();
      if (kDebugMode) {
        print(
          '❌ Network request for $operationName '
          'failed after: ${stopwatch.elapsedMilliseconds}ms - $e',
        );
      }
      return _exceptionHandler(e);
    }
  }

  // update/put call
  static Future<Response> putCall({
    required String url,
    var body,
    bool tokenNeeded = false,
    String? operationName,
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      _ensureInterceptors();
      Response response = await _dio.put(
        url,
        data: body,
        options: Options(
          validateStatus: (_) => true,
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
          headers: tokenNeeded
              ? {'Authorization': 'Bearer ${_getToken()}'}
              : null,
        ),
      );
      stopwatch.stop();
      if (kDebugMode) {
        print(
          '⏱️  Network request for $operationName '
          'completed in: ${stopwatch.elapsedMilliseconds}ms,'
          '  Status Code: ${response.statusCode}',
        );
      }
      return _responseGenerator(response.statusCode ?? 201, response.data);
    } catch (e) {
      stopwatch.stop();
      if (kDebugMode) {
        print(
          '❌ Network request for $operationName '
          'failed after: ${stopwatch.elapsedMilliseconds}ms - $e',
        );
      }
      return _exceptionHandler(e);
    }
  }

  // update/patch call
  static Future<Response> patchCall({
    required String url,
    var body,
    bool tokenNeeded = false,
    String? operationName,
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      _ensureInterceptors();
      Response response = await _dio.patch(
        url,
        data: body,
        options: Options(
          validateStatus: (_) => true,
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
          headers: tokenNeeded
              ? {'Authorization': 'Bearer ${_getToken()}'}
              : null,
        ),
      );
      stopwatch.stop();
      if (kDebugMode) {
        print(
          '⏱️  Network request for $operationName '
          'completed in: ${stopwatch.elapsedMilliseconds}ms,'
          '  Status Code: ${response.statusCode}',
        );
      }
      return _responseGenerator(response.statusCode ?? 201, response.data);
    } catch (e) {
      stopwatch.stop();
      if (kDebugMode) {
        print(
          '❌ Network request for $operationName '
          'failed after: ${stopwatch.elapsedMilliseconds}ms - $e',
        );
      }
      return _exceptionHandler(e);
    }
  }

  // delete call
  static Future<Response> deleteCall({
    required String url,
    var body,
    bool tokenNeeded = false,
    String? operationName,
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      _ensureInterceptors();
      Response response = await _dio.delete(
        url,
        data: body,
        options: Options(
          validateStatus: (_) => true,
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
          headers: tokenNeeded
              ? {'Authorization': 'Bearer ${_getToken()}'}
              : null,
        ),
      );
      stopwatch.stop();
      if (kDebugMode) {
        print(
          '⏱️  Network request for $operationName '
          'completed in: ${stopwatch.elapsedMilliseconds}ms',
        );
      }
      return _responseGenerator(response.statusCode ?? 201, response.data);
    } catch (e) {
      stopwatch.stop();
      if (kDebugMode) {
        print(
          '❌ Network request for $operationName '
          'failed after: ${stopwatch.elapsedMilliseconds}ms - $e',
        );
      }
      return _exceptionHandler(e);
    }
  }

  //download file
  static Future<Response> downloadCall({
    required String url,
    required String savePath,
    required void Function(int, int) onReciveProgress,
    Options? options,
    String? operationName,
  }) async {
    final Stopwatch stopwatch = Stopwatch()..start();
    try {
      _ensureInterceptors();
      Response response = await _dio.download(
        url,
        savePath,
        onReceiveProgress: (recieved, total) =>
            onReciveProgress(recieved, total),
        options: options,
      );
      stopwatch.stop();
      if (kDebugMode) {
        print(
          '⏱️  Network request for $operationName '
          'completed in: ${stopwatch.elapsedMilliseconds}ms',
        );
      }
      return _responseGenerator(response.statusCode ?? 201, response.data);
    } catch (e) {
      stopwatch.stop();
      if (kDebugMode) {
        print(
          '❌ Network request for $operationName '
          'failed after: ${stopwatch.elapsedMilliseconds}ms - $e',
        );
      }
      return _exceptionHandler(e);
    }
  }

  // upload file
  static Future<Response> uploadCall({
    required String url,
    required File file,
    String? operationName,
  }) async {
    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });
    try {
      _ensureInterceptors();
      Response response = await _dio.post(
        url,
        data: formData,
        options: Options(
          validateStatus: (_) => true,
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
        ),
      );
      return response;
    } catch (e) {
      return _exceptionHandler(e);
    }
  }
}

/// ------- [ Errormessages ]---------
const String invalidPhoneNum = 'Invalid Phone number';
const String cantBeEmpty = "Can't be empty";
const String provideValidInput = 'Please provide valid input';
const String passwordMissMatch = "Password Mismatch Occured";
const String invalidEmail = 'Invalid Email address';
const String connectionError = 'Connection Error';
const String timeoutResponse = 'Response time out';
const String somethingWentWrong = 'Something went wrong';
const String faliedToSendOtp = 'Failed to send an OTP';
