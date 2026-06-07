import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NaszBabelScreen extends StatefulWidget {
  final String currentUser;
  const NaszBabelScreen({super.key, required this.currentUser});

  @override
  State<NaszBabelScreen> createState() => _NaszBabelScreenState();
}

class _NaszBabelScreenState extends State<NaszBabelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathingController;
  Timer? _localRefreshTimer;

  int _coins = 45;
  double _hunger = 78.0;

  bool _freeClaimed = false;
  bool _msgClaimed = false;
  bool _photoClaimed = false;
  bool _sexClaimed = false;

  bool _isSexActiveToday = true;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _loadLocalDemoData();

    _localRefreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _localRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadLocalDemoData() async {
    final prefs = await SharedPreferences.getInstance();
    final String prefix = widget.currentUser == 'User 1' ? 'user1_' : 'user2_';
    final String todayKey = _getTodayKey();

    setState(() {
      _coins = prefs.getInt('demo_babel_coins') ?? 45;
      _hunger = prefs.getDouble('demo_babel_hunger') ?? 78.0;

      _freeClaimed = prefs.getString('${prefix}last_free_claim') == todayKey;
      _msgClaimed = prefs.getString('${prefix}last_msg_claim') == todayKey;
      _photoClaimed = prefs.getString('${prefix}last_photo_claim') == todayKey;
      _sexClaimed = prefs.getString('${prefix}last_sex_claim') == todayKey;

      _isSexActiveToday =
          prefs.getBool('demo_calendar_${todayKey}_sex') ?? true;
    });
  }

  Future<void> _saveLocalDemoData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('demo_babel_coins', _coins);
    await prefs.setDouble('demo_babel_hunger', _hunger);
    await prefs.setInt(
      'demo_babel_last_update',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> _purchaseFood(int cost, double value, String successMsg) async {
    if (_coins < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            'Masz za mało monet! 🪙 Potrzebujesz: $cost.',
            style: const TextStyle(fontFamily: 'Lato', color: Colors.white),
          ),
        ),
      );
      return;
    }
    if (_hunger >= 100.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF222029),
          content: const Text(
            'Bąbel jest już najedzony do pełna! 🍗',
            style: TextStyle(fontFamily: 'Lato', color: Colors.white),
          ),
        ),
      );
      return;
    }

    setState(() {
      _coins = math.max(0, _coins - cost);
      _hunger = math.min(100.0, _hunger + value);
    });

    await _saveLocalDemoData();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 800),
        backgroundColor: const Color(0xFFFA709A),
        content: Text(
          successMsg,
          style: const TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getTodayKey() =>
      "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}";

  void _showCoinsPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16151A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            bool canClaimFree = _isAfterNineAM() && !_freeClaimed;
            bool canClaimMsg = !_msgClaimed;
            bool canClaimPhoto = !_photoClaimed;
            bool canClaimSex = _isSexActiveToday && !_sexClaimed;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Zadania dnia 💎 [DEMO]',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTaskTile(
                      title: 'Darmowa moneta dnia (Po 9:00)',
                      reward: 1,
                      isActive: canClaimFree,
                      isClaimed: _freeClaimed,
                      icon: Icons.card_giftcard,
                      onTap: () async {
                        await _claimTaskReward('last_free_claim', 1);
                        setModalState(() {
                          _freeClaimed = true;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTaskTile(
                      title: 'Wysłanie wiadomości tekstowej',
                      reward: 1,
                      isActive: canClaimMsg,
                      isClaimed: _msgClaimed,
                      icon: Icons.chat_bubble_outline,
                      onTap: () async {
                        await _claimTaskReward('last_msg_claim', 1);
                        setModalState(() {
                          _msgClaimed = true;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTaskTile(
                      title: 'Wysłanie zdjęcia',
                      reward: 2,
                      isActive: canClaimPhoto,
                      isClaimed: _photoClaimed,
                      icon: Icons.camera_alt_outlined,
                      onTap: () async {
                        await _claimTaskReward('last_photo_claim', 2);
                        setModalState(() {
                          _photoClaimed = true;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTaskTile(
                      title: 'Dzisiejszy seks',
                      reward: 3,
                      isActive: canClaimSex,
                      isClaimed: _sexClaimed,
                      icon: Icons.favorite_border,
                      onTap: () async {
                        await _claimTaskReward('last_sex_claim', 3);
                        setModalState(() {
                          _sexClaimed = true;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTaskTile({
    required String title,
    required int reward,
    required bool isActive,
    required bool isClaimed,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    Color backgroundColor = const Color(0xFF222029).withValues(alpha: 0.4);
    Color borderColor = Colors.white.withValues(alpha: 0.05);
    Color textColor = Colors.white38;
    Color iconColor = Colors.white24;
    if (isClaimed) {
      backgroundColor = const Color(0xFF1D2721);
      borderColor = Colors.green.withValues(alpha: 0.3);
      textColor = Colors.white54;
      iconColor = Colors.greenAccent;
    } else if (isActive) {
      backgroundColor = const Color(0xFFFA709A);
      borderColor = Colors.white24;
      textColor = Colors.white;
      iconColor = Colors.black;
    }
    return InkWell(
      onTap: isActive ? onTap : null,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 15,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: textColor,
                  decoration: isClaimed ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            Row(
              children: [
                Icon(
                  Icons.monetization_on,
                  color: isClaimed
                      ? Colors.grey
                      : (isActive
                            ? Colors.black
                            : Colors.amber.withValues(alpha: 0.4)),
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  '+$reward',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isClaimed
                        ? Colors.grey
                        : (isActive ? Colors.black : Colors.white60),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLongHungerBatteryCard({
    required IconData icon,
    required double value,
    required Color activeColor,
  }) {
    double percentage = value / 100.0;
    if (percentage > 1.0) percentage = 1.0;
    if (percentage < 0.0) percentage = 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF222029),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: percentage < 0.3 ? Colors.redAccent : activeColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 14,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(7),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeOutCubic,
                    width: double.infinity,
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: percentage,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7),
                          gradient: LinearGradient(
                            colors: percentage < 0.3
                                ? [Colors.red, Colors.redAccent]
                                : [
                                    activeColor.withValues(alpha: 0.7),
                                    activeColor,
                                  ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${value.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontFamily: 'Lato',
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int moodStage = 1;
    if (_hunger < 30) {
      moodStage = 3;
    } else if (_hunger < 70) {
      moodStage = 2;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF16151A),
      appBar: AppBar(
        title: const Text(
          'Nasz Bąbel',
          style: TextStyle(
            fontFamily: 'Lato',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFFA709A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: InkWell(
                onTap: () => _showCoinsPanel(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF222029),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFA709A).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$_coins',
                        style: const TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned(
            top: -30,
            left: -60,
            child: Icon(
              Icons.favorite,
              size: 240,
              color: const Color(0xFFFA709A).withValues(alpha: 0.03),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 16,
                    bottom: 8,
                  ),
                  child: _buildLongHungerBatteryCard(
                    icon: Icons.restaurant,
                    value: _hunger,
                    activeColor: Colors.orangeAccent,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _breathingController,
                      builder: (context, child) {
                        double scaleY =
                            1.0 + (_breathingController.value * 0.07);
                        double scaleX =
                            1.0 - (_breathingController.value * 0.04);
                        double translateY = _breathingController.value * 12;

                        return Transform.translate(
                          offset: Offset(0, -translateY),
                          child: SizedBox(
                            width: 230,
                            height: 250,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned(
                                  top: moodStage == 3
                                      ? 32
                                      : (moodStage == 2 ? 20 : 12),
                                  left: 16,
                                  child: Transform.rotate(
                                    angle: moodStage == 3
                                        ? -0.05
                                        : (moodStage == 2 ? -0.25 : -0.45),
                                    child: Container(
                                      width: 45,
                                      height: 65,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6C5CE7),
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(30),
                                              bottom: Radius.circular(15),
                                            ),
                                        border: Border.all(
                                          color: const Color(0xFFB19FFB),
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 25,
                                          height: 45,
                                          decoration: BoxDecoration(
                                            color: moodStage == 3
                                                ? const Color(0xFF5A49E3)
                                                : const Color(0xFFFA709A),
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(20),
                                                  bottom: Radius.circular(10),
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: moodStage == 3
                                      ? 32
                                      : (moodStage == 2 ? 20 : 12),
                                  right: 16,
                                  child: Transform.rotate(
                                    angle: moodStage == 3
                                        ? 0.05
                                        : (moodStage == 2 ? 0.25 : 0.45),
                                    child: Container(
                                      width: 45,
                                      height: 65,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6C5CE7),
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(30),
                                              bottom: Radius.circular(15),
                                            ),
                                        border: Border.all(
                                          color: const Color(0xFFB19FFB),
                                          width: 2,
                                        ),
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 25,
                                          height: 45,
                                          decoration: BoxDecoration(
                                            color: moodStage == 3
                                                ? const Color(0xFF5A49E3)
                                                : const Color(0xFFFA709A),
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(20),
                                                  bottom: Radius.circular(10),
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 4,
                                  left: 50,
                                  child: Container(
                                    width: 30,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF5A49E3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 4,
                                  right: 50,
                                  child: Container(
                                    width: 30,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF5A49E3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                Transform.scale(
                                  scaleX: scaleX,
                                  scaleY: scaleY,
                                  child: Container(
                                    width: 175,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      gradient: const RadialGradient(
                                        center: Alignment(-0.15, -0.25),
                                        radius: 0.85,
                                        colors: [
                                          Color(0xFFB19FFB),
                                          Color(0xFF6C5CE7),
                                        ],
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(85),
                                        topRight: Radius.circular(85),
                                        bottomLeft: Radius.circular(70),
                                        bottomRight: Radius.circular(70),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(
                                            0xFF6C5CE7,
                                          ).withValues(alpha: 0.3),
                                          blurRadius: 25,
                                          offset: const Offset(0, 12),
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.4,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Positioned(
                                          top: 15,
                                          left: 30,
                                          child: Container(
                                            width: 40,
                                            height: 18,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: 0.25,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: moodStage == 3 ? 72 : 65,
                                          left: 32,
                                          child: _buildEye(moodStage),
                                        ),
                                        Positioned(
                                          top: moodStage == 3 ? 72 : 65,
                                          right: 32,
                                          child: _buildEye(moodStage),
                                        ),
                                        if (moodStage == 1) ...[
                                          Positioned(
                                            top: 95,
                                            left: 20,
                                            child: Container(
                                              width:
                                                  22 +
                                                  (_breathingController.value *
                                                      4),
                                              height:
                                                  12 +
                                                  (_breathingController.value *
                                                      2),
                                              decoration: BoxDecoration(
                                                color: Colors.pinkAccent
                                                    .withValues(
                                                      alpha:
                                                          0.6 +
                                                          (_breathingController
                                                                  .value *
                                                              0.2),
                                                    ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            top: 95,
                                            right: 20,
                                            child: Container(
                                              width:
                                                  22 +
                                                  (_breathingController.value *
                                                      4),
                                              height:
                                                  12 +
                                                  (_breathingController.value *
                                                      2),
                                              decoration: BoxDecoration(
                                                color: Colors.pinkAccent
                                                    .withValues(
                                                      alpha:
                                                          0.6 +
                                                          (_breathingController
                                                                  .value *
                                                              0.2),
                                                    ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          ),
                                        ],
                                        Positioned(
                                          top: moodStage == 3
                                              ? 100
                                              : (moodStage == 2 ? 94 : 90),
                                          child: _buildMouth(moodStage),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 24,
                    left: 20,
                    right: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFoodButton(
                        icon: Icons.cookie,
                        bonusText: '+15',
                        cost: 3,
                        color: Colors.orangeAccent,
                        onTap: () => _purchaseFood(
                          3,
                          15.0,
                          'Bąbel schrupał pyszną przekąskę! 🍪 (-3 🪙)',
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildFoodButton(
                        icon: Icons.restaurant,
                        bonusText: '+40',
                        cost: 6,
                        color: Colors.amber,
                        onTap: () => _purchaseFood(
                          6,
                          40.0,
                          'Bąbel zjadł potężny, duży obiad! 🍗 (-6 🪙)',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodButton({
    required IconData icon,
    required String bonusText,
    required int cost,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF222029),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    bonusText,
                    style: const TextStyle(
                      fontFamily: 'Lato',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: Colors.amber,
                          size: 12,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$cost',
                          style: const TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEye(int moodStage) {
    if (moodStage == 3) {
      return SizedBox(
        width: 34,
        height: 24,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 32,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF1D1B26),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(width: 20, height: 2, color: Colors.black26),
            ),
          ],
        ),
      );
    } else if (moodStage == 2) {
      return Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
          color: Color(0xFF1D1B26),
          shape: BoxShape.circle,
        ),
        child: Stack(
          children: [
            Positioned(
              top: 5,
              left: 6,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Color(0xFF1D1B26),
        shape: BoxShape.circle,
      ),
      child: Stack(
        children: [
          Positioned(
            top: 4,
            left: 5,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 5,
            right: 5,
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMouth(int moodStage) {
    if (moodStage == 3) {
      return CustomPaint(
        size: const Size(44, 22),
        painter: _VerySadMouthPainter(),
      );
    } else if (moodStage == 2) {
      return Transform.rotate(
        angle: 0.08,
        child: Container(
          width: 20,
          height: 4,
          decoration: BoxDecoration(
            color: const Color(0xFF1D1B26),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
    }
    return Container(
      width: 40,
      height: 24,
      decoration: const BoxDecoration(
        color: Color(0xFF1D1B26),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            bottom: -4,
            child: Container(
              width: 28,
              height: 16,
              decoration: const BoxDecoration(
                color: Colors.pinkAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _claimTaskReward(String fieldName, int rewardAmount) async {
    final prefs = await SharedPreferences.getInstance();
    final String todayKey = _getTodayKey();
    final String prefix = widget.currentUser == 'User 1' ? 'user1_' : 'user2_';

    setState(() {
      _coins += rewardAmount;
    });

    await prefs.setString('$prefix$fieldName', todayKey);
    await _saveLocalDemoData();
  }

  bool _isAfterNineAM() => DateTime.now().hour >= 9;
}

class _VerySadMouthPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1D1B26)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(2, size.height)
      ..quadraticBezierTo(size.width / 2, -2, size.width - 2, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
