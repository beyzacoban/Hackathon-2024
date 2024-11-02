import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/screens/navigationbar_screen.dart';
import 'package:flutter_application/service/auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  bool isLogin = true;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  String? errorMessage;
  bool isLoading = false;
  Future<void> signIn() async {
    try {
      await Auth().signIn(
        email: emailController.text,
        password: passwordController.text,
      );
      navigateToHomePage();
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = "E-posta veya şifre yanlış.";
      });
    }
    if (emailController.text.isEmpty) {
      setState(() {
        errorMessage = 'E-posta gerekli.';
        isLoading = false;
      });
      return;
    }

    if (passwordController.text.isEmpty) {
      setState(() {
        errorMessage = 'Şifre gerekli.';
        isLoading = false;
      });
      return;
    }
  }

  Future<void> register() async {
    if (usernameController.text.isEmpty) {
      setState(() {
        errorMessage = 'Kullanıcı adı gerekli.';
      });
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        errorMessage = 'Şifreler eşleşmiyor.';
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await Auth().createUser(
        email: emailController.text,
        password: passwordController.text,
        username: usernameController.text,
        name: nameController.text,
      );
      setState(() {
        isLogin = true;
        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
        usernameController.clear();
        nameController.clear();
        errorMessage = null;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage =
            e.code == 'weak-password' ? 'Verilen şifre çok zayıf.' : e.message;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> signInWithGoogle() async {
    setState(() {
      isLoading = true;
    });
    try {
      final user = await Auth().signInWithGoogle();
      if (user != null) {
        navigateToHomePage();
      }
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void navigateToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const NavigationbarScreen()),
    );
  }

  void toggleLoginRegister() {
    setState(() {
      isLogin = !isLogin;
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      usernameController.clear();
      errorMessage = null;
    });
  }

  Widget buildTextField(
    TextEditingController controller,
    String hintText, {
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          suffixIcon: suffixIcon,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        style: const TextStyle(
            color: Colors.black, fontSize: 18), // Increased font size
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ Color(0xFF678FB4),Color(0xFF65B0B4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isLogin ? 'Hoş Geldiniz!' : 'Bir Hesap Oluşturun!',
                  style: const TextStyle(
                    fontSize: 34, // Increased font size for title
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                if (!isLogin) ...[
                  buildTextField(usernameController, "Kullanıcı Adı"),
                  buildTextField(nameController, "Ad"),
                ],
                buildTextField(emailController, "E-posta"),
                buildTextField(
                  passwordController,
                  "Şifre",
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
                if (!isLogin)
                  buildTextField(
                    confirmPasswordController,
                    "Şifreyi Onayla",
                    obscureText: !isConfirmPasswordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          isConfirmPasswordVisible = !isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                const SizedBox(height: 20),
                if (errorMessage != null)
                  Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18), // Increased font size for error message
                  ),
                const SizedBox(height: 20),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: isLogin ? signIn : register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFF65B0B4),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    child: Text(
                      isLogin ? 'Giriş Yap' : 'Kaydol',
                      style: const TextStyle(
                          fontSize: 18), // Increased font size for button text
                    ),
                  ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: toggleLoginRegister,
                  child: Text(
                    isLogin
                        ? 'Bir Hesap Oluştur'
                        : 'Zaten bir hesabınız var mı? Giriş yapın',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16), // Increased font size for button text
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: signInWithGoogle,
                  child: Image.asset(
                    'lib/assets/images/google.png',
                    width: 50,
                    height: 50,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
