import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/players.dart';

class AppState with ChangeNotifier {
  AppState() {
    _load();
  }

  // defaults
  List<Player> _players = [];
  int _currentPlayer = 0;
  bool _gameIsRunning = true;
  ThemeData _themeData;
  bool _blitz = false;
  Timer _timer;
  Duration _timerDuration = Duration(minutes: 1);
  String _timerAlarmSound = 'sounds/Foghorn.mp3';
  Map _themePrefs = {
    "textSize": 25.0,
    "brightness": Brightness.dark,
    "primaryColor": Color(0xff0277bd),
    "accentColor": Color(0xff42a5f5),
  };

  // getters and setters
  List<Player> get getPlayers => _players;
  bool get gameIsRunning => _gameIsRunning;
  Map get prefs => _themePrefs;
  bool get blitz => _blitz;
  String get timerAlarmSound => _timerAlarmSound.substring( // todo: fix this shit with regexp pattern matching?
      _timerAlarmSound.lastIndexOf("/")+1, _timerAlarmSound.lastIndexOf(".")
  );
  Duration get timerDuration => _timerDuration;
  ThemeData get theme => _themeData;

  set timerAlarmSound(String sound) {
    print("sounds/$sound.mp3");
    _timerAlarmSound = "sounds/$sound.mp3";
    _save();    // TODO: don't forget to save timer value, cancel it and restart with old value and new sound!
  }

  set timerDuration(Duration duration) {
    _timerDuration = duration;
    _save();
  }

  set blitz(bool mode) {
    _blitz = mode;
    notifyListeners();
  }

  // methods
  void themeTextSize(double size) {
    _themePrefs['textSize'] = size;
    _updateTheme();
  }

  void flipDark(s) {
    _themePrefs['brightness'] = s ? Brightness.dark : Brightness.light;
    _updateTheme();
  }

  void setColor(String kind, c) {
    _themePrefs[kind] = c;
    _updateTheme();
  }

  void _updateTheme() {
    _themeData = ThemeData(
      brightness: _themePrefs['brightness'],
      primaryColor: _themePrefs['primaryColor'],
      accentColor: _themePrefs['accentColor'],
      textTheme: TextTheme(
        headline5: TextStyle(
            fontSize: _themePrefs['textSize'],
            fontWeight: FontWeight.bold
        ),
      ),
    );
    _save();
  }

  void addPlayer(Player player) {
    _players.add(player);
    _save();
  }

  void switchPlayers(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final player = _players.removeAt(oldIndex);
    _players.insert(newIndex, player);
    _save();
  }

  void tossCoin() {
    _players.shuffle();
    _save();
  }

  void addScore(int score) {
    if (_timer != null) _timer.cancel();
    _players[_currentPlayer].addScore(score);
    if (_blitz) {
      _timer = Timer(_timerDuration, () => Audio.load(_timerAlarmSound.replaceAll(' ', '_')).play());
    } else {
      _timer = null;
    }
    nextPlayer();
  }

  void editScore(Player player, int index, int score) {
    Player pl = _players.firstWhere((element) => element == player);
    pl.scores[index] = score;
    _save();
  }

  void finishGame() {
    if (_timer != null) _timer.cancel();
    _gameIsRunning = false;
    _save();
  }

  void newGame() {
    if (_timer != null) _timer.cancel();
    _gameIsRunning = true;
    _players.forEach((player) {player.scores = [];});
    _currentPlayer = 0;
    _save();
  }

  void removePlayer(String playerName) {
    _players.removeWhere((item) => item.name == playerName);
    _save();
  }

  void nextPlayer() {
    _currentPlayer += 1;
    if (_currentPlayer == _players.length) _currentPlayer = 0;
    _save();
  }

  bool isPlayerCurrent(Player player) {
    return _players.indexOf(player) == _currentPlayer;
  }

  // shared preferences
  void _load() => _store(load: true);
  void _save() => _store();
  void _store({bool load = false}) async {
    const String _spCurrentPlayer = 'elevenCurrentPlayer';
    const String _spPlayers = 'elevenPlayers';
    const String _spBlitzDuration = 'elevenBlitzDuration';
    const String _spBlitzAlarmSound = 'elevenBlitzAlarmSound';
    const String _spPrefs = 'elevenPreferences';
    const String _spGameIsRunning = 'elevenGameIsRunning';
    final preferences = await SharedPreferences.getInstance();

    if (load) {
      _currentPlayer = preferences.getInt(_spCurrentPlayer) ?? 0;
      _gameIsRunning = preferences.getBool(_spGameIsRunning) ?? true;
      var ps = json.decode(preferences.getString(_spPlayers) ?? "{}");
      _players = ps.isEmpty
          ? []
          : List<Player>.from(ps.map((i) => Player.fromJson(i)));
      _timerDuration = Duration(minutes: preferences.getInt(_spBlitzDuration) ?? _timerDuration.inMinutes);
      _timerAlarmSound = preferences.getString(_spBlitzAlarmSound) ?? _timerAlarmSound;
      var pr = preferences.getStringList(_spPrefs) ?? [];
      if (pr.isNotEmpty) _themePrefs = deserialize(pr);
      _updateTheme();
    } else {
      await preferences.setInt(_spCurrentPlayer, _currentPlayer);
      await preferences.setBool(_spGameIsRunning, _gameIsRunning);
      await preferences.setString(_spPlayers, json.encode(_players));
      await preferences.setStringList(_spPrefs, serialize(_themePrefs));
      await preferences.setInt(_spBlitzDuration, _timerDuration.inMinutes);
      await preferences.setString(_spBlitzAlarmSound, _timerAlarmSound);
    }
    notifyListeners();
  }

  Map deserialize(List<String> prefs) {
    return {
      'textSize': double.tryParse(prefs[0]),
      'brightness': prefs[1].contains('dark') ? Brightness.dark : Brightness.light,
      'primaryColor': Color(int.tryParse(prefs[2])),
      'accentColor': Color(int.tryParse(prefs[3])),
    };
  }

  List<String> serialize(Map prefs) {
    return [
      prefs['textSize'].toString(),
      prefs['brightness'].toString(),
      prefs['primaryColor'].value.toString(),
      prefs['accentColor'].value.toString(),
    ];
  }
}