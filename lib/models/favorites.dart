import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesModel extends ChangeNotifier {
  static late FavoritesModel instance;
  static const String favsKey = 'favs';
  static const String isFavKey = 'isFavorite';
  final SharedPreferences _prefs;
  Set<String> _favs = <String>{};

  FavoritesModel(this._prefs) {
    instance = this;
    var favsList = _prefs.getStringList(favsKey);
    if (favsList != null) {
      _favs = favsList.toSet();
    }
  }

  static FavoritesModel getInstance() {
    return instance;
  }

  bool isFavorite(String symbol) {
    return _favs.contains(symbol);
  }

  addToFavorites(String symbol) {
    _favs.add(symbol);
    _finishTransaction();
  }

  removeFromFavorites(String symbol) {
    _favs.remove(symbol);
    _finishTransaction();
  }

  _finishTransaction() {
    notifyListeners();
    _saveStateToPrefs();
  }

  _saveStateToPrefs() {
    _prefs.setStringList(favsKey, _favs.toList(growable: false));
  }

  Set<String> getFavorites() {
    return _favs;
  }
}
