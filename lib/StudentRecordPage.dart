import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expansion_card/expansion_card.dart';
import 'package:random_string/random_string.dart';
import 'package:fl_chart/fl_chart.dart';

// import 'package:random_string/random_string.dart';

import 'Objects.dart';
import 'TournamentRecordPage.dart';

class StudentRecordPage extends StatefulWidget {

  StudentRecordPage(this.student) : super();

  final Student student;

  @override
  _StudentRecordPage createState() => _StudentRecordPage(student);

}

class _StudentRecordPage extends State<StudentRecordPage> {
  
  Student student;
  // Map<String, Tournament> tourneys = {};
  List<Tournament> tourneys = [];
  List<Record> studentRecords = [];
  String initialName = "";
  String initialGrade = "";

  _StudentRecordPage(this.student);

  @override
  void initState() { 
    super.initState();
    loadTourneys();
  }

  void loadTourneys() {
    tourneys = [];
    student.onReady(
      () {
        setState(() {
          initialName = student.name;
          initialGrade = student.grade.toString();        
        });
        CollectionReference tourneyCollection = FirebaseFirestore.instance.collection("tourneys");        
        tourneys = [];
        for (String tourneyId in student.tourneyIds) {
          tourneyCollection.doc(tourneyId).get().then((fbTourney) {
            setState(() {
              tourneys.add(Tournament(fbTourney.id, fbTourney.data()));                  
            });
          });
        }
      }
    );
  }

  Widget getRecordsList() {
      
      List<Padding> getStudentRecordsListFromTourney(Tournament tourney) {
        
        for (var eventKey in tourney.events.keys) {
          List<Record> currentRecords = tourney.events[eventKey];
          for (var record in currentRecords) {
            if(record.participantId == student.id)
            {
              setState(() {
                studentRecords.add(record);       
              });
            }
          }
        }

        return List.generate(
          studentRecords.length,
          (recordIndex) {
          return Padding(
            padding: const EdgeInsets.only(left: 18, bottom: 3.0, top: 3),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                studentRecords.elementAt(recordIndex).title.toString().split('.').last
                + " - " + 
                studentRecords.elementAt(recordIndex).score.overallScore.toString(),
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
            children: List.generate(tourneys.length, (index) { 
              var current = tourneys.elementAt(index);
              return Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                child: ElevatedButton(
                  // style: ElevatedButton.styleFrom(primary: Theme.of(context).primaryColor),
                  onLongPress: () {Navigator.push(context, MaterialPageRoute(builder: (context) => 
                    TournamentRecordPage(tourneys.elementAt(index))
                  ));},
                  onPressed: () { },
                  child: ExpansionCard(
                    margin: EdgeInsets.zero,
                    borderRadius: 40,
                    title: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            current.title,
                            style: TextStyle(
                              fontFamily: Theme.of(context).textTheme.subtitle2.fontFamily,
                              fontSize: Theme.of(context).textTheme.subtitle2.fontSize,
                              color: Colors.white
                            ),
                          ),
                          Text(
                            current.getPrettyDate(),
                            style: TextStyle(
                              fontFamily: Theme.of(context).textTheme.subtitle2.fontFamily,
                              fontSize: Theme.of(context).textTheme.subtitle2.fontSize,
                              color: Colors.white
                            ),
                          ),
                        ],
                      ),
                    ),
                    children: getStudentRecordsListFromTourney(current) + [Padding(padding: EdgeInsets.only(bottom: 15))]
                  ),
                ),
              );
            }),
          )
        );
  }

  Widget getEventsChart() {
    var chartScores = {};
    studentRecords.forEach((record) {
      if(!chartScores.containsKey(record.title.toString().split('.').last))
      {
        chartScores[record.title.toString().split('.').last] = record.score;
      }
      else
      {
        print(record.score.overallScore);
        record.score.addScores(chartScores[record.title.toString().split('.').last].scores);
        print(record.score.overallScore);
        chartScores[record.title.toString().split('.').last] = record.score;
      }
    });
    return Center(
      child: BarChart(
        BarChartData(
          maxY: 10.0,
          alignment: BarChartAlignment.center,
          groupsSpace: 45.0,
          barGroups: List.generate(chartScores.length, (index) { 
            return BarChartGroupData(
              x: index,
              barRods: [BarChartRodData(
                y: chartScores[chartScores.keys.elementAt(index)].overallScore,
              )]
            );
          }),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: SideTitles(
              getTitles: (value) {
                return chartScores.keys.elementAt(value.toInt());
              },
              showTitles: true
            )
          )
        )
      ),
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
                              key: Key(initialName),
                              initialValue: initialName,
                              decoration: InputDecoration(
                                labelText: "Name"
                              ),
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              key: Key(initialGrade),
                              initialValue: initialGrade,
                              decoration: InputDecoration(
                                labelText: "Grade"
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
                "Tournaments",
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            SizedBox(
              height: 265,
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0, bottom: 8.0, left: 8.0, right: 8.0),
                child: getRecordsList(),
              ),
            ),
            Text(
              "Events",
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontFamily: Theme.of(context).textTheme.headline6.fontFamily,
                fontSize: Theme.of(context).textTheme.headline6.fontSize,
                color: Colors.black
              )
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0, bottom: 8.0, left: 8.0, right: 50.0),
              child: getEventsChart(),
            )
          ],
        ),
      ),
    );
  }

}
