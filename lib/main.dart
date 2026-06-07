import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'snap_chat_screen.dart';
import 'nasz_babel_screen.dart';
import 'partner_calendar_screen.dart';
import 'old_counter_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DynamicLoveCounterApp());
}

class DynamicLoveCounterApp extends StatefulWidget {
  const DynamicLoveCounterApp({super.key});

  @override
  State<DynamicLoveCounterApp> createState() =>
      _DynamicLoveCounterAppAppState();
}

class _DynamicLoveCounterAppAppState extends State<DynamicLoveCounterApp> {
  final ThemeMode _themeMode = ThemeMode.dark;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User 1 & User 2',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF16151A),
      ),
      home: const AppNavigationMaster(),
    );
  }
}

class AppNavigationMaster extends StatefulWidget {
  const AppNavigationMaster({super.key});

  @override
  State<AppNavigationMaster> createState() => _AppNavigationMasterState();
}

class _AppNavigationMasterState extends State<AppNavigationMaster> {
  String? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkUserSession();
  }

  Future<void> _checkUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUser = prefs.getString('user_profile');
      _isLoading = false;
    });
  }

  Future<void> _selectUser(String user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_profile', user);
    setState(() {
      _currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_currentUser == null) {
      return UserSelectionScreen(onUserSelected: _selectUser);
    }

    return MainMenuScreen(currentUser: _currentUser!);
  }
}

class UserSelectionScreen extends StatelessWidget {
  final Function(String) onUserSelected;
  const UserSelectionScreen({super.key, required this.onUserSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF16151A),
          ),
          Positioned(
            top: -50,
            right: -100,
            child: Icon(
              Icons.favorite,
              size: 300,
              color: const Color(0xFFFA709A).withValues(alpha: 0.05),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: Icon(
              Icons.favorite,
              size: 280,
              color: const Color(0xFFFA709A).withValues(alpha: 0.03),
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Kim jesteś?',
                    style: TextStyle(
                      fontFamily: 'DancingScript',
                      fontSize: 54,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFA709A),
                    ),
                  ),
                  const SizedBox(height: 50),
                  _buildUserButton(context, 'User 1', Icons.male),
                  const SizedBox(height: 24),
                  _buildUserButton(context, 'User 2', Icons.female),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserButton(BuildContext context, String name, IconData icon) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 18),
        backgroundColor: const Color(0xFF222029),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: const BorderSide(color: Color(0xFFFA709A), width: 1.5),
        ),
        elevation: 5,
      ),
      icon: Icon(icon, color: const Color(0xFFFA709A), size: 28),
      label: Text(
        name,
        style: const TextStyle(
          fontFamily: 'Lato',
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: () => onUserSelected(name),
    );
  }
}

class MainMenuScreen extends StatefulWidget {
  final String currentUser;
  const MainMenuScreen({super.key, required this.currentUser});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _localCoins = 45;
  double _localHunger = 78.0;

  @override
  void initState() {
    super.initState();
    _loadLocalBabelData();
  }

  Future<void> _loadLocalBabelData() async {
    final prefs = await SharedPreferences.getInstance();
    int savedCoins = prefs.getInt('demo_babel_coins') ?? 45;
    double savedHunger = prefs.getDouble('demo_babel_hunger') ?? 78.0;
    int? lastUpdateMillis = prefs.getInt('demo_babel_last_update');

    DateTime now = DateTime.now();
    if (lastUpdateMillis != null) {
      DateTime lastUpdate = DateTime.fromMillisecondsSinceEpoch(
        lastUpdateMillis,
      );
      int secondsPassed = now.difference(lastUpdate).inSeconds;

      if (secondsPassed >= 10) {
        double hungerDrain = secondsPassed * 0.001157;
        savedHunger = savedHunger - hungerDrain;
        if (savedHunger < 0) savedHunger = 0.0;
      }
    }

    await prefs.setInt('demo_babel_last_update', now.millisecondsSinceEpoch);
    await prefs.setDouble('demo_babel_hunger', savedHunger);

    if (mounted) {
      setState(() {
        _localCoins = savedCoins;
        _localHunger = savedHunger;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF16151A),
          ),
          Positioned(
            top: 100,
            left: -50,
            child: Icon(
              Icons.favorite,
              size: 250,
              color: const Color(0xFFFA709A).withValues(alpha: 0.04),
            ),
          ),
          Positioned(
            bottom: 40,
            right: -90,
            child: Icon(
              Icons.favorite,
              size: 350,
              color: const Color(0xFFFA709A).withValues(alpha: 0.05),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Cześć ${widget.currentUser}! ❤️',
                            style: const TextStyle(
                              fontFamily: 'DancingScript',
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.logout,
                              color: Color(0xFFFA709A),
                              size: 28,
                            ),
                            onPressed: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.remove('user_profile');
                              if (context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AppNavigationMaster(),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF222029),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(
                              0xFFFA709A,
                            ).withValues(alpha: 0.3),
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
                              '$_localCoins',
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
                    ],
                  ),
                  const SizedBox(height: 50),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildMenuCard(
                          context,
                          'Nasz kalendarz',
                          Icons.calendar_month,
                          const Color(0xFFFA709A),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PartnerCalendarScreen(
                                currentUser: widget.currentUser,
                              ),
                            ),
                          ).then((_) => _loadLocalBabelData()),
                        ),
                        const SizedBox(height: 16),
                        _buildMenuCard(
                          context,
                          'Nasz licznik',
                          Icons.favorite,
                          const Color(0xFFFA709A),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OldCounterScreen(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildMenuCard(
                          context,
                          'Nasz snap',
                          Icons.camera_alt,
                          const Color(0xFFFA709A),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SnapChatScreen(
                                currentUser: widget.currentUser,
                              ),
                            ),
                          ).then((_) => _loadLocalBabelData()),
                        ),
                        const SizedBox(height: 16),
                        _buildMenuCard(
                          context,
                          'Nasz Bąbel',
                          Icons.pets,
                          const Color(0xFFFA709A),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NaszBabelScreen(
                                currentUser: widget.currentUser,
                              ),
                            ),
                          ).then((_) => _loadLocalBabelData()),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context,
    String title,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: const Color(0xFF222029),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 36, color: iconColor),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.white30,
            ),
          ],
        ),
      ),
    );
  }
}
