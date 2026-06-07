import 'package:flutter/material.dart';
import 'heart_loading_animation.dart';

class OldCounterScreen extends StatefulWidget {
  const OldCounterScreen({super.key});

  @override
  State<OldCounterScreen> createState() => _OldCounterScreenState();
}

class _OldCounterScreenState extends State<OldCounterScreen> {
  final DateTime _startDate = DateTime(2026, 1, 5, 0, 0);
  int years = 0;
  int months = 0;
  int days = 0;

  @override
  void initState() {
    super.initState();
    _calculateTime();
  }

  void _calculateTime() {
    final nowRaw = DateTime.now();
    final now = DateTime(nowRaw.year, nowRaw.month, nowRaw.day);

    if (now.isBefore(_startDate)) return;

    int tempYears = now.year - _startDate.year;
    int tempMonths = now.month - _startDate.month;
    int tempDays = now.day - _startDate.day;

    if (tempDays < 0) {
      final previousMonthDoc = DateTime(now.year, now.month, 0);
      tempDays += previousMonthDoc.day;
      tempMonths--;
    }

    if (tempMonths < 0) {
      tempMonths += 12;
      tempYears--;
    }

    setState(() {
      years = tempYears;
      months = tempMonths;
      days = tempDays;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF16151A),
        elevation: 0,
        foregroundColor: const Color(0xFFFA709A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF16151A),
          ),
          Positioned(
            top: -30,
            left: -60,
            child: Icon(
              Icons.favorite,
              size: 240,
              color: const Color(0xFFFA709A).withValues(alpha: 0.04),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -70,
            child: Icon(
              Icons.favorite,
              size: 280,
              color: const Color(0xFFFA709A).withValues(alpha: 0.04),
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'User 1 & User 2',
                    style: TextStyle(
                      fontFamily: 'DancingScript',
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF222029),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFA709A).withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Text(
                      'W ZWIĄZKU JUŻ OD:',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFFA709A),
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  const HeartLoadingAnimation(),
                  const SizedBox(height: 35),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTimeCard('$years', 'LATA'),
                      const SizedBox(width: 10),
                      _buildTimeCard('$months', 'MIESIĄCE'),
                      const SizedBox(width: 10),
                      _buildTimeCard('$days', 'DNI'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard(String value, String label) {
    return Container(
      width: 95,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF222029),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFA709A),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Lato',
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: Colors.white60,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
