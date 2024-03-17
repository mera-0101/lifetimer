import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '/utils/timer_utils.dart';
import '/global.dart';
import 'settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({Key? key}) : super(key: key);

  @override
  TimerScreenState createState() => TimerScreenState();
}

class TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  late Timer _timer;
  late AnimationController _animationController;
  int _remainingSeconds = 0; // 仮の残り時間（1時間）
  double _wavePhase = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..addListener(() {
        setState(() {
          _wavePhase = _animationController.value * 2 * math.pi;
        });
      });
    _animationController.repeat();

    _initState();
  }

  Future<void> _initState() async {
    await _loadTimerData();
    _setupTimer();
  }

  Future<void> _loadTimerData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      Globals.eventDate = DateTime.fromMillisecondsSinceEpoch(
        prefs.getInt('eventDate') ?? DateTime.now().millisecondsSinceEpoch
      );
      Globals.setDate = DateTime.fromMillisecondsSinceEpoch(
        prefs.getInt('setDate') ?? DateTime.now().millisecondsSinceEpoch
      );
      Globals.spendYear = prefs.getInt('spendYear') ?? 0;
      Globals.spendMonth = prefs.getInt('spendMonth') ?? 0;
      Globals.spendDay = prefs.getInt('spendDay') ?? 0;
      Globals.appBarTitle = prefs.getString('appBarTitle') ?? 'Life Timer';
    });
    _saveTimerData();
    _remainingSeconds = TimerUtils.calculateRemainingSeconds();
  }

  void _saveTimerData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('eventDate', Globals.eventDate.millisecondsSinceEpoch);
    prefs.setInt('spendYear', Globals.spendYear);
    prefs.setInt('spendMonth', Globals.spendMonth);
    prefs.setInt('spendDay', Globals.spendDay);
  }

  void _setupTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String remainingTime = TimerUtils.changeFormat(
      _remainingSeconds > 0 ? _remainingSeconds : 0
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(Globals.appBarTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _openSettingsScreen(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (_, __) => CustomPaint(
                painter: WaterWavePainter(
                  wavePhase: _wavePhase,
                  waterHeightRatio: _remainingSeconds / TimerUtils.calculateTotalTimeSeconds(),
                ),
              ),
            ),
          ),
          Center(
            child:Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // HourglassWidget(),
                // SizedBox(height: 24),
                Text(
                        remainingTime,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  void _openSettingsScreen(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen())
    );

    if (Globals.changeResult) {
      setState(() {
        _remainingSeconds = TimerUtils.calculateRemainingSeconds();
        Globals.changeResult = false;
      });
    }
  }
}

class WaterWavePainter extends CustomPainter {
  final double wavePhase;
  final double waterHeightRatio;

  WaterWavePainter({required this.wavePhase, required this.waterHeightRatio});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black26;
    final path = Path();

    const  waveAmplitude = 20.0; // 波の振幅
    final waterTop = size.height * (1 - waterHeightRatio);

    path.moveTo(0, waterTop);
    for (double x = 0.0; x <= size.width; x++) {
      final y = waterTop +
          math.sin(wavePhase + x * 0.02) * waveAmplitude;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
