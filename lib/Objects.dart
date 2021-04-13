import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

enum event {
  Poetry,
  Prose,
  Extemp,
  Impromptu
}

class Student {

  String id;
  String name;
  int grade;
  bool isReady = false;

  List<String> tourneyIds = [];

  Function callBack;

  Student(this.id, Map<String, dynamic> fbObject) {
    name = fbObject["name"];
    grade = fbObject["grade"];
    for (var id in fbObject['tourneyIds']) {
      tourneyIds.add(id as String);
    }
    isReady = true;
  }

  Student.load(this.id) {
    refresh();
  }

  Future<void> refresh() async {
    return FirebaseFirestore.instance.collection("students").doc(id).get().then((value) => {
      name = value["name"],
      grade = value["grade"],
      for (var id in value['tourneyIds']) {
        if(id!="")
          tourneyIds.add(id as String)
      },
      if(!isReady)
        ready()
    });
  }

  void onReady(Function func) {
    if(!isReady)
      callBack = func;
    else
      func.call();
  }

  void ready() => {
    isReady = true,
    if(callBack != null)
      callBack.call()
  };

}

class Tournament {

  double overallScore = 0;
  int recordsLength = 0;
  List<String> participantIds = [];
  List<dynamic> scores = [];

  String id;
  String title;
  DateTime date;

  dynamic events = {};

  Tournament.two(this.id, this.title, this.date);

  Tournament(this.id, Map<String, dynamic> fbObject) {
    title = fbObject["title"];
    date = (fbObject["date"] as Timestamp).toDate();
    if(fbObject["events"] != null)
      for (String eventKeyString in fbObject["events"].keys) {
        for (var record in fbObject["events"][eventKeyString]) {
          addRecord(
            Record(record, 
              event.values.firstWhere((e) => e.toString().split('.').last.toLowerCase() == eventKeyString.toLowerCase()), 
              id
            )
          );
        }
      }
  }

  void addRecord(Record toAdd) {

    if(events[toAdd.title] == null)
    {
      events[toAdd.title] = [toAdd];
    }
    else
    {
      events[toAdd.title].add(toAdd);
    }

    toAdd.score.scores.forEach((element) {scores.add(element);});
    if(scores.length != 0)
      overallScore = double.parse((scores.reduce((a,b) => a + b) / scores.length).toStringAsFixed(2));

  }

  String getPrettyDate() {

    return DateFormat('MM-dd-yyyy').format(date);

  }

}

class Record {

  Score score;
  String participantId;
  String tourneyId;
  event title;

  Record.create(this.title, this.participantId, this.tourneyId, this.score);

  Record(Map<String, dynamic> fbObject, this.title, this.tourneyId) {
    score = Score(fbObject["score"]);
    participantId = fbObject["participantId"];
  }

}

class Score {

  double overallScore = 1;
  List<dynamic> scores = [];

  Score(List<dynamic> someScores) {
    addScores(someScores);
  }

  int getSum() => scores.reduce((a,b) => a + b);

  void addScores(List<dynamic> toAdd) {
    toAdd.forEach((element) {scores.add(element as int);});
    if(scores.length != 0)
      overallScore = double.parse(((scores.reduce((a,b) => a + b) / scores.length)).toStringAsFixed(2));
  }

}

