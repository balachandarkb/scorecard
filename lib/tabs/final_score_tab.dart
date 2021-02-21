import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'file:///C:/Users/Admin/AndroidStudioProjects/scorecard/lib/app_state.dart';
import 'package:scorecard/models/players.dart';

class FinalScores extends StatefulWidget {
  @override
  FinalScoresState createState() => FinalScoresState();
}

class FinalScoresState extends State<FinalScores> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    List<Player> sortedPlayers = [...appState.getPlayers];
    sortedPlayers.sort((a, b) => b.totalScore().compareTo(a.totalScore()));
    return Scaffold(
        body: Column(
          children: [
            for (var player in sortedPlayers) finalScore(player)
          ],
        ),
        floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FloatingActionButton(
                onPressed: () async {
                  String question = "Finish this game?";
                  await dialogOkCancel(context, question) ? appState.finishGame() : null;
                },
                child: Icon(Icons.close),
              ),
              FloatingActionButton(
                onPressed: () async {
                  String question = "Are you sure to reset the score ?";
                  await dialogOkCancel(context, question) ? appState.newGame() : null;
                },
                backgroundColor: Colors.red,
                child: Icon(Icons.delete),
              )
            ],
          ),
        )
    );
  }

  Widget finalScore(Player player) {
    return Card(
        child: Container(
            padding: EdgeInsets.all(10.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(player.name,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  Text(player.totalScore().toString(),
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ]
            )
        )
    );
  }

  Future<bool> dialogOkCancel (BuildContext context, String text) async {
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(text),
            actions: <Widget>[
              FlatButton(
                child: Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              ),
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ],
          );
        }
    );
  }
}
