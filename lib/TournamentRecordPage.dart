import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expansion_card/expansion_card.dart';
import 'package:project_4n6/Objects.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/src/text_style.dart' as style;
import 'package:charts_flutter/src/text_element.dart' as TextElement;
import 'package:carousel_slider/carousel_slider.dart';
import 'StudentRecordPage.dart';
import 'dart:math';

class CustomCircleSymbolRenderer extends charts.CircleSymbolRenderer {

  static String value;

  @override
  void paint(charts.ChartCanvas canvas, Rectangle<num> bounds, {List<int> dashPattern, charts.Color fillColor, charts.FillPatternType fillPattern, charts.Color strokeColor, double strokeWidthPx}) {
    super.paint(canvas, bounds, dashPattern: dashPattern, fillColor: fillColor, fillPattern: fillPattern, strokeColor: strokeColor, strokeWidthPx: strokeWidthPx);
    canvas.drawRect(
      Rectangle(bounds.left - 5, bounds.top - 30, bounds.width + 10, bounds.height + 10),
      fill: charts.Color.white
    );
    var textStyle = style.TextStyle();
    textStyle.color = charts.Color.black;
    textStyle.fontSize = 15;
    canvas.drawText(
      TextElement.TextElement(value, style: textStyle,),
        (bounds.left).round() - 8,
        (bounds.top - 28).round()
    );
  }

}

class ColoredTabBar extends Container implements PreferredSizeWidget {
  ColoredTabBar(this.color, this.tabBar);

  final Color color;
  final TabBar tabBar;

  @override
  Size get preferredSize => tabBar.preferredSize;

  @override
  Widget build(BuildContext context) => Container(
    color: color,
    child: tabBar,
  );
}

class TournamentRecordPage extends StatefulWidget {

  TournamentRecordPage(this.tourney) : super();

  final Tournament tourney;

  @override
  _TournamentRecordPage createState() => _TournamentRecordPage(tourney);

}

class _TournamentRecordPage extends State<TournamentRecordPage> {
  
  Tournament tourney;

  List<Card> eventList = [];
  Map<event, Map<String, Record>> eventRecords = {};

