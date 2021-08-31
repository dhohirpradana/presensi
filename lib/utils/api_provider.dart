import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'global_store.dart';
import 'url.dart';

class BaseApi {
  static String login = '$localhost/absikaweb/api/login.php';

  static final _dio = Dio();
  static Future<List> getMapelData(String kelas, String hari) async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    Map<String, dynamic> qParams = {
      'par': 'mapel',
      'kelas': kelas,
      'waktu': hari,
      'tgl': formattedDate
    };

    var res = await _dio.get('$localhost/absikaweb/api/getData.php',
        queryParameters: qParams);
    final data = jsonDecode(res.data);
    return data;
  }

  static Future<int> submitPresensi({
    required String nis,
    required String kdmapel,
    required String tgl,
    required File foto,
    required String latitude,
    required String longitude,
    required String keterangan,
    required String mapelTime,
  }) async {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('Hm').format(now);
    var formData = FormData.fromMap({
      'nis': nis,
      'kdmapel': kdmapel,
      'tgl': tgl,
      "foto": await MultipartFile.fromFile(foto.path),
      'latitude': latitude,
      'longitude': longitude,
      'keterangan': keterangan,
      'jam': formattedDate,
      'mapel_time': mapelTime
    });

    var res = await _dio.post('$localhost/absikaweb/api/submit.php',
        options: Options(headers: {
          HttpHeaders.contentTypeHeader: "application/json",
        }),
        data: formData);
    // final data = jsonDecode(res.data);
    pickedFile = null;
    return (res.data == '1') ? 354 : int.parse(res.data);
  }

  static Future<List> getPresensiByUser(
      String nis, String tgl, String hari) async {
    Map<String, dynamic> qParams = {
      'par': 'presensiByUser',
      'nis': nis,
      'tgl': tgl,
      'waktu': hari
    };

    var res = await _dio.get('$localhost/absikaweb/api/getData.php',
        queryParameters: qParams);
    final data = jsonDecode(res.data);
    // print(data);
    return data;
  }
}
