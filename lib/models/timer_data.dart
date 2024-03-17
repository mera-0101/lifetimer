class TimerData {
  int lifespan;
  int currentAge;

  TimerData({
    required this.lifespan,
    required this.currentAge,
  });

  Map<String, dynamic> toJson() {
    return {
      'lifespan': lifespan,
      'currentAge': currentAge,
    };
  }

  factory TimerData.fromJson(Map<String, dynamic> json) {
    return TimerData(
      lifespan: json['lifespan'],
      currentAge: json['currentAge'],
    );
  }
}
