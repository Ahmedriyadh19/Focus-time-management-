import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:theme_manager/theme_manager.dart';
import 'package:time_management/Model/my_time.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isDark = true;
  int _currentValueRoundPicker = 3;
  int _currentValueWorkPicker = 100;
  int _currentValueBreakPicker = 15;
  Color darkColor = const Color.fromARGB(255, 32, 33, 36);
  String? hints;
  final CountDownController _controller = CountDownController();
  List<MyTime> myWorkTime = [];

  List<Widget> myWidgetClock = [];
  List<Widget> myWorkTimeWidget = [];

  void setDark() {
    ThemeManager.of(context).setBrightnessPreference(
        _isDark ? BrightnessPreference.dark : BrightnessPreference.light);
  }

  IconButton darkBtn() {
    return IconButton(
      icon: Icon(_isDark ? Icons.sunny : FontAwesomeIcons.moon),
      onPressed: () {
        setState(() {
          _isDark = !_isDark;
          setDark();
        });
      },
    );
  }

  workBreakTime() {
    return Container(
      margin: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildCon(label: 'work time', op: 0),
          buildCon(label: 'break time', op: 1)
        ],
      ),
    );
  }

  Column buildCon({required String label, required int op}) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        NumberPicker(
          value: op == 0 ? _currentValueWorkPicker : _currentValueBreakPicker,
          minValue: 1,
          maxValue: op == 0 ? 120 : 60,
          infiniteLoop: true,
          onChanged: (value) => setState(() {
            op == 0
                ? _currentValueWorkPicker = value
                : _currentValueBreakPicker = value;
          }),
        ),
      ],
    );
  }

  Container roundPicker() {
    int min = 1;
    int max = 10;
    return Container(
      margin: const EdgeInsets.all(5),
      child: Column(
        children: [
          Text(
            'Round'.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () => setState(() {
                  if (_currentValueRoundPicker > min) {
                    _currentValueRoundPicker--;
                  }
                }),
              ),
              Text('$_currentValueRoundPicker'),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => setState(() {
                  if (_currentValueRoundPicker < max) {
                    _currentValueRoundPicker++;
                  }
                }),
              ),
            ],
          )
        ],
      ),
    );
  }

  Divider myXDivider() {
    return const Divider(
      thickness: 0.5,
      endIndent: 80,
      indent: 80,
    );
  }

  ElevatedButton submitBtn() {
    return ElevatedButton(
      style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(_isDark ? darkColor : null)),
      child: const Icon(Icons.directions_run_rounded),
      onPressed: () {
        setState(() {
          getTimeWork();
        });
      },
    );
  }

  myBtnS(double h, double w) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [submitBtn(), const SizedBox(width: 20), editBtn(h: h, w: w)],
    );
  }

  editBtn({required double h, required double w}) {
    return ElevatedButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(_isDark ? darkColor : null)),
        onPressed: () async {
          setState(() {
            myWorkTimeWidget.clear();
            getTimeWork();
            if (myWorkTime.isNotEmpty) {
              for (int i = 0; i < myWorkTime.length; i++) {
                myWorkTimeWidget.add(buildMyEdit(roundNumber: (i + 1), w: w));
              }
            }
          });
          await bottomSheet(h: h, w: w);
        },
        child: const Icon(Icons.edit));
  }

  dynamic bottomSheet({required double h, required double w}) async {
    return await showModalBottomSheet(
        backgroundColor: _isDark
            ? darkColor.withOpacity(0.5)
            : Colors.white.withOpacity(0.5),
        context: context,
        elevation: 20,
        isScrollControlled: true,
        isDismissible: true,
        enableDrag: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
        ),
        builder: (context) {
          return StatefulBuilder(
            builder: (context, StateSetter myState) {
              return Container(
                height: h,
                margin: const EdgeInsets.symmetric(vertical: 15),
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: myWorkTimeWidget),
                ),
              );
            },
          );
        });
  }

  buildMyEdit({required int roundNumber, required double w}) {
    return Center(
      child: Container(
        width: w,
        decoration: BoxDecoration(
            color: _isDark
                ? darkColor.withOpacity(0.7)
                : Colors.blue.withOpacity(0.7),
            borderRadius: BorderRadius.circular(50)),
        margin: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('round $roundNumber'.toUpperCase()),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('Work for mins'.toUpperCase()),
                            // roundPicker(isL: false)
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('Break for mins'.toUpperCase()),
                            // roundPicker(isL: false)
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever_rounded),
                      onPressed: () {
                        setState(() {
                         // myWorkTimeWidget.removeAt(roundNumber-1);
                        });
                      },
                    )
                  ],
                ),
              ]),
        ),
      ),
    );
  }

  p({required double h, required double w, required int d}) {
    return Column(
      children: [drawTime(h: h, w: w, d: d)],
    );
  }

  drawTime({required double h, required double w, required int d}) {
    return CircularCountDownTimer(
      duration: d * 60,
      initialDuration: 0,
      controller: _controller,
      width: w / 2,
      height: h / 4,
      ringColor: _isDark ? const Color.fromARGB(255, 32, 97, 12) : Colors.white,
      fillColor: _isDark ? darkColor.withOpacity(0.5) : Colors.blue,
      autoStart: false,
      isReverse: true,
      textStyle: const TextStyle(
        fontSize: 33.0,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      onStart: () {
        // debugPrint('Countdown Started');
      },
      onComplete: () {
        //  debugPrint('Countdown Ended');
      },
    );
  }

  void getTimeWork() {
    myWorkTime.clear();
    for (int i = 0; i < _currentValueRoundPicker; i++) {
      myWorkTime.add(MyTime(
          startBreak: _currentValueBreakPicker,
          startWork: _currentValueWorkPicker));
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        actions: [darkBtn()],
        centerTitle: true,
        title: Center(child: Text('Time'.toUpperCase())),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(children: [
            roundPicker(),
            myXDivider(),
            workBreakTime(),
            myBtnS(height * 0.80, width * 0.70),
            const SizedBox(height: 10),
          ]),
        ),
      ),
    );
  }
}


