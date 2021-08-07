import 'package:flutter/material.dart';
import 'package:presensi/screens/home_screen.dart';
import 'package:presensi/utils/auth.dart';
import 'package:presensi/utils/validation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _key = GlobalKey<FormState>();
  bool isHide = true;
  final TextEditingController _nisController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<List> getPref() async {
    final prefs = await SharedPreferences.getInstance();
    final nis = prefs.getInt('nis');
    final password = prefs.getString('password');
    return [nis, password];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff2c3e50),
        title: const Text('LOGIN'),
      ),
      body: Form(
        key: _key,
        child: FutureBuilder(
            future: getPref(),
            builder: (context, AsyncSnapshot<List> snapshot) {
              if (snapshot.hasData) {
                final data = snapshot.data;
                if (data![0] != null && data[1] != null) {
                  _nisController.text = data[0].toString();
                  _passwordController.text = data[1];
                }
                return Column(
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Icon(
                        Icons.person,
                        size: MediaQuery.of(context).size.width / 4,
                        color: Colors.grey,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: TextFormField(
                        textInputAction: TextInputAction.next,
                        controller: _nisController,
                        validator: (nis) {
                          if (InputValidationMixin.isNisValid(nis!)) {
                            return null;
                          }
                          return 'NIS tidak boleh kosong!';
                        },
                        keyboardType: TextInputType.number,
                        autocorrect: true,
                        decoration: const InputDecoration(
                            labelText: 'NIS', hintText: 'Masukan NIS'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: TextFormField(
                        controller: _passwordController,
                        validator: (password) {
                          if (InputValidationMixin.isPasswordValid(password!)) {
                            return null;
                          }
                          return 'Password tidak boleh kosong!';
                        },
                        obscureText: isHide,
                        autocorrect: true,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isHide = !isHide;
                                  });
                                },
                                icon: Icon(
                                  (isHide)
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                )),
                            labelText: 'Password',
                            hintText: 'Masukan password'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Expanded(
                              child: ElevatedButton(
                                  onPressed: () async {
                                    if (_key.currentState!.validate()) {
                                      final login = await Auth.login(
                                          _nisController.text,
                                          _passwordController.text);
                                      if (login.isNotEmpty) {
                                        final prefs = await SharedPreferences
                                            .getInstance();
                                        prefs.setInt('nis',
                                            int.parse(_nisController.text));
                                        prefs.setString('password',
                                            _passwordController.text);
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    HomeScreen(siswa: login)));
                                      } else {
                                        // FocusManager.instance.primaryFocus?.unfocus();
                                        const snackBar = SnackBar(
                                            content: Text(
                                                'NIS atau password salah!'));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(snackBar);
                                        Future.delayed(
                                            const Duration(seconds: 2), () {
                                          ScaffoldMessenger.of(context)
                                              .hideCurrentSnackBar();
                                        });
                                      }
                                    }
                                  },
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              const Color(0xff2c3e50))),
                                  child: const Text('LOGIN'))),
                        ],
                      ),
                    )
                  ],
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),
      ),
    );
  }
}
