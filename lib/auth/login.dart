import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isLoading = false;
  String? message;

  /// Signs a user up with a username, password, and email. The required
  /// attributes may be different depending on your app's configuration.
  Future<void> signUpUser({
    required String username,
    required String password,
    required String email,
    String? phoneNumber,
  }) async {
    try {
      setState(() {
        isLoading = true;
        message = null;
      });
      final userAttributes = {
        AuthUserAttributeKey.email: email,
        if (phoneNumber != null) AuthUserAttributeKey.phoneNumber: phoneNumber,
        // additional attributes as needed
      };
      final result = await Amplify.Auth.signUp(
        username: username,
        password: password,
        options: SignUpOptions(
          userAttributes: userAttributes,
        ),
      );
      await _handleSignUpResult(result);
    } on AuthException catch (e) {
      setState(() {
        isLoading = false;
        message = e.message;
      });
      safePrint('Error signing up user: ${e.message}');
    }
  }

  Future<void> _handleSignUpResult(SignUpResult result) async {
    switch (result.nextStep.signUpStep) {
      case AuthSignUpStep.confirmSignUp:
        final codeDeliveryDetails = result.nextStep.codeDeliveryDetails!;
        _handleCodeDelivery(codeDeliveryDetails);
        break;
      case AuthSignUpStep.done:
        safePrint('Sign up is complete');
        break;
    }
  }

  void _handleCodeDelivery(AuthCodeDeliveryDetails codeDeliveryDetails) {
    safePrint(
      'A confirmation code has been sent to ${codeDeliveryDetails.destination}. '
      'Please check your ${codeDeliveryDetails.deliveryMedium.name} for the code.',
    );
    setState(() {
      isLoading = false;
    });
  }

  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _key,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Text(
                    "Sign up",
                    style: TextStyle(fontSize: 30),
                  ),
                  SizedBox(height: 10),
                  // TextFormField(
                  //   controller: usernameController,
                  //   validator: (val) {
                  //     if (val == null || val.isEmpty) return 'username is required';
                  //     return null;
                  //   },
                  //   decoration: InputDecoration(hintText: "User name"),
                  // ),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController,
                    decoration: InputDecoration(hintText: "Email"),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'email is required';
                      return null;
                    },
                  ),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(hintText: "Password"),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'password is required';
                      return null;
                    },
                    controller: passwordController,
                  ),
                  if (message != null)
                    Text(
                      message!,
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        message = null;
                      });
                      if (_key.currentState!.validate()) {
                        signUpUser(
                          username: emailController.text.trim(),
                          password: passwordController.text.trim(),
                          email: emailController.text.trim(),
                        );
                      }
                    },
                    child: isLoading ? Transform.scale(scale: 0.6, child: CircularProgressIndicator()) : Text("Signup"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
