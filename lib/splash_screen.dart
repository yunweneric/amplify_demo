import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final subscription = Amplify.Hub.listen(HubChannel.Auth, (AuthHubEvent event) {
    switch (event.type) {
      case AuthHubEventType.signedIn:
        safePrint('User is signed in.');
        break;
      case AuthHubEventType.signedOut:
        safePrint('User is signed out.');
        break;
      case AuthHubEventType.sessionExpired:
        safePrint('The session has expired.');
        break;
      case AuthHubEventType.userDeleted:
        safePrint('The user has been deleted.');
        break;
    }
  });

  Future<void> fetchCognitoAuthSession() async {
    try {
      final cognitoPlugin = Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
      final result = await cognitoPlugin.fetchAuthSession();
      final identityId = result.identityIdResult.value;
      safePrint(result.toJson());

      if (result.isSignedIn) {
        Navigator.pushNamed(context, "/todos");
      }
      safePrint("Current user's identity ID: $identityId");
    } on AuthException catch (e) {
      safePrint('Error retrieving auth session: ${e.message}');
    }
  }

  @override
  void initState() {
    fetchCognitoAuthSession();
    subscription.onData((data) {
      safePrint(data.payload?.toJson());
    });
    super.initState();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}
