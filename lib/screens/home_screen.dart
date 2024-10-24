import 'package:flutter/material.dart';
import 'package:flutter_application/screens/plan_screen.dart';
import 'package:flutter_application/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "STUDY",
            style: TextStyle(
              fontFamily: 'KitaharaBrush',
              fontSize: 36,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.blueGrey[100],
          leading: Builder(builder: (context) {
            return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(Icons.menu));
          }),
        ),
        drawer: Drawer(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 10,
                width: MediaQuery.of(context).size.width,
                color: Colors.black,
                child: const Center(
                  child: Text(
                    "STUDY",
                    style: TextStyle(
                      fontFamily: 'KitaharaBrush',
                      fontSize: 36,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      title: const Text(
                        "Planım",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      leading: const Icon(Icons.calendar_month_outlined),
                      onTap: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PlanScreen(),
                            ))
                      },
                    ),
                    const ListTile(
                      title: Text(
                        "Kitaplığım",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      leading: Icon(Icons.library_books_sharp),
                    ),
                    ListTile(
                      title: const Text(
                        "Ayarlar",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      leading: const Icon(Icons.settings),
                      onTap: () => {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ))
                      },
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        body: ListView(
          scrollDirection: Axis.vertical,
          
        ),
      ),
    );
  }
}
