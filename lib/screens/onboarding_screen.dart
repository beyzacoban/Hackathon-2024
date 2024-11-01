import 'package:flutter/material.dart';
import 'package:fancy_on_boarding/fancy_on_boarding.dart';
import 'package:flutter_application/screens/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  final List<PageModel> pageList = [
    PageModel(
      color: const Color(0xFF678FB4),
      heroImagePath: 'lib/assets/images/book.png',
      title: const Text(
        'Sınav Asistanı',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.white,
          fontSize: 34.0,
        ),
      ),
      body: const Text(
        'Sınav hazırlığınızı daha etkili hale getirin! Planlama, hedef belirleme ve daha fazlası sizi bekliyor.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
      ),
      icon: const Icon(
        Icons.school,
        color: Colors.white,
        size: 37,
      ),
    ),
    PageModel(
      color: const Color(0xFF65B0B4),
      heroImagePath: 'lib/assets/images/banks.png',
      title: const Text(
        'Hedef Belirleme',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.white,
          fontSize: 34.0,
        ),
      ),
      body: const Text(
        'Başarıya ulaşmak için hedeflerinizi kolayca belirleyin ve takip edin.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
      ),
      icon: const Icon(
        Icons.flag,
        color: Colors.white,
        size: 37,
      ),
    ),
    PageModel(
      color: const Color(0xFF9B90BC),
      heroImagePath: 'lib/assets/images/stores.png',
      title: const Text(
        'Soru Sorun',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.white,
          fontSize: 34.0,
        ),
      ),
      body: const Text(
        'Aklınıza takılan soruları anında uzmanlarımıza sorun ve hızlı cevaplar alın.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
      ),
      icon: const Icon(
        Icons.help_outline,
        color: Colors.white,
        size: 37,
      ),
    ),
    PageModel(
      color: const Color(0xFF34A853),
      heroImagePath: 'lib/assets/images/stores.png',
      title: const Text(
        'Yapay Zeka Önerileri',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.white,
          fontSize: 34.0,
        ),
      ),
      body: const Text(
        'Yapay zeka destekli önerilerle en iyi çalışma yöntemlerinizi keşfedin ve sınav başarınızı artırın.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
      ),
      icon: const Icon(
        Icons.lightbulb_outline,
        color: Colors.white,
        size: 37,
      ),
    ),
    PageModel(
      color: const Color(0xFF0A73E0),
      heroImagePath: 'lib/assets/images/book.png',
      title: const Text(
        'Kayıt Olun',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: Colors.white,
          fontSize: 34.0,
        ),
      ),
      body: const Text(
        'Hemen kaydolun ve sınav asistanı ile sınav hazırlık yolculuğunuza başlayın.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
      ),
      icon: const Icon(
        Icons.person_add,
        color: Colors.white,
        size: 37,
      ),
    ),
  ];

  OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FancyOnBoarding(
        doneButtonText: "Başla",
        skipButtonText: "Atla",
        pageList: pageList,
        onDoneButtonPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        },
        onSkipButtonPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        },
      ),
    );
  }
}