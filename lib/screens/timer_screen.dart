import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Duration _duration = const Duration(); 
  Timer? _timer;
  bool _isRunning = false;
  Duration _totalDuration = const Duration(); 
  Duration _weeklyDuration = const Duration(); 
  Duration _monthlyDuration = const Duration();
  Duration _yearlyDuration = const Duration(); 
  Duration _overallTotalDuration = const Duration();
  DateTime _lastSavedDate = DateTime.now(); 

  List<Duration> _weeklyDurations =
      List.filled(7, const Duration()); 
  List<Duration> _monthlyDurations =
      List.filled(31, const Duration()); 
  List<Duration> _yearlyDurations =
      List.filled(12, const Duration()); 
  @override
  void initState() {
    super.initState();
    _loadDuration();
    _loadWeeklyDurations(); 
    _loadMonthlyDurations();
    _loadYearlyDurations();
    _loadTotalDuration();
    _loadWeeklyDuration();
    _loadMonthlyDuration();
    _loadYearlyDuration();
    _loadOverallTotalDuration(); 
    _checkNewDay();
    _checkNewWeek();
    _checkNewMonth();
    _checkNewYear();
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
      _totalDuration = Duration(seconds: prefs.getInt('daily_study_time') ?? 0);
    });
  }

  void _loadWeeklyDuration() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _weeklyDuration =
          Duration(seconds: prefs.getInt('weekly_study_time') ?? 0);
    });
  }

  void _loadMonthlyDuration() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _monthlyDuration =
          Duration(seconds: prefs.getInt('monthly_study_time') ?? 0);
    });
  }

  void _loadYearlyDuration() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _yearlyDuration =
          Duration(seconds: prefs.getInt('yearly_study_time') ?? 0);
    });
  }

  void _loadOverallTotalDuration() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _overallTotalDuration =
          Duration(seconds: prefs.getInt('overall_total_study_time') ?? 0);
    });
  }

  void _checkNewDay() {
    final now = DateTime.now();
    if (_lastSavedDate.day != now.day) {
      _saveDailyDuration();
      _lastSavedDate = now; // Güncellemeyi burada yapıyoruz
    }
  }

  void _checkNewWeek() {
    final now = DateTime.now();
    // Haftanın başlangıcını kontrol et
    if (_lastSavedDate.weekday == DateTime.sunday &&
        now.weekday == DateTime.monday) {
      _weeklyDuration = const Duration(); // Haftalık süreyi sıfırla
      _saveWeeklyDuration();
    }
  }

  void _checkNewMonth() {
    final now = DateTime.now();
    // Ayın başında kontrol et
    if (_lastSavedDate.month != now.month) {
      _monthlyDuration = const Duration(); // Aylık süreyi sıfırla
      _saveMonthlyDuration();
    }
  }

  void _checkNewYear() {
    final now = DateTime.now();
    // Yılın başında kontrol et
    if (_lastSavedDate.year != now.year) {
      _yearlyDuration = const Duration(); // Yıllık süreyi sıfırla
      _saveYearlyDuration();
    }
  }

  void _loadWeeklyDurations() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? durations = prefs.getStringList('weekly_study_times');
    if (durations != null) {
      setState(() {
        _weeklyDurations =
            durations.map((d) => Duration(seconds: int.parse(d))).toList();
      });
    }
  }

  void _loadMonthlyDurations() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? durations = prefs.getStringList('monthly_study_times');
    if (durations != null) {
      setState(() {
        _monthlyDurations =
            durations.map((d) => Duration(seconds: int.parse(d))).toList();
      });
    }
  }

  void _loadYearlyDurations() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? durations = prefs.getStringList('yearly_study_times');
    if (durations != null) {
      setState(() {
        _yearlyDurations =
            durations.map((d) => Duration(seconds: int.parse(d))).toList();
      });
    }
  }

  void _toggleTimer() {
    if (_isRunning) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    setState(() {
      _isRunning = true; // Timer'ın durumu hemen güncelleniyor
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _duration += const Duration(seconds: 1);
      });
    });
  }

  void _stopTimer() {
    setState(() {
      _isRunning = false; // Timer'ın durumu hemen güncelleniyor
    });
    _timer?.cancel();
  }

  void _saveDailyDuration() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('study_time', _duration.inSeconds);

    // Günlük toplam süreyi güncelle
    _totalDuration += _duration;
    prefs.setInt('daily_study_time', _totalDuration.inSeconds);

    // Haftalık toplam süreyi güncelle
    final dayOfWeek = DateTime.now().weekday - 1; // Pazartesi 0, Pazar 6
    final dayOfMonth = DateTime.now().day - 1; // Gün, 1 eksiğiyle indekslenir.
    _monthlyDurations[dayOfMonth] += _duration;
    _weeklyDurations[dayOfWeek] += _duration;

    // Haftalık ve aylık toplam süreleri güncelle
    _weeklyDuration = _weeklyDurations.reduce((a, b) => a + b);
    _monthlyDuration = _monthlyDurations.reduce((a, b) => a + b);

    prefs.setInt('weekly_study_time', _weeklyDuration.inSeconds);
    prefs.setInt('monthly_study_time', _monthlyDuration.inSeconds);

    // Haftalık ve aylık süreleri kaydet
    List<String> durations =
        _weeklyDurations.map((d) => d.inSeconds.toString()).toList();
    prefs.setStringList('weekly_study_times', durations);

    List<String> monthlyDurationsStringList =
        _monthlyDurations.map((d) => d.inSeconds.toString()).toList();
    prefs.setStringList('monthly_study_times', monthlyDurationsStringList);

    // Yıllık süreleri güncelle
    final now = DateTime.now();
    int currentMonth = now.month - 1; // Ay, 1 eksiğiyle indekslenir.
    _yearlyDurations[currentMonth] += _duration; // Bu ayın süresini güncelle

    // Yıllık toplam süreyi hesapla
    _yearlyDuration = _yearlyDurations.reduce((a, b) => a + b);
    prefs.setInt('yearly_study_time', _yearlyDuration.inSeconds);

    // Yıllık süreleri kaydet
    List<String> yearlyDurationsStringList =
        _yearlyDurations.map((d) => d.inSeconds.toString()).toList();
    prefs.setStringList('yearly_study_times', yearlyDurationsStringList);

    // Toplam süreyi güncelle
    _overallTotalDuration += _duration;
    prefs.setInt('overall_total_study_time', _overallTotalDuration.inSeconds);

    // Bildirim göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Günlük süre kaydedildi: ${timerText}')),
    );

    // Süreyi sıfırla
    setState(() {
      _duration = const Duration();
    });
  }

  void _saveWeeklyDuration() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('weekly_study_time', _weeklyDuration.inSeconds);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Haftalık süre sıfırlandı')),
    );
  }

  void _saveMonthlyDuration() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('monthly_study_time', _monthlyDuration.inSeconds);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Aylık süre sıfırlandı')),
    );
  }

  void _saveYearlyDuration() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('yearly_study_time', _yearlyDuration.inSeconds);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Yıllık süre sıfırlandı')),
    );
  }

  String get timerText {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(_duration.inHours);
    final minutes = twoDigits(_duration.inMinutes.remainder(60));
    final seconds = twoDigits(_duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  String get dailyTimerText {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(_totalDuration.inHours);
    final minutes = twoDigits(_totalDuration.inMinutes.remainder(60));
    final seconds = twoDigits(_totalDuration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  String get _weeklyTimerText {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(_weeklyDuration.inHours);
    final minutes = twoDigits(_weeklyDuration.inMinutes.remainder(60));
    final seconds = twoDigits(_weeklyDuration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  String get _monthlyTimerText {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(_monthlyDuration.inHours);
    final minutes = twoDigits(_monthlyDuration.inMinutes.remainder(60));
    final seconds = twoDigits(_monthlyDuration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  String get _yearlyTimerText {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(_yearlyDuration.inHours);
    final minutes = twoDigits(_yearlyDuration.inMinutes.remainder(60));
    final seconds = twoDigits(_yearlyDuration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  String get _overallTotalTimerText {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(_overallTotalDuration.inHours);
    final minutes = twoDigits(_overallTotalDuration.inMinutes.remainder(60));
    final seconds = twoDigits(_overallTotalDuration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
        'KRONOMETRE',
        style: TextStyle(
          fontFamily: 'Lorjuk',
          fontWeight: FontWeight.bold,
          fontSize: 30,
        ),
      )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200, // Increased width for the circle
              height: 200, // Increased height for the circle
              decoration: const BoxDecoration(
                shape: BoxShape.circle, // Make the container circular
                color: Color.fromARGB(
                    255, 81, 206, 108), // Change the background color to purple
              ),
              child: Center(
                // Center the text inside the container
                child: Text(
                  'Ölçülen Süre:\n$timerText', // Use newline for better formatting
                  style: const TextStyle(
                      fontSize: 24, color: Colors.white), // Text color
                  textAlign: TextAlign.center, // Center the text
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _toggleTimer,
                  child: Text(_isRunning ? 'Bitir' : 'Başla'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _saveDailyDuration,
                  child: const Text('Kaydet'),
                ),
                const SizedBox(width: 20), // Space between buttons
                ElevatedButton(
                  onPressed: _resetTimer, // Add your reset function here
                  child: const Text('Sıfırla'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showAllRecordedTimes,
              child: const Text('Tüm Kayıtlar'),
            ),
          ],
        ),
      ),
    );
  }

  void _resetTimer() {
    setState(() {
      _duration = const Duration(); // Reset the duration to zero
      _isRunning = false; // Ensure the timer is stopped
    });
  }

  void _showMonthlyChart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            MonthlyChartScreen(monthlyDurations: _monthlyDurations),
      ),
    );
  }

  void _showWeeklyChart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            WeeklyChartScreen(weeklyDurations: _weeklyDurations),
      ),
    );
  }

  void _showYearlyChart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => YearlyChartScreen(
            yearlyDurations:
                _yearlyDurations), // Send the correct yearly durations
      ),
    );
  }

  void _showAllRecordedTimes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecordedTimesScreen(
          dailyTime: dailyTimerText,
          weeklyTime: _weeklyTimerText,
          monthlyTime: _monthlyTimerText,
          yearlyTime: _yearlyTimerText,
          overallTime: _overallTotalTimerText,
          weeklyDurations: _weeklyDurations, // Pass weekly durations
          monthlyDurations: _monthlyDurations, // Pass monthly durations
          yearlyDurations: _yearlyDurations, // Pass yearly durations
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

class RecordedTimesScreen extends StatelessWidget {
  final String dailyTime;
  final String weeklyTime;
  final String monthlyTime;
  final String yearlyTime;
  final String overallTime;
  final List<Duration> weeklyDurations; // Add this line
  final List<Duration> monthlyDurations; // Add this line
  final List<Duration> yearlyDurations; // Add this line

  const RecordedTimesScreen({
    super.key,
    required this.dailyTime,
    required this.weeklyTime,
    required this.monthlyTime,
    required this.yearlyTime,
    required this.overallTime,
    required this.weeklyDurations, // Add this line
    required this.monthlyDurations, // Add this line
    required this.yearlyDurations, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tüm Kayıtlar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double buttonSize =
              constraints.maxWidth - 20; // Adjusted for a single column

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView(
              children: [
                // Row for the two labels with adjusted alignment
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0), // Adjusted padding
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween, // Space between the labels
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bu Gün:\n$dailyTime',
                              style: const TextStyle(fontSize: 18)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment
                            .end, // Align text to the end for better look
                        children: [
                          Text('Şimdiye Kadar:\n$overallTime',
                              style: const TextStyle(fontSize: 18)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                    height: 20), // Add space between the labels and buttons
                _buildButton('Bu Hafta:\n$weeklyTime', buttonSize, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WeeklyChartScreen(weeklyDurations: weeklyDurations),
                    ),
                  );
                }),
                const SizedBox(height: 10), // Add space between buttons
                _buildButton('Bu Ay:\n$monthlyTime', buttonSize, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MonthlyChartScreen(
                          monthlyDurations: monthlyDurations),
                    ),
                  );
                }),
                const SizedBox(height: 10), // Add space between buttons
                _buildButton('Bu Yıl:\n$yearlyTime', buttonSize, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          YearlyChartScreen(yearlyDurations: yearlyDurations),
                    ),
                  );
                }),
                const SizedBox(height: 10), // Add space between buttons
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildButton(String label, double size, VoidCallback onPressed) {
    return SizedBox(
      width: size, // Set the width of the button
      child: ElevatedButton(
        onPressed: onPressed, // Use the provided onPressed function
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 18),
        ),
        child: Text(label),
      ),
    );
  }
}

