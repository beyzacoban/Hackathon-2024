import 'package:flutter/material.dart';
import 'package:flutter_application/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final List<Map<String, String>> onboardingData = [
    {
      "title": "Sınav Asistanı",
      "body":
          "Sınav hazırlığınızı daha etkili hale getirin! Planlama, hedef belirleme ve daha fazlası sizi bekliyor.",
      "icon": "school"
    },
    {
      "title": "Hedef Belirleme",
      "body":
          "Başarıya ulaşmak için hedeflerinizi kolayca belirleyin ve takip edin.",
      "icon": "flag"
    },
    {
      "title": "Soru Sorun",
      "body":
          "Aklınıza takılan soruları anında yapay zekaya sorun ve hızlı cevaplar alın.",
      "icon": "help_outline"
    },
    {
      "title": "Yapay Zeka Önerileri",
      "body":
          "Yapay zeka destekli önerilerle en iyi çalışma yöntemlerinizi keşfedin ve sınav başarınızı artırın.",
      "icon": "lightbulb_outline"
    },
    {
      "title": "Kayıt Olun",
      "body":
          "Hemen kaydolun ve sınav asistanı ile sınav hazırlık yolculuğunuza başlayın.",
      "icon": "person_add"
    },
  ];

  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: onboardingData.length,
        itemBuilder: (context, index) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: index.isEven
                  ? const Color(0xFF678FB4)
                  : const Color(0xFF65B0B4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                AnimatedOpacity(
                  opacity: _currentPage == index ? 1 : 0.5,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    _getIconData(onboardingData[index]["icon"]),
                    color: Colors.white,
                    size: 70,
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedOpacity(
                  opacity: _currentPage == index ? 1 : 0.5,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    onboardingData[index]["title"]!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontSize: 34.0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedOpacity(
                  opacity: _currentPage == index ? 1 : 0.5,
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    onboardingData[index]["body"]!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
            color: _currentPage.isEven
                ? const Color(0xFF678FB4)
                : const Color(0xFF65B0B4),
            border:
                const Border(top: BorderSide(color: Colors.white, width: 2))),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text(
                  "Atla",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              _buildPageIndicator(),
              TextButton(
                onPressed: _goToNextPage,
                child: const Text(
                  "İleri",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      children: List.generate(onboardingData.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          width: 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            color: _currentPage == index ? Colors.white : Colors.grey,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case "school":
        return Icons.school;
      case "flag":
        return Icons.flag;
      case "help_outline":
        return Icons.help_outline;
      case "lightbulb_outline":
        return Icons.lightbulb_outline;
      case "person_add":
        return Icons.person_add;
      default:
        return Icons.help; // fallback icon
    }
  }
}
