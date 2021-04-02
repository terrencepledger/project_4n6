import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_4n6/StudentRecordPage.dart';
import 'package:random_string/random_string.dart';


import 'Objects.dart';

Widget StudentPage(BuildContext context) {

  List<Student> students = [];

  Widget getStudentList() {

    List.generate(50, (index) {
      int grade = randomBetween(8, 12);
      students.add(Student(index.toString(), randomString(randomBetween(4, 7)), "Grade: $grade"));
    });

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
                              Text(students.elementAt(index).grade, maxLines: 1, overflow: TextOverflow.ellipsis,),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () { print("Something happened..."); },
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

  return Center(
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
            padding: const EdgeInsets.only(top: 5.0, bottom: 8.0, left: 8.0, right: 8.0),
            child: getStudentList(),
          ),
        ),
      ],
    ),
  );

}