  _TournamentRecordPage(this.tourney);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadEvents();
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
                  padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
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
                            initialValue: tourney.getPrettyDate(),
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
          Container(
            child: Padding(
              padding: const EdgeInsets.only(top: 5.0, bottom: 8.0, left: 8.0, right: 8.0),
              child: Container(
                padding: const EdgeInsets.only(top: 5.0, bottom: 8.0, left: 20.0, right: 20.0),
                child: ListView(
                  primary: false,
                  shrinkWrap: true,
                  padding: EdgeInsets.only(top: 10),
                  children: eventList
                )
              ),
            ),
          ),
        ],
      ),
    );
      
}

  Widget getEventsChartTab() {

    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            "Event Charts",
            style: TextStyle(
              decoration: TextDecoration.underline,
              fontFamily: Theme.of(context).textTheme.headline6.fontFamily,
              fontSize: Theme.of(context).textTheme.headline6.fontSize,
              color: Colors.black
            )
          ),
          getEventsChart(),
        ],
      ),
    );

  }

  void loadEvents() {

    FirebaseFirestore.instance.collection('tourneys').doc(tourney.id).get().then((fbObject) {
      
      setState(() {
        tourney = Tournament(fbObject.id, fbObject.data());
      });
      eventList = [];

      for (var eventKey in event.values) {
        String eventTitle = eventKey.toString().split(".").last;
        setState(() {
          eventList.add(Card(
            color: Theme.of(context).primaryColor,
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ExpansionCard(
                margin: EdgeInsets.zero,
                borderRadius: 40,
                title: Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        eventTitle,
                        style: TextStyle(
                          fontFamily: Theme.of(context).textTheme.subtitle2.fontFamily,
                          fontSize: Theme.of(context).textTheme.subtitle2.fontSize,
                          color: Colors.white
                        ),
                      ),
                    ],
                  ),
                ),
                children: getEventRecordList(
                  event.values.firstWhere((e) => e.toString().split('.').last.toLowerCase() == eventTitle.toLowerCase())
                )
              ),
            ),
          ));
        });
      }

    }); 

  }

  Widget getEventsChart() {

    Map<String, List> studentDataList = {};
    for (var i = 0; i < eventRecords.length; i++) {
      var eventKey = eventRecords.keys.elementAt(i);
      studentDataList[eventKey.toString().split('.').last] = [];
      for (var j = 0; j < eventRecords[eventKey].length; j++) {
        String studentId = eventRecords[eventKey].keys.elementAt(j); 
        Student currentStudent = Student.load(studentId);
        setState(() {
          currentStudent.onReady( () {
            studentDataList[eventKey.toString().split('.').last].add({'name': currentStudent.name, 'score': eventRecords[eventKey][studentId].score.overallScore});
          });
        });
      }
    }

    return Align(
      alignment: Alignment.center,
      child: CarouselSlider(
        options: CarouselOptions(
          height: 500,
          aspectRatio: 1,
          autoPlay: true,
          enlargeCenterPage: true,
          viewportFraction: .8,
          autoPlayInterval: Duration(seconds: 6)
        ),
        items: List.generate(eventRecords.length, (eventIndex) {
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Container(
              // height: 500,
              child: new charts.BarChart(
                [
                  new charts.Series(
                    id: eventRecords.keys.elementAt(eventIndex).toString().split('.').last,
                    
                    // displayName: eventRecords.keys.elementAt(eventIndex).toString().split('.').last,
                    // labelAccessorFn: (record, index) => record[index].name,
                    domainFn: (record, _) =>  record["name"],
                    measureFn: (record, _) => record["score"],
                    data: studentDataList[eventRecords.keys.elementAt(eventIndex).toString().split('.').last],
                  )
                ],
                
                domainAxis: charts.OrdinalAxisSpec(
                  renderSpec: charts.SmallTickRendererSpec(labelRotation: 60),
                ),
                behaviors: [
                  new charts.ChartTitle(eventRecords.keys.elementAt(eventIndex).toString().split('.').last,
                    behaviorPosition: charts.BehaviorPosition.bottom,
                    titleStyleSpec: charts.TextStyleSpec(fontSize: 11,),
                    titleOutsideJustification:
                      charts.OutsideJustification.middleDrawArea
                  ),
                  new charts.SlidingViewport(),
                  new charts.PanAndZoomBehavior(),
                  charts.LinePointHighlighter(
                    symbolRenderer: CustomCircleSymbolRenderer()
                  )
                ],
                selectionModels: [
                  charts.SelectionModelConfig(
                    changedListener: (charts.SelectionModel model) {
                      CustomCircleSymbolRenderer.value = model.selectedSeries[0].measureFn(model.selectedDatum[0].index).toString();
                    }
                  )
                ],
                animate: false,
                barGroupingType: charts.BarGroupingType.groupedStacked,
              ),
            ),
          );
        })
      )
    );
  }

  List<Padding> getEventRecordList(event _event) {

    List<Padding> records = [];
    List<Student> currentStudents = [];
    if(tourney.events[_event] != null)
    {
      for (Record record in tourney.events[_event]) {
        String studentName = "";
        setState(() {
          if(eventRecords[record.title] == null)
          {
            eventRecords[record.title] = {record.participantId: record};
          }
          else
            eventRecords[record.title][record.participantId] = record;                  
        });
        records.add(Padding(
          padding: const EdgeInsets.only(left: 18, bottom: 3.0, top: 3),
          child: Align(
            alignment: Alignment.centerLeft,
            child: StatefulBuilder(builder: (context, StateSetter setState2) {
              Student student = Student.load(record.participantId);
              student.onReady(() {
                setState2(() {
                  studentName = student.name;
                  currentStudents.add(student);
                });
              });
              return ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
                onLongPress: () { confirmDialog(student, _event.toString().split(".").last); },
                onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => 
                  StudentRecordPage(student)
                ));},
                child: Text(
                  studentName
                  + " - " + 
                  record.score.overallScore.toString(),
                  style: TextStyle(
                    fontFamily: Theme.of(context).textTheme.subtitle2.fontFamily,
                    fontSize: Theme.of(context).textTheme.subtitle2.fontSize,
                    color: Colors.white
                  ),
                  textAlign: TextAlign.start,
                ),
              );
            })
          ),
        )); 
      }
    }

    Widget addFab = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.centerRight,
        child: FloatingActionButton(
          onPressed: () { addStudentPopup(currentStudents, _event.toString().split('.').last); },
          child: const Icon(Icons.add_circle_outline),
          mini: true,
        ),
      ),
    );

    records.add(addFab);
    
    return records;

  }

  Future<void> confirmDialog(Student toRemove, String eventTitle) async {

    if(!toRemove.isReady && mounted)
    {
      await toRemove.refresh();
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove Student?'),
          content: SingleChildScrollView(
            child: Text('Are you sure you want to remove ' + toRemove.name + " from $eventTitle?",
              style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold, decoration: TextDecoration.none)
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                remove(toRemove, eventTitle);
              },
            ),
            ElevatedButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void addStudentPopup(List<Student> existingStudents, String eventTitle) async {

    List<int> scoreList = [];
    TextEditingController controller = TextEditingController();

    Student toAdd;
    int toAddIndex;

    void submit() async {
      await addToEvent(toAdd, tourney.id, eventTitle, scoreList);
      loadEvents();
    }
    List<Student> allStudents = [];
    await FirebaseFirestore.instance.collection("students").get()
    .then((studentCollection) {
      studentCollection.docs.forEach((studentSnap) {
        Student current = Student(studentSnap.id, studentSnap.data());
        bool alreadyExists = false;
        for (var student in existingStudents) {
          if(student.id == current.id)
            alreadyExists = true;
        }
        if(!alreadyExists) {
          setState(() {
            allStudents.add(current);
          });
        }
      });
    });
    toAddIndex = 0;
    toAdd = allStudents[0];

    showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: StatefulBuilder(builder: (context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
              elevation: 16,
              child: Container(
                height: 400.0,
                width: 360.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: Center(
                        child: Text(
                          "New Record",
                          style: TextStyle(fontSize: 24, color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 200,
                        child: Row(
                          children: [
                            Text(
                              "Student: ", 
                              style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: DropdownButton<int>(
                                items: List.generate(allStudents.length, (index) {
                                  return DropdownMenuItem<int>(
                                    value: index,
                                    child: Text(
                                      allStudents[index].name.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 18, color: Colors.blue, decoration: TextDecoration.none),
                                    ),
                                  );
                                }),
                                value: toAddIndex,
                                onChanged: (newIndex) {
                                  toAdd = allStudents[newIndex];
                                  setState(() {
                                    toAddIndex = newIndex;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Center(
                        child: Text(
                          "Add Scores",
                          style: TextStyle(fontSize: 24, color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Center(
                        child: scoreInput(controller, scoreList)
                      ),
                    ),
                    Expanded(child: 
                      Align(alignment: Alignment.bottomCenter,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(elevation: 20),
                          onPressed: () {
                            Navigator.of(context).pop();
                            submit();
                          },
                          child: Text("Add"),
                        ),
                      )
                    )
                  ],
                ),
              ),
            ); 
          }),
        );
      }
    );

  }

  void remove(Student toRemove, String eventTitle) {

    var updatedTourney, updatedStudent;

    FirebaseFirestore fb = FirebaseFirestore.instance;
    CollectionReference tourneyCollection = fb.collection("tourneys");
    CollectionReference studentCollection = fb.collection("students");

    tourneyCollection.doc(tourney.id)
    .get().then((fbObject) {
      
      updatedTourney = fbObject.data()['events'];
      int indexToRemove = -1;
      int studentAppearanceCount = 0;

      for (var i = 0; i < updatedTourney.length; i++) {
        
        String currentEventTitle = updatedTourney.keys.elementAt(i);
        for (var j = 0; j < updatedTourney[currentEventTitle].length; j++) {
          var currentRecord = updatedTourney[currentEventTitle].elementAt(j);
          if((currentRecord)['participantId'] == toRemove.id)
            studentAppearanceCount++;
          if(currentEventTitle == eventTitle.toLowerCase())
            indexToRemove = j;
        }

      }

      updatedTourney[eventTitle.toLowerCase()].removeAt(indexToRemove);

      if(studentAppearanceCount == 1)
      {
        studentCollection.doc(toRemove.id)
        .get().then((fbObject2) async {

          updatedStudent = fbObject2.data()["tourneyIds"];
          updatedStudent.removeWhere((studentsTourneyId) => studentsTourneyId == tourney.id);
          await tourneyCollection.doc(tourney.id).update({"events": updatedTourney});
          studentCollection.doc(toRemove.id).update({"tourneyIds": updatedStudent}).then((value) => loadEvents());

        });
      }

      else
        tourneyCollection.doc(tourney.id).update({"events": updatedTourney}).then((value) => loadEvents());

    });

  }

  Future<void> addToEvent(Student toAdd, String tourneyId, String eventTitle, List<int> scores) async {

    var updatedTourney;

    FirebaseFirestore fb = FirebaseFirestore.instance;
    CollectionReference tourneyCollection = fb.collection("tourneys");
    CollectionReference studentCollection = fb.collection("students");

    await tourneyCollection.doc(tourneyId)
    .get().then((fbObject) async {
      
      updatedTourney = fbObject.data()['events'];
      if(updatedTourney == null || updatedTourney.keys.length == 0) {
        updatedTourney = {};
        event.values.forEach((eventKey) {
          updatedTourney[eventKey.toString().split('.').last.toLowerCase()] = [];
        });
      }

      updatedTourney[eventTitle.toLowerCase()].add({'score': scores, 'participantId': toAdd.id.toString()});

      await tourneyCollection.doc(tourneyId)
      .get().then((fbObject2) async {
      
        var updatedStudent = fbObject2.data()['tourneyIds'] != null ? fbObject2.data()['tourneyIds'] : [];

        int currentTourneyIndex = updatedStudent.indexOf(tourneyId);
        if(currentTourneyIndex == -1)
        {
          updatedStudent.add(tourneyId);
          await studentCollection.doc(toAdd.id).update({'tourneyIds': updatedStudent});
        }
        await tourneyCollection.doc(tourneyId).update({'events': updatedTourney});

      });

    });

  }

  Widget scoreInput(TextEditingController _myController, List<int> scoreList) {
    return StatefulBuilder(builder: (context, StateSetter setState) {
      return Column(
        children: <Widget>[
          new Container(
            child: new Text(
              scoreList.toString(),
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          new Container(
            child: new Text(
              Score(scoreList).overallScore.toString(),
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          new Container(
            margin: new EdgeInsets.symmetric(horizontal: 50.0),
            child: new TextFormField(
              controller: _myController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Enter Score Here"
              ),
              style: Theme.of(context).textTheme.headline6,
              onChanged: (text) {
                setState(() {
                  scoreList.add(int.parse(text));
                  _myController.clear();
                  FocusScope.of(context).unfocus();
                });
              },
            ),
          )
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: DefaultTabController(
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

    // return Scaffold(
    //   body: DefaultTabController(
    //     length: 2,
    //     child: Column(
    //       children: <Widget>[
    //         Container(
    //           height: 75,
    //           color: Colors.grey.shade300,
    //           child: TabBarView(
    //             physics: NeverScrollableScrollPhysics(),
    //             children: [
    //               Icon(Icons.list),
    //               Icon(Icons.score),
    //             ],
    //           ),
    //         ),
    //         Expanded(
    //           child: TabBar(
    //             unselectedLabelColor: Colors.blue,
    //             labelColor: Colors.blue,
    //             indicatorColor: Colors.white,
    //             labelPadding: const EdgeInsets.all(0.0),
    //             tabs: [
    //               getRecordsTab(), Text("Hello") 
    //             ],
    //           ),
    //         ),
    //       ],
    //     )
    //   ),
    // );

  }

}
