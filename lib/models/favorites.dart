import 'package:devicelocale/devicelocale.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockscape/analytics.dart';

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

  addToFavorites(String symbol, num price) async {
    _favs.add(symbol);
    String? locale = await Devicelocale.defaultLocale;
    var format = NumberFormat.simpleCurrency(locale: locale);
    Analytics.instance.logPurchase(format.currencyName, price.toDouble(),
        <AnalyticsEventItem>[AnalyticsEventItem(itemName: symbol)]);
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
