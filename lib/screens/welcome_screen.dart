import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:math_quiz_app/constants.dart';
import 'package:math_quiz_app/screens/game_screen.dart';

class  WelcomeScreen extends StatelessWidget {

  static final id = 'welcome_screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container (
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/backgroundImage.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: AbsorbPointer(
            child: Column(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                 Container(
                  child: AnimatedTextKit (
                    animatedTexts: [
                      ColorizeAnimatedText(
                        'Math Quiz \nGame',
                        textAlign: TextAlign.center, //가운데 정렬
                        textStyle: kAnimationTextStyle,
                        colors: kColorizeAnimationColors,
                       )
                  ],
                  repeatForever: true,
                ),
              ),
             Text(
                  'Tap to Start',
                  textAlign: TextAlign.center,
                  style: KTapToStartTextStyle,
                )
            ],
        ),
          ),
          onTap: () {
            Navigator.pushNamed(context, GameScreen.id);
          },
         ),
        ),
    );
  }
}