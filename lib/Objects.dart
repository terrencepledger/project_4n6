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

  Student(this.id, this.name, this.grade);

}

class Tournament {

  double overallScore = 1;
  int recordsLength = 0;
  List<String> participantIds = [];

  String id;
  String title;
  String date;

  dynamic events = {};

  Tournament(this.id, this.title, this.date);

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

  Record(this.title, this.participantId, this.score);

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

