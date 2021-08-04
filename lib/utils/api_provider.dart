import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

class BaseApi {
  static String url = 'http://192.168.43.205:8000/absikaphp';
  static String login = '$url/login.php';

  static Future<List> getMapelData(String kelas) async {
    var _dio = Dio();
    Map<String, dynamic> qParams = {'par': 'mapel', 'kelas': kelas};

    var res = await _dio.get('$url/getData.php', queryParameters: qParams);
    final data = jsonDecode(res.data);
    return data;
  }

  static Future<bool> submitPresensi({
    required String nis,
    required String kdmapel,
    required String tgl,
    required String foto,
    required String latitude,
    required String longitude,
    required String keterangan,
  }) async {
    var _dio = Dio();

    var formData = FormData.fromMap({
      'nis': nis,
      'kdmapel': kdmapel,
      'tgl': tgl,
      'foto': foto,
      'latitude': latitude,
      'longitude': longitude,
      'keterangan': keterangan,
    });

    var res = await _dio.post('$url/submit.php',
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: formData);
    // final data = jsonDecode(res.data);
    print(res);
    return true;
  }
}
