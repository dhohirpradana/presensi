import 'package:flutter/material.dart';
import 'package:presensi/screens/home_screen.dart';
import 'package:presensi/utils/auth.dart';
import 'package:presensi/utils/validation.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LOGIN'),
      ),
      body: Form(
        key: _key,
        child: Column(
          children: [
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
                          (isHide) ? Icons.visibility_off : Icons.visibility,
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
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            HomeScreen(siswa: login)));
                              } else {
                                // FocusManager.instance.primaryFocus?.unfocus();
                                const snackBar = SnackBar(
                                    content: Text('NIS atau password salah!'));
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                                Future.delayed(const Duration(seconds: 2), () {
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                });
                              }
                            }
                          },
                          child: const Text('LOGIN'))),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
