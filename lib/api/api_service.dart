import 'package:dio/dio.dart';
import 'token_service.dart';

const String apiBaseUrl = "http://10.0.2.2:8000";

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,

      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
    ),
  );

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await TokenService.getToken();
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401) {
          // Handle token expiration (e.g., redirect to login)
        }
        return handler.next(e);
      },
    ));
  }

  Future<Response> post(String path, Map<String, dynamic> data) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> get(String path) async {
    return await _dio.get(path);
  }

  Future<Response> put(String path, Map<String, dynamic> data) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}

