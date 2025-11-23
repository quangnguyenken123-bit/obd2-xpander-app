import 'package:app_chan_doan/menu_page.dart';
import 'package:app_chan_doan/sigup_page.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // ✅ COMMENT HOẶC XÓA DÒNG NÀY

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _errorMessage;

  // final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // ✅ COMMENT HOẶC XÓA DÒNG NÀY

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            // decoration: const BoxDecoration(
            //   image: DecorationImage(
            //     image: AssetImage("assets/images/login.png"),
            //     fit: BoxFit.cover,
            //   ),
            // ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    Center(
                      child: Image.asset(
                        'assets/images/logoBK.png',
                        width: 150,
                        height: 130,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text('HELLO!',
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                          labelText: 'Email', prefixIcon: Icon(Icons.email)),
                      validator: _validateEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                          labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                      validator: _validatePassword,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_errorMessage != null)
                          Expanded(
                            child: Text(_errorMessage!,
                                style: const TextStyle(
                                    color: Colors.redAccent, fontSize: 14),
                                textAlign: TextAlign.left),
                          ),
                        // ✅ COMMENT HOẶC XÓA PHẦN FORGOT PASSWORD NẾU KHÔNG CẦN
                        // TextButton(
                        //   onPressed: _sendPasswordResetEmail,
                        //   child: const Text(
                        //     'Forgot Password?',
                        //     style: TextStyle(fontWeight: FontWeight.bold),
                        //   ),
                        // ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: _attemptLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 9, 9, 9),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Sign In',
                          style: TextStyle(color: Colors.white)),
                    ),
                    // ✅ COMMENT HOẶC XÓA PHẦN SIGN UP NẾU KHÔNG CẦN
                    // TextButton(
                    //   onPressed: () => Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (context) => SignUpPage())),
                    //   child: const Text('No account? Sign up here',
                    //       style: TextStyle(
                    //           fontFamily: 'Times',
                    //           fontWeight: FontWeight.bold)),
                    // ),

                    // 🆕 THÊM NÚT LOGIN NHANH (OPTIONAL)
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: _quickLogin,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        side: const BorderSide(color: Colors.black),
                      ),
                      child: const Text('Quick Login (No Verification)',
                          style: TextStyle(color: Colors.black)),
                    ),

                    const SizedBox(height: 10),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    // ✅ GIẢM BỚT VALIDATION STRICT
    if (!value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _attemptLogin() {
    if (_formKey.currentState!.validate()) {
      _login();
    }
  }

  void _login() async {
    try {
      // ✅ SIMPLE LOGIN - KHÔNG CẦN FIREBASE
      String email = _emailController.text.trim();
      String password = _passwordController.text;

      // 🔥 OPTION 1: CHO PHÉP LOGIN VỚI BẤT KỲ EMAIL/PASSWORD NÀO (với password >= 6 ký tự)
      if (password.length >= 6) {
        _navigateToMenu();
      } else {
        setState(() {
          _errorMessage = 'Password must be at least 6 characters';
        });
      }

      // 🔥 OPTION 2: LOGIN VỚI EMAIL/PASSWORD CỐ ĐỊNH (Bỏ comment để dùng)
      /*
      const String defaultEmail = "admin@obd.com";
      const String defaultPassword = "123456";

      if (email == defaultEmail && password == defaultPassword) {
        _navigateToMenu();
      } else {
        setState(() {
          _errorMessage = 'Incorrect email or password\n\nTry:\nEmail: admin@obd.com\nPassword: 123456';
        });
      }
      */

    } catch (e) {
      setState(() {
        _errorMessage = 'Login error: $e';
      });
    }
  }

  // 🆕 HÀM LOGIN NHANH KHÔNG CẦN NHẬP GÌ
  void _quickLogin() {
    _navigateToMenu();
  }

  // HÀM ĐIỀU HƯỚNG VÀO MENU
  void _navigateToMenu() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MenuPage())
    );
  }

  // ✅ COMMENT HOẶC XÓA PHẦN RESET PASSWORD
  /*
  void _sendPasswordResetEmail() async {
    String email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _errorMessage =
            "Please enter your email address to reset your password.";
      });
      return;
    }
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      setState(() {
        _errorMessage =
            "Password reset email sent. Check your email to reset your password.";
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error sending password reset email: ${e.toString()}";
      });
    }
  }
  */

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}