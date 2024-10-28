[1mdiff --cc android/app/build.gradle[m
[1mindex 2ce5a21,2fbdab9..0000000[m
[1m--- a/android/app/build.gradle[m
[1m+++ b/android/app/build.gradle[m
[36m@@@ -65,13 -65,10 +65,18 @@@[m [mandroid [m
      }[m
      buildTypes {[m
          release {[m
[32m +          [m
[32m +            signingConfig = signingConfigs.release[m
[32m +        }[m
[32m +        debug {[m
              // TODO: Add your own signing config for the release build.[m
              // Signing with the debug keys for now,[m
[32m++<<<<<<< Updated upstream[m
[32m +            // so `flutter run --release` works.[m
[32m++=======[m
[32m+             // so flutter run --release works.[m
[32m+             signingConfig = signingConfigs.debug[m
[32m++>>>>>>> Stashed changes[m
              signingConfig = signingConfigs.release[m
          }[m
      }}[m
[1mdiff --cc lib/assets/images/tree.png[m
[1mindex 1048cf7,d46d433..0000000[m
Binary files differ
[1mdiff --cc lib/main.dart[m
[1mindex 2ce30d3,cb9c9f3..0000000[m
[1m--- a/lib/main.dart[m
[1m+++ b/lib/main.dart[m
[36m@@@ -1,12 -1,9 +1,9 @@@[m
  import 'package:flutter/material.dart';[m
[31m- import 'package:flutter_application/screens/navigationbar_screen.dart';[m
[31m -import 'package:flutter_application/screens/login_screen.dart';[m
[32m +[m
[32m+ import 'package:flutter_application/screens/navigationbar_screen.dart';[m
  import 'package:firebase_core/firebase_core.dart';[m
[31m--import 'package:flutter_application/screens/onboarding_screen.dart';[m
[31m- import 'firebase_options.dart';[m
[31m- import 'screens/home_screen.dart';[m
[31m- import 'screens/login_screen.dart';[m
[32m +[m
[32m+ import 'firebase_options.dart';[m
  [m
  Future<void> main() async {[m
    WidgetsFlutterBinding.ensureInitialized();[m
[1mdiff --cc lib/screens/login_screen.dart[m
[1mindex f08f07b,ee7b8d0..0000000[m
[1m--- a/lib/screens/login_screen.dart[m
[1m+++ b/lib/screens/login_screen.dart[m
[36m@@@ -1,7 -1,8 +1,8 @@@[m
  import 'package:firebase_auth/firebase_auth.dart';[m
  import 'package:flutter/material.dart';[m
[31m- import 'package:flutter_application/service/auth.dart';[m
[31m- import 'home_screen.dart';[m
[32m+ import 'package:flutter_application/screens/navigationbar_screen.dart';[m
[32m+ import 'package:flutter_application/service/auth.dart'; // Auth sınıfında Google Sign-In eklemeniz gerekecek[m
[31m -import 'home_screen.dart';[m
[32m++[m
  [m
  class LoginScreen extends StatefulWidget {[m
    const LoginScreen({super.key});[m
[36m@@@ -166,9 -167,9 +167,9 @@@[m [mclass _LoginScreen extends State<LoginS[m
                    ),[m
                    const SizedBox(height: 10),[m
                    GestureDetector([m
[31m -                    onTap: signInWithGoogle, // Google ile giriş fonksiyonu[m
[32m +                    onTap: signInWithGoogle,[m
                      child: Image.asset([m
[31m-                       'lib/assets/images/google.png',[m
[32m+                       'lib/assets/images/google.png', // Google logosu[m
                        width: 50,[m
                        height: 50,[m
                      ),[m
[1mdiff --cc lib/screens/navigationbar_screen.dart[m
[1mindex f6c0478,d1e6908..0000000[m
[1m--- a/lib/screens/navigationbar_screen.dart[m
[1m+++ b/lib/screens/navigationbar_screen.dart[m
[1mdiff --cc pubspec.lock[m
[1mindex e98a374,f685da7..0000000[m
[1m--- a/pubspec.lock[m
[1m+++ b/pubspec.lock[m
[1mdiff --cc pubspec.yaml[m
[1mindex 7f5b223,1b6ca42..0000000[m
[1m--- a/pubspec.yaml[m
[1m+++ b/pubspec.yaml[m
[36m@@@ -40,6 -42,10 +42,10 @@@[m [mflutter[m
   [m
    [m
    fonts:[m
[31m-     - family: KitaharaBrush [m
[32m+     - family: KitaharaBrush  # Font ailesinin adı[m
        fonts:[m
[31m-         - asset: lib/assets/fonts/KitaharaBrushScript.ttf [m
[32m+         - asset: lib/assets/fonts/KitaharaBrushScript.ttf  # Font dosyasının yolu[m
[32m+     - family: Lorjuk[m
[32m+       fonts: [m
[32m+         - asset: li