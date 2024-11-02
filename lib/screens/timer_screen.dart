import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Duration _duration = Duration();
  Timer? _timer;
  bool _isRunning = false;
  Duration _totalDuration = Duration();

  @override
  void initState() {
    super.initState();
    _loadDuration();
    _loadTotalDuration();
  }

  void _loadDuration() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _duration = Duration(seconds: prefs.getInt('study_time') ?? 0);
    });
  }

  void _loadTotalDuration() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalDuration = Duration(seconds: prefs.getInt('total_study_time') ?? 0);
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    _isRunning = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _duration += Duration(seconds: 1);
      });
    });
  }

  void _stopTimer() {
    _isRunning = false;
    _timer?.cancel();
  }

  void _saveDuration() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('study_time', _duration.inSeconds);

    // Günlük toplam süreyi güncelle
    _totalDuration += _duration;
    prefs.setInt('total_study_time', _totalDuration.inSeconds);

    // Kullanıcıya kaydedildiğini bildiren bir mesaj
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Kaydedilen süre: ${timerText}, Günlük Toplam Süre: ${_totalTimerText}')),
    );

    // Süreyi sıfırla
    setState(() {
      _duration = Duration(); // Kayıttan sonra süreyi sıfırlayın
    });
  }

  String get timerText {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(_duration.inHours);
    final minutes = twoDigits(_duration.inMinutes.remainder(60));
    final seconds = twoDigits(_duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  String get _totalTimerText {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(_totalDuration.inHours);
    final minutes = twoDigits(_totalDuration.inMinutes.remainder(60));
    final seconds = twoDigits(_totalDuration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Study Timer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Mevcut Süre: $timerText',
              style: TextStyle(fontSize: 48),
            ),
            SizedBox(height: 20),
            Text(
              'Günlük Toplam Süre: $_totalTimerText',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _toggleTimer,
                  child: Text(_isRunning ? 'Stop' : 'Start'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _saveDuration,
                  child: Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
