import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:presensi/screens/history_screen.dart';
import 'package:presensi/utils/api_provider.dart';
import 'package:presensi/utils/get_location.dart';
import 'package:presensi/utils/global_store.dart';
import 'package:presensi/utils/validation.dart';

class HomeScreen extends StatefulWidget {
  final List<dynamic> siswa;
  const HomeScreen({Key? key, required this.siswa}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _keteranganController = TextEditingController();
  String? _dropdownError;
  String? _pickedFileError;
  final ImagePicker _picker = ImagePicker();
  int _radioValue = 0;
  String mapelTime = '';

  void _handleRadioValueChange(int? value) {
    setState(() {
      _radioValue = value!;

      switch (_radioValue) {
        case 0:
          break;
        case 1:
          break;
      }
    });
  }

  String? _mySelection;
  Position? currLocation;
  void getLocation() async {
    final curr = await Locator.determinePosition();
    setState(() {
      currLocation = curr;
    });
  }

  void pickImage() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 50);
    if (image != null) {
      setState(() {
        pickedFile = File(image.path);
      });
    } else {
      setState(() {
        pickedFile = null;
      });
    }
  }

  _validateForm() async {
    bool _isValid = _formKey.currentState!.validate();

    if (pickedFile == null && _mySelection == null) {
      _dropdownError = "Pilih mapel pilihan!";
      setState(() => _pickedFileError = "Tidak ada foto!");
      _isValid = false;
    } else if (_mySelection == null) {
      _dropdownError = "Pilih mapel pilihan!";
      _isValid = false;
    } else if (pickedFile == null) {
      setState(() => _pickedFileError = "Tidak ada foto!");
      _isValid = false;
    }

    if (_isValid && mapelTime != '') {
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd').format(now);
      final response = await BaseApi.submitPresensi(
          mapelTime: mapelTime,
          nis: widget.siswa[0]['nis'],
          kdmapel: _mySelection!,
          tgl: formattedDate,
          foto: pickedFile!,
          latitude: currLocation!.latitude.toString(),
          longitude: currLocation!.longitude.toString(),
          keterangan: (_radioValue == 0)
              ? "HADIR"
              : _keteranganController.text.toUpperCase());
      if (response == 354) {
        AwesomeDialog(
          dismissOnTouchOutside: false,
          context: context,
          dialogType: DialogType.SUCCES,
          animType: AnimType.BOTTOMSLIDE,
          title: 'SUKSES',
          desc: 'Berhasil Presensi',
          // autoHide: const Duration(seconds: 7),
          btnOkOnPress: () {},
        ).show().then((v) {
          setState(() {
            _mySelection == null;
            _keteranganController.clear();
          });
        });
      } else if (response > 59) {
        AwesomeDialog(
          dismissOnTouchOutside: false,
          context: context,
          dialogType: DialogType.WARNING,
          animType: AnimType.BOTTOMSLIDE,
          title: 'GAGAL',
          desc: 'Belum waktunya presensi!',
          // autoHide: const Duration(seconds: 7),
          btnCancelOnPress: () {
            setState(() {});
          },
        ).show();
      } else {
        double telat = response.abs() / 60;
        int intTelat = telat.toInt();
        AwesomeDialog(
          dismissOnTouchOutside: false,
          context: context,
          dialogType: DialogType.WARNING,
          animType: AnimType.BOTTOMSLIDE,
          title: 'GAGAL',
          desc: 'Telat $intTelat menit!',
          // autoHide: const Duration(seconds: 7),
          btnCancelOnPress: () {
            setState(() {});
          },
        ).show();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    final hari = DateFormat('EEEE').format(DateTime.now());
    final String hariId = (hari == 'Sunday')
        ? 'MINGGU'
        : (hari == 'Monday')
            ? 'SENIN'
            : (hari == 'Tuesday')
                ? 'SELASA'
                : (hari == 'Wednesday')
                    ? 'RABU'
                    : (hari == 'Thursday')
                        ? 'KAMIS'
                        : (hari == 'Friday')
                            ? 'JUMAT'
                            : 'SABTU';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff2c3e50),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('PRESENSI SISWA'),
            IconButton(
                onPressed: () {
                  DateTime now = DateTime.now();
                  String formattedDate = DateFormat('yyyy-MM-dd').format(now);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HistoryScreen(
                                nis: widget.siswa[0]['nis'],
                                tgl: formattedDate,
                                hari: hariId,
                              )));
                },
                icon: const Icon(Icons.list_alt_rounded))
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: TextFormField(
                  enabled: false,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  autocorrect: true,
                  decoration: InputDecoration(
                    labelText: widget.siswa[0]['nama'].toUpperCase(),
                  ),
                ),
              ),
              FutureBuilder<List>(
                future: BaseApi.getMapelData(widget.siswa[0]['kelas'], hariId),
                builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
                  final data = snapshot.data;
                  if (snapshot.hasData) {
                    return Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: DropdownButton<String>(
                                isExpanded: true,
                                isDense: true,
                                hint: Text((data!.isNotEmpty)
                                    ? "Pilih mapel"
                                    : 'Tidak ada mapel hari ini'),
                                value: _mySelection,
                                onChanged: (v) {
                                  setState(() {
                                    _mySelection = v;
                                    _dropdownError = null;
                                  });
                                },
                                items: [
                                  for (int i = 0; i < data.length; i++)
                                    DropdownMenuItem<String>(
                                      value: data[i]["kode"].toString(),
                                      onTap: () {
                                        mapelTime = data[i]["waktu"].toString();
                                      },
                                      child: Text(
                                        data[i]["pelajaran"],
                                      ),
                                    )
                                ]),
                          ),
                        ),
                      ],
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
              _dropdownError == null
                  ? const SizedBox.shrink()
                  : Row(
                      children: [
                        Text(
                          _dropdownError ?? "",
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ],
                    ),
              const SizedBox(
                height: 24,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  (pickedFile != null)
                      ? InkWell(
                          onTap: () {
                            pickImage();
                          },
                          child: Image.file(
                            File(pickedFile!.path),
                            width: 150,
                          ),
                        )
                      : Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              pickImage();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.camera,
                                  color: Colors.black87,
                                ),
                                Text('Kamera',
                                    style: TextStyle(color: Colors.black87))
                              ],
                            ),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.white)),
                          ),
                        ),
                ],
              ),
              pickedFile != null
                  ? const SizedBox.shrink()
                  : Row(
                      children: [
                        Text(
                          _pickedFileError ?? "",
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ],
                    ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Radio(
                          value: 0,
                          groupValue: _radioValue,
                          onChanged: _handleRadioValueChange,
                        ),
                        const Text(
                          'HADIR',
                        ),
                        Radio(
                          value: 1,
                          groupValue: _radioValue,
                          onChanged: _handleRadioValueChange,
                        ),
                        const Text(
                          'TIDAK HADIR',
                        ),
                      ],
                    ),
                    (_radioValue == 1)
                        ? TextFormField(
                            controller: _keteranganController,
                            validator: (password) {
                              if (InputValidationMixin.isPasswordValid(
                                  password!)) {
                                return null;
                              }
                              return 'Keterangan tidak boleh kosong!';
                            },
                            decoration: const InputDecoration(
                                labelText: 'Keterangan',
                                hintText: 'Masukan keterangan'),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          getLocation();
                        },
                        child: Card(
                            color: (currLocation != null &&
                                    !currLocation!.isMocked)
                                ? Colors.green[600]
                                : Colors.red[400],
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  (currLocation != null &&
                                          !currLocation!.isMocked)
                                      ? 'Location OK'
                                      : 'No Location',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0.0),
                child: Row(
                  children: [
                    Expanded(
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    const Color(0xff2c3e50))),
                            onPressed: () {
                              if (currLocation != null &&
                                  !currLocation!.isMocked) {
                                _validateForm();
                              }
                            },
                            child: const Text('KIRIM'))),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
