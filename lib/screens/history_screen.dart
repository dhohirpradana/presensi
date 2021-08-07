import 'package:flutter/material.dart';
import 'package:presensi/screens/login_screen.dart';
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
        backgroundColor: const Color(0xff2c3e50),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('PRESENSI HARI INI'),
            Column(
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                          (Route<dynamic> route) => false);
                    },
                    icon: const Icon(Icons.exit_to_app_rounded)),
              ],
            )
          ],
        ),
      ),
      body: FutureBuilder<List>(
        future: BaseApi.getPresensiByUser(nis, tgl, hari),
        builder: (context, AsyncSnapshot<List> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!.isNotEmpty) {
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, i) {
                    final data = snapshot.data!;
                    return Card(
                      child: ListTile(
                        title: Text(data[i]['pelajaran']),
                        subtitle: Text(data[i]['keterangan']),
                      ),
                    );
                  });
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
