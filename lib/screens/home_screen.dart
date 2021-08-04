import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:presensi/utils/api_provider.dart';
import 'package:presensi/utils/get_location.dart';
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
  File? _pickedFile;

  String? _mySelection;
  Position? currLocation;
  void getLocation() async {
    final curr = await Locator.determinePosition();
    setState(() {
      currLocation = curr;
    });
  }

  void pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _pickedFile = File(image.path);
        _pickedFileError == null;
      });
    } else {
      setState(() {
        _pickedFile = null;
      });
    }
  }

  _validateForm() {
    bool _isValid = _formKey.currentState!.validate();

    if (_mySelection == null) {
      _dropdownError = "Pilih mapel pilihan!";
      if (_pickedFile == null) {
        setState(() => _pickedFileError = "Tidak ada foto!");
        _isValid = false;
      }
    }

    if (_isValid) {
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd').format(now);
      BaseApi.submitPresensi(
          nis: widget.siswa[0]['nis'],
          kdmapel: _mySelection!,
          tgl: formattedDate,
          foto: '',
          latitude: currLocation!.latitude.toString(),
          longitude: currLocation!.longitude.toString(),
          keterangan: _keteranganController.text);
    }
  }

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('PRESENSI SISWA'),
            IconButton(onPressed: () {}, icon: const Icon(Icons.person))
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
                future: BaseApi.getMapelData(widget.siswa[0]['kelas']),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
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
                                hint: const Text("Pilih mapel"),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  (_pickedFile != null)
                      ? InkWell(
                          onTap: () {
                            pickImage();
                          },
                          child: Image.file(
                            File(_pickedFile!.path),
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
              _pickedFileError == null
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
                child: TextFormField(
                  controller: _keteranganController,
                  validator: (password) {
                    if (InputValidationMixin.isPasswordValid(password!)) {
                      return null;
                    }
                    return 'Keterangan tidak boleh kosong!';
                  },
                  decoration: const InputDecoration(
                      labelText: 'Keterangan', hintText: 'Masukan keterangan'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: Row(
                  children: [
                    Expanded(
                        child: ElevatedButton(
                            onPressed: () {
                              _validateForm();
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
