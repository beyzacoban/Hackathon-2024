import 'package:flutter/material.dart';
import 'package:fancy_on_boarding/fancy_on_boarding.dart';
import 'package:flutter_application/screens/login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  final List<PageModel> pageList = [
    PageModel(
      color: const Color(0xFF678FB4),
      heroImagePath: 'lib/assets/icons/hotels.png',
      title: const Text('Sınav Asistanı',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 34.0,
          )),
      body: const Text(
        'Sınav hazırlığınızı daha etkili hale getirin!',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
      ),
      iconImagePath: 'lib/assets/icons/key.png',
    ),
    PageModel(
      color: const Color(0xFF65B0B4),
      heroImagePath: 'lib/assets/icons/banks.png',
      title: const Text('Hedef Belirleme',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 34.0,
          )),
      body:const  Text(
        'Hedeflerinizi belirleyerek başarılı bir sınav dönemi geçirin.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
      ),
      iconImagePath: 'lib/assets/icons/wallet.png',
    ),
    PageModel(
      color: const Color(0xFF9B90BC),
      heroImagePath: 'lib/assets/icons/stores.png',
      title: const Text('Soru Sorun',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 34.0,
          )),
      body: const Text(
        'Herhangi bir sorunuz mu var? Uzmanlarımızdan anında cevap alın.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
      ),
      icon: const Icon(
        Icons.question_answer,
        color:  Color(0xFF9B90BC),
      ),
    ),
    PageModel(
      color: const Color(0xFF34A853),
      heroImagePath: 'lib/assets/icons/stores.png',
      title: const Text('Yapay Zeka Önerileri',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 34.0,
          )),
      body: const Text(
        'Yapay zeka destekli önerilerle en iyi çalışma yöntemlerinizi bulun.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
      ),
      icon: const Icon(
        Icons.lightbulb,
        color: Color(0xFF34A853),
      ),
    ),
  ];

   OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FancyOnBoarding(
        doneButtonText: "Tamam",
        skipButtonText: "Atla",
        pageList: pageList,
        onDoneButtonPressed: () {
          // Onboarding tamamlandığında Login ekranına yönlendir
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(),
            ),
          );
        },
        onSkipButtonPressed: () {
          // Skip butonuna basıldığında Login ekranına yönlendir
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
