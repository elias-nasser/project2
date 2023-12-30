import 'package:flutter/material.dart';
import 'package:project2/dashboard.dart';
import 'package:project2/events.dart';
import 'package:provider/provider.dart';
import '../auth/auth_provider.dart';
import '../home.dart';
import '../auth/sign_in.dart';
import '../auth/sign_up.dart';

class navigationDrawer extends StatelessWidget {
  const navigationDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var authProvider = Provider.of<AuthProvider>(context);
    bool isLoggedIn = authProvider.isLoggedIn;
    String? userName = authProvider.firstName;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nasser Hotel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
                if (isLoggedIn)
                  Text(
                    'Welcome, $userName!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  )
                else
                  Text(
                    'Please sign in',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
              ],
            ),
          ),
          buildDrawerItem(
            title: 'Book Room',
            onTap: () => navigateToPage(context, ShowRooms()),
          ),
          buildDrawerItem(
            title: 'Book Event',
            onTap: () => navigateToPage(context, ShowEvents()),
          ),
          if (isLoggedIn)
            buildDrawerItem(
              title: 'Dashboard',
              onTap: () => navigateToPage(context, DashboardPage()),
            ),
          if (isLoggedIn)
            buildDrawerItem(
              title: 'Logout',
              onTap: () {
                authProvider.logout();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => SignInPage()),
                );
              },
            ),
          if (!isLoggedIn)
            buildDrawerItem(
              title: 'Sign In',
              onTap: () => navigateToPage(context, SignInPage()),
            ),
          if (!isLoggedIn)
            buildDrawerItem(
              title: 'Sign Up',
              onTap: () => navigateToPage(context, SignUpPage()),
            ),
        ],
      ),
    );
  }

  ListTile buildDrawerItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      onTap: onTap,
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
