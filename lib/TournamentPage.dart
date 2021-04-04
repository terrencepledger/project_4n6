import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:intl/intl.dart';
import 'package:expansion_card/expansion_card.dart';
import 'TournamentRecordPage.dart';
import 'Objects.dart';

class TournamentPage extends StatefulWidget {
  TournamentPage({Key key}) : super(key: key);

  @override
  _TournamentPageState createState() => _TournamentPageState();

}

class _TournamentPageState extends State<TournamentPage> {

  List<Tournament> tourneys = [];

  @override
  void initState() { 
    super.initState();
    loadTournaments();
  }

  void loadTournaments() {

    FirebaseFirestore.instance.collection("tourneys").get()
    .then((studentCollection) {
      studentCollection.docs.forEach((tourney) {
        setState(() {
          tourneys.add(Tournament(tourney.id, tourney.data()));
        });
      });
    });

  }

  Widget getTourneyList() {

    List<Widget> getEventsList(Tournament current) {

      List<Widget> eventList = [];

      for (var eventKey in current.events.keys) {
        eventList.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 8, bottom: 3),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        eventKey.toString().split(".").last,
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      children: List.generate(current.events[eventKey].length, (index) => Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "\u2022 " + current.events[eventKey].elementAt(index).participantId,
                          textAlign: TextAlign.left,
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                      )),
                    )
                  ),
                ],
              ),
            ),
          )
        );
      }

      return eventList;

    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: ListView(children: List.generate(tourneys.length, (index) {
        var current = tourneys.elementAt(index);
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onLongPress: () {Navigator.push(context, MaterialPageRoute(builder: (context) => TournamentRecordPage(tourneys.elementAt(index))));},
            onPressed: () {  },
            child: ExpansionCard(
              margin: EdgeInsets.zero,
              borderRadius: 40,
              title: Text(
                current.title,
                style: Theme.of(context).textTheme.headline4
              ),
              children: getEventsList(current),
            ),
          ),
        );
      })),
    );
  
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 15.0, bottom: 8.0, left: 8.0, right: 8.0),
            child: Text(
              "Tournaments",
              style: Theme.of(context).textTheme.headline3
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 8.0, left: 8.0, right: 8.0),
              child: getTourneyList(),
            ),
          ),
        ],
      ),
    );
  }

}
