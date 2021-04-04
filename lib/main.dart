import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project_4n6/StudentPage.dart';
import 'HomePage.dart';
import 'TournamentPage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Season Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          subtitle1: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
          subtitle2: TextStyle(color: Colors.white),
          headline4: TextStyle(color: Colors.white, decoration: TextDecoration.underline),
          headline3: TextStyle(color: Colors.black),
          headline6: TextStyle(color: Colors.black)
        )
      ),
      home: AppPage(title: 'Home Page'),
    );
  }
  
}

class AppPage extends StatefulWidget {
  AppPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AppPageState createState() => _AppPageState();
  
}

class _AppPageState extends State<AppPage> {

  static Widget pageBody;
  static Widget pageTitle = Text("Home");

  Drawer menu(BuildContext context) {
    return Drawer(
      child:  ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text('Sumner Forensics Season Tracker'),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text('Home'),
            onTap: () {
              setState(() {
                pageBody = HomePage();
                pageTitle = Text('Home');
                Navigator.pop(context);
              });
            },
          ),
          ListTile(
            title: Text('Students'),
            onTap: () {
              setState(() {
                pageBody = StudentPage();
                pageTitle = Text('Students');
                Navigator.pop(context);
              });
            },
          ),
          ListTile(
            title: Text('Tournaments'),
            onTap: () {
              setState(() {
                pageBody = TournamentPage();
                pageTitle = Text('Tournaments');
                Navigator.pop(context);
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if(pageBody == null)
    {
      setState(() {
        pageBody = HomePage();
      });
    }
    return Scaffold(
      drawer: menu(context),
      appBar: AppBar(
        title: pageTitle,
      ),
      body: pageBody
    );
  }

}
