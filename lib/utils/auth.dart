import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:presensi/utils/api_provider.dart';

class Auth {
  static Future<List> login(String nis, String password) async {
    var _dio = Dio();
    Map<String, dynamic> qParams = {
      'par': 'login',
      'nis': nis,
      'passiswa': password,
    };

    var res = await _dio.get(BaseApi.login, queryParameters: qParams);
    final data = jsonDecode(res.data);
    return data;
  }
}
