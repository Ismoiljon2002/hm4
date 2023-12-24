import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'posts_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome Screen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    checkForFirstEntering();
  }

  void checkForFirstEntering() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstEntering = prefs.getBool('firstTime') ?? true;

    if (isFirstEntering) {
      prefs.setBool('firstTime', false);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Tutorial'),
          content: Text(
            'Welcome to the App!\nThis is a quick tutorial for the first-time users only.',
            style: TextStyle(color: Colors.blue)),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      goToPostsPage();
    }
  }

  void goToPostsPage() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => PostsPage(),
        transitionsBuilder: (context, animation1, animation2, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation1.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to the Posts App!'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PostsPage()),
            ),
          child: Text('Okay, Go to Posts')
        ),
      ),
    );
  }
}