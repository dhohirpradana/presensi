import 'package:flutter/material.dart';
import 'package:presensi/utils/api_provider.dart';

class HistoryScreen extends StatelessWidget {
  final String nis;
  final String tgl;
  final String hari;
  const HistoryScreen(
      {Key? key, required this.nis, required this.tgl, required this.hari})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PRESENSI HARI INI'),
      ),
      body: FutureBuilder<List>(
        future: BaseApi.getPresensiByUser(nis, tgl, hari),
        builder: (context, AsyncSnapshot<List> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isNotEmpty) {
              return const Text('ADA');
            } else {
              return const Center(
                  child: Text('BELUM ADA DATA PRESENSI HARI INI'));
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
