import 'dart:async';
import 'dart:ffi';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:theme_manager/theme_manager.dart';
import 'package:time_management/model/my_time.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CountDownController _controller = CountDownController();
  late Timer timer;
  bool _isDark = true;
  bool _isStart = false;
  bool _isAttempt = false;
  int _currentValueRoundPicker = 3;
  int _currentValueWorkPicker = 20;
  int _currentValueBreakPicker = 15;
  final int _targetIndex = 0;
  final int _maxRound = 12;
  final int _maxWorkTime = 120;
  final int _maxBreakTime = 60;
  Color darkColor = const Color.fromARGB(255, 32, 33, 36);
  String? hints;
  List<MyTime> myWorkTime = [];
  List<Widget> myWorkTimeWidget = [];
  List<int> myTimeTarget = [];
  List<List<int>> myInt = [];

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

  Container workBreakTimeWidget() {
    return Container(
      margin: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildWorkBreakTime(label: 'work time', op: 0),
          buildWorkBreakTime(label: 'break time', op: 1)
        ],
      ),
    );
  }

  Column buildWorkBreakTime({required String label, required int op}) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        NumberPicker(
          value: op == 0 ? _currentValueWorkPicker : _currentValueBreakPicker,
          minValue: 1,
          maxValue: op == 0 ? _maxWorkTime : _maxBreakTime,
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
    int max = _maxRound;
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

  Container editTimePicker(
      {required int round, required int op, required Function setNewState}) {
    int min = 1;
    int max = op == 0 ? _maxWorkTime : _maxBreakTime;
    return Container(
      margin: const EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () => setNewState(() {
              if (myInt[round][op] > min) {
                myInt[round][op]--;
              }
            }),
            onLongPressStart: (details) {
              timer = Timer.periodic(
                const Duration(milliseconds: 100),
                (timer) {
                  setNewState(() {
                    if (myInt[round][op] > min) {
                      myInt[round][op]--;
                    }
                  });
                },
              );
            },
            onLongPressEnd: ((details) {
              timer.cancel();
            }),
            child: const Icon(Icons.remove),
          ),
          Text('${myInt[round][op]}'),
          GestureDetector(
            onTap: () => setNewState(() {
              if (myInt[round][op] < max) {
                myInt[round][op]++;
              }
            }),
            onLongPressStart: (details) {
              timer =
                  Timer.periodic(const Duration(milliseconds: 100), ((timer) {
                setNewState(() {
                  if (myInt[round][op] < max) {
                    myInt[round][op]++;
                  }
                });
              }));
            },
            onLongPressEnd: ((details) {
              timer.cancel();
            }),
            child: const Icon(Icons.add),
          ),
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

  ElevatedButton submitBtn({required double h, required double w}) {
    return ElevatedButton(
      style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(_isDark ? darkColor : null)),
      child: const Icon(Icons.directions_run_rounded),
      onPressed: () {
        setState(() {
          getTimeWork();
          getMyInt();
          getTargetTime();
        });
      },
    );
  }

  void getTargetTime() {
    setState(() {
      myTimeTarget.clear();
      for (int i = 0; i < myWorkTime.length; i++) {
        myTimeTarget.add(myWorkTime[i].startWork);
        myTimeTarget.add(myWorkTime[i].startBreak);
      }
    });
  }

  Row myBtnS(double h, double w) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        submitBtn(h: h, w: w),
        const SizedBox(width: 20),
        editBtn(h: h, w: w)
      ],
    );
  }

  ElevatedButton editBtn({required double h, required double w}) {
    return ElevatedButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(_isDark ? darkColor : null)),
        onPressed: () async {
          setState(() {
            myWorkTimeWidget.clear();
            getTimeWork();
          });
          await bottomSheet(h: h, w: w);
        },
        child: const Icon(Icons.reorder_rounded));
  }

  void getMyInt() {
    setState(() {
      myInt.clear();
      if (myWorkTime.isNotEmpty) {
        for (int i = 0; i < myWorkTime.length; i++) {
          myInt.add([myWorkTime[i].startWork, myWorkTime[i].startBreak]);
        }
      }
    });
  }

  void initMyEdit({required double w, required Function x}) {
    myWorkTimeWidget.clear();
    if (myWorkTime.isNotEmpty) {
      for (int i = 0; i < myWorkTime.length; i++) {
        myWorkTimeWidget.add(buildMyEdit(roundNumber: (i + 1), w: w, edit: x));
      }
    }
  }

  dynamic bottomSheet({required double h, required double w}) async {
    getMyInt();
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
            builder: (context, myState) {
              initMyEdit(w: w, x: myState);
              return Container(
                height: h,
                margin: const EdgeInsets.symmetric(vertical: 15),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: myWorkTimeWidget),
                      submitMyCustomizeWorkTimeBtn(h: h, w: w, ctx: context)
                    ],
                  ),
                ),
              );
            },
          );
        });
  }

  Center buildMyEdit(
      {required int roundNumber, required double w, required Function edit}) {
    return Center(
      child: Container(
        width: w,
        decoration: BoxDecoration(
            color: _isDark
                ? darkColor.withOpacity(0.7)
                : Colors.blue.withOpacity(0.7),
            borderRadius: BorderRadius.circular(15)),
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
                            editTimePicker(
                                round: roundNumber - 1,
                                op: 0,
                                setNewState: edit)
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('Break for mins'.toUpperCase()),
                            editTimePicker(
                                round: roundNumber - 1,
                                op: 1,
                                setNewState: edit)
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever_rounded),
                      onPressed: () {
                        setState(() {
                          edit(() {
                            myInt.removeAt(roundNumber - 1);
                            myWorkTime.removeAt(roundNumber - 1);
                            myWorkTimeWidget.removeAt(roundNumber - 1);
                          });
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

  Column drawTime({required double h, required double w, required int d}) {
    return Column(
      children: [
        CircularCountDownTimer(
          duration: d * 60,
          controller: _controller,
          width: w / 2,
          height: h / 4,
          ringColor:
              _isDark ? const Color.fromARGB(255, 32, 97, 12) : Colors.white,
          fillColor: _isDark ? darkColor.withOpacity(0.5) : Colors.blue,
          autoStart: false,
          isReverse: true,
          textStyle: TextStyle(
            fontSize: 33.0,
            color: _isDark ? Colors.greenAccent : Colors.blueAccent,
            fontWeight: FontWeight.bold,
          ),
          onStart: () {},
          onComplete: () {},
          onChange: ((value) {}),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            clockBtn(),
          ],
        )
      ],
    );
  }

  ElevatedButton clockBtn() {
    return ElevatedButton(
      style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(_isDark ? darkColor : null)),
      onPressed: () {
        setState(() {
          if (!_isAttempt) {
            _controller.start();
            _isAttempt = true;
          } else {
            _isStart = !_isStart;
            _isStart ? _controller.pause() : _controller.resume();
          }
        });
      },
      child: !_isAttempt
          ? Icon(Icons.start_rounded)
          : _isStart
              ? Icon(Icons.play_arrow_rounded)
              : Icon(Icons.pause_rounded),
    );
  }

  void getTimeWork() {
    setState(() {
      myWorkTime.clear();
      for (int i = 0; i < _currentValueRoundPicker; i++) {
        myWorkTime.add(MyTime(
            startBreak: _currentValueBreakPicker,
            startWork: _currentValueWorkPicker));
      }
    });
  }

  ElevatedButton submitMyCustomizeWorkTimeBtn(
      {required double h, required double w, required BuildContext ctx}) {
    return ElevatedButton(
      style: ButtonStyle(
          backgroundColor:
              MaterialStateProperty.all(_isDark ? darkColor : null)),
      child: const Icon(Icons.directions_run_rounded),
      onPressed: () {
        setState(() {
          getMyCustomizeWorkTime();
          Navigator.pop(ctx);
        });
      },
    );
  }

  void getMyCustomizeWorkTime() {
    setState(() {
      myWorkTime.clear();
      for (int i = 0; i < myInt.length; i++) {
        myWorkTime.add(MyTime(startWork: myInt[i][0], startBreak: myInt[i][1]));
      }
      _currentValueWorkPicker = myWorkTime[0].startWork;
      _currentValueBreakPicker = myWorkTime[0].startBreak;
      _currentValueRoundPicker = myWorkTime.length;
    });
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
        title: Center(child: Text('focus time'.toUpperCase())),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(children: [
            roundPicker(),
            myXDivider(),
            workBreakTimeWidget(),
            myBtnS(height * 0.80, width * 0.70),
            const SizedBox(height: 10),
            if (myTimeTarget.isNotEmpty)
              drawTime(d: myTimeTarget[0], h: height, w: width)
          ]),
        ),
      ),
    );
  }
}
