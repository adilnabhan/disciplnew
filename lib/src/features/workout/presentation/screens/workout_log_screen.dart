import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/completed_badge.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/primary_pill_button.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/screens/own_workout_screen.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/screens/workout_plan_screen.dart';


class WorkoutLogScreen extends StatefulWidget {
  const WorkoutLogScreen({super.key});

  @override
  State<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _lastSelectedDate = DateTime.now();

  late final ScrollController _scrollController;
  late final List<DateTime> _scrollableDays;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Generate 180 days before today, today itself, and 2 upcoming days (total 183 days)
    final today = DateTime.now();
    _scrollableDays = List.generate(183, (index) {
      return DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: 180 - index));
    });

    // Center the selected date on layout finish
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _centerSelectedDate(animate: false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _centerSelectedDate({bool animate = true}) {
    if (!_scrollController.hasClients) return;

    final index = _scrollableDays.indexWhere(
      (d) => _isSameDay(d, _selectedDate),
    );
    if (index == -1) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final double slotWidth = (screenWidth - 32.0) / 5.0;

    // Calculate targeted offset to put the slot in the exact middle of the screen
    final double targetOffset =
        index * slotWidth + (slotWidth / 2) + 16.0 - (screenWidth / 2);

    final double maxScroll = _scrollController.position.maxScrollExtent;
    final double minScroll = _scrollController.position.minScrollExtent;
    final double clampedOffset = targetOffset.clamp(minScroll, maxScroll);

    if (animate) {
      _scrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _scrollController.jumpTo(clampedOffset);
    }
  }

  void _changeMonth(int delta) {
    final today = DateTime.now();
    final targetDate = DateTime(
      _selectedDate.year,
      _selectedDate.month + delta,
      1,
    );

    // Block transitioning if the target month is in the future relative to the current month/year
    if (targetDate.year > today.year || 
        (targetDate.year == today.year && targetDate.month > today.month)) {
      return;
    }

    setState(() {
      _lastSelectedDate = _selectedDate;
      _selectedDate = targetDate;
      _centerSelectedDate();
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _lastSelectedDate = _selectedDate;
      _selectedDate = date;
    });
    _centerSelectedDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgcolorgrey,
      appBar: AppBar(
        backgroundColor: AppColors.light,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Text(
          'Workout Log',
          style: AppStyles.text20Px.poppins.w500.copyWith(
            height: 1.0,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {
                context.push(const SettingsScreen());
              },
              child: SvgPicture.asset(
                'assets/images/svg/icons/settings _icon.svg',
                width: 22,
                height: 22,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 21),
            _buildMonthNav(),
            const SizedBox(height: 34),
            _buildWeekStrip(),
            const SizedBox(height: 28),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _WorkoutCard(
                    index: 1,
                    title: 'Back\nExercise',
                    badge: 'Day 3/30',
                    hasImage: true,
                    isCompleted: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Workoutplanscreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  const _WorkoutCard(
                    index: 2,
                    title: 'Abs\nWorkout',
                    badge: null,
                    hasImage: false,
                    isCompleted: false,
                  ),
                ],
              ),
            ),
            _buildStartButton(),
          ],
        ),
      ),
    );
  }

  // ── Month navigation ──────────────────────────────────────────────────────
  Widget _buildMonthNav() {
    final monthLabel =
        '${_selectedDate.day} ${_monthName(_selectedDate.month)} ${_selectedDate.year}';
    
    final today = DateTime.now();
    final isCurrentOrFutureMonth = _selectedDate.year > today.year || 
        (_selectedDate.year == today.year && _selectedDate.month >= today.month);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _NavArrow(icon: Icons.chevron_left, onTap: () => _changeMonth(-1)),
          const SizedBox(width: 12),
          Text(
            monthLabel,
            textAlign: TextAlign.center,
            style: AppStyles.text16Px.poppins.w600.copyWith(
              height: 1.0,
              color: const Color(0xFF434A5D),
            ),
          ),
          const SizedBox(width: 14),
          _NavArrow(
            icon: Icons.chevron_right, 
            onTap: isCurrentOrFutureMonth ? null : () => _changeMonth(1),
          ),
        ],
      ),
    );
  }

  // ── Continuous swipable, auto-centering horizontal calendar strip ──────────
  Widget _buildWeekStrip() {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double slotWidth = (screenWidth - 32.0) / 5.0;
    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);

    return SizedBox(
      height: 85,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _scrollableDays.length,
        itemBuilder: (context, index) {
          final d = _scrollableDays[index];
          final isFutureDay = d.isAfter(todayMidnight);
          return SizedBox(
            width: slotWidth,
            child: Center(
              child: _DayTile(
                date: d,
                selected: _isSameDay(d, _selectedDate),
                onTap: isFutureDay ? null : () => _selectDate(d),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Bottom CTA ────────────────────────────────────────────────────────────
  Widget _buildStartButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 24),
      child: PrimaryPillButton(
        text: 'Start your own Workout',
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OwnWorkoutScreen(),
            ),
          );
        },
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _monthName(int month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[month - 1];
  }
}

// ── Day tile ─────────────────────────────────────────────────────────────────
class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.date,
    required this.selected,
    this.onTap,
  });

  final DateTime date;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = dayNames[date.weekday - 1];

    final isEnabled = onTap != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: selected ? 65 : 55,
        height: selected ? 85 : 70,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : const Color(0xFFECECEC),
          borderRadius: BorderRadius.circular(12),
          boxShadow:
              selected
                  ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.24),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                  : null,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding:
                selected
                    ? const EdgeInsets.only(
                      top: 12,
                      bottom: 12,
                      left: 20,
                      right: 20,
                    )
                    : const EdgeInsets.only(
                      top: 12,
                      bottom: 12,
                      left: 16,
                      right: 16,
                    ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  textAlign: TextAlign.center,
                  style: selected
                      ? AppStyles.text16Px.poppins.w700.copyWith(
                          height: 1.3,
                          color: Colors.white,
                        )
                      : isEnabled
                          ? AppStyles.text16Px.poppins.w600.copyWith(
                              height: 1.3,
                              color: AppColors.button,
                            )
                          : AppStyles.text16Px.poppins.w600.copyWith(
                              height: 1.3,
                              color: const Color(0xFF888888),
                            ),
                ),
                SizedBox(height: selected ? 12 : 4),
                Text(
                  dayName,
                  textAlign: TextAlign.center,
                  style: selected
                      ? AppStyles.text12Px.poppins.w500.copyWith(
                          fontSize: 12,
                          height: 1.3,
                          color: Colors.white,
                        )
                      : isEnabled
                          ? AppStyles.text12Px.poppins.w400.copyWith(
                              fontSize: 12,
                              height: 1.3,
                              color: AppColors.button,
                            )
                          : AppStyles.text12Px.poppins.w400.copyWith(
                              fontSize: 12,
                              height: 1.3,
                              color: const Color(0xFF888888),
                            ),
                ),
                if (selected) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Nav arrow button ──────────────────────────────────────────────────────────
