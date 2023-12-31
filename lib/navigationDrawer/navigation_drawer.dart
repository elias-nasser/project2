import 'dart:math';

import 'package:flutter/material.dart';
import 'package:project2/dashboard.dart';
import 'package:project2/events.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../home.dart';
import '../auth/sign_in.dart';
import '../auth/sign_up.dart';

const String _baseURL = 'https://nasserhotel.000webhostapp.com/';

class navigationDrawer extends StatefulWidget {
  const navigationDrawer({Key? key}) : super(key: key);

  @override
  _navigationDrawerState createState() => _navigationDrawerState();
}

class _navigationDrawerState extends State<navigationDrawer> {
  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context);
    bool isLoggedIn = authProvider.isLoggedIn;
    String? fName = authProvider.firstName;
    String? email = authProvider.email;
    String? profileImage = authProvider.profileImage;
    Random random = Random();
    return Drawer(
      child: Theme(
        data: ThemeData(
          brightness: authProvider.isDarkMode ? Brightness.dark : Brightness.light,
          canvasColor: authProvider.isDarkMode ? Colors.grey[850] : Colors.white,
        ),
        child: Container(
          color: authProvider.isDarkMode ? Colors.grey[850] : Colors.white,
          child: Column(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: isLoggedIn ? Text(fName!) : null,
              accountEmail: isLoggedIn ? Text(email!) : null,
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                  '$_baseURL/assets/picture/profiles/$profileImage',
                ),
              ),
              decoration: BoxDecoration(
                color: authProvider.isDarkMode ? Colors.grey[650] : Color.fromRGBO(random.nextInt(256), random.nextInt(256), random.nextInt(256), 1.0),
              ),
            ),
            ListTile(
              title: Text('Book Room'),
              onTap: () => navigateToPage(context, ShowRooms()),
            ),
            ListTile(
              title: Text('Book Event'),
              onTap: () => navigateToPage(context, ShowEvents()),
            ),
            if (isLoggedIn)
              ListTile(
                title: Text('Dashboard'),
                onTap: () => navigateToPage(context, DashboardPage()),
              ),
            if (isLoggedIn)
              ListTile(
                title: Text('Logout'),
                onTap: () {
                  authProvider.logout();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => SignInPage()),
                  );
                },
              ),
            if (!isLoggedIn)
              ListTile(
                title: Text('Sign In'),
                onTap: () => navigateToPage(context, SignInPage()),
              ),
            if (!isLoggedIn)
              ListTile(
                title: Text('Sign Up'),
                onTap: () => navigateToPage(context, SignUpPage()),
              ),
            Spacer(),
            ListTile(
              title: Text('Dark Mode'),
              trailing: Switch(
                value: authProvider.isDarkMode,
                onChanged: (value) {
                  setState(() {
                    authProvider.toggleDarkMode(value);
                  });
                },
              ),
            ),
          ],
        ),)
      ),
    );
  }

  void navigateToPage(BuildContext context, Widget page) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutQuad;
        var tween =
        Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
    ));
  }
}
