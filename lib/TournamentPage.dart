import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:intl/intl.dart';
import 'package:expansion_card/expansion_card.dart';


import 'Objects.dart';
import 'TournamentRecordPage.dart';

Widget TournamentPage(BuildContext context) {

  Tournament x = Tournament("0", "Title", DateTime.now().toString());
  x.addRecord(Record(event.Extemp, "abc123", Score([1, 1, 2])));
  x.addRecord(Record(event.Extemp, "abc124", Score([1, 1, 2])));
  x.addRecord(Record(event.Impromptu, "abc125", Score([1, 1, 2])));  
  x.addRecord(Record(event.Impromptu, "abc128", Score([1, 3, 2])));
  x.addRecord(Record(event.Extemp, "abc126", Score([1, 1, 2])));
  x.addRecord(Record(event.Prose, "abc127", Score([1, 1, 2])));

  Tournament y = Tournament("1", "Title2", DateTime.now().toString());
  y.addRecord(Record(event.Extemp, "abc123", Score([1, 1, 2])));
  y.addRecord(Record(event.Extemp, "abc124", Score([1, 1, 2])));
  y.addRecord(Record(event.Impromptu, "abc125", Score([1, 1, 2])));  
  y.addRecord(Record(event.Impromptu, "abc128", Score([1, 3, 2])));
  y.addRecord(Record(event.Extemp, "abc126", Score([1, 1, 2])));
  y.addRecord(Record(event.Prose, "abc127", Score([1, 1, 2])));

  List<Tournament> tourneys = [x,y];

  Widget getTourneyList() {

    List<Widget> getEventsList(Tournament current) {

      List<Widget> eventList = [];

      for (var eventKey in current.events.keys) {
        eventList.add(
          Align(
            alignment: Alignment.centerLeft,
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
          )
        );
      }

      return eventList;

    }

    // List.generate(8, (index) {
    //   var current = Tournament(index.toString(), randomString(5), DateFormat('MM-dd').format(DateTime.now()));
    //   tourneys.add(current);
    // });

    return Container(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0, right: 8.0),
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: ListView(children: List.generate(tourneys.length, (index) {
        var current = tourneys.elementAt(index);
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            // : Theme.of(context).primaryColor,
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
      }
      )),
    );

  }

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
