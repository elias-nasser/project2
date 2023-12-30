import 'package:flutter/material.dart';
import 'package:project2/auth/sign_in.dart';
import 'package:provider/provider.dart';
import 'auth/auth_provider.dart';
import 'home.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nasser Hotel',
      home: authProvider.isLoggedIn ? ShowRooms() : SignInPage(),
    );
  }
}
