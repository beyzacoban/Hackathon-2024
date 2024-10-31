import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final Map<String, List<Map<String, dynamic>>> taskLists = {
    "1": [],
    "2": [],
    "3": [],
    "4": [],
    "5": [],
    "6": [],
    "7": [],
  };

  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  // Görevleri kaydetme fonksiyonu
  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final taskJson = jsonEncode(taskLists); // Görev listesini JSON'a çevir
    await prefs.setString('taskLists', taskJson); // JSON'u kaydet
  }

  // Görevleri yükleme fonksiyonu
  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? taskJson = prefs.getString('taskLists');
    if (taskJson != null) {
      setState(() {
        taskLists.clear();
        taskLists.addAll(Map<String, List<Map<String, dynamic>>>.from(
          jsonDecode(taskJson).map((key, value) =>
              MapEntry(key, List<Map<String, dynamic>>.from(value))),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            title: const Text(
              "PLAN HARİTAM",
              style: TextStyle(
                fontFamily: 'Lorjuk',
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.blueGrey[100],
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back)),
          ),
          body: Stack(
            children: [
              Image.asset(
                'lib/assets/images/mapImage.jpg',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              buildButton(context, 0.6, 0.9, "1"),
              buildButton(context, 0.35, 0.73, "2"),
              buildButton(context, 0.25, 0.53, "3"),
              buildButton(context, 0.3, 0.35, "4"),
              buildButton(context, 0.58, 0.27, "5"),
              buildButton(context, 0.65, 0.12, "6"),
              buildButton(context, 0.41, 0.02, "7"),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildButton(BuildContext context, double x, double y, String label) {
    return Align(
      alignment: FractionalOffset(x, y),
      child: GestureDetector(
        onTap: () {
          showTaskModal(context, label);
        },
        child: CircleAvatar(
          radius: 25,
          backgroundColor: Colors.blueGrey,
          child: Text(label),
        ),
      ),
    );
  }

  void showTaskModal(BuildContext context, String label) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Stack(
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 32),
                      Text(
                        "Görev $label",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: taskLists[label]?.length ?? 0,
                          itemBuilder: (context, index) {
                            final task = taskLists[label]![index];
                            return Row(
                              children: [
                                Checkbox(
                                  value: task['isCompleted'],
                                  onChanged: (bool? value) {
                                    setModalState(() {
                                      task['isCompleted'] = value ?? false;
                                    });
                                    saveTasks(); // Durumu kaydet
                                  },
                                ),
                                Expanded(
                                  child: Text(task['name']),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setModalState(() {
                                      taskLists[label]?.removeAt(index);
                                    });
                                    saveTasks(); // Görevi sildiğinde kaydet
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      TextField(
                        controller: _taskController,
                        decoration:
                            const InputDecoration(hintText: "Görev adı"),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (_taskController.text.isNotEmpty) {
                            setModalState(() {
                              taskLists[label]?.add({
                                'name': _taskController.text,
                                'isCompleted': false,
                              });
                              _taskController.clear();
                            });
                            saveTasks(); // Yeni görev eklenince kaydet
                          }
                        },
                        child: const Text("Ekle"),
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
            );
          },
        );
      },
    );
  }
}
