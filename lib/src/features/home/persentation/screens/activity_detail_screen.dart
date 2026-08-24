import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:customer_mobile_app/src/features/home/services/health_sync_service.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/cyber_workout_theme.dart';

enum ActivityTimeTab { day, week, month }
enum ActivityMetricType { steps, heartPoints, calories, distance }

class ActivityDetailScreen extends StatefulWidget {
  final HealthActivityData initialHealthData;

  const ActivityDetailScreen({
    super.key,
    required this.initialHealthData,
  });

  @override
  State<ActivityDetailScreen> createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  ActivityTimeTab _selectedTimeTab = ActivityTimeTab.day;
  ActivityMetricType _selectedMetric = ActivityMetricType.steps;
  DateTime _currentDate = DateTime.now();

  late HealthActivityData _healthData;
  bool _isSyncing = false;
  bool _isLoadingData = false;
  double _userWeightKg = 73.0;

  // Day hourly queried data
  List<Map<String, dynamic>> _hourlyData = [];

  // Week breakdown (Past 7 days queried data)
  List<Map<String, dynamic>> _weekData = [];

  // Month breakdown (Past 4 weeks queried data)
  List<Map<String, dynamic>> _monthWeeksData = [];

  @override
  void initState() {
    super.initState();
    _healthData = widget.initialHealthData;
    _fetchDetailedData();
  }

