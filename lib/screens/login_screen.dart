import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/service/auth.dart'; // Auth sınıfında Google Sign-In eklemeniz gerekecek
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLogin = true;
  bool isPasswordVisible = false;
  String? errorMessage;

  Future<void> signIn() async {
    try {
      await Auth().signIn(
        email: emailController.text,
        password: passwordController.text,
      );
      navigateToHomePage();
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> register() async {
    try {
      await Auth().createUser(
        email: emailController.text,
        password: passwordController.text,
      );
      navigateToHomePage();
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await Auth().signInWithGoogle(); // Auth sınıfında bu metodu tanımlayın
      navigateToHomePage();
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  void navigateToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  void toggleLoginRegister() {
    setState(() {
      isLogin = !isLogin;
      emailController.clear();
      passwordController.clear();
      errorMessage = null;
    });
  }

  Widget buildTextField(
    TextEditingController controller,
    String hintText, {
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.5),
        suffixIcon: suffixIcon,
      ),
      style: const TextStyle(color: Colors.black),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.white.withOpacity(0.6)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    isLogin ? 'Welcome Back!' : 'Create an Account',
                    style: const TextStyle(fontSize: 30, color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  buildTextField(emailController, "Email"),
                  const SizedBox(height: 10),
                  buildTextField(
                    passwordController,
                    "Password",
                    obscureText: !isPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (errorMessage != null)
                    Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed:
                        isLogin ? signIn : register, // Kayıt ve giriş işlemleri
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(isLogin ? 'Login' : 'Register'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: toggleLoginRegister,
                    child: Text(
                      isLogin
                          ? 'Create an Account'
                          : 'Already have an account? Login',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: signInWithGoogle, // Google ile giriş fonksiyonu
                    child: Image.asset(
                      'lib/assets/google.png', // Google logosu
                      width: 50,
                      height: 50,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
