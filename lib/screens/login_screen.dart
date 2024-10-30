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
  bool isLogin = true;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  String? errorMessage;
  bool isLoading = false; // Loading state

  Future<void> signIn() async {
    setState(() {
      isLoading = true;
    });
    try {
      await Auth().signIn(
        email: emailController.text,
        password: passwordController.text,
      );
      navigateToHomePage();
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.code == 'wrong-password'
            ? 'Your password is incorrect.'
            : e.code == 'user-not-found'
                ? 'No user found for that email.'
                : e.message;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> register() async {
    if (usernameController.text.isEmpty) {
      setState(() {
        errorMessage = 'Username is required.';
      });
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        errorMessage = 'Passwords do not match.';
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
      );
      setState(() {
        isLogin = true;
        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
        usernameController.clear();
        errorMessage = null;
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.code == 'weak-password'
            ? 'The password provided is too weak.'
            : e.message;
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
                  if (!isLogin)
                    buildTextField(
                      usernameController,
                      "Username",
                    ),
                  const SizedBox(height: 10),
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
                  if (!isLogin)
                    buildTextField(
                      confirmPasswordController,
                      "Confirm Password",
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
                            isConfirmPasswordVisible =
                                !isConfirmPasswordVisible;
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
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton(
                      onPressed: isLogin ? signIn : register,
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
        ],
      ),
    );
  }
}
