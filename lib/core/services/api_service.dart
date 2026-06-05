import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart';
import 'dart:io';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  static const String baseUrl = 'https://goalzone-api.vercel.app/api';
  late Dio _dio;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) {
      _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.resolve(Response(
            requestOptions: options,
            data: {'success': true, 'data': []},
            statusCode: 200,
          ));
        },
      ));
    }

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // You can add global error logging here
        return handler.next(e);
      },
    ));
  }

  Dio get client => _dio;
}
