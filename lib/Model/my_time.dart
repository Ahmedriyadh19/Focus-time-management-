class MyTime {
  int startWork;
  int startBreak;
  MyTime({
    required this.startWork,
    required this.startBreak,
  });

  @override
  String toString() =>
      'MyTime(startWork: $startWork, startBreak: $startBreak)';
}
