import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smartbill/screens/authentication/otp.dart';
import 'package:smartbill/screens/authentication/phone_image.dart';
import 'package:smartbill/services.dart/auth.dart';

const List countryCode = ["+57", "+51"];

class AuthenticateScreen extends StatefulWidget {
  const AuthenticateScreen({super.key});

  @override
  State<AuthenticateScreen> createState() => _AuthenticateScreenState();
}

class _AuthenticateScreenState extends State<AuthenticateScreen> {
  final AuthService _auth = AuthService();
  final TextEditingController _phoneText = TextEditingController();
  String fullphone = "";
  String? _verificationId;
  bool isLoading = false;

  String dropdownvalue = countryCode.first;

  //Snackbar in cade of error phone
  void _showSnackbarEmptyPhone() {
    const snackbar = SnackBar(content: Text("Ingresa tu número"), duration: Duration(seconds: 2));

    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  //Snackbar invalid phone number
  void _showSnackbarcInvalidPhone() {
    const snackbar = SnackBar(content: Text("Número invalido"), duration: Duration(seconds: 2));

    ScaffoldMessenger.of(context).showSnackBar(snackbar);
    
  }



  //SIGN IN WITH PHONE
  Future<void> _startPhoneAuth() async {

    setState(() {
      isLoading = true;
    });

    fullphone = dropdownvalue + _phoneText.text.trim();

    FocusScope.of(context).unfocus();

    if (_phoneText.text.trim() == "") {     

      _showSnackbarEmptyPhone();

      setState(() {
        isLoading = false;
      });

    } else {

      await _auth.verifyPhone(context: context, phone: fullphone, codeSentCallback: (verificationId) {
            print("IT ENTERED CODE SENT");

            setState(() {
              _verificationId = verificationId;
            });

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OtpScreen(code: _verificationId)));
          },
          codeErrorCallback: (message) {
            print("Error en entrar: $message");
            _showSnackbarcInvalidPhone();

            setState(() {
              isLoading = false;
            });

          });

    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Registrate"),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const PhoneImage(),
            //Add phone number. Country code with a dropdownmenu and number input
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Dropdownmenu of country doe
                DropdownButtonHideUnderline(
                  child: DropdownButton(
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.black),
                    value: dropdownvalue,
                    onChanged: <String>(value) {
                      setState(() {
                        dropdownvalue = value!;
                      });
                    },
                    items: countryCode.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                  ),
                ),
                // Input of phone number
                SizedBox(
                    width: 250,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: TextField(
                        controller: _phoneText,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        style: const TextStyle(fontSize: 21, letterSpacing: 3, fontWeight: FontWeight.w500),
                        decoration:
                            const InputDecoration(label: Text("Telefono")),
                      ),
                    ))
              ],
            ),

            const SizedBox(height: 30),

            //Submit button
            isLoading ? const CircularProgressIndicator() : SizedBox(
              height: 50,
              width: MediaQuery.of(context).size.width - 40,
              child: ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Color.fromARGB(255, 75, 78, 80))),
                  onPressed: _startPhoneAuth,
                  child: const Text(
                          "Enviar código",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        )),
            ),
          ],
        ),
      ),
    );
  }
}
