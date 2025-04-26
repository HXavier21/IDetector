import 'package:dio/dio.dart';

class NetworkUtil {
  static final NetworkUtil _instance = NetworkUtil._internal();

  factory NetworkUtil() {
    return _instance;
  }

  NetworkUtil._internal();

  final Dio _dio = Dio();
  final baseUrl = 'https://jointly-on-kit.ngrok-free.app/api';
  CancelToken? _token;

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      cancelPreviousRequest();
      _token = CancelToken();
      return await _dio.get(
        baseUrl + path,
        queryParameters: queryParameters,
        cancelToken: _token,
      );
    } catch (e) {
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 500,
        statusMessage: e.toString(),
      );
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
  }) async {
    try {
      cancelPreviousRequest();
      _token = CancelToken();
      return await _dio.post(
        baseUrl + path,
        data: data,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
          },
        ),
        cancelToken: _token,
      );
    } catch (e) {
      return Response(
        requestOptions: RequestOptions(path: path),
        statusCode: 500,
        statusMessage: e.toString(),
      );
    }
  }

  void cancelPreviousRequest() {
    if (_token != null && !_token!.isCancelled) {
      _token!.cancel('Canceled due to new request');
    }
  }
}
