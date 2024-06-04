import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:provider/provider.dart';

import '../home.dart';
import 'auth_provider.dart';

class VerifyAccountPage extends StatefulWidget {
  final String email;
  final String firstName;
  final String profileImage;
  final String userId;

  const VerifyAccountPage({
    Key? key,
    required this.email,
    required this.firstName,
    required this.profileImage,
    required this.userId,
  }) : super(key: key);

  @override
  _VerifyAccountPageState createState() => _VerifyAccountPageState();
}

class _VerifyAccountPageState extends State<VerifyAccountPage> {
  late List<TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(6, (index) => TextEditingController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Account'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Enter the 6-digit verification code sent to ${widget.email}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                6,
                    (index) => SizedBox(
                  width: 50,
                  child: TextField(
                    controller: controllers[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        FocusScope.of(context).nextFocus();
                      }
                    },
                    decoration: InputDecoration(
                      counter: Offstage(),
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => verifyAccount(context),
              child: Text('Verify'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => resendVerificationCode(),
              child: Text('Resend Code'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> verifyAccount(BuildContext context) async {
    String verificationCode = controllers.fold<String>(
      '',
          (prev, controller) => prev + controller.text,
    );

    // Make API call to verify the account
    var url = Uri.parse('https://nasserhotel.000webhostapp.com/verification_mobile.php');
    var response = await http.post(url, body: {
      'email': widget.email,
      'verification_code': verificationCode,
    });

    if (response.statusCode == 200) {
      // Handle success or error response
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['status'] == 'success') {
        // Account verified successfully, navigate to next screen
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your account has been verified.')));

        // Update authProvider
        var authProvider = Provider.of<AuthProvider>(context, listen: false);
        authProvider.login(widget.firstName, widget.userId, widget.email, widget.profileImage);

        // Navigate to ShowRooms
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ShowRooms()));
      } else {
        // Handle error message from server
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonResponse['message'])));
      }
    } else {
      // Handle server error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to verify account. Please try again later.')));
    }
  }

  Future<void> resendVerificationCode() async {
    // var url = Uri.parse('https://nasserhotel.000webhostapp.com/resend_code_mobile.php');
    // var response = await http.post(
    //   url,
    //   headers: {'Content-Type': 'application/json'},
    //   body: json.encode({'email': widget.email}),
    // );
    // if (response.statusCode == 200) {
    //   if (response.body.isNotEmpty) {
    //     var jsonResponse = json.decode(response.body);
    //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonResponse['message'])));
    //   } else {
    //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Empty response received from the server.${widget.email}')));
    //   }
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to resend verification code. Please try again later.')));
    // }
    var url = Uri.parse('https://nasserhotel.000webhostapp.com/resend_code_mobile.php');
    var response = await http.post(url, body: jsonEncode({'email': widget.email}));

    if (response.statusCode == 200) {
      // Handle success or error response
      var jsonResponse = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsonResponse)));
    } else {
      // Handle server error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to resend verification code. Please try again later.')));
    }
  }

  Future<void> sendingmail(BuildContext context) async {
    final smtpServer = gmail('eliasnasser405@gmail.com', 'bncx bodg qzlt kafm');

    final message = Message()
      ..from = Address('info@resthotel.com', 'Rest Hotel')
      ..recipients.add(widget.email)
      ..subject = 'Rest Hotel Registration Successful'
      ..text = 'Your email address has been successfully verified. You can now login to your account.';

    try {
      final sendReport = await send(message, smtpServer);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email sent successfully.')));
    } catch (e) {
      // Handle any exceptions that occur during the sending process
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to send email. Please try again later.')));
    }

  }


}
