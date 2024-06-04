import 'dart:convert' as convert;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:project2/auth/verify_account.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import '../home.dart';
import 'sign_up.dart';

const String _baseURL = 'https://nasserhotel.000webhostapp.com/';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  void update(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  bool _hasAccount() {
    var authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isLoggedIn;
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context);

    return Theme(
        data: ThemeData(
          brightness:
              authProvider.isDarkMode ? Brightness.dark : Brightness.light,
          canvasColor:
              authProvider.isDarkMode ? Colors.grey[850] : Colors.white,
        ),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Sign In'),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(labelText: 'Email'),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                      ),
                      const SizedBox(height: 32.0),
                      ElevatedButton(
                        onPressed:
                            _loading ? null : () => _handleSubmitted(context),
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),
                if (!_loading && !_hasAccount())
                  TextButton(
                    onPressed: _navigateToSignUp,
                    child: const Text("Don't have an account? Create one"),
                  ),
              ],
            ),
          ),
        ));
  }

  void _handleSubmitted(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _loading = true;
      });

      await signInUser(
        context,
        update,
        _emailController.text,
        _passwordController.text,
      );

      setState(() {
        _loading = false;
      });

      var authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ShowRooms(),
          ),
        );
      }
    }
  }
}

Future<void> signInUser(BuildContext context, Function(String text) updateUser,
    String email, String password) async {
  var authProvider = Provider.of<AuthProvider>(context, listen: false);
  var data = {
    'email': email,
    'password': password,
  };

  try {
    final response = await http.post(
      Uri.parse('$_baseURL/loginValidation.php'),
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      final jsonResponse = convert.jsonDecode(response.body);

      if (jsonResponse['status'] == 'success') {
        final firstName = jsonResponse['FirstName'];
        final userEmail = jsonResponse['Email'];
        final profileImage = jsonResponse['ProfileImage'];
        final userId = jsonResponse['UserId'];

        authProvider.login(firstName, userId, userEmail, profileImage);
      }else if (jsonResponse['status'] == 'error' && jsonResponse['message'] == 'User is not active') {
        // Redirect to verifyAccount
        updateUser(jsonResponse['message']);
        verifyAccount(context, jsonResponse['FirstName'], jsonResponse['UserId'], jsonResponse['Email'], jsonResponse['ProfileImage']);
        return;
      }

      updateUser(jsonResponse['message']);
    } else {
      updateUser(
          'Failed to Login. Please try again later. ${response.statusCode}');
    }
  } catch (error) {
    updateUser('An error occurred: $error');
  }
}
void verifyAccount(BuildContext context, String firstName, String userId, String email, String profileImage) {
  // Implement your logic to navigate or handle user verification
  // For example:
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => VerifyAccountPage(email: email, firstName: firstName, profileImage: profileImage, userId: userId)),
  );
}
