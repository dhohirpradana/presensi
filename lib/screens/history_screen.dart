import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:presensi/screens/login_screen.dart';
import 'package:presensi/utils/api_provider.dart';
import 'package:presensi/utils/url.dart';

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
                    final foto = data[i]['foto'];
                    return Card(
                      child: ListTile(
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CachedNetworkImage(
                              height: 75,
                              imageUrl: "$localhost/absikaweb/api/$foto",
                              placeholder: (context, url) => const Padding(
                                padding: EdgeInsets.all(8.0),
                                child:
                                    Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Mata Pelajaran : ' +
                                      data[i]['pelajaran']
                                          .toString()
                                          .toUpperCase()),
                                  Text('Keterangan       : ' +
                                      data[i]['keterangan'])
                                ],
                              ),
                            )
                          ],
                        ),
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
