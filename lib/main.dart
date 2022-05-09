import 'package:flutter/material.dart';
import 'package:math_quiz_app/screens/game_screen.dart';
import 'screens/welcome_screen.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MathQuizApp());
}

class MathQuizApp extends StatelessWidget {
  const MathQuizApp([Key? key]) : super(key: key);

  @override
  Widget build(BuildContext context) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
    return MaterialApp(
      debugShowCheckedModeBanner: false, //디버그 표시 지우기
      initialRoute: WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        GameScreen.id: (context) => GameScreen()
      },
    );
  }
}