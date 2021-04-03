enum event {
  Poetry,
  Prose,
  Extemp,
  Impromptu
}

class Student {

  String id;
  String name;
  String grade;

  List<String> tourneys = [];

  Student.two(this.id, this.name, this.grade);

  Student(this.id, Map<String, dynamic> fbObject) {
    name = fbObject[name];
    grade = fbObject[grade];
  }

}

class Tournament {

  double overallScore = 1;
  int recordsLength = 0;
  List<String> participantIds = [];

  String id;
  String title;
  String date;

  dynamic events = {};

  Tournament.two(this.id, this.title, this.date);

  Tournament(this.id, Map<String, dynamic> fbObject) {
    title = fbObject[title];
    date = fbObject[date];
    for (var eventKey in fbObject[events].keys) {
      for (var record in fbObject[events][eventKey]) {
        if(events[eventKey] == null)
        {
          events[eventKey] = [Record(record)];
        }
        else
        {
          events[eventKey].add(Record(record));
        }
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

    recordsLength++;
    overallScore = (overallScore + toAdd.score.overallScore) / recordsLength;

  }

}

class Record {

  Score score;
  String participantId;
  event title;

  Record.create(this.title, this.participantId, this.score);

  Record(Map<String, dynamic> fbObject) {
    score = Score(fbObject[score]);
    participantId = fbObject[participantId];
    title = fbObject[title];
  }

}

class Score {

  double overallScore = 1;
  List<int> scores = [];

  Score(List<int> someScores) {
    addScores(someScores);
  }

  void addScores(List<int> toAdd) {
    print(toAdd);
    toAdd.forEach((element) {scores.add(element);});
    overallScore = (scores.reduce((a,b) => a + b) / scores.length);
    print(scores);
  }

}

