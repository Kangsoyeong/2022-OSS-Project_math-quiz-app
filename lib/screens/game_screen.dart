import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:math_quiz_app/quizBrain.dart';
import 'package:math_quiz_app/constants.dart';
import 'package:outline_gradient_button/outline_gradient_button.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

QuizBrain _quizBrain = QuizBrain();
int _score = 0;
int _highScore = 0;
double _value = 0;
int _falseCounter = 0;
int _totalNumberOfQuizzes = 0;

class GameScreen extends StatefulWidget {
  static final id = 'game_screen';

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late Timer _timer;
  int _totalTime = 0;

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() async {
    _quizBrain.makeQuiz();
    startTimer();
    _value = 1;
    _score = 0;
    _falseCounter = 0;
    _totalNumberOfQuizzes = 0;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    _highScore = preferences.getInt('highscore') ??
        0; //게임을 완전하게 종료했다가 실행했을 때에도 HIGHSCORE가 저장되도록 함.
  }

  void startTimer() {
    const speed = Duration(milliseconds: 100);
    _timer = Timer.periodic(speed, (timer) {
      if (_value > 0) {
        setState(() {
          _value > 0.005
              ? _value -= 0.005
              : _value = 0; //시간이 끝났을 때 앱이 꺼지는 현상 방지. 숫자를 작게 입력할수록 천천히 줄어든다.
          _totalTime = (_value * 20 + 1)
              .toInt(); //1:0.005 = 200 -> 1 Second is 10 * 100 Millisecond -> 200:10 = 20.
        });
      } else {
        setState(() {
          _totalTime = 0;
          showMyDialog();
          _timer.cancel();
        });
      }
    });
  }

  Future<void> showMyDialog() {
    return showDialog<void>(
        context: context,
        barrierDismissible: false, //user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
              25,
            )),
            backgroundColor: Color(0xff1542bf),
            title: FittedBox(
              child: const Text('GAME OVER',
                  textAlign: TextAlign.center, style: kTitleTS),
            ),
            content: Text('Score: $_score | $_totalNumberOfQuizzes',
                //GAME OVER 아래에 나오는 점수 | 총 풀은 문제 수
                textAlign: TextAlign.center, //가운데 정렬
                style: kContentTS),
            actions: [
              TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: const Text('EXIT', style: kDialogButtonTS),
              ),
              TextButton(
                onPressed: () {
                  startGame();
                  Navigator.of(context).pop(); //다시하기 버튼 눌러서 게임 재시작
                },
                child: const Text('PLAY AGAIN', style: kDialogButtonTS),
              ),
            ],
          );
        });
  }

  CircularPercentIndicator buildCircularPercentIndicator() {
    return CircularPercentIndicator(
      radius: 65.0,
      lineWidth: 12,
      percent: _value,
      circularStrokeCap: CircularStrokeCap.round,
      //끝 모양을 둥글게
      center: Text(
        '$_totalTime',
        style: kTimerTextStyle,
      ),
      //원 안에 줄어드는 숫자 표시
      progressColor: _value > 0.6
          ? Colors.green
          : _value > 0.3
          ? Colors.yellow
          : Colors.red, //시간이 지남에 따라 색이 초록색->노란색->빨간색으로 변함.
    );
  }



  Column getPortraitMode() { //세로모드 함수
    return Column(
      children: [
        ScoreIndicators(),
        QuizBody(),
        Expanded(flex: 3, child: buildCircularPercentIndicator()),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              ReUsableOutlineButton(
                  color: Colors.redAccent, userChoice: 'FALSE'),
              ReUsableOutlineButton(
                  color: Colors.lightGreenAccent, userChoice: 'TRUE'),
            ],
          ),
        ),
      ],
    );
  }

  Row getLandscapeMode() { //가로모드 함수
    return Row(
      children: [
        ReUsableOutlineButton(userChoice: 'FALSE', color: Colors.redAccent),
        Expanded(
          flex:3,
            child: Column(
              children: [
              ScoreIndicators(),
              QuizBody(),
                Expanded(flex: 3, child: buildCircularPercentIndicator()),
          ],
        ),
        ),
        ReUsableOutlineButton(
            userChoice: 'TRUE', color: Colors.lightGreenAccent),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    var data = MediaQuery.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: kGradientColors,
          ),
        ),
        child: getTrueMode(data),
      ),
    );
  }

  Widget getTrueMode(MediaQueryData data) {
    if (data.size.width < data.size.height) //데이터의 크기(화면에 보이는 크기. 글자, 버튼 등)가 가로 < 세로이면
      return getPortraitMode(); //세로모드 반환(호출)
    else //그렇지 않으면
      return getLandscapeMode(); //가로모드 반환(호출)
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  } //game screen에서 welcome screen으로 돌아올 시 timer가 background에서 작동되는 현상 방지
}

class ReUsableOutlineButton extends StatelessWidget {
  ReUsableOutlineButton({this.userChoice, this.color});

  final userChoice;
  final color;

  Future<void> playSound(String soundName) async {
    final _player = AudioCache();
    _player.play(soundName);
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setInt('highscore', _highScore);
  }

  void checkAnswer() {
    if (userChoice == _quizBrain.quizAnswer) {
      playSound('correct-choice.wav'); //정답을 맞추면 나오는 소리
      _score++;
      _value >= 0.89 ? _value = 1 : _value += 0.1;
      if (_highScore < _score) {
        _highScore = _score;
      }
    } else {
      playSound('wrong-choice.wav'); //오답을 고르면 나오는 소리
      _falseCounter++;
      _value < 0.02 * _falseCounter
          ? _value = 0
          : _value -= 0.02 * _falseCounter;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: OutlineGradientButton(
          padding: EdgeInsets.symmetric(horizontal: 20),
          gradient: LinearGradient(
            colors: kGradientColors,
          ),
          strokeWidth: 12,
          child: Center(
              child: FittedBox(
            child: Text(
              userChoice,
              style: kButtonTextStyle.copyWith(color: color),
            ),
          )),
          elevation: 1,
          radius: Radius.circular(36),
          onTap: () {
            _totalNumberOfQuizzes++;
            checkAnswer();
            _quizBrain.makeQuiz();
          },
        ),
      ),
    );
  }
}

class QuizBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: FittedBox(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            _quizBrain.quiz,
            style: kQuizTextStyle,
          ),
        ),
      ),
    );
  }
}

class ScoreIndicators extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 24, right: 24, top: 24),
      child: FittedBox(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ScoreIndicator(label: 'HIGHSCORE', score: '$_highScore'),
          SizedBox(width: 40),
          ScoreIndicator(label: 'SCORE', score: '$_score')
        ],
      )),
    );
  }
}

class ScoreIndicator extends StatelessWidget {
  ScoreIndicator({this.label, this.score});

  final label;
  final score;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: kScoreLabelTextStyle),
        SizedBox(height: 10),
        Text(score, style: kScoreIndicatorTextStyle),
      ],
    );
  }
}