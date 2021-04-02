import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expansion_card/expansion_card.dart';
import 'package:project_4n6/Objects.dart';
import 'package:random_string/random_string.dart';
import 'package:fl_chart/fl_chart.dart';

class TournamentRecordPage extends StatefulWidget {

  TournamentRecordPage(this.tourney) : super();

  final Tournament tourney;

  @override
  _TournamentRecordPage createState() => _TournamentRecordPage(tourney);

}

class _TournamentRecordPage extends State<TournamentRecordPage> {
  
  Tournament tourney;

  _TournamentRecordPage(this.tourney);

  Widget getRecordsList() {
      
      List<Padding> getEventRecords(event event) {
        
        List<Record> eventRecords = tourney.events[event];

        return List.generate(
          eventRecords.length,
          (recordIndex) {
          return Padding(
            padding: const EdgeInsets.only(left: 18, bottom: 3.0, top: 3),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                eventRecords.elementAt(recordIndex).participantId
                + " - " + 
                eventRecords.elementAt(recordIndex).score.overallScore.toString(),
                style: TextStyle(
                  fontFamily: Theme.of(context).textTheme.subtitle2.fontFamily,
                  fontSize: Theme.of(context).textTheme.subtitle2.fontSize,
                  color: Colors.white
                ),
                textAlign: TextAlign.start,
              ),
            ),
          );
        });

      }     

      return Container(
          padding: const EdgeInsets.only(top: 0.0, bottom: 8.0, left: 20.0, right: 20.0),
          decoration: BoxDecoration(
            border: Border.all(),
          ),
          child: ListView(
            padding: EdgeInsets.only(top: 10),
            children: List.generate(tourney.events.keys.length, (index) { 
              var current = tourney.events.keys.elementAt(index);
              return Card(
                color: Theme.of(context).primaryColor,
                elevation: 10,
                child: ExpansionCard(
                  margin: EdgeInsets.zero,
                  borderRadius: 40,
                  title: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          current.toString().split('.').last,
                          style: TextStyle(
                            fontFamily: Theme.of(context).textTheme.subtitle2.fontFamily,
                            fontSize: Theme.of(context).textTheme.subtitle2.fontSize,
                            color: Colors.white
                          ),
                        ),
                      ],
                    ),
                  ),
                  children: getEventRecords(current) + [Padding(padding: EdgeInsets.only(bottom: 15))]
                ),
              );
            }),
          )
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 30.0, bottom: 8.0, left: 8.0, right: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              initialValue: tourney.title,
                              decoration: InputDecoration(
                                labelText: "Title"
                              ),
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              initialValue: tourney.date,
                              decoration: InputDecoration(
                                labelText: "Date"
                              ),
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Records",
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            SizedBox(
              height: 450,
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0, bottom: 8.0, left: 8.0, right: 8.0),
                child: getRecordsList(),
              ),
            ),
            // Text(
            //   "Events",
            //   style: TextStyle(
            //     decoration: TextDecoration.underline,
            //     fontFamily: Theme.of(context).textTheme.headline6.fontFamily,
            //     fontSize: Theme.of(context).textTheme.headline6.fontSize,
            //     color: Colors.black
            //   )
            // ),
            // Padding(
            //   padding: const EdgeInsets.only(top: 15.0, bottom: 8.0, left: 8.0, right: 50.0),
            //   child: getEventsChart(),
            // )
          ],
        ),
      ),
    );
  }

}
