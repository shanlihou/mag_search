import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';

import 'models/db/http_cache.dart';
import 'models/db/search_history.dart';
import 'views/page/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var path = await getApplicationDocumentsDirectory();
  Hive.init(path.path);
  Hive.registerAdapter(HttpCacheAdapter());
  Hive.registerAdapter(SearchHistoryAdapter());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: const HomePage(),
        );
      },
    );
  }
}
