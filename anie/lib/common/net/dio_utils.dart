import 'dart:io';
import 'package:anie/common/net/api.dart';
import 'package:anie/common/net/base_res.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:anie/common/net/dio_intercept.dart' as interceptor;
import 'package:anie/common/net/dio_wrapper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HttpUtils {
  static final HttpUtils _obj = HttpUtils._();

  static HttpUtils get obj => HttpUtils();

  factory HttpUtils() => _obj;

  static late Dio _dio;

  Dio get dio => _dio;

  HttpUtils._() {
    // 构造 Dio options
    final BaseOptions options = BaseOptions(
      responseType: ResponseType.json,
      validateStatus: (_) => true,
      baseUrl: Api.baseUrl,
    );

    // 实例化 Dio
    _dio = Dio(options);

    // 添加迭代器
    _dio.interceptors.add(interceptor.AuthInterceptor());
    if (kDebugMode) {
      _dio.interceptors.add(interceptor.LogInterceptor());
    }
  }

  Future<BaseResponse> _request(
    String url, {
    String? method = 'POST',
    dynamic params,
    bool tips = false,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    late BaseResponse response;
    try {
      if (tips) {
        // 展示 loading
      }
      late Response<dynamic> res;
      if (method == 'GET') {
        res = await _dio.get(url, queryParameters: params);
      } else if (method == 'UPLOAD') {
        FormData formData = FormData.fromMap(params);
        res = await _dio.post(
          url,
          data: formData,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress,
        );
      } else {
        res = await _dio.post(
          url,
          data: params,
        );
      }
      response = DioWrapper.responseWrapper(res);
    } catch (e) {
      response = DioWrapper.errorWrapper(e);
    } finally {
      // 隐藏 loading
    }
    return response;
  }

  // GET
  Future<BaseResponse> get(
    String url, {
    dynamic params,
    bool tips = false,
  }) async {
    return _request(
      url,
      method: 'GET',
      params: params,
      tips: tips,
    );
  }

  // POST
  Future<BaseResponse> post(
    String url, {
    dynamic params,
    bool tips = false,
  }) async {
    return _request(
      url,
      method: 'POST',
      params: params,
      tips: tips,
    );
  }

  // UPLOAD
  Future<BaseResponse> upload(
    String url, {
    dynamic params,
    bool tips = false,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    return _request(
      url,
      method: 'UPLOAD',
      params: params,
      tips: tips,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
