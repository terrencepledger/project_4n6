import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_4n6/TournamentRecordPage.dart';
import 'Objects.dart';

class HomePage extends StatefulWidget {
  const HomePage({ Key key }) : super(key: key);

  @override
  _HomePage createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  
  Tournament _nextTournament;
  String _nextTournamentName = "N/A";
  String _nextTournamentDate = "N/A";
  
  double _score = 1;

  List<Tournament> tournaments = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Firebase.initializeApp().then((value) {
      loadTourneys();
    });
  }

  void loadTourneys() {
    var tempScores = [];
    tournaments = [];
    CollectionReference tourneyCollection = FirebaseFirestore.instance.collection("tourneys");
    tourneyCollection.get().then((fbTourneys) {
      fbTourneys.docs.forEach((fbTourney) { 
        Tournament current = Tournament(fbTourney.id, fbTourney.data());
        tempScores.addAll(current.scores);
        setState(() {
          tournaments.add(current);
          _nextTournament = current; 
          _nextTournamentDate = current.getPrettyDate();
          _nextTournamentName = current.title;        
        });
      });
      setState(() {
        if(tempScores.length > 0)
          _score = double.parse((tempScores.reduce((a,b) => a + b) / tempScores.length).toStringAsFixed(2));              
      });
    });
  }

  Widget getRecentList() {

    return Container(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0, left: 8.0, right: 8.0),
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: SingleChildScrollView(child: Table(
        children: List.generate(tournaments.length, (index) => TableRow(children: [
          ElevatedButton(
            onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => 
              TournamentRecordPage(tournaments.elementAt(index))
            )).then((value) => loadTourneys());},
            child: Center(
              child: Row(
                children: [
                  Center(child: Text(tournaments.elementAt(index).title)), 
                  Center(child: Text(tournaments.elementAt(index).overallScore.toString())),
                ],
                mainAxisAlignment: MainAxisAlignment.spaceAround,
              ),
            ),
          )
        ]),
      )),
    ));

  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 50.0, bottom: 8.0, left: 8.0, right: 8.0),
              child: Text(
                "Sumner Overall Score: \n$_score",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline5
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0, bottom: 8.0, left: 8.0, right: 8.0),
            child: Column(
              children: [
                Text(
                  "Upcoming Tournament:",
                  style: Theme.of(context).textTheme.headline5
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => 
                      TournamentRecordPage(_nextTournament)
                    )).then((value) => loadTourneys());},
                    child: Text("$_nextTournamentName on $_nextTournamentDate"),
                  ),
                )
              ],
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
            child: getRecentList(),
          ),
        ],
      ),
    );
  }
}