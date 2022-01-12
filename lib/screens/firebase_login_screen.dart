import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:numeric_keyboard/numeric_keyboard.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'home_screen.dart';

enum MobileVerificationState {
  showMobilePhoneState,
  showOtpFormState,
}

class FirebaseLoginScreen extends StatefulWidget {

  const FirebaseLoginScreen({Key? key
  }) : super(key: key);

  @override
  _FirebaseLoginScreenState createState() => _FirebaseLoginScreenState();
}

class _FirebaseLoginScreenState extends State<FirebaseLoginScreen> {

  String initialCountry = 'CA';
  PhoneNumber number = PhoneNumber(isoCode: 'CA');

  var currentState = MobileVerificationState.showMobilePhoneState;

  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool showLoading = false;

  String verificationId = '';

  String otpText = '';
  String updatedPhoneNumber = '';

  bool phoneNumberIsValidated = false;
  bool isSmsCodeIsSixDigits = false;

  Widget getMobileFormWidget(context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(40)),
        color: Colors.white,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TextField(
            //   controller: phoneController,
            //   textInputAction: TextInputAction.send,
            //   maxLines: 1,
            //   decoration: InputDecoration(
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(30.0),
            //     ),
            //     focusedBorder: OutlineInputBorder(
            //       borderSide: const BorderSide(color: Colors.black, width: 2.0),
            //       borderRadius: BorderRadius.circular(30.0),
            //     ),
            //     icon: const Icon(
            //       Icons.phone,
            //       color: Colors.black,
            //       size: 25,
            //     ),
            //     hintText: 'Phone Number',
            //   ),
            // ),
            InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber number) {
                print(number.phoneNumber);
                updatedPhoneNumber = '${number.phoneNumber}';
              },
              onInputValidated: (bool value) {
                setState(() {
                  phoneNumberIsValidated = value;
                });
              },
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.DIALOG,
              ),
              spaceBetweenSelectorAndTextField: 0,
              ignoreBlank: false,
              autoValidateMode: AutovalidateMode.onUserInteraction,
              selectorTextStyle: const TextStyle(color: Colors.black),
              initialValue: number,
              textFieldController: phoneController,
              formatInput: true,
              keyboardType:
              const TextInputType.numberWithOptions(signed: true, decimal: true),
              onSaved: null,
            ),
            const SizedBox(height: 30),
            // SizedBox(
            //   width: 200,
            //   child: ElevatedButton(
            //     onPressed: () async {
            //       setState(() {
            //         showLoading = true;
            //       });
            //       await _auth.verifyPhoneNumber(
            //         phoneNumber: updatedPhoneNumber,
            //         verificationCompleted: (phoneAuthCredential) async {
            //           setState(() {
            //             showLoading = false;
            //           });
            //           //signInWithPhoneAuthCredential(phoneAuthCredential);
            //         },
            //         verificationFailed: (verificationFailed) async {
            //           setState(() {
            //             showLoading = false;
            //           });
            //           _scaffoldKey.currentState?.showSnackBar(SnackBar(
            //               content: Text(verificationFailed.message ??
            //                   'verificationFailed message is Null')));
            //         },
            //         codeSent: (verificationId, resendingToken) async {
            //           setState(() {
            //             showLoading = false;
            //             currentState = MobileVerificationState.showOtpFormState;
            //             this.verificationId = verificationId;
            //           });
            //         },
            //         codeAutoRetrievalTimeout: (verificationId) async {},
            //       );
            //     },
            //     child: const Text(
            //       'Continue',
            //       style: TextStyle(
            //           fontSize: 20,
            //           fontWeight: FontWeight.bold,
            //           color: Colors.white),
            //     ),
            //     style: ButtonStyle(
            //       backgroundColor:
            //           MaterialStateProperty.all<Color>(Colors.black),
            //       shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            //         RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(18.0),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
            OutlinedButton(
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: const BorderSide(color: Colors.red)))),
              onPressed: () async {
                if (phoneNumberIsValidated) {
                  setState(() {
                    showLoading = true;
                  });
                  await _auth.verifyPhoneNumber(
                    phoneNumber: updatedPhoneNumber,
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
                      _scaffoldKey.currentState?.showSnackBar(SnackBar(
                          content: Text(verificationFailed.message ??
                              'verificationFailed message is Null')));
                    },
                    codeSent: (verificationId, resendingToken) async {
                      setState(() {
                        showLoading = false;
                        currentState = MobileVerificationState.showOtpFormState;
                        this.verificationId = verificationId;
                      });
                    },
                    codeAutoRetrievalTimeout: (verificationId) async {},
                  );
                }
              },
              child: Text('Continue',
                  style: TextStyle(
                    fontSize: 18,
                    color: phoneNumberIsValidated ? const Color(0xFFFE2C55) : Colors.grey,
                  )),
            ),
          ],
        ),
      ),
    );
  }

  String eachNumber(index) {
    if (otpText.length == 6) {
      setState(() {
        isSmsCodeIsSixDigits = true;
      });
    } else {
      setState(() {
        isSmsCodeIsSixDigits = false;
      });
    }
    if (otpText.isEmpty) {
      return '';
    } else {
      if (otpText.length >= index + 1) {
        return otpText[index];
      }
      return '';
    }
  }

  Widget otpNumberWidget(int position) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 0),
          borderRadius: const BorderRadius.all(Radius.circular(8))),
      child: Center(
          child: Text(
        eachNumber(position),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      )),
    );
  }

  void _onKeyboardTap(String value) {
    setState(() {
      otpText = otpText + value;
    });
  }

  verificationCodeSentToFirebase() async {
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otpText,
    );
    signInWithPhoneAuthCredential(phoneAuthCredential);
  }

  Widget getOtpFormWidget2(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 30),
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Text(
                        'Enter 6 digits verification code sent to your number',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w500))),
                const SizedBox(height: 30),
                Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      otpNumberWidget(0),
                      otpNumberWidget(1),
                      otpNumberWidget(2),
                      otpNumberWidget(3),
                      otpNumberWidget(4),
                      otpNumberWidget(5),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            OutlinedButton(
              style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: const BorderSide(color: Colors.red)))),
              onPressed: () async {
                if (isSmsCodeIsSixDigits) {
                  await verificationCodeSentToFirebase();
                }
              },
              child: Text('Continue',
                  style: TextStyle(
                    fontSize: 18,
                    color: isSmsCodeIsSixDigits ? const Color(0xFFFE2C55) : Colors.grey,
                  )),
            ),
            NumericKeyboard(
              onKeyboardTap: _onKeyboardTap,
              textColor: Colors.white,
              rightButtonFn: () {
                setState(() {
                  otpText = otpText.substring(0, otpText.length - 1);
                });
              },
              rightIcon: const Icon(
                Icons.backspace,
                color: Colors.white,
                size: 25,
              ),
              leftButtonFn: () async {
                if (isSmsCodeIsSixDigits) {
                  await verificationCodeSentToFirebase();
                }
              },
              leftIcon: Icon(
                Icons.check,
                color: isSmsCodeIsSixDigits ? const Color(0xFFFE2C55) : Colors.grey,
                size: 30,
              ),
            ),
          ],
        )
      ],
    );
  }

  // Widget getOtpFormWidget(context) {
  //   return Column(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       TextField(
  //         controller: otpController,
  //         textInputAction: TextInputAction.go,
  //         maxLines: 1,
  //         decoration: InputDecoration(
  //           border: OutlineInputBorder(
  //             borderRadius: BorderRadius.circular(30.0),
  //           ),
  //           focusedBorder: OutlineInputBorder(
  //             borderSide: const BorderSide(color: Colors.black, width: 2.0),
  //             borderRadius: BorderRadius.circular(30.0),
  //           ),
  //           icon: const Icon(
  //             Icons.sms_outlined,
  //             color: Colors.black,
  //             size: 25,
  //           ),
  //           hintText: 'SMS Code...',
  //         ),
  //       ),
  //       const SizedBox(height: 30),
  //       ElevatedButton(
  //         onPressed: () async {
  //           PhoneAuthCredential phoneAuthCredential =
  //               PhoneAuthProvider.credential(
  //             verificationId: verificationId,
  //             smsCode: otpController.text,
  //           );
  //
  //           signInWithPhoneAuthCredential(phoneAuthCredential);
  //         },
  //         child: const Text(
  //           'Verify',
  //           style: TextStyle(
  //               fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
  //         ),
  //         style: ButtonStyle(
  //           backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
  //           shape: MaterialStateProperty.all<RoundedRectangleBorder>(
  //             RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(18.0),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  signInWithPhoneAuthCredential(PhoneAuthCredential phoneAuthCredential) async {
    setState(() {
      showLoading = true;
    });

    try {
      final authCredential =
          await _auth.signInWithCredential(phoneAuthCredential);

      setState(() {
        showLoading = false;
      });

      if (authCredential.user != null) {
        print('Tenant ID: ${_auth.currentUser?.uid}');
        //TODO: After successful login go to second home page
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        showLoading = false;
      });
      _scaffoldKey.currentState?.showSnackBar(
          SnackBar(content: Text(e.message ?? 'e.message is null!')));
    }
  }

  @override
  void initState() {
    super.initState();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
                padding: EdgeInsets.only(left: 40, right: 40),
                child: Image(image: AssetImage('assets/login_logo.jpg'))),
            showLoading
                ? const Center(child: CupertinoActivityIndicator(radius: 25))
                : (currentState == MobileVerificationState.showMobilePhoneState)
                    ? getMobileFormWidget(context)
                    : getOtpFormWidget2(context),
            //getOtpFormWidget2(context),
          ],
        ),
      ),
    );
  }
}
