import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expansion_card/expansion_card.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
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
        tourneys.sort((a, b) => a.date.compareTo(b.date));
      }
    );
  }

  void updateName(String updated) {
    
    FirebaseFirestore.instance.collection("students")
    .doc(student.id).update({'name': updated});

  }
  
  void updateGrade(String updated) {
    FirebaseFirestore.instance.collection("students")
    .doc(student.id).update({'grade': int.parse(updated)});
  }

  Widget getRecordsList() {
      
      List<Padding> getStudentRecordsListFromTourney(Tournament tourney) {
        
        List tourneyRecords = [];
        for (var eventKey in tourney.events.keys) {
          List<Record> currentRecords = tourney.events[eventKey];
          for (var record in currentRecords) {
            if(record.participantId == student.id)
            {                
              tourneyRecords.add(record);
              setState(() {
                studentRecords.add(record);       
              });
            }
          }
        }

        return List.generate(
          tourneyRecords.length,
          (recordIndex) {
          return Padding(
            padding: const EdgeInsets.only(left: 18, bottom: 3.0, top: 3),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                tourneyRecords.elementAt(recordIndex).title.toString().split('.').last
                + " - " + 
                tourneyRecords.elementAt(recordIndex).score.overallScore.toString(),
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
          // decoration: BoxDecoration(
          //   border: Border.all(),
          // ),
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

  List<Widget> getEventsChart() {
    List<LineChartBarData> chartItems = [];
    List<event> eventKeys = []; 
    for (event eventKey in event.values) {
      List<Record> currentEventRecords = [];
      for (var i = 0; i < tourneys.length; i++) {
        var tourney = tourneys.elementAt(i);
        if(tourney.events[eventKey] != null)
        {
          for (Record record in tourney.events[eventKey]) {
            if(record.participantId == student.id)
            {
              record.id = currentEventRecords.length;
              currentEventRecords.add(record);
            }
          }
        }
      }
      if(currentEventRecords.length > 0){
        print(currentEventRecords.map((e) => e.id).toList());
        chartItems.add(
          LineChartBarData(
            colors: [Colors.accents.elementAt(chartItems.length)],
            spots: List.generate(currentEventRecords.length, (index) => 
              FlSpot(currentEventRecords.elementAt(index).date.millisecondsSinceEpoch.toDouble(), currentEventRecords.elementAt(index).score.overallScore 
            ))
          )
        );
        eventKeys.add(eventKey);
      }
    }
    
    Widget chart = Padding(padding: EdgeInsets.only(right: 35, bottom: 35, top: 35), child: 
    LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
          ),
          touchCallback: (LineTouchResponse touchResponse) {},
          handleBuiltInTouches: true,
        ),
        gridData: FlGridData(
          show: false,
        ),
        titlesData: FlTitlesData(
          bottomTitles: SideTitles(
            showTitles: true,
            rotateAngle: 75,
            reservedSize: 22,
            getTextStyles: (value) => const TextStyle(
              color: Color(0xff72719b),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            margin: 10,
            checkToShowTitle: (minValue, maxValue, sideTitles, appliedInterval, value) {
              return tourneys.map((e) => e.date.millisecondsSinceEpoch).toList().indexOf(value.toInt()) != -1;
            },
            getTitles: (value) {
              return DateFormat('MM-dd-yy').format(DateTime.fromMillisecondsSinceEpoch(value.toInt()));
            },
          ),
        ),
        lineBarsData: chartItems,
      ),
    ));

    Widget legend = Container( child: Column(
      children: List.generate(chartItems.length, (index) => 
        Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              child: Center(child: Icon(Icons.linear_scale, color: Colors.accents.elementAt(index),)),
              width: 50,
            ),
            SizedBox(
              child: Center(child: Text(eventKeys.elementAt(index).toString().split('.').last,
                textWidthBasis: TextWidthBasis.parent,
              )),
              width: 75,
            ),
          ],
        )
      ),
    ),
    decoration: BoxDecoration(
      border: Border.all(),
    ),);

    return [chart, legend];

  }

  Widget getRecordsTab() {

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 0.0, bottom: 8.0, left: 8.0, right: 8.0),
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
                            onChanged: (value) => value.length > 0 ? updateName(value) : updateName(initialName),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            key: Key(initialGrade),
                            initialValue: initialGrade,
                            decoration: InputDecoration(
                              labelText: "Grade"
                            ),
                            style: Theme.of(context).textTheme.headline6,
                            onChanged: (value) => value.length > 0 ? updateGrade(value) : updateGrade(initialGrade)
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
        ]
      )
    );

  }

  Widget getEventsChartTab() {

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Events Graph",
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          Row( children: [Expanded(child: getEventsChart().first)]),
          SizedBox(child: Center(child: getEventsChart().last), width: 130),
        ],
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: ColoredTabBar(Theme.of(context).primaryColor, TabBar(
            labelPadding: EdgeInsets.all(20),
            tabs: [
              Icon(Icons.list),
              Icon(Icons.score),
            ],
          )),
          body: TabBarView(
            children: [
             getRecordsTab(), getEventsChartTab()
            ],
          ),
        ),
      ),
    );
  
  }

}