class WeeklyChartScreen extends StatelessWidget {
  final List<Duration> weeklyDurations;

  const WeeklyChartScreen({super.key, required this.weeklyDurations});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Haftalık Süre Grafiği')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            gridData: const FlGridData(show: false), // Izgara çizgilerini gizle
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40, // Sol eksenin ayırdığı alan
                  getTitlesWidget: (value, meta) {
                    final duration = Duration(seconds: value.toInt());
                    String label;

                    if (duration.inHours > 0) {
                      label = '${duration.inHours} saat';
                    } else if (duration.inMinutes > 0) {
                      label = '${duration.inMinutes} dakika';
                    } else {
                      label = '${duration.inSeconds} saniye';
                    }

                    return Text(label,
                        style: const TextStyle(
                            fontSize: 12)); // Yazı boyutunu düşürdük
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40, // Alt eksenin ayırdığı alan
                  getTitlesWidget: (value, meta) {
                    switch (value.toInt()) {
                      case 0:
                        return const Text('Pazartesi',
                            style: TextStyle(fontSize: 12));
                      case 1:
                        return const Text('Salı',
                            style: TextStyle(fontSize: 12));
                      case 2:
                        return const Text('Çarşamba',
                            style: TextStyle(fontSize: 12));
                      case 3:
                        return const Text('Perşembe',
                            style: TextStyle(fontSize: 12));
                      case 4:
                        return const Text('Cuma',
                            style: TextStyle(fontSize: 12));
                      case 5:
                        return const Text('Cumartesi',
                            style: TextStyle(fontSize: 12));
                      case 6:
                        return const Text('Pazar',
                            style: TextStyle(fontSize: 12));
                      default:
                        return const Text('');
                    }
                  },
                ),
              ),
            ),
            barGroups: List.generate(7, (index) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: weeklyDurations[index].inSeconds.toDouble(),
                    color: Colors.blue,
                    width: 15,
                  ),
                ],
              );
            }),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.black, width: 1),
            ),
          ),
        ),
      ),
    );
  }
}

