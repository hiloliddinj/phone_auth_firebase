import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phone_auth_firebase/screens/home_screen.dart';
import 'package:phone_auth_firebase/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';

///Example from ==> https://www.youtube.com/watch?v=W19IfZ-nqB8&ab_channel=EasyApproach
/// For firebase notification: https://www.youtube.com/watch?v=p7aIZ3aEi2w&ab_channel=EasyApproach

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const InitializerWidget(),
    );
  }
}


class InitializerWidget extends StatefulWidget {
  const InitializerWidget({Key? key}) : super(key: key);
  @override
  _InitializerWidgetState createState() => _InitializerWidgetState();
}

class _InitializerWidgetState extends State<InitializerWidget> {

  late FirebaseAuth _auth;
  User? _user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _user = _auth.currentUser;
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? const Center(child: CircularProgressIndicator(),) :
      _user == null ? const LoginScreen() : const HomeScreen(),
    );
  }
}


