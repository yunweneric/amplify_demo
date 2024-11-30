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
            child: Column(
              children: [
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(hintText: "User name"),
                ),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(hintText: "Email"),
                ),
                TextFormField(
                  decoration: InputDecoration(hintText: "Password"),
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
                    if (_key.currentState!.validate()) {
                      signUpUser(
                        username: usernameController.text.trim(),
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
    );
  }
}