  Future<void> _fetchDetailedData() async {
    if (!mounted) return;
    setState(() => _isLoadingData = true);

    try {
      final weekRes = await HealthSyncService().fetchWeekData(_currentDate);
      final hourlyRes = await HealthSyncService().fetchDayHourlyData(_currentDate);
      final monthRes = await HealthSyncService().fetchMonthData(_currentDate);

      if (mounted) {
        setState(() {
          _weekData = weekRes;
          _hourlyData = hourlyRes;
          _monthWeeksData = monthRes;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  Future<void> _triggerSync() async {
    setState(() => _isSyncing = true);
    final granted = await HealthSyncService().connectGoogleFitOrHealthConnect();
    await HealthSyncService().syncHealthData();
    if (mounted) {
      setState(() {
        _healthData = HealthSyncService().currentData;
      });
      await _fetchDetailedData();
      if (mounted) {
        setState(() => _isSyncing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              granted
                  ? '✅ Google Fit & Health Connect synced with all historical data!'
                  : 'Synced with live sensors.',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: granted ? const Color(0xFF00E676) : CyberWorkoutTheme.crimsonRed,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _shiftDate(int deltaDays) {
    setState(() {
      if (_selectedTimeTab == ActivityTimeTab.day) {
        _currentDate = _currentDate.add(Duration(days: deltaDays));
      } else if (_selectedTimeTab == ActivityTimeTab.week) {
        _currentDate = _currentDate.add(Duration(days: deltaDays * 7));
      } else {
        _currentDate = DateTime(_currentDate.year, _currentDate.month + deltaDays, _currentDate.day);
      }
    });
    _fetchDetailedData();
  }

  String _getDateHeaderString() {
    if (_selectedTimeTab == ActivityTimeTab.day) {
      final now = DateTime.now();
      if (_currentDate.year == now.year && _currentDate.month == now.month && _currentDate.day == now.day) {
        return 'Today, ${DateFormat('d MMMM').format(_currentDate)}';
      }
      return DateFormat('EEEE, d MMMM').format(_currentDate);
    } else if (_selectedTimeTab == ActivityTimeTab.week) {
      final startOfWeek = _currentDate.subtract(const Duration(days: 6));
      return '${DateFormat('d MMM').format(startOfWeek)} – ${DateFormat('d MMM').format(_currentDate)}';
    } else {
      return DateFormat('MMMM yyyy').format(_currentDate);
    }
  }

  int _getCalculatedTotalSteps() {
    if (_selectedTimeTab == ActivityTimeTab.day) {
      final now = DateTime.now();
      final isToday = _currentDate.year == now.year && _currentDate.month == now.month && _currentDate.day == now.day;
      if (isToday && _healthData.steps > 0) return _healthData.steps;

      int sum = 0;
      for (final h in _hourlyData) {
        sum += (h['steps'] as int? ?? 0);
      }
      return sum > 0 ? sum : (_weekData.isNotEmpty ? (_weekData.last['steps'] as int? ?? 0) : 0);
    } else if (_selectedTimeTab == ActivityTimeTab.week) {
      int sum = 0;
      for (final d in _weekData) {
        sum += (d['steps'] as int? ?? 0);
      }
      return sum;
    } else {
      int sum = 0;
      for (final w in _monthWeeksData) {
        sum += (w['steps'] as int? ?? 0);
      }
      return sum;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int displaySteps = _getCalculatedTotalSteps();
    final int heartPts = (displaySteps * 0.005).round();
    final String distStr = (displaySteps * 0.00075).toStringAsFixed(1);
    final int kcalVal = (displaySteps * 0.045).round();

    final bool isGoogleFit = _healthData.sourceType == HealthSourceType.googleFitHealthConnect;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101018),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Activity',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          // Source badge
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isGoogleFit
                  ? const Color(0xFF4285F4).withOpacity(0.2)
                  : const Color(0xFF00E676).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isGoogleFit ? const Color(0xFF4285F4) : const Color(0xFF00E676),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isGoogleFit ? Icons.health_and_safety_rounded : Icons.sensors_rounded,
                  color: isGoogleFit ? const Color(0xFF4285F4) : const Color(0xFF00E676),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  isGoogleFit ? 'GOOGLE FIT' : 'LIVE SENSOR',
                  style: TextStyle(
                    color: isGoogleFit ? const Color(0xFF4285F4) : const Color(0xFF00E676),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: (_isSyncing || _isLoadingData)
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.sync_rounded, color: Colors.white),
            onPressed: (_isSyncing || _isLoadingData) ? null : _triggerSync,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: CyberWorkoutTheme.crimsonRed,
        backgroundColor: const Color(0xFF141420),
        onRefresh: _triggerSync,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Time Navigation Tabs (Day / Week / Month)
              _buildTimeTabs(),
              const SizedBox(height: 16),

              // 2. Date Switcher Header (< Monday, 24 August >)
              _buildDateNavigator(),
              const SizedBox(height: 14),

              // 3. Hero Metric Display (Heart Points / Steps / Calories / Distance)
              _buildHeroMetricSection(displaySteps, heartPts, kcalVal, distStr),
              const SizedBox(height: 16),

              // 4. Interactive Chart Card (Matching Screenshot 1 & 2)
              _buildActivityChartCard(displaySteps, heartPts),
              const SizedBox(height: 16),

              // 5. Metric Toggles (Heart Points | Steps | Calories | Distance)
              _buildMetricSelector(),
              const SizedBox(height: 16),

              // 6. Educational Info Banner & Source Data Link
              _buildExplanationCard(),
              const SizedBox(height: 20),

              // 7. Detailed Log Breakdown (Matching Screenshot 2)
              _buildHistoryBreakdownList(),
              const SizedBox(height: 20),

              // 8. Weekly Target / WHO Card (Matching Screenshot 3)
              _buildWeeklyTargetCard(heartPts),
              const SizedBox(height: 20),

              // 9. Trends Section Grid (Steps, Weight, Calories, Heart Rate)
              _buildTrendsSection(displaySteps, kcalVal),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Day / Week / Month Tabs
  Widget _buildTimeTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF14141E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          _buildTimeTabItem('Day', ActivityTimeTab.day),
          _buildTimeTabItem('Week', ActivityTimeTab.week),
          _buildTimeTabItem('Month', ActivityTimeTab.month),
        ],
      ),
    );
  }

  Widget _buildTimeTabItem(String title, ActivityTimeTab tab) {
    final bool isSelected = _selectedTimeTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedTimeTab = tab);
          _fetchDetailedData();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? CyberWorkoutTheme.crimsonRed : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: CyberWorkoutTheme.crimsonRed.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white60,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  // 2. Date Navigation Header
  Widget _buildDateNavigator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: Colors.white70, size: 28),
          onPressed: () => _shiftDate(-1),
        ),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _currentDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: CyberWorkoutTheme.crimsonRed,
                      onPrimary: Colors.white,
                      surface: Color(0xFF161622),
                      onSurface: Colors.white,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              setState(() => _currentDate = picked);
              _fetchDetailedData();
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getDateHeaderString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.calendar_month_rounded, color: CyberWorkoutTheme.crimsonRed, size: 16),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 28),
          onPressed: () => _shiftDate(1),
        ),
      ],
    );
  }

  // 3. Hero Metric Display
  Widget _buildHeroMetricSection(int steps, int heartPts, int kcal, String distStr) {
    String valueStr = '$steps';
    String labelStr = _selectedTimeTab == ActivityTimeTab.day ? 'steps today' : 'total steps';
    IconData icon = Icons.directions_walk_rounded;
    Color iconColor = const Color(0xFF00E676);

    if (_selectedMetric == ActivityMetricType.heartPoints) {
      valueStr = '$heartPts';
      labelStr = 'Heart Points';
      icon = Icons.favorite_rounded;
      iconColor = CyberWorkoutTheme.crimsonRed;
    } else if (_selectedMetric == ActivityMetricType.calories) {
      valueStr = '$kcal';
      labelStr = 'kcal burned';
      icon = Icons.local_fire_department_rounded;
      iconColor = const Color(0xFFFF9100);
    } else if (_selectedMetric == ActivityMetricType.distance) {
      valueStr = distStr;
      labelStr = 'km traveled';
      icon = Icons.straighten_rounded;
      iconColor = const Color(0xFF3395FF);
    }

    return Center(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Text(
                valueStr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                labelStr,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4. Interactive Chart Card
  Widget _buildActivityChartCard(int steps, int heartPts) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141420),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _selectedTimeTab == ActivityTimeTab.day
                      ? '24-HOUR ACTIVITY TIMELINE'
                      : (_selectedTimeTab == ActivityTimeTab.week ? 'WEEKLY DISTRIBUTION' : 'MONTHLY TRENDS'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _selectedTimeTab == ActivityTimeTab.day
                    ? 'Goal: 10,000 / day'
                    : (_selectedTimeTab == ActivityTimeTab.week ? 'Goal: 70,000 / wk' : 'Goal: 300k / mo'),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Chart Rendering
          SizedBox(
            height: 160,
            child: _selectedTimeTab == ActivityTimeTab.day
                ? _buildDayTimelineChart()
                : (_selectedTimeTab == ActivityTimeTab.week ? _buildWeekBarChart() : _buildMonthBarChart()),
          ),
        ],
      ),
    );
  }

  // Day 24h timeline
  Widget _buildDayTimelineChart() {
    if (_hourlyData.isEmpty) {
      return const Center(child: Text('Loading activity...', style: TextStyle(color: Colors.white38)));
    }

    int maxHourSteps = 100;
    for (final h in _hourlyData) {
      final int s = h['steps'] as int? ?? 0;
      if (s > maxHourSteps) maxHourSteps = s;
    }

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _hourlyData.map((item) {
              final int s = item['steps'] as int? ?? 0;
              final double heightFactor = (s / maxHourSteps).clamp(0.06, 1.0);
              final bool isPeak = s >= (maxHourSteps * 0.7) && s > 0;

              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 14,
                    height: 110 * heightFactor,
                    decoration: BoxDecoration(
                      color: isPeak
                          ? CyberWorkoutTheme.crimsonRed
                          : (_selectedMetric == ActivityMetricType.heartPoints
                              ? const Color(0xFF00E676)
                              : const Color(0xFF3395FF)),
                      borderRadius: BorderRadius.circular(4),
                      gradient: isPeak
                          ? const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFFF334B), Color(0xFF990011)],
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['time'].toString().split(' ')[0],
                    style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // Week 7-day bar chart
  Widget _buildWeekBarChart() {
    if (_weekData.isEmpty) {
      return const Center(child: Text('Loading week data...', style: TextStyle(color: Colors.white38)));
    }

    int maxWeekSteps = 5000;
    for (final d in _weekData) {
      final int s = d['steps'] as int? ?? 0;
      if (s > maxWeekSteps) maxWeekSteps = s;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _weekData.map((item) {
        final int s = item['steps'] as int? ?? 0;
        final double heightFactor = (s / maxWeekSteps).clamp(0.08, 1.0);
        final bool isToday = item['day'] == 'Today';

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (s > 0)
              Text(
                s >= 1000 ? '${(s / 1000).toStringAsFixed(1)}k' : '$s',
                style: TextStyle(
                  color: isToday ? CyberWorkoutTheme.crimsonRed : Colors.white54,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            const SizedBox(height: 4),
            Container(
              width: 24,
              height: 110 * heightFactor,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: isToday
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFF334B), Color(0xFF990011)],
                      )
                    : LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF00E676).withOpacity(0.8),
                          const Color(0xFF008945).withOpacity(0.5),
                        ],
                      ),
                boxShadow: isToday
                    ? [
                        BoxShadow(
                          color: CyberWorkoutTheme.crimsonRed.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item['day'] as String,
              style: TextStyle(
                color: isToday ? Colors.white : Colors.white38,
                fontSize: 10,
                fontWeight: isToday ? FontWeight.w900 : FontWeight.bold,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // Month 4-week bar chart
  Widget _buildMonthBarChart() {
    if (_monthWeeksData.isEmpty) {
      return const Center(child: Text('Loading month data...', style: TextStyle(color: Colors.white38)));
    }

    int maxMonthSteps = 20000;
    for (final w in _monthWeeksData) {
      final int s = w['steps'] as int? ?? 0;
      if (s > maxMonthSteps) maxMonthSteps = s;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _monthWeeksData.map((item) {
        final int s = item['steps'] as int? ?? 0;
        final double heightFactor = (s / maxMonthSteps).clamp(0.1, 1.0);
        final bool isCurrent = item['week'].toString().contains('Current');

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              s >= 1000 ? '${(s / 1000).toStringAsFixed(0)}k' : '$s',
              style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Container(
              width: 44,
              height: 110 * heightFactor,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isCurrent
                      ? [const Color(0xFFFF334B), const Color(0xFF6B0010)]
                      : [const Color(0xFF3395FF), const Color(0xFF00387A)],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item['week'].toString().split(' ')[0],
              style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        );
      }).toList(),
    );
  }

  // 5. Metric Selector Pills
  Widget _buildMetricSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildMetricPill('Heart Points', ActivityMetricType.heartPoints),
          const SizedBox(width: 8),
          _buildMetricPill('Steps', ActivityMetricType.steps),
          const SizedBox(width: 8),
          _buildMetricPill('Calories', ActivityMetricType.calories),
          const SizedBox(width: 8),
          _buildMetricPill('Distance', ActivityMetricType.distance),
        ],
      ),
    );
  }

  Widget _buildMetricPill(String title, ActivityMetricType metric) {
    final bool isSelected = _selectedMetric == metric;
    return GestureDetector(
      onTap: () => setState(() => _selectedMetric = metric),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF222533) : const Color(0xFF14141E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF3395FF) : Colors.white10,
            width: isSelected ? 1.2 : 1.0,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // 6. Educational Info Banner & Source Data Link
  Widget _buildExplanationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _selectedMetric == ActivityMetricType.heartPoints
                ? "You score Heart Points for each minute of activity that gets your heart pumping, like a brisk walk. Increase the intensity to earn more."
                : "Steps are a useful measure of how much you're moving around, and can help you spot changes in your activity levels.",
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _triggerSync,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'See source data & sync Google Fit',
                  style: TextStyle(
                    color: Color(0xFF3395FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF3395FF), size: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 7. Detailed Log Breakdown
  Widget _buildHistoryBreakdownList() {
    final list = _selectedTimeTab == ActivityTimeTab.month ? _monthWeeksData : _weekData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedTimeTab == ActivityTimeTab.month ? 'MONTHLY WEEK BREAKDOWN' : 'DAILY BREAKDOWN',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = list[list.length - 1 - index];
            final int s = item['steps'] as int? ?? 0;
            final String title = _selectedTimeTab == ActivityTimeTab.month
                ? (item['week'] as String)
                : DateFormat('EEEE, d MMMM').format(item['date'] as DateTime);
            final int hr = item['hr'] as int? ?? (item['avgHr'] as int? ?? 74);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF141420),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$s steps',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: CyberWorkoutTheme.crimsonRed.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.favorite_rounded, color: CyberWorkoutTheme.crimsonRed, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              '$hr BPM',
                              style: const TextStyle(
                                color: CyberWorkoutTheme.crimsonRed,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // 8. Weekly Target / WHO Card
  Widget _buildWeeklyTargetCard(int heartPts) {
    const int targetPts = 150;
    final double progress = (heartPts / targetPts).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141420),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your weekly target',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 14),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            '23–29 Aug',
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$heartPts ',
                      style: const TextStyle(
                        color: Color(0xFF00E676),
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const TextSpan(
                      text: 'of 150',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.white10,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Scoring 150 Heart Points a week can help you live longer, sleep better and boost your mood',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 11, height: 1.4),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.public_rounded, color: Color(0xFF38BDF8), size: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 9. Trends Section Grid (Steps, Weight, Calories, Heart Rate)
  Widget _buildTrendsSection(int steps, int kcal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TRENDS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 12),

        // Steps Trend
        _buildTrendTile(
          title: 'Steps',
          subtitle: 'Past 7 days',
          value: '$steps Steps',
          icon: Icons.directions_walk_rounded,
          color: const Color(0xFF3395FF),
          onTap: () => setState(() => _selectedMetric = ActivityMetricType.steps),
        ),
        const SizedBox(height: 10),

        // Weight Trend
        _buildTrendTile(
          title: 'Weight',
          subtitle: 'Updated today',
          value: '${_userWeightKg.toStringAsFixed(1)} kg',
          icon: Icons.monitor_weight_rounded,
          color: const Color(0xFF00E676),
          trailing: IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF00E676), size: 22),
            onPressed: _showWeightDialog,
          ),
        ),
        const SizedBox(height: 10),

        // Energy Expended
        _buildTrendTile(
          title: 'Energy expended',
          subtitle: 'Active calorie burn',
          value: '$kcal kcal',
          icon: Icons.local_fire_department_rounded,
          color: const Color(0xFFFF9100),
          onTap: () => setState(() => _selectedMetric = ActivityMetricType.calories),
        ),
        const SizedBox(height: 10),

        // Heart Rate
        _buildTrendTile(
          title: 'Resting Heart Rate',
          subtitle: 'Cardio Pulse',
          value: '${_healthData.heartRate > 0 ? _healthData.heartRate : 74} BPM',
          icon: Icons.favorite_rounded,
          color: CyberWorkoutTheme.crimsonRed,
          onTap: () => setState(() => _selectedMetric = ActivityMetricType.heartPoints),
        ),
      ],
    );
  }

  Widget _buildTrendTile({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    required Color color,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF141420),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            if (trailing != null)
              trailing
            else
              Row(
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 18),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _showWeightDialog() {
    final controller = TextEditingController(text: '$_userWeightKg');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF161622),
          title: const Text('Log Body Weight', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
            decoration: InputDecoration(
              suffixText: 'kg',
              suffixStyle: const TextStyle(color: Colors.white60),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white24),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: CyberWorkoutTheme.crimsonRed),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: CyberWorkoutTheme.crimsonRed),
              onPressed: () {
                final double? w = double.tryParse(controller.text);
                if (w != null && w > 0) {
                  setState(() => _userWeightKg = w);
                }
                Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
