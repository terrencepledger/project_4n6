import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_4n6/StudentRecordPage.dart';
import 'package:random_string/random_string.dart';

import 'Objects.dart';

class StudentPage extends StatefulWidget {
  StudentPage({Key key}) : super(key: key);

  @override
  _StudentPageState createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  
  List<Student> students = [];
  String newStudentName = "";
  int newStudentGradeSelection;

  @override
  void initState() { 
    super.initState();
    loadStudents();
  }

  void loadStudents() {
    
    students = [];
    FirebaseFirestore.instance.collection("students").get()
    .then((studentCollection) {
      studentCollection.docs.forEach((student) {
        setState(() {
          students.add(Student(student.id, student.data()));
        });
      });
    });

  }

  Widget getStudentList() {

    return Container(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0, right: 8.0),
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: ListView(children: [Table(
        children: List.generate(students.length, (index) {
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Card(
                  elevation: 10,
                  child: ElevatedButton(
                    onLongPress: () {Navigator.push(context, MaterialPageRoute(builder: (context) => StudentRecordPage(students.elementAt(index))));},
                    onPressed: () { },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(width: 145, child: Text(students.elementAt(index).name, maxLines: 1, overflow: TextOverflow.ellipsis,)), 
                              Text(students.elementAt(index).grade.toString(), maxLines: 1, overflow: TextOverflow.ellipsis,),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () { confirmDialog(students.elementAt(index)); },
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
    ));
  
  }
  
  void remove(Student toRemove) {

    FirebaseFirestore.instance.collection("students").doc(toRemove.id).delete().whenComplete(() => loadStudents());

  }

  void newStudentPopup() {
    newStudentGradeSelection = 8;

    void submit() {
      Map<String, dynamic> newStudentFbObject = {};
      newStudentFbObject['name'] = newStudentName;
      newStudentFbObject['grade'] = newStudentGradeSelection;
      newStudentFbObject['tourneyIds'] = [];
      FirebaseFirestore.instance.collection('students').add(newStudentFbObject);
      loadStudents();
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, StateSetter setState) {
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
                        "New Student",
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
                          // textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                          decoration: new InputDecoration(
                            labelStyle: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold, decoration: TextDecoration.none),
                            labelText: 'Name'
                          ),
                          onChanged: (change) { newStudentName = change; }
                        ),
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
                            "Grade", 
                            style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: DropdownButton<int>(
                              items: <int>[8, 9, 10, 11, 12].map((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text(
                                    value.toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 18, color: Colors.blue, decoration: TextDecoration.none),
                                  ),
                                );
                              }).toList(),
                              value: newStudentGradeSelection,
                              onChanged: (newValue) {
                                setState(() {
                                  newStudentGradeSelection = newValue;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
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
        });
      }
    );
  }

  Future<void> confirmDialog(Student toRemove) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove Student?'),
          content: SingleChildScrollView(
            child: Text('Are you sure you want to remove ' + toRemove.name + "?",
              style: TextStyle(fontSize: 16, color: Colors.blue, fontWeight: FontWeight.bold, decoration: TextDecoration.none)
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                remove(toRemove);
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
                "Students",
                style: Theme.of(context).textTheme.headline3
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0, bottom: 75.0, left: 8.0, right: 8.0),
                child: getStudentList(),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(primary: Theme.of(context).primaryColorDark),
        child: Text("Add Student"),
        onPressed: () {newStudentPopup();},
      ),
    );
  }
}
