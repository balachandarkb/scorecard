class Player {
  final String name;
  List<int> scores;

  Player(this.name, this.scores);

  Map toJson() => {
    'name': name,
    'scores': scores,
  };

  factory Player.fromJson(var json) {
    String n = json['name'];
    List<int> s = List<int>.from(json['scores']);
    return Player(n, s);
  }

  void addScore(score) {
    this.scores.add(score);
  }

  int totalScore() {
    return this.scores.fold(0, (a, b) => a + b);
  }
}