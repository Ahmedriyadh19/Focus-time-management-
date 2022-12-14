import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:theme_manager/theme_manager.dart';
import 'package:time_management/model/my_time.dart';
import 'package:wakelock/wakelock.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CountDownController _controller = CountDownController();
  final player = AudioPlayer();
  late Timer timer;
  bool _isDark = true;
  bool _isStart = false;
  bool _isAlwaysOn = true;
  int _currentValueRoundPicker = 3;
  int _currentValueWorkPicker = 20;
  int _currentValueBreakPicker = 15;
  int _targetIndex = 0;
  final int _maxRound = 12;
  final int _maxWorkTime = 120;
  final int _maxBreakTime = 60;
  Color darkColor = const Color.fromARGB(255, 32, 33, 36);
  List<MyTime> myWorkTime = [];
  List<Widget> myWorkTimeEditWidget = [];
  List<int> myTimeTarget = [];
  List<List<int>> myIntTime = [];
  List<Widget> viewMyTimes = [];

  void setDark() {
    ThemeManager.of(context).setBrightnessPreference(
        _isDark ? BrightnessPreference.dark : BrightnessPreference.light);
  }

  Tooltip darkBtn() {
    return Tooltip(
      message: 'Dark mode',
      child: IconButton(
        icon: Icon(_isDark ? Icons.sunny : FontAwesomeIcons.moon),
        onPressed: () {
          setState(() {
            _isDark = !_isDark;
            setDark();
          });
        },
      ),
    );
  }

  Tooltip alwaysOnBtn() {
    return Tooltip(
      message: 'Always Screen is ${_isAlwaysOn ? 'On' : 'Off'}',
      child: IconButton(
        icon: Icon(_isAlwaysOn
            ? Icons.phone_android_rounded
            : Icons.phonelink_erase_rounded),
        onPressed: () {
          setState(() {
            _isAlwaysOn = !_isAlwaysOn;
            setAlwaysOn();
          });
        },
      ),
    );
  }

  setAlwaysOn() {
    setState(() {
      Wakelock.toggle(enable: _isAlwaysOn);
    });
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
              if (myIntTime[round][op] > min) {
                myIntTime[round][op]--;
              }
            }),
            onLongPressStart: (details) {
              timer = Timer.periodic(
                const Duration(milliseconds: 100),
                (timer) {
                  setNewState(() {
                    if (myIntTime[round][op] > min) {
                      myIntTime[round][op]--;
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
          Text('${myIntTime[round][op]}'),
          GestureDetector(
            onTap: () => setNewState(() {
              if (myIntTime[round][op] < max) {
                myIntTime[round][op]++;
              }
            }),
            onLongPressStart: (details) {
              timer =
                  Timer.periodic(const Duration(milliseconds: 100), ((timer) {
                setNewState(() {
                  if (myIntTime[round][op] < max) {
                    myIntTime[round][op]++;
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

  Tooltip submitBtn({required double h, required double w}) {
    return Tooltip(
      message: 'set all'.toUpperCase(),
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(_isDark ? darkColor : null)),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Row(
            children: [
              const Icon(Icons.directions_run_rounded),
              SizedBox(width: 3),
              Text('Set All')
            ],
          ),
        ),
        onPressed: () {
          setState(() {
            getTimeWork();
            getMyInt();
            getTargetTime();
          });
        },
      ),
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

  Tooltip editBtn({required double h, required double w}) {
    return Tooltip(
      message: 'edit'.toUpperCase(),
      child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(_isDark ? darkColor : null)),
          onPressed: () async {
            setState(() {
              myWorkTimeEditWidget.clear();
              getTimeWork();
            });
            await bottomSheet(h: h, w: w);
          },
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Row(
              children: [
                const Icon(Icons.reorder_rounded),
                SizedBox(width: 3),
                Text('Customize')
              ],
            ),
          )),
    );
  }

  void getMyInt() {
    setState(() {
      myIntTime.clear();
      if (myWorkTime.isNotEmpty) {
        for (int i = 0; i < myWorkTime.length; i++) {
          myIntTime.add([myWorkTime[i].startWork, myWorkTime[i].startBreak]);
        }
      }
    });
  }

  void initMyEdit({required double w, required Function x}) {
    myWorkTimeEditWidget.clear();
    if (myWorkTime.isNotEmpty) {
      for (int i = 0; i < myWorkTime.length; i++) {
        myWorkTimeEditWidget
            .add(buildMyEdit(roundNumber: (i + 1), w: w, edit: x));
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
                        children: myWorkTimeEditWidget,
                      ),
                      SizedBox(
                          width: 120,
                          child: submitMyCustomizeWorkTimeBtn(
                              h: h, w: w, ctx: context))
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
                            myIntTime.removeAt(roundNumber - 1);
                            myWorkTime.removeAt(roundNumber - 1);
                            myWorkTimeEditWidget.removeAt(roundNumber - 1);
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
          onComplete: () async {
            await play();
            setState(() {
              successStep();
            });
          },
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              clockBtn(op: 0),
              SizedBox(width: 8),
              clockBtn(op: 1),
              SizedBox(width: 8),
              skipBtn()
            ],
          ),
        )
      ],
    );
  }

  Tooltip skipBtn() {
    return Tooltip(
      message: 'next'.toUpperCase(),
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(_isDark ? darkColor : null)),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Row(
            children: [
              Icon(Icons.skip_next_rounded),
              SizedBox(width: 3),
              Text('Next Step')
            ],
          ),
        ),
        onPressed: () {
          setState(() {
            nextProcess();
          });
        },
      ),
    );
  }

  nextProcess() {
    setState(() {
      if (myTimeTarget.isNotEmpty && _targetIndex < myTimeTarget.length - 1) {
        _targetIndex++;
        _controller.restart(duration: (myTimeTarget[_targetIndex]) * 60);
      } else {
        _targetIndex = 0;
        myTimeTarget.clear();
      }
    });
  }

  Tooltip clockBtn({required int op}) {
    return Tooltip(
      message: op == 0
          ? 'start over'.toUpperCase()
          : _isStart
              ? 'resume'.toUpperCase()
              : 'pause'.toUpperCase(),
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(_isDark ? darkColor : null)),
        onPressed: () {
          setState(() {
            if (op == 0) {
              _controller.restart(duration: myTimeTarget[_targetIndex] * 60);
            } else {
              _isStart = !_isStart;
              _isStart ? _controller.pause() : _controller.resume();
            }
          });
        },
        child: op == 0
            ? Padding(
                padding: const EdgeInsets.all(3.0),
                child: Row(
                  children: [
                    Icon(Icons.redo_rounded),
                    SizedBox(width: 3),
                    Text('Start Over')
                  ],
                ),
              )
            : _isStart
                ? Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow_rounded),
                        SizedBox(width: 3),
                        Text('Resume')
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Row(
                      children: [
                        Icon(Icons.pause_rounded),
                        SizedBox(width: 3),
                        Text('Pause')
                      ],
                    ),
                  ),
      ),
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

  Tooltip submitMyCustomizeWorkTimeBtn(
      {required double h, required double w, required BuildContext ctx}) {
    return Tooltip(
      message: 'save'.toUpperCase(),
      child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(_isDark ? darkColor : null)),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.save_alt_rounded),
              SizedBox(width: 3),
              Text('Save')
            ],
          ),
        ),
        onPressed: () {
          setState(() {
            getMyCustomizeWorkTime();
            Navigator.pop(ctx);
          });
        },
      ),
    );
  }

  void getMyCustomizeWorkTime() {
    setState(() {
      myWorkTime.clear();
      for (int i = 0; i < myIntTime.length; i++) {
        myWorkTime.add(
            MyTime(startWork: myIntTime[i][0], startBreak: myIntTime[i][1]));
      }
      _currentValueWorkPicker = myWorkTime[0].startWork;
      _currentValueBreakPicker = myWorkTime[0].startBreak;
      myWorkTime.isNotEmpty ? _currentValueRoundPicker = myWorkTime.length : 1;
    });
  }

  viewMyTime() {
    viewMyTimes.clear();
    for (var i = 0; i < myIntTime.length; i++) {
      viewMyTimes.add(buildMyView(index: i));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: viewMyTimes),
    );
  }

  buildMyView({required int index}) {
    setState(() {});
    return Center(
      child: Container(
        decoration: BoxDecoration(
            color: _isDark
                ? darkColor.withOpacity(0.7)
                : Colors.blue.withOpacity(0.7),
            borderRadius: BorderRadius.circular(10)),
        width: 150,
        margin: EdgeInsets.symmetric(horizontal: 15),
        padding: EdgeInsets.all(10),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('round ${index + 1}'.toUpperCase()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('work for'.toUpperCase()),
              Text('${myIntTime[index][0]}'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('break for'.toUpperCase()),
              Text('${myIntTime[index][1]}'),
            ],
          )
        ]),
      ),
    );
  }

  successStep() {
    return AwesomeDialog(
      context: context,
      animType: AnimType.leftSlide,
      headerAnimationLoop: false,
      dialogType: DialogType.success,
      showCloseIcon: true,
      title: 'Success',
      desc: 'Congratulation keep it up',
      btnOkOnPress: () async {
        await stop();
        setState(() {
          nextProcess();
        });
      },
      btnOkIcon: Icons.check_circle,
    ).show();
  }

  Text print() {
    return Text(
        'round ${((_targetIndex + 1) / 2).ceil()}\n${_targetIndex % 2 == 0 ? 'Work' : 'break'} time\n\nstep ${_targetIndex + 1} of ${myTimeTarget.length}'
            .toUpperCase(),
        textAlign: TextAlign.center);
  }

  play() async {
    await player.play(DeviceFileSource(
        'lib/assets/sound.mp3')); // will immediately start playing
  }

  stop() async {
    await player.stop(); // will resume from beginning
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        actions: [alwaysOnBtn(), darkBtn()],
        centerTitle: true,
        title: Center(child: Text('focus time'.toUpperCase())),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                roundPicker(),
                myXDivider(),
                workBreakTimeWidget(),
                myBtnS(height * 0.80, width * 0.70),
                const SizedBox(height: 10),
                if (myTimeTarget.isNotEmpty) viewMyTime(),
                const SizedBox(height: 10),
                if (myTimeTarget.isNotEmpty &&
                    _targetIndex < myTimeTarget.length)
                  print(),
                const SizedBox(height: 10),
                if (myTimeTarget.isNotEmpty &&
                    _targetIndex < myTimeTarget.length)
                  drawTime(d: myTimeTarget[_targetIndex], h: height, w: width),
              ]),
        ),
      ),
    );
  }
}
