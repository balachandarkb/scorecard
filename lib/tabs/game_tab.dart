import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'file:///C:/Users/Admin/AndroidStudioProjects/scorecard/lib/app_state.dart';
import 'package:scorecard/models/players.dart';

class Scores extends StatefulWidget {
  @override
  ScoresState createState() => ScoresState();
}

class ScoresState extends State<Scores> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return
      CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: true,
              backgroundColor: Theme.of(context).accentColor,
              titleSpacing: 0,
              title: Row(
                children: [
                  for (var player in appState.getPlayers) Expanded(
                      child: Text(
                        player.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headline5,
                      )
                  )
                ],
              ),
            ),
            SliverToBoxAdapter(
                child: SingleChildScrollView(
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (var player in appState.getPlayers) Expanded(
                              child: scoresColumn(player))
                        ]
                    )
                )
            )
          ]
      );
  }

  Widget scoresColumn(Player player) {
    final appState = Provider.of<AppState>(context);
    List<int> scores = player.scores;

    return ListView.separated(
      shrinkWrap: true,
      primary: false,
      reverse: true,
      itemCount: scores.length + 1,
      separatorBuilder: (context, index) => Divider(height: 0),
      itemBuilder: (context, index) {
        if (index == scores.length)
          if (appState.isPlayerCurrent(player) && appState.gameIsRunning)
            return ListTile(
                title: FloatingActionButton(
                  mini: true,
                  onPressed: () async {
                    int newScore = await getScoreValue(context, null);
                    if (newScore != null) appState.addScore(newScore);
                  },
                  child: Icon(Icons.add),
                )
            );
          else
            return null;
        else
          return ListTile(
            onLongPress: () async {
              int newScore = await getScoreValue(context, scores[index]);
              if (newScore != null) appState.editScore(player, index, newScore);
            },
            title: Text(
              scores[index].toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline5,
            ),
          );
      },
    );
  }

  Future<int> getScoreValue(BuildContext context, int score) async {
    String dialogText = score == null ? "Enter score" : "Edit score";
    String scoreEntered;
    TextEditingController initialValue = score == null ? null : TextEditingController(text: score.toString());
    int _parsedInput(String input) {
      return input.contains(RegExp(r"\d"))
          ? input.split("*").fold(1, (a, b) => a * (int.tryParse(b) ?? 1))
          : null;
    }
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(dialogText),
            content: TextField(
                controller: initialValue,
                autofocus: true,
                keyboardType: TextInputType.phone,
                inputFormatters: [WhitelistingTextInputFormatter(RegExp(r"\d|\*"))],
                decoration: InputDecoration(),
                onChanged: (s) => scoreEntered = s,
                onSubmitted: (_) => Navigator.of(context).pop(_parsedInput(scoreEntered))
            ),
            actions: [
              FlatButton(
                  child: Text('CANCEL'),
                  onPressed: () => Navigator.of(context).pop()
              ),
              FlatButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(_parsedInput(scoreEntered)),
              ),
            ],
          );
        }
    );
  }
}