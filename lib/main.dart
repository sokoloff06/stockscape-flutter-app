import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockscape/analytics.dart';
import 'package:stockscape/ui/home_screen.dart';
import 'package:stockscape/ui/stock_detail_screen.dart';

import 'api_service.dart';
import 'models/favorites.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
        path: '/stocks/:symbol',
        builder: (context, state) =>
            StockDetailScreen(state.pathParameters['symbol']!))
  ],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  FavoritesModel(prefs);
  Cache(prefs);
  runApp(ChangeNotifierProvider(
      create: (BuildContext context) {
        return FavoritesModel.getInstance();
      },
      child: const MyApp()));
  // if (kIsWeb) {
  //   SemanticsBinding.instance.ensureSemantics();
  // }
}

class MyApp extends StatefulWidget {
  static const IS_DEBUG_BUILD = true;
  static final APIService apiService = APIService(
      'cjp2419r01qj85r47bhgcjp2419r01qj85r47bi0',
      'iEzh6dNrbIfRncuAZdMRQ71fCLkMlD1M');

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<SharedPreferences> futurePrefs = SharedPreferences.getInstance();
  late SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    futurePrefs.then((value) => () {
          prefs = value;
        });
    Analytics.instance.initSDKs();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      title: 'Stock Market App',
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
    );
  }
}
