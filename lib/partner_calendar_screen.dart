import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PartnerCalendarScreen extends StatefulWidget {
  final String currentUser;
  const PartnerCalendarScreen({super.key, required this.currentUser});

  @override
  State<PartnerCalendarScreen> createState() => _PartnerCalendarScreenState();
}

class _PartnerCalendarScreenState extends State<PartnerCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _noteFocusNode = FocusNode();

  late final DateTime _minDate;
  late final DateTime _maxDate;
  late SharedPreferences _prefs;
  bool _isPrefsInitialized = false;

  final List<String> _polishMonths = [
    'Styczeń',
    'Luty',
    'Marzec',
    'Kwiecień',
    'Maj',
    'Czerwiec',
    'Lipiec',
    'Sierpień',
    'Wrzesień',
    'Październik',
    'Listopad',
    'Grudzień',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _minDate = DateTime(now.year - 5, now.month, 1);
    _maxDate = DateTime(now.year + 10, now.month, 1);

    _selectedDay = DateTime(
      _focusedDay.year,
      _focusedDay.month,
      _focusedDay.day,
    );
    _initLocalPrefs();
  }

  Future<void> _initLocalPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isPrefsInitialized = true;
        _loadCurrentDayNote();
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  String _getDateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void _loadCurrentDayNote() {
    if (!_isPrefsInitialized || _noteFocusNode.hasFocus) return;

    final key = _getDateKey(_selectedDay);
    _noteController.text = _prefs.getString('demo_calendar_${key}_note') ?? '';
  }

  Future<void> _updateLocalData(String field, dynamic value) async {
    if (!_isPrefsInitialized) return;
    final key = _getDateKey(_selectedDay);

    setState(() {
      if (value is bool) {
        _prefs.setBool('demo_calendar_${key}_$field', value);
      } else if (value is String) {
        _prefs.setString('demo_calendar_${key}_$field', value);
      }
    });
  }

  bool _getLocalBoolValue(DateTime date, String field) {
    if (!_isPrefsInitialized) return false;
    final key = _getDateKey(date);
    return _prefs.getBool('demo_calendar_${key}_$field') ?? false;
  }

  void _previousMonth() {
    final prevMonth = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    if (prevMonth.isAfter(_minDate) || prevMonth.isAtSameMomentAs(_minDate)) {
      setState(() {
        _focusedDay = prevMonth;
        _selectedDay = prevMonth;
        _loadCurrentDayNote();
      });
    }
  }

  void _nextMonth() {
    final nextMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    if (nextMonth.isBefore(_maxDate) || nextMonth.isAtSameMomentAs(_maxDate)) {
      setState(() {
        _focusedDay = nextMonth;
        _selectedDay = nextMonth;
        _loadCurrentDayNote();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPrefsInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final todayRaw = DateTime.now();
    final today = DateTime(todayRaw.year, todayRaw.month, todayRaw.day);

    bool isPeriod = _getLocalBoolValue(_selectedDay, 'period');
    bool isOvulation = _getLocalBoolValue(_selectedDay, 'ovulation');
    bool isSex = _getLocalBoolValue(_selectedDay, 'sex');

    final int daysInMonth = DateTime(
      _focusedDay.year,
      _focusedDay.month + 1,
      0,
    ).day;
    final int firstWeekdayOfMonth = DateTime(
      _focusedDay.year,
      _focusedDay.month,
      1,
    ).weekday;
    final int offset = firstWeekdayOfMonth - 1;
    final int totalItems = daysInMonth + offset;

    final List<String> weekdaysLabels = [
      'Pn',
      'Wt',
      'Śr',
      'Cz',
      'Pt',
      'Sb',
      'Nd',
    ];

    bool canGoBack =
        DateTime(
          _focusedDay.year,
          _focusedDay.month - 1,
          1,
        ).isAfter(_minDate) ||
        DateTime(
          _focusedDay.year,
          _focusedDay.month - 1,
          1,
        ).isAtSameMomentAs(_minDate);
    bool canGoForward =
        DateTime(
          _focusedDay.year,
          _focusedDay.month + 1,
          1,
        ).isBefore(_maxDate) ||
        DateTime(
          _focusedDay.year,
          _focusedDay.month + 1,
          1,
        ).isAtSameMomentAs(_maxDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nasz intymny kalendarz',
          style: TextStyle(fontFamily: 'Lato', fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFA709A),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                color: const Color(0xFF222029),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.chevron_left,
                              color: canGoBack
                                  ? const Color(0xFFFA709A)
                                  : Colors.grey,
                            ),
                            onPressed: canGoBack ? _previousMonth : null,
                          ),
                          Text(
                            "${_polishMonths[_focusedDay.month - 1]} ${_focusedDay.year}",
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.chevron_right,
                              color: canGoForward
                                  ? const Color(0xFFFA709A)
                                  : Colors.grey,
                            ),
                            onPressed: canGoForward ? _nextMonth : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                            ),
                        itemCount: 7,
                        itemBuilder: (context, index) => Center(
                          child: Text(
                            weekdaysLabels[index],
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.bold,
                              color: Colors.white38,
                            ),
                          ),
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                            ),
                        itemCount: totalItems,
                        itemBuilder: (context, index) {
                          if (index < offset) return const SizedBox.shrink();

                          final dayNumber = index - offset + 1;
                          final currentLoopDate = DateTime(
                            _focusedDay.year,
                            _focusedDay.month,
                            dayNumber,
                          );

                          bool loopPeriod = _getLocalBoolValue(
                            currentLoopDate,
                            'period',
                          );
                          bool loopOvulation = _getLocalBoolValue(
                            currentLoopDate,
                            'ovulation',
                          );
                          bool loopSex = _getLocalBoolValue(
                            currentLoopDate,
                            'sex',
                          );

                          bool isRealToday =
                              today.year == currentLoopDate.year &&
                              today.month == currentLoopDate.month &&
                              today.day == dayNumber;

                          bool isSelected =
                              _selectedDay.year == currentLoopDate.year &&
                              _selectedDay.month == currentLoopDate.month &&
                              _selectedDay.day == dayNumber;

                          Color cellColor = Colors.transparent;
                          if (loopPeriod)
                            cellColor = Colors.red.withValues(alpha: 0.3);
                          if (loopOvulation)
                            cellColor = Colors.blue.withValues(alpha: 0.3);
                          if (loopSex)
                            cellColor = Colors.pink.withValues(alpha: 0.5);

                          Color textColor = Colors.white;
                          if (loopPeriod) textColor = Colors.redAccent[100]!;
                          if (loopOvulation)
                            textColor = Colors.blueAccent[100]!;

                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedDay = currentLoopDate;
                                _loadCurrentDayNote();
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: cellColor,
                                borderRadius: BorderRadius.circular(10),
                                border: isSelected
                                    ? Border.all(
                                        color: const Color(0xFFFA709A),
                                        width: 2,
                                      )
                                    : (isRealToday
                                          ? Border.all(
                                              color: Colors.white24,
                                              width: 1,
                                            )
                                          : null),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$dayNumber',
                                    style: TextStyle(
                                      fontFamily: 'Lato',
                                      fontSize: 15,
                                      fontWeight: (isRealToday || isSelected)
                                          ? FontWeight.w900
                                          : FontWeight.normal,
                                      color: textColor,
                                    ),
                                  ),
                                  if (isRealToday)
                                    Container(
                                      margin: const EdgeInsets.only(top: 2),
                                      width: 5,
                                      height: 5,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFFA709A),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (widget.currentUser == 'User 2' ||
                  widget.currentUser == 'User 1') ...[
                Card(
                  color: const Color(0xFF222029),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 16,
                    ),
                    child: Column(
                      children: [
                        CheckboxListTile(
                          title: const Text(
                            'Okres 🩸',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              color: Colors.white,
                            ),
                          ),
                          activeColor: Colors.red,
                          value: isPeriod,
                          onChanged: (val) => _updateLocalData('period', val),
                        ),
                        CheckboxListTile(
                          title: const Text(
                            'Owulacja 🥚',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              color: Colors.white,
                            ),
                          ),
                          activeColor: Colors.blue,
                          value: isOvulation,
                          onChanged: (val) =>
                              _updateLocalData('ovulation', val),
                        ),
                        CheckboxListTile(
                          title: const Text(
                            'Seks  ❤️',
                            style: TextStyle(
                              fontFamily: 'Lato',
                              color: Colors.white,
                            ),
                          ),
                          activeColor: Colors.pink,
                          value: isSex,
                          onChanged: (val) => _updateLocalData('sex', val),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Card(
                  color: const Color(0xFF222029),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatusIndicator('Okres', isPeriod, Colors.red),
                        _buildStatusIndicator(
                          'Owulacja',
                          isOvulation,
                          Colors.blue,
                        ),
                        _buildStatusIndicator('Seks', isSex, Colors.pink),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 15),
              Card(
                color: const Color(0xFF222029),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Wspólna notatka na ten dzień:',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _noteController,
                        focusNode: _noteFocusNode,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Wpisz notatkę...',
                          hintStyle: const TextStyle(color: Colors.white30),
                          border: const OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFA709A),
                        ),
                        onPressed: () async {
                          await _updateLocalData('note', _noteController.text);
                          _noteFocusNode.unfocus();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Notatka zapisana lokalnie!'),
                              ),
                            );
                          }
                        },
                        child: const Text(
                          'Zapisz notatkę',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(String label, bool isActive, Color color) {
    return Column(
      children: [
        Icon(
          isActive ? Icons.check_circle : Icons.cancel,
          color: isActive ? color : Colors.grey,
          size: 30,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
