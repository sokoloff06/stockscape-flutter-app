import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesModel extends ChangeNotifier {
  static const String prefsKey = 'favs';
  static const String symbolDataKey = 'isFavorite';

  SharedPreferences _prefs;
  Set<String> _favs = <String>{};

  FavoritesModel(this._prefs) {
    var list = _prefs.getStringList(prefsKey);
    if (list != null) {
      _favs = list.toSet();
    }
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
    _prefs.setStringList(prefsKey, _favs.toList(growable: false));
  }
}
