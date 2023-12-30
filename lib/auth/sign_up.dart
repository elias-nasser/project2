import 'dart:convert';
import 'package:flutter/material.dart';
import 'sign_in.dart';
import 'package:http/http.dart' as http;

const String _baseURL = 'https://nasserhotel.000webhostapp.com/';
String username = '';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _contactNoController = TextEditingController();
  String? _selectedGender;
  bool _loading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _contactNoController.dispose();
    super.dispose();
  }

  void update(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
    setState(() {
      _loading = false;
    });
  }

  void _handleSubmitted() async {
    setState(() {
      _loading = true;
    });
    if (_formKey.currentState!.validate()) {
      createUser(
        (text) {
          update(text);
          if (text == 'Sign up successful!') {
            _firstNameController.clear();
            _lastNameController.clear();
            _emailController.clear();
            _passwordController.clear();
            _contactNoController.clear();
            setState(() {
              _selectedGender = null;
            });
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignInPage()),
            );
          }
        },
        _firstNameController.text,
        _lastNameController.text,
        _emailController.text,
        _passwordController.text,
        _contactNoController.text,
        _selectedGender,
      );
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _contactNoController,
                decoration: const InputDecoration(labelText: 'Contact Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your contact number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Text('Gender:'),
                  Radio(
                    value: 'Male',
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value as String?;
                      });
                    },
                  ),
                  const Text('Male'),
                  Radio(
                    value: 'Female',
                    groupValue: _selectedGender,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value as String?;
                      });
                    },
                  ),
                  const Text('Female'),
                ],
              ),
              const SizedBox(height: 32.0),
              ElevatedButton(
                onPressed: _loading ? null : _handleSubmitted,
                child: const Text('Sign Up'),
              ),
              const SizedBox(height: 16.0),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignInPage()),
                  );
                },
                child: const Text('Already have an account? Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> createUser(
  Function(String text) updateUser,
  String firstName,
  String lastName,
  String email,
  String password,
  String contactNo,
  String? gender,
) async {
  var data = {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'password': password,
    'contactNo': contactNo,
    'gender': gender,
    'key': 'your_key'
  };

  final response = await http.post(
    Uri.parse('$_baseURL/createUser.php'),
    body: json.encode(data),
  );

  if (response.statusCode == 200) {
    updateUser(response.body);
  } else {
    updateUser('Failed to create user. Please try again later.');
  }
}
