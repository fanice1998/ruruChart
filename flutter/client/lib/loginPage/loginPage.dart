import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isRegistering = false;
  final logger = Logger();

  void _toggleRegister(bool value) {
    setState(() {
      _isRegistering = value;
      logger.d("Register mode changed to: $_isRegistering");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isRegistering ? 'Register Mode' : 'Login Mode',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                SigninPage(
                  isRegistering: _isRegistering,
                  onRegisterChanged: _toggleRegister,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SigninPage extends StatefulWidget {
  final bool isRegistering;
  final ValueChanged<bool> onRegisterChanged;

  SigninPage({required this.isRegistering, required this.onRegisterChanged});

  @override
  _SigninPageState createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final logger = Logger();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.message_outlined,
            size: 80,
            color: Colors.grey.shade800,
          ),
          SizedBox(height: 20),
          TextField(
            controller: _accountController,
            decoration: InputDecoration(
              icon: Icon(Icons.account_box),
              labelText: 'Account',
              hintText: 'Enter your username or email',
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _passwordController,
            obscureText: _obscureText,
            decoration: InputDecoration(
              icon: Icon(Icons.lock),
              labelText: 'Password',
              hintText: 'Enter your password',
              suffixIcon: IconButton(
                icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              ),
            ),
            keyboardType: TextInputType.visiblePassword,
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                child: Text(widget.isRegistering ? 'Register' : 'Login'),
                onPressed: () {
                  logger.d("Account: ${_accountController.text}");
                  logger.d("Password: ${_passwordController.text}");
                  // 在这里添加登录或注册逻辑
                },
              ),
              ElevatedButton(
                child: Text(widget.isRegistering
                    ? 'Switch to Login'
                    : 'Switch to Register'),
                onPressed: () {
                  widget.onRegisterChanged(!widget.isRegistering);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
