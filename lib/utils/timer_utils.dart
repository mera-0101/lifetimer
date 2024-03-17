import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '/models/timer_data.dart';
import '/global.dart';

class TimerUtils {
  static const String _timerDataKey = 'timer_data_key';

  static Future<TimerData> loadTimerData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? timerDataJson = prefs.getString(_timerDataKey);

    if (timerDataJson != null) {
      Map<String, dynamic> json = jsonDecode(timerDataJson);
      return TimerData.fromJson(json);
    }

    // Return default values if not set
    return TimerData(lifespan: 0, currentAge: 0);
  }

  static int calculateTotalTimeSeconds(){
    int total = Duration(days: Globals.spendYear*365 + Globals.spendMonth*30 + Globals.spendDay).inSeconds;
    total += Globals.eventDate.difference(Globals.setDate).inSeconds;
    return total;
  }

  static int calculateRemainingSeconds() {
    // Calculate the difference between the goal date and the current date in seconds
    int remainingSeconds = Globals.eventDate.difference(DateTime.now()).inSeconds;
    return remainingSeconds >= 0 ? remainingSeconds : 0; // Ensure non-negative value
  }

  static String changeFormat(int seconds) {
    switch (Globals.formatTime) {
      case 1: return _formatToMinutesAndSeconds(seconds);
      case 2: return _formatToHoursMinutesAndSeconds(seconds);
      case 3: return _formatToDaysHoursMinutesAndSeconds(seconds);
      default: return '$seconds s'; // Default to seconds if no format is specified
    }
  }

  static String _formatToMinutesAndSeconds(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes m $remainingSeconds s';
  }

  static String _formatToHoursMinutesAndSeconds(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$hours h $minutes m $remainingSeconds s';
  }

  static String _formatToDaysHoursMinutesAndSeconds(int seconds) {
    int days = seconds ~/ 86400;
    int hours = (seconds % 86400) ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$days d $hours h $minutes m $remainingSeconds s';
  }
}
