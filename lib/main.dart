import 'package:flutter/material.dart';

import 'package:amplify_flutter/amplify.dart';
import 'package:amplify_analytics_pinpoint/amplify_analytics_pinpoint.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

import './amplifyconfiguration.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _confirmationController = TextEditingController();
  //late TextEditingController _usernameController;
  //late TextEditingController _passwordController;

  @override
  initState() {
    super.initState();
    _configureAmplify();
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  void _configureAmplify() async {
    //add pinpoint and analytics plugins and any others
    AmplifyAnalyticsPinpoint analyticsPlugin = AmplifyAnalyticsPinpoint();
    AmplifyAuthCognito authPlugin = AmplifyAuthCognito();
    await Amplify.addPlugins([authPlugin, analyticsPlugin]);

    //once plugins are added, configure Amplify()
    //Note: Amplify can only be configured once
    try {
      await Amplify.configure(amplifyconfig);
    } on AmplifyAlreadyConfiguredException {
      print(
          'tried to reconfigure amplify, this can occur when your app restarts on Android');
    }
  }

  bool isSignUpComplete = false;
  bool isSignedIn = false;

  void _signUpDemoUser() async {
    try {
      Map<String, String> userAttributes = {
        'email': 'nobu.kim66@gmail.com',
        //'phone': '+16661234567',
      };
      SignUpResult res = await Amplify.Auth.signUp(
        username: 'nobu.kim66@gmail.com',
        password: 'Password123!',
        options: CognitoSignUpOptions(userAttributes: userAttributes),
      );
      setState(() {
        isSignUpComplete = res.isSignUpComplete;
      });
    } on AuthException catch (e) {
      print(e.message);
    }
  }

  void _confirmSignUp({String? confirmCode}) async {
    try {
      SignUpResult res = await Amplify.Auth.confirmSignUp(
          username: 'nobu.kim66@gmail.com',
          confirmationCode: confirmCode ?? 'dummy');
      setState(() {
        isSignUpComplete = res.isSignUpComplete;
      });
      //return true;
    } on AuthException catch (e) {
      print(e.message);
      //return false;
    }
  }

  void _signOut() async {
    try {
      SignOutResult res = await Amplify.Auth.signOut();
      setState(() {
        isSignedIn = !isSignedIn;
      });
    } on AuthException catch (e) {
      print(e.message);
    }
  }

  void _signInUser() async {
    try {
      SignInResult res = await Amplify.Auth.signIn(
        username: 'nobu.kim66@gmail.com', //_usernameController.text.trim(),
        password: 'Password123!', //_passwordController.text.trim(),
      );
      dynamic awsCredentials = await Amplify.Auth.getCurrentUser();
      print(awsCredentials.toString());
      setState(() {
        isSignedIn = res.isSignedIn;
      });
    } on AuthException catch (e) {
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'amplify auth example from https://docs.amplify.aws/lib/auth/signin/q/platform/flutter/#prerequisites:',
            ),
            ElevatedButton(
              onPressed: _signUpDemoUser,
              child: Text('signUpDemoUser'),
            ),
            TextField(
              controller: _confirmationController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'check email for code'),
              onSubmitted: (String value) async {
                await showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    _confirmSignUp(confirmCode: value);
                    return AlertDialog(
                      content: const Text('check console'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('ok'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ElevatedButton(
              onPressed: _signOut,
              child: Text('signOut'),
            ),
            ElevatedButton(
              onPressed: _signInUser,
              child: Text('sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
