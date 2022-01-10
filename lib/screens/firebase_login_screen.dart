import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'home_screen.dart';

enum MobileVerificationState {
  showMobilePhoneState,
  showOtpFormState,
}

class FirebaseLoginScreen extends StatefulWidget {
  const FirebaseLoginScreen({Key? key}) : super(key: key);

  @override
  _FirebaseLoginScreenState createState() => _FirebaseLoginScreenState();
}

class _FirebaseLoginScreenState extends State<FirebaseLoginScreen> {

  var currentState = MobileVerificationState.showMobilePhoneState;

  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool showLoading = false;

  String verificationId = '';

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
        //TODO: After successful login go to second home page
        Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      }

    } on FirebaseAuthException catch (e) {
      setState(() {
        showLoading = false;
      });
      _scaffoldKey.currentState?.showSnackBar(SnackBar(content: Text(e.message ?? 'e.message is null!')));
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Image(image: AssetImage('assets/login_logo.jpg')),
          Container(
              padding: const EdgeInsets.only(left: 30, right: 30),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Colors.white,
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                child: showLoading ? const Center(child: CircularProgressIndicator())
                    : (currentState == MobileVerificationState.showMobilePhoneState)
                    ? getMobileFormWidget(context)
                    : getOtpFormWidget(context),
              )
          ),
        ],
      ),
    );
  }
}
