import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Deneme {
  String tur;
  String ders;
  int dogru;
  int yanlis;
  int bos;
  double? net;

  Deneme({
    required this.tur,
    required this.ders,
    required this.dogru,
    required this.yanlis,
    required this.bos,
    this.net,
  });
}

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  List<Deneme> denemeler = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? secilenTur;
  final List<String> turler = ['TYT', 'AYT', 'Branş'];
  final List<String> dersler = [
    'Türkçe/Edebiyat',
    'Matematik',
    'Fen Bilimleri',
    'Sosyal Bilgiler'
  ];
  List<TextEditingController> dogruControllers = [];
  List<TextEditingController> yanlisControllers = [];
  List<TextEditingController> bosControllers = [];
  Future<void> kaydetDenemeler() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> denemeListesiJson = denemeler.map((deneme) {
      return jsonEncode({
        'tur': deneme.tur,
        'ders': deneme.ders,
        'dogru': deneme.dogru,
        'yanlis': deneme.yanlis,
        'bos': deneme.bos,
        'net': deneme.net,
      });
    }).toList();
    await prefs.setStringList('denemeler', denemeListesiJson);
  }

  Future<void> denemeleriYukle() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? denemeListesiJson = prefs.getStringList('denemeler');
    if (denemeListesiJson != null) {
      denemeler = denemeListesiJson.map((jsonStr) {
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        return Deneme(
          tur: data['tur'],
          ders: data['ders'],
          dogru: data['dogru'],
          yanlis: data['yanlis'],
          bos: data['bos'],
          net: data['net'],
        );
      }).toList();
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    denemeleriYukle();
  }

  void _showDenemePanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              top: 16.0,
              left: 16.0,
              right: 16.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
            ),
            child: Form(
              key: _formKey,
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration:
                            const InputDecoration(labelText: 'Deneme Türü'),
                        items: turler.map((tur) {
                          return DropdownMenuItem(
                            value: tur,
                            child: Text(tur),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            secilenTur = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Deneme türü seçmelisiniz.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: dersler.length,
                        itemBuilder: (context, index) {
                          dogruControllers.add(TextEditingController());
                          yanlisControllers.add(TextEditingController());
                          bosControllers.add(TextEditingController());

                          return Column(
                            children: [
                              Text(
                                dersler[index],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextFormField(
                                controller: dogruControllers[index],
                                decoration:
                                    const InputDecoration(labelText: 'Doğru'),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Doğru sayısı boş olamaz.';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: yanlisControllers[index],
                                decoration:
                                    const InputDecoration(labelText: 'Yanlış'),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Yanlış sayısı boş olamaz.';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: bosControllers[index],
                                decoration:
                                    const InputDecoration(labelText: 'Boş'),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Boş sayısı boş olamaz.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            int toplamDogru = 0;
                            int toplamYanlis = 0;

                            for (int i = 0; i < dersler.length; i++) {
                              toplamDogru +=
                                  int.parse(dogruControllers[i].text);
                              toplamYanlis +=
                                  int.parse(yanlisControllers[i].text);
                            }

                            double toplamNet =
                                hesaplaNet(toplamDogru, toplamYanlis);

                            denemeler.add(Deneme(
                              tur: secilenTur!,
                              ders: 'Toplam',
                              dogru: toplamDogru,
                              yanlis: toplamYanlis,
                              bos: 0,
                              net: toplamNet,
                            ));
                            kaydetDenemeler();
                            Navigator.pop(context);
                            setState(() {});
                          }
                        },
                        child: const Text('Kaydet'),
                      ),
                    ],
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDetaylarPanel(BuildContext context, Map<String, dynamic> deneme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Deneme: ${deneme['tur']}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 16),
              ...deneme['dersBilgileri'].map<Widget>((ders) {
                return ListTile(
                  title: Text("${ders['ad']}"),
                  subtitle: Text(
                      "Doğru: ${ders['dogru']}, Yanlış: ${ders['yanlis']}, Boş: ${ders['bos']}"),
                );
              }).toList(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Kapat"),
              ),
            ],
          ),
        );
      },
    );
  }

  double hesaplaNet(int dogru, int yanlis) {
    return dogru - (yanlis * 0.25);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: const Text(
              "DENEMELERİM",
              style: TextStyle(
                  fontFamily: 'Lorjuk',
                  fontWeight: FontWeight.bold,
                  fontSize: 30),
            ),
            centerTitle: true,
            backgroundColor: Colors.blueGrey[300],
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back)),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showDenemePanel,
            backgroundColor: Colors.blueGrey[300],
            child: const Icon(Icons.add),
          ),
          body: ListView.builder(
            itemCount: denemeler.length,
            itemBuilder: (context, index) {
              final deneme = denemeler[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Deneme Türü: ${deneme.tur}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                          'Net: ${deneme.net?.toStringAsFixed(2) ?? 'Hesaplanmadı'}'), // Net bilgisini gösterir
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
