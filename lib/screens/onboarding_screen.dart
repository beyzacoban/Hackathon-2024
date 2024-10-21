import 'package:flutter/material.dart';
import 'package:fancy_on_boarding/fancy_on_boarding.dart';

class OnboardingScreen extends StatelessWidget {
  final List<PageModel> pageList = [
    PageModel(
      color: const Color(0xFF678FB4),
      heroImagePath: 'lib/assets/hotels.png',
      title: Text('Hotels',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 34.0,
          )),
      body: Text(
        'All hotels and hostels are sorted by hospitality rating',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
      ),
      iconImagePath: 'lib/assets/key.png',
    ),
    PageModel(
      color: const Color(0xFF65B0B4),
      heroImagePath: 'lib/assets/banks.png',
      title: Text('Banks',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 34.0,
          )),
      body: Text(
        'We carefully verify all banks before adding them into the app',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
      ),
      iconImagePath: 'lib/assets/wallet.png',
    ),
    PageModel(
      color: const Color(0xFF9B90BC),
      heroImagePath: 'lib/assets/stores.png',
      title: Text('Store',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 34.0,
          )),
      body: Text(
        'All local stores are categorized for your convenience',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18.0,
        ),
      ),
      icon: Icon(
        Icons.shopping_cart,
        color: const Color(0xFF9B90BC),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FancyOnBoarding(
        doneButtonText: "Done",
        skipButtonText: "Skip",
        pageList: pageList,
        onDoneButtonPressed: () {
          Navigator.of(context).pushReplacementNamed('/home');
        },
        onSkipButtonPressed: () {
          Navigator.of(context).pushReplacementNamed('/home');
        },
      ),
    );
  }
}
