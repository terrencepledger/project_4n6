import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'Objects.dart';

class HomePage extends StatefulWidget {
  const HomePage({ Key key }) : super(key: key);

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {

  var _student = "";
  
  _HomePage() {
    Firebase.initializeApp().then((value) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference studentsCollection = firestore.collection('students');
      studentsCollection.doc("0").get().then((value) => {
        setState(() {
          _student = value.data()["name"];
        })
      });
    });
  }

  String _nextTournament = "N/A";
  
  double _score = 1;

  List<Tournament> tournaments = [Tournament(1.toString(), "Tournament 1", DateTime.now().toString())];

  Widget getRecentList() {

    Student me = Student(1.toString(), "Terrence", "12th");

    double temp = 0;
    tournaments.forEach((element) {
      element.addRecord(
        Record(event.Extemp, me.id, Score([3,5,2, tournaments.indexOf(element)]))
      );
      temp += element.overallScore;
    });
    temp = temp/tournaments.length;
    _score = temp;
    // setState(() {
    //     _score = temp;         
    // });

    return Container(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0, left: 8.0, right: 8.0),
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: SingleChildScrollView(child: Table(
        children: List.generate(tournaments.length, (index) => TableRow(children: [Center(child: Text(tournaments.elementAt(index).title)), Center(child: Text(tournaments.elementAt(index).overallScore.toString()))]),
      )),
    ));

  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 50.0, bottom: 8.0, left: 8.0, right: 8.0),
            child: Text(
              "Sumner Overall Score: $_score",
              style: Theme.of(context).textTheme.headline5
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 8.0, left: 8.0, right: 8.0),
            child: Text(
              "Upcoming Tournament: $_nextTournament",
              style: Theme.of(context).textTheme.headline5
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 8.0, left: 8.0, right: 8.0),
            child: Text(
              "Recent Tournaments",
              style: Theme.of(context).textTheme.headline5
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0, bottom: 8.0, left: 8.0, right: 8.0),
            child: Text(
              "Student: $_student",
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5.0, bottom: 8.0, left: 8.0, right: 8.0),
            child: getRecentList(),
          ),
        ],
      ),
    );
  }
}