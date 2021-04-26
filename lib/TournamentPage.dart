import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'TournamentRecordPage.dart';
import 'Objects.dart';

class TournamentPage extends StatefulWidget {
  TournamentPage({Key key}) : super(key: key);

  @override
  _TournamentPageState createState() => _TournamentPageState();

}

class _TournamentPageState extends State<TournamentPage> {

  DateTime selectedDate = DateTime.now();

  List<Tournament> tourneyList = [];
  String newTourneyTitle = "";
  DateTime newTourneyDate = DateTime.now();

  @override
  void initState() { 
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadTournaments();
  }

  void loadTournaments() {
    tourneyList = [];
    FirebaseFirestore.instance.collection("tourneys").get()
    .then((tourneyCollection) {
      tourneyCollection.docs.forEach((fbTourney) {
        setState(() {
          tourneyList.add(
            Tournament(fbTourney.id, fbTourney.data()),
          );
        });
      });
    });

  }

  Widget getTourneyList() {

    return Expanded(
      child: Container(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0, right: 8.0),
        decoration: BoxDecoration(
          border: Border.all(),
        ),
        child: ListView(children: [Table(
          children: List.generate(tourneyList.length, (index) {
            return TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Card(
                    elevation: 10,
                    child: ElevatedButton(
                      onLongPress: () {Navigator.push(context, MaterialPageRoute(builder: (context) => 
                        TournamentRecordPage(tourneyList.elementAt(index)))).then((value) => loadTournaments());
                      },
                      onPressed: () { },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(width: 145, child: Text(tourneyList.elementAt(index).title, maxLines: 1, overflow: TextOverflow.ellipsis,)), 
                                Text(tourneyList.elementAt(index).getPrettyDate(), maxLines: 1, overflow: TextOverflow.ellipsis,),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () { confirmDialog(tourneyList.elementAt(index)); },
                            icon: Icon(Icons.remove_circle_outline_sharp)
                          ),
                        ],
                      ),
                    ),),
                )
              ]
            );
          }
        ))],
        shrinkWrap: true,
      )),
    );

  }

  Future<void> confirmDialog(Tournament tourney) async {

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove Student?'),
          content: SingleChildScrollView(
            child: Text('Are you sure you want to remove ${tourney.title}?',
              style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold, decoration: TextDecoration.none)
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                removeTourney(tourney);
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

  void removeTourney(Tournament toRemove) {

    FirebaseFirestore.instance.collection("tourneys").doc(toRemove.id).delete().whenComplete(() => loadTournaments());

  }

  void newTourneyPopup() {

    newTourneyDate = DateTime.now();

    void submit() {
      Map<String, dynamic> newTourneyFbObject = {};
      newTourneyFbObject['title'] = newTourneyTitle;
      newTourneyFbObject['date'] = Timestamp.fromDate(newTourneyDate);
      newTourneyFbObject['events'] = Map<String, dynamic>();
      FirebaseFirestore.instance.collection('tourneys').add(newTourneyFbObject);
      loadTournaments();
    }

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
                      padding: const EdgeInsets.only(bottom: 35.0),
                      child: Center(
                        child: Text(
                          "New Tournament",
                          style: TextStyle(fontSize: 24, color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: SizedBox(
                          width: 200,
                          child: TextFormField(
                            style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                            decoration: new InputDecoration(
                              labelStyle: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                              labelText: 'Title'
                            ),
                            onChanged: (change) { newTourneyTitle = change; }
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20,),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: 200,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: () => selectDate(setState),
                              child: Text('Select date'),
                            ),
                            SizedBox(height: 7.0,),
                            Text("${selectedDate.toLocal()}".split(' ')[0],
                              style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold, decoration: TextDecoration.none)
                            ),
                          ],
                        )
                      )
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

  Future<void> selectDate(StateSetter setState) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(Duration(days: 90)));
    if (picked != null && picked != selectedDate)
    {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
                padding: const EdgeInsets.only(top: 5.0, bottom: 75.0, left: 8.0, right: 8.0),
                child: getTourneyList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
        child: Text("Add Tournament"),
        onPressed: () {newTourneyPopup();},
      ),
    );
  }

}