class MonthlyChartScreen extends StatelessWidget {
  final List<Duration> monthlyDurations;

  const MonthlyChartScreen({super.key, required this.monthlyDurations});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aylık Süre Grafiği')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    final duration = Duration(seconds: value.toInt());
                    String label = duration.inHours > 0
                        ? '${duration.inHours} saat'
                        : '${duration.inMinutes} dakika';
                    return Text(label, style: const TextStyle(fontSize: 12));
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '${value.toInt() + 1}', // Gün numaraları 1'den başlıyor
                      style: const TextStyle(fontSize: 12),
                    );
                  },
                ),
              ),
            ),
            barGroups: List.generate(31, (index) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: monthlyDurations[index].inSeconds.toDouble(),
                    color: Colors.green,
                    width: 10,
                  ),
                ],
              );
            }),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.black, width: 1),
            ),
          ),
        ),
      ),
    );
  }
}

class YearlyChartScreen extends StatelessWidget {
  final List<Duration> yearlyDurations; // Her ayın toplam süresi

  const YearlyChartScreen({super.key, required this.yearlyDurations});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yıllık Süre Grafiği')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            gridData: const FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    final duration = Duration(seconds: value.toInt());
                    String label = duration.inHours > 0
                        ? '${duration.inHours} saat'
                        : '${duration.inMinutes} dakika';
                    return Text(label, style: const TextStyle(fontSize: 12));
                  },
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    const months = [
                      'Oca',
                      'Şub',
                      'Mar',
                      'Nis',
                      'May',
                      'Haz',
                      'Tem',
                      'Ağu',
                      'Eyl',
                      'Eki',
                      'Kas',
                      'Ara'
                    ];
                    return Text(
                      months[value.toInt() % 12], // Ay numarasına göre metin
                      style: const TextStyle(fontSize: 12),
                    );
                  },
                ),
              ),
            ),
            barGroups: List.generate(12, (index) {
              return BarChartGroupData(
                x: index,
                barRods: [
                  BarChartRodData(
                    toY: yearlyDurations[index].inSeconds.toDouble(),
                    color: Colors.blue,
                    width: 20,
                  ),
                ],
              );
            }),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.black, width: 1),
            ),
          ),
        ),
      ),
    );
  }
}
