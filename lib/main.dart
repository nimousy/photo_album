import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:photo_album/screen/login_screen.dart';
import 'package:photo_album/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeChanger>(
      create: (_) => ThemeChanger(ThemeData.light()), 
      child: Consumer<ThemeChanger>(
        builder: (context, themeChanger, _) {
          return MaterialApp(
            title: 'Photo Album Application',
            theme: themeChanger.getTheme(), 
            home: Login(),
          );
        },
      ),
    );
  }
}
