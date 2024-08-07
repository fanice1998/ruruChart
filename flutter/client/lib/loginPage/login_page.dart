import 'package:client/homePage/home_page.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
  });

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
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
      // backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isRegistering ? 'R e g i s t e r' : 'L o g i n',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
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

  const SigninPage({
    required this.isRegistering,
    required this.onRegisterChanged,
    super.key,
  });

  @override
  SigninPageState createState() => SigninPageState();
}

class SigninPageState extends State<SigninPage> {
  final logger = Logger();
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscureText = true;

  @override
  void initState() {
    _accountController.text = "admin@example.com";
    _passwordController.text = "password";
    super.initState();
  }

  void _cleanController() {
    setState(() {
      _accountController.text = "";
      _passwordController.text = "";
      _emailController.text = "";
      _confirmPasswordController.text = "";
      _obscureText = true;
      logger.d(
          "Account: ${_accountController.text} \nPassword: ${_passwordController.text} \nEmail: ${_emailController.text} \n_ConfirmPassword: ${_confirmPasswordController.text}");
    });
  }

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool checkAccount(String account) {
    String accountPattern = r'^[a-zA-z0-9._%+-]+@[a-zA-z0-9.-]+\.[a-zA-z]{2,}$';
    RegExp regExp = RegExp(accountPattern);

    if (account.isEmpty) {
      logger.d("Account is empty");
      return false;
    } else if (account.length > 10 &&
        account.contains("@") &&
        regExp.hasMatch(account)) {
      return true;
    } else {
      return false;
    }
  }

  void login() {
    if (checkAccount(_accountController.text)) {
      logger.d("Login Access !!!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      logger.d(
        "Account: ${_accountController.text}\nPassword: ${_passwordController.text}",
      );
    }
  }

  void register() {
    logger.d(
        "Account: ${_accountController.text} \nPassword: ${_passwordController.text} \nEmail: ${_emailController.text} \nConfirmPassword: ${_confirmPasswordController.text}");
    if (_passwordController.text == _confirmPasswordController.text) {
      logger.d(
          "Password: ${_passwordController.text} \nConfirmPassword: ${_confirmPasswordController.text} \nConfirmPassword: true");
      // 進行註冊
    } else {
      // 請確認密碼是否正確
      logger.d(
          "Password: ${_passwordController.text} \nConfirmPassword: ${_confirmPasswordController.text} \nPlease check your password!!!");
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
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
          const SizedBox(height: 20),
          widget.isRegistering
              ?
              // RegisterContainer()
              Column(
                  children: [
                    const SizedBox(height: 10),
                    InputBoxContainer(
                        customIcon: const Icon(Icons.account_box),
                        labelText: "Account",
                        hintText: "Enter your account",
                        controller: _accountController),
                    InputBoxContainer(
                        customIcon: const Icon(Icons.email),
                        labelText: "Email",
                        hintText: "Enter your email",
                        controller: _emailController),
                    InputBoxContainer(
                      customIcon: const Icon(Icons.lock),
                      labelText: "Password",
                      hintText: "Enter your password",
                      isPassword: true,
                      controller: _passwordController,
                      obscureText: _obscureText,
                      onVisibilityToggle: _togglePasswordVisibility,
                    ),
                    InputBoxContainer(
                      customIcon: const Icon(Icons.password),
                      labelText: "Check password",
                      hintText: "Check your password",
                      isPassword: true,
                      controller: _confirmPasswordController,
                      obscureText: _obscureText,
                      onVisibilityToggle: _togglePasswordVisibility,
                    ),
                  ],
                )
              : Column(
                  children: [
                    const SizedBox(height: 10),
                    InputBoxContainer(
                      customIcon: const Icon(Icons.account_box),
                      labelText: "Account",
                      hintText: "Enter your username or email",
                      controller: _accountController,
                    ),
                    InputBoxContainer(
                      customIcon: const Icon(Icons.lock),
                      labelText: "Password",
                      hintText: "Enter your password",
                      isPassword: true,
                      controller: _passwordController,
                      obscureText: _obscureText,
                      onVisibilityToggle: _togglePasswordVisibility,
                    ),
                  ],
                ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                child: Text(widget.isRegistering ? 'Register' : 'Login'),
                onPressed: () {
                  widget.isRegistering ? register() : login();
                  // 在这里添加登录或注册逻辑
                },
              ),
              ElevatedButton(
                child: Text(widget.isRegistering
                    ? 'Switch to Login'
                    : 'Switch to Register'),
                onPressed: () {
                  _cleanController();
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

class InputBoxContainer extends StatelessWidget {
  final Widget customIcon;
  final String labelText;
  final String hintText;
  final bool isPassword;
  final bool obscureText;
  final TextEditingController? controller;
  final VoidCallback? onVisibilityToggle;

  const InputBoxContainer({
    super.key,
    required this.customIcon,
    required this.labelText,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.obscureText = false,
    this.onVisibilityToggle,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        icon: customIcon,
        labelText: labelText,
        hintText: hintText,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: onVisibilityToggle,
              )
            : null,
      ),
    );
  }
}
