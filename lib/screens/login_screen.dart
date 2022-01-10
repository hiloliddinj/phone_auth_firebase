import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:phone_auth_firebase/screens/home_screen.dart';

enum MobileVerificationState {
  showMobilePhoneState,
  showOtpFormState,
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var currentState = MobileVerificationState.showMobilePhoneState;

  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool showLoading = false;

  String verificationId = '';

  signInWithPhoneAuthCredential(PhoneAuthCredential phoneAuthCredential) async {

    setState(() {
      showLoading = true;
    });

    try {
      final authCredential = await _auth.signInWithCredential(phoneAuthCredential);

      setState(() {
        showLoading = false;
      });

      if (authCredential.user != null) {
        print('Tenant ID: ${_auth.currentUser?.uid}');
        Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      }

    } on FirebaseAuthException catch (e) {
      setState(() {
        showLoading = false;
      });
      _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(e.message ?? 'e.message is null!')));
    }
  }

  Widget getMobileFormWidget(context) {
    return Column(
       mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //const Spacer(),
        TextField(
          controller: phoneController,
          decoration: const InputDecoration(
            hintText: 'Phone Number',
          ),
        ),
        TextButton(
          onPressed: () async {
            setState(() {
              showLoading = true;
            });
            await _auth.verifyPhoneNumber(
              phoneNumber: phoneController.text,
              verificationCompleted: (phoneAuthCredential) async {
                setState(() {
                  showLoading = false;
                });
                //signInWithPhoneAuthCredential(phoneAuthCredential);
              },
              verificationFailed: (verificationFailed) async {
                setState(() {
                  showLoading = false;
                });
                _scaffoldKey.currentState?.showSnackBar(
                  SnackBar(content: Text(verificationFailed.message ?? 'verificationFailed message is Null'))
                );
              },
              codeSent: (verificationId, resendingToken) async {
                setState(() {
                  showLoading = false;
                  currentState = MobileVerificationState.showOtpFormState;
                  this.verificationId = verificationId;
                });
              },
              codeAutoRetrievalTimeout: (verificationId) async {

              },
            );
          },
          child: const Text('SEND', style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue
          ),),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(16.0),
            primary: Colors.white,
            textStyle: const TextStyle(fontSize: 20),
          ),
        ),
      ],
    );
  }

  Widget getOtpFormWidget(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //const Spacer(),
        TextField(
          controller: otpController,
          decoration: const InputDecoration(
            hintText: 'ENTER OTP',
          ),
        ),
        TextButton(
          onPressed: () async {
            PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
                verificationId: verificationId,
                smsCode: otpController.text,
            );

            signInWithPhoneAuthCredential(phoneAuthCredential);
          },
          child: const Text('Verify', style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue
          ),),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(16.0),
            primary: Colors.white,
            textStyle: const TextStyle(fontSize: 20),
          ),
        ),
      ],
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        child: showLoading ? const Center(child: CircularProgressIndicator(),) : (currentState == MobileVerificationState.showMobilePhoneState)
            ? getMobileFormWidget(context)
            : getOtpFormWidget(context),
        padding: const EdgeInsets.all(25),
      ),
    );
  }
}
