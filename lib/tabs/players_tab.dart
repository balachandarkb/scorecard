import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'file:///C:/Users/Admin/AndroidStudioProjects/scorecard/lib/app_state.dart';
import 'package:scorecard/models/players.dart';

class PlayersSelection extends StatefulWidget {
  @override
  PlayersSelectionState createState() => PlayersSelectionState();
}

class PlayersSelectionState extends State<PlayersSelection> {

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
        body: ReorderableListView(
          onReorder: (oldIndex, newIndex) => appState.switchPlayers(oldIndex, newIndex),
          children: appState.getPlayers
              .asMap()
              .map((index, player) => MapEntry(index, playerCard(index, player)))
              .values
              .toList(),
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FloatingActionButton(
                onPressed: () async {
                  String name = await newPlayerName(context);
                  if (name != "") appState.addPlayer(Player(name, []));
                },
                child: Icon(Icons.person_add),
              )
            ],
          ),
        )
    );
  }

  Widget playerCard(index, player) {
    final appState = Provider.of<AppState>(context);

    return Card(
        key: ValueKey(index),
        child: Row(
          children: [

            Expanded(
                child:
                ListTile(
                  title: Text(
                    player.name,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                )
            ),
          ],
        )
    );
  }

  Future<String> newPlayerName(BuildContext context) async {
    String playerName;
    return await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Enter player's name"),
            content: TextField(
                autofocus: true,
                onChanged: (s) => playerName = s,
                decoration: InputDecoration(),
                onSubmitted: (s) => Navigator.of(context).pop(s)
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('CANCEL'),
                onPressed: () => Navigator.of(context).pop(""),
              ),
              FlatButton(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(playerName),
              ),
            ],
          );
        }
    );
  }
}