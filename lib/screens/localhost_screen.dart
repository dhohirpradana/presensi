import 'package:flutter/material.dart';
import 'package:presensi/utils/url.dart';

class LocalhostScren extends StatefulWidget {
  const LocalhostScren({Key? key}) : super(key: key);

  @override
  State<LocalhostScren> createState() => _LocalhostScrenState();
}

class _LocalhostScrenState extends State<LocalhostScren> {
  final TextEditingController _textEditingController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff2c3e50),
        title: const Text('Localhost'),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextFormField(
                textInputAction: TextInputAction.next,
                controller: _textEditingController,
                keyboardType: TextInputType.text,
                autocorrect: true,
                decoration: const InputDecoration(
                    labelText: 'Url',
                    hintText: 'http:// tanpa nama folder htdocs'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                      child: ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              localhost = _textEditingController.text;
                            });
                            final snackBar = SnackBar(
                                content: Text('Berhasil set ke ' +
                                    _textEditingController.text));
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                            Future.delayed(const Duration(seconds: 2), () {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentSnackBar();
                            });
                          },
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  const Color(0xff2c3e50))),
                          child: const Text('SET LOCALHOST URL'))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
