import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photo_album/theme.dart';

class themeScreen extends StatelessWidget {
  const themeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);
    return new Scaffold(
      appBar: AppBar(
        title: Text('Change Theme'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[ 
            TextButton(   
              child: Text('Dark Theme'),
              onPressed: () => _themeChanger.setTheme(ThemeData.dark())
            ),
            TextButton(   
              child: Text('Light Theme'),
              onPressed: () => _themeChanger.setTheme(ThemeData.light())
            ),
          ],
        ),
      ),
    );
  }
}