class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon, 
        size: 16, 
        color: onTap != null ? const Color(0xFF434A5D) : const Color(0xFFD1D3D9),
      ),
    );
  }
}

// ── Workout card ──────────────────────────────────────────────────────────────
class _WorkoutCard extends StatelessWidget {
  const _WorkoutCard({
    required this.index,
    required this.title,
    required this.badge,
    required this.hasImage,
    required this.isCompleted,
    this.onTap,
  });

  final int index;
  final String title;
  final String? badge;
  final bool hasImage;
  final bool isCompleted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Completed is beige/taupe color, uncompleted is sleek grey
    final Color cardBg =
        isCompleted ? const Color(0xFFB09E92) : const Color(0xFFD1D3D9);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 135,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            image: hasImage
                ? const DecorationImage(
                    image: AssetImage('assets/images/png/vectors/workout_plan.png'),
                    fit: BoxFit.cover,
                    alignment: Alignment.centerRight,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left side: White nested container
              Container(
                width: 170,
                height: 120,
                margin: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$index',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF020202),
                        height: 1.15,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF212121),
                              height: 1.15,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 17,
                          color: Color(0xFF666666),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Right side: Badge text & circular white button
              Expanded(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 16, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (badge != null) ...[
                          Text(
                            badge!,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: Color(0xFF020202),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
       ),

        // Jagged coral-red star check badge overlay at top right of the card
        if (isCompleted)
          const Positioned(top: -7.0, right: -5.35, child: CompletedBadge()),
      ],
    );
  }
}
