import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:anie/common/net/base_res.dart';

class DioWrapper {
  static BaseResponse errorWrapper(Object e) {
    return BaseResponse(
      code: -1,
      message: e is DioError ? _dioErrorWrapper(e) : '未知错误',
      data: '',
      success: false,
      ores: null,
    );
  }

  static String _dioErrorWrapper(DioError error) {
    switch (error.type) {
      case DioErrorType.connectionTimeout:
        return '连接服务器超时';
      case DioErrorType.sendTimeout:
        return '连接服务器超时';
      case DioErrorType.receiveTimeout:
        return '连接服务器超时';
      case DioErrorType.cancel:
        return '连接被取消';
      default:
        return '未知错误';
    }
  }

  static BaseResponse responseWrapper(Response response) {
    // 此处如果数据比较大，可以使用 compute 放在后台计算
    final res = response.data;
    if (response.statusCode == 200) {
      final BaseResponse wrapres = BaseResponse.fromJson(res);
      wrapres.ores = response;
      return wrapres;
    } else {
      var msg = res["msg"] ?? '';
      if (response.statusCode == 401) {
        msg = 'token失效';
      }
      return BaseResponse(
        code: -1,
        success: false,
        message: msg,
        data: "",
        ores: response,
      );
    }
  }
}
