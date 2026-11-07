
import 'package:dio/dio.dart';

class ApiService {
  // Заміни цю адресу на свій субдомен RequestCatcher.
  static const String baseUrl =
      'https://artem-pr12-26.requestcatcher.com/test';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.plain,
    ),
  );

  // Авторизація
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _dio.post(
      '/login',
      data: {
        'email': email,
        'password': password,
      },
    );
  }

  // Реєстрація
  Future<void> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    await _dio.post(
      '/signup',
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
    );
  }

  // Відновлення пароля
  Future<void> resetPassword({
    required String email,
  }) async {
    await _dio.post(
      '/reset',
      data: {
        'email': email,
      },
    );
  }
}