/*
{

class _MyHomePageState extends State<MyHomePage> {
  final int _duration = 10;
  final CountDownController _controller = CountDownController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: Center(
        child: CircularCountDownTimer(
          // Countdown duration in Seconds.
          duration: _duration,

          // Countdown initial elapsed Duration in Seconds.
          initialDuration: 0,

          // Controls (i.e Start, Pause, Resume, Restart) the Countdown Timer.
          controller: _controller,

          // Width of the Countdown Widget.
          width: MediaQuery.of(context).size.width / 2,

          // Height of the Countdown Widget.
          height: MediaQuery.of(context).size.height / 2,

          // Ring Color for Countdown Widget.
          ringColor: Colors.grey[300]!,

          // Ring Gradient for Countdown Widget.
          ringGradient: null,

          // Filling Color for Countdown Widget.
          fillColor: Colors.purpleAccent[100]!,

          // Filling Gradient for Countdown Widget.
          fillGradient: null,

          // Background Color for Countdown Widget.
          backgroundColor: Colors.purple[500],

          // Background Gradient for Countdown Widget.
          backgroundGradient: null,

          // Border Thickness of the Countdown Ring.
          strokeWidth: 20.0,

          // Begin and end contours with a flat edge and no extension.
          strokeCap: StrokeCap.round,

          // Text Style for Countdown Text.
          textStyle: const TextStyle(
            fontSize: 33.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),

          // Format for the Countdown Text.
          textFormat: CountdownTextFormat.S,

          // Handles Countdown Timer (true for Reverse Countdown (max to 0), false for Forward Countdown (0 to max)).
          isReverse: false,

          // Handles Animation Direction (true for Reverse Animation, false for Forward Animation).
          isReverseAnimation: false,

          // Handles visibility of the Countdown Text.
          isTimerTextShown: true,

          // Handles the timer start.
          autoStart: false,

          // This Callback will execute when the Countdown Starts.
          onStart: () {
            // Here, do whatever you want
            debugPrint('Countdown Started');
          },

          // This Callback will execute when the Countdown Ends.
          onComplete: () {
            // Here, do whatever you want
            debugPrint('Countdown Ended');
          },

          // This Callback will execute when the Countdown Changes.
          onChange: (String timeStamp) {
            // Here, do whatever you want
            debugPrint('Countdown Changed $timeStamp');
          },
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 30,
          ),
          _button(
            title: "Start",
            onPressed: () => _controller.start(),
          ),
          const SizedBox(
            width: 10,
          ),
          _button(
            title: "Pause",
            onPressed: () => _controller.pause(),
          ),
          const SizedBox(
            width: 10,
          ),
          _button(
            title: "Resume",
            onPressed: () => _controller.resume(),
          ),
          const SizedBox(
            width: 10,
          ),
          _button(
            title: "Restart",
            onPressed: () => _controller.restart(duration: _duration),
          ),
        ],
      ),
    );
  }

  Widget _button({required String title, VoidCallback? onPressed}) {
    return Expanded(
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.purple),
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
}*/

/*    return await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.5),
      elevation: 10,
      builder: (
        context,
      ) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateForgetPassword) {
            return Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(218, 0, 170, 179),
                  Color.fromARGB(172, 66, 239, 248),
                ],
              )), */
