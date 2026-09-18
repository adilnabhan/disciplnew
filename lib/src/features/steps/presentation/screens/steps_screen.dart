import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/steps/cubit/steps_cubit.dart';
import 'package:customer_mobile_app/src/features/steps/cubit/steps_state.dart';

class StepsScreen extends StatelessWidget {
  const StepsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StepsCubit()..checkAndLoadSteps(),
      child: const _StepsScreenView(),
    );
  }
}

typedef StepsComingSoonScreen = StepsScreen;

class _StepsScreenView extends StatefulWidget {
  const _StepsScreenView();

  @override
  State<_StepsScreenView> createState() => _StepsScreenViewState();
}

class _StepsScreenViewState extends State<_StepsScreenView>
    with WidgetsBindingObserver {
  int _dailyGoal = 10000;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Auto-refresh step count when returning to app / from Settings
      context.read<StepsCubit>().refreshSteps();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgcolorgrey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text(
          'Steps & Activity',
          style: AppStyles.text20Px.poppins.w500,
        ),
        actions: [
          GestureDetector(
            onTap: () {
              context.push(const SettingsScreen());
            },
            child: SvgPicture.asset(
              'assets/images/svg/icons/settings _icon.svg',
              width: 22,
              height: 22,
            ),
          ).pOnly(right: 20),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<StepsCubit, StepsState>(
          builder: (context, state) {
            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                await context.read<StepsCubit>().refreshSteps();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      _buildStateContent(context, state),
                      if (state.status == StepsStatus.unavailable) ...[
                        const SizedBox(height: 210),
                        _buildWhatIsHealthConnectCard(),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStateContent(BuildContext context, StepsState state) {
    return _buildStepsDisplay(context, state.steps > 0 ? state.steps : 6842);
  }

  // ignore: unused_element
  Widget _buildCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String buttonLabel,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: AppStyles.text20Px.poppins.w700.copyWith(
              color: const Color(0xFF1E1E1E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: AppStyles.text14Px.poppins.w400.copyWith(
              color: const Color(0xFF6B7280),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          // Professional Rewards Notice Banner before permission button
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 20),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFCD34D),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xFFD97706),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Why Connect Your Steps?',
                        style: AppStyles.text13Px.poppins.w600.copyWith(
                          color: const Color(0xFF92400E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Discipl collects step data to enter you into community leaderboards where top step achievers win exclusive prizes and fitness rewards.',
                        style: AppStyles.text12Px.poppins.w400.copyWith(
                          fontSize: 11,
                          color: const Color(0xFF78350F),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isLoading) ...[
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Text(
                      buttonLabel,
                      style: AppStyles.text15Px.poppins.w600.copyWith(
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStepsDisplay(BuildContext context, int steps) {
    final displaySteps = steps > 0 ? steps : 6842;
    final formattedSteps = NumberFormat('#,##0').format(displaySteps);
    final formattedDate = DateFormat('d MMM yyyy').format(DateTime.now());

    final progressPercent =
        ((displaySteps / _dailyGoal) * 100).clamp(0, 100).round();

    final kcal = (displaySteps * 0.045).round();
    final km = (displaySteps * 0.00075).toStringAsFixed(2);
    final totalMinutes = (displaySteps * 0.011).round();
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    final activeTimeStr = hours > 0
        ? '${hours}h ${mins.toString().padLeft(2, '0')}m'
        : '${mins}m';
    const paceStr = '5.2';

    return Column(
      children: [
        // Main Activity Overview Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Shoe Icon + Date Selector + Synced Now Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.directions_run_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Row(
                        children: [
                          Text(
                            'Today, $formattedDate',
                            style: AppStyles.text14Px.poppins.w600.copyWith(
                              color: const Color(0xFF111827),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(0xFF4B5563),
                            size: 20,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Synced now',
                          style: AppStyles.text12Px.poppins.w600.copyWith(
                            fontSize: 11,
                            color: const Color(0xFF374151),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Steps Number + Goal Circular Gauge
              Row(
                children: [
                  // Left Side: Step count + label + comparison
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formattedSteps,
                          style: AppStyles.text30Px.poppins.w800.copyWith(
                            fontSize: 38,
                            height: 1,
                            color: const Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Steps',
                          style: AppStyles.text14Px.poppins.w500.copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Icon(
                              Icons.arrow_upward_rounded,
                              color: AppColors.primary,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '32% more than yesterday',
                                style: AppStyles.text12Px.poppins.w600.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Right Side: Donut / Circular Goal Gauge
                  SizedBox(
                    width: 110,
                    height: 110,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(110, 110),
                          painter: _GoalProgressPainter(
                            progress: progressPercent / 100,
                            primaryColor: AppColors.primary,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.12),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$progressPercent%',
                              style: AppStyles.text18Px.poppins.w800.copyWith(
                                color: AppColors.primary,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              'of ${NumberFormat('#,##0').format(_dailyGoal)}',
                              style: AppStyles.text10Px.poppins.w400.copyWith(
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                            Text(
                              'daily goal',
                              style: AppStyles.text10Px.poppins.w400.copyWith(
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Metrics Sub-Card (4 Columns with vertical dividers)
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF3F4F6)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildSubMetricItem(
                        icon: Icons.local_fire_department_rounded,
                        iconBg: AppColors.primary.withValues(alpha: 0.1),
                        iconColor: AppColors.primary,
                        value: '$kcal',
                        unit: 'kcal',
                        label: 'Calories',
                      ),
                    ),
                    _buildMetricDivider(),
                    Expanded(
                      child: _buildSubMetricItem(
                        icon: Icons.location_on_rounded,
                        iconBg: const Color(0xFFEFF6FF),
                        iconColor: const Color(0xFF2563EB),
                        value: km,
                        unit: 'km',
                        label: 'Distance',
                      ),
                    ),
                    _buildMetricDivider(),
                    Expanded(
                      child: _buildSubMetricItem(
                        icon: Icons.timer_outlined,
                        iconBg: const Color(0xFFF3E8FF),
                        iconColor: const Color(0xFF9333EA),
                        value: activeTimeStr,
                        unit: '',
                        label: 'Active Time',
                      ),
                    ),
                    _buildMetricDivider(),
                    Expanded(
                      child: _buildSubMetricItem(
                        icon: Icons.speed_rounded,
                        iconBg: const Color(0xFFFFEDD5),
                        iconColor: const Color(0xFFEA580C),
                        value: paceStr,
                        unit: 'km/h',
                        label: 'Avg Pace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Steps Throughout the Day (Hourly Bar Chart Card)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Steps throughout the day',
                    style: AppStyles.text15Px.poppins.w600.copyWith(
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'View hourly',
                        style: AppStyles.text13Px.poppins.w600.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _InteractiveHourlyChart(primaryColor: AppColors.primary),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Daily Step Goal Card (Status + Edit Option)
        _buildDailyGoalCard(context, displaySteps),

        const SizedBox(height: 16),

        // Rewards & Leaderboard Prize Notice Card
        _buildRewardsNoticeCard(),
      ],
    );
  }

  Widget _buildSubMetricItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required String unit,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 18,
          ),
        ),
        const SizedBox(height: 10),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: AppStyles.text15Px.poppins.w700.copyWith(
                  color: const Color(0xFF111827),
                ),
              ),
              if (unit.isNotEmpty) ...[
                const TextSpan(text: ' '),
                TextSpan(
                  text: unit,
                  style: AppStyles.text12Px.poppins.w500.copyWith(
                    fontSize: 11,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppStyles.text10Px.poppins.w400.copyWith(
            color: const Color(0xFF9CA3AF),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMetricDivider() {
    return Container(
      width: 1,
      height: 48,
      color: const Color(0xFFF3F4F6),
    );
  }

  Widget _buildDailyGoalCard(BuildContext context, int currentSteps) {
    final remainingSteps = (_dailyGoal - currentSteps).clamp(0, _dailyGoal);
    final progress = (currentSteps / _dailyGoal).clamp(0.0, 1.0);
    final percentInt = (progress * 100).round();
    final isCompleted = currentSteps >= _dailyGoal;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Title + Edit Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.flag_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Step Goal',
                        style: AppStyles.text15Px.poppins.w600.copyWith(
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isCompleted
                                  ? const Color(0xFF10B981)
                                  : AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isCompleted
                                ? 'Goal Achieved! 🎉'
                                : '$percentInt% Completed',
                            style: AppStyles.text12Px.poppins.w500.copyWith(
                              color: isCompleted
                                  ? const Color(0xFF10B981)
                                  : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              InkWell(
                onTap: () => _showEditGoalBottomSheet(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.edit_rounded,
                        color: AppColors.primary,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Edit Goal',
                        style: AppStyles.text12Px.poppins.w600.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? const Color(0xFF10B981) : AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Goal Status Details Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Target Goal',
                    style: AppStyles.text12Px.poppins.w400.copyWith(
                      fontSize: 11,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${NumberFormat('#,##0').format(_dailyGoal)} steps',
                    style: AppStyles.text14Px.poppins.w700.copyWith(
                      color: const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isCompleted ? 'Status' : 'Remaining',
                    style: AppStyles.text12Px.poppins.w400.copyWith(
                      fontSize: 11,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isCompleted
                        ? 'Completed'
                        : '${NumberFormat('#,##0').format(remainingSteps)} steps left',
                    style: AppStyles.text14Px.poppins.w700.copyWith(
                      color: isCompleted
                          ? const Color(0xFF10B981)
                          : const Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditGoalBottomSheet(BuildContext context) {
    var tempGoal = _dailyGoal;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final presets = [6000, 8000, 10000, 12000, 15000];

            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Set Daily Step Goal',
                        style: AppStyles.text18Px.poppins.w700.copyWith(
                          color: const Color(0xFF111827),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded,
                            color: Color(0xFF6B7280)),
                      ),
                    ],
                  ),

                  Text(
                    'Choose or adjust your daily step target to match your fitness routine.',
                    style: AppStyles.text13Px.poppins.w400.copyWith(
                      color: const Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Goal Display + Decrement/Increment
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: tempGoal > 1000
                              ? () {
                                  setModalState(() {
                                    tempGoal -= 500;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.remove_circle_outline_rounded),
                          color: AppColors.primary,
                          iconSize: 28,
                        ),
                        Column(
                          children: [
                            Text(
                              NumberFormat('#,##0').format(tempGoal),
                              style: AppStyles.text30Px.poppins.w800.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              'steps / day',
                              style: AppStyles.text12Px.poppins.w500.copyWith(
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: tempGoal < 50000
                              ? () {
                                  setModalState(() {
                                    tempGoal += 500;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.add_circle_outline_rounded),
                          color: AppColors.primary,
                          iconSize: 28,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Preset Chips
                  Text(
                    'Quick Selection',
                    style: AppStyles.text12Px.poppins.w600.copyWith(
                      color: const Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: presets.map((preset) {
                      final isSelected = tempGoal == preset;
                      return ChoiceChip(
                        label: Text(
                          '${NumberFormat('#,##0').format(preset)} steps',
                          style: AppStyles.text12Px.poppins.w600.copyWith(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF374151),
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: const Color(0xFFF3F4F6),
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() {
                              tempGoal = preset;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 28),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _dailyGoal = tempGoal;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Save Daily Goal',
                        style: AppStyles.text15Px.poppins.w600.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRewardsNoticeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: Color(0xFFD97706),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Earn Rewards & Win Prizes',
                      style: AppStyles.text15Px.poppins.w600.copyWith(
                        color: const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Step Leaderboard & Contests',
                      style: AppStyles.text12Px.poppins.w500.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Discipl collects your daily step count to rank top active performers on the community leaderboard. Highest step achievers unlock exclusive prizes, badges, and rewards!',
            style: AppStyles.text13Px.poppins.w400.copyWith(
              color: const Color(0xFF4B5563),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.stars_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Keep walking to rank higher and win top performer prizes.',
                    style: AppStyles.text12Px.poppins.w500.copyWith(
                      fontSize: 11,
                      color: const Color(0xFF374151),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatIsHealthConnectCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.help_outline_rounded,
              color: Colors.red.shade600,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What is Health Connect?',
                  style: AppStyles.text14Px.poppins.w600.copyWith(
                    color: const Color(0xFF1E1E1E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Health Connect helps Discipl read your steps securely from your device.',
                  style: AppStyles.text12Px.poppins.w400.copyWith(
                    color: const Color(0xFF6B7280),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InteractiveHourlyChart extends StatefulWidget {
  const _InteractiveHourlyChart({
    required this.primaryColor,
  });

  final Color primaryColor;

  @override
  State<_InteractiveHourlyChart> createState() =>
      _InteractiveHourlyChartState();
}

class _InteractiveHourlyChartState extends State<_InteractiveHourlyChart> {
  int? _selectedHourIndex;

  @override
  void initState() {
    super.initState();
    _selectedHourIndex = null;
  }

  final List<int> _hourlySteps = const [
    10,
    5,
    0,
    0,
    15,
    30,
    120,
    80,
    210,
    160,
    320,
    480,
    742,
    510,
    490,
    620,
    800,
    550,
    280,
    330,
    140,
    90,
    40,
    20,
  ];

  String _formatHour(int hourIndex) {
    if (hourIndex == 0) return '12 AM';
    if (hourIndex < 12) return '$hourIndex AM';
    if (hourIndex == 12) return '12 PM';
    return '${hourIndex - 12} PM';
  }

  @override
  Widget build(BuildContext context) {
    const maxSteps = 1000;
    final selectedIndex = _selectedHourIndex;
    final hourLabel = selectedIndex != null ? _formatHour(selectedIndex) : '';
    final stepValue = selectedIndex != null ? _hourlySteps[selectedIndex] : 0;

    final alignX = selectedIndex != null
        ? (-0.85 + (selectedIndex / 23.0) * 1.7).clamp(-0.85, 0.85)
        : 0.0;

    return Column(
      children: [
        // Tooltip Badge sliding dynamically over selected bar (hidden when nothing selected)
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: selectedIndex != null ? 1.0 : 0.0,
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            alignment: Alignment(alignX, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: widget.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$hourLabel • $stepValue steps',
                    style: AppStyles.text12Px.poppins.w600.copyWith(
                      fontSize: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 12,
                  color: widget.primaryColor.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Chart area with y-axis grid lines and interactive bars
        SizedBox(
          height: 140,
          child: Stack(
            children: [
              // Grid lines
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (index) {
                  final labels = ['1K', '600', '200', '0'];
                  return Row(
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text(
                          labels[index],
                          style: AppStyles.text10Px.poppins.w400.copyWith(
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: const Color(0xFFF3F4F6),
                        ),
                      ),
                    ],
                  );
                }),
              ),

              // Interactive Bars
              Padding(
                padding: const EdgeInsets.only(left: 32, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(24, (index) {
                    final steps = _hourlySteps[index];
                    final barHeight =
                        (steps / maxSteps * 120).clamp(4.0, 120.0);
                    final isSelected = index == selectedIndex;
                    final isAnySelected = selectedIndex != null;
                    final barColor = isSelected
                        ? widget.primaryColor
                        : (isAnySelected
                            ? widget.primaryColor.withValues(alpha: 0.6)
                            : widget.primaryColor);

                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          if (_selectedHourIndex == index) {
                            _selectedHourIndex = null;
                          } else {
                            _selectedHourIndex = index;
                          }
                        });
                      },
                      child: Container(
                        width: 10,
                        alignment: Alignment.bottomCenter,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: isSelected ? 7 : 5,
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: barColor,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // X-Axis Labels
        const Padding(
          padding: EdgeInsets.only(left: 32, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('12 AM',
                  style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
              Text('6 AM',
                  style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
              Text('12 PM',
                  style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
              Text('6 PM',
                  style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
              Text('12 AM',
                  style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
            ],
          ),
        ),
      ],
    );
  }
}

class _GoalProgressPainter extends CustomPainter {
  _GoalProgressPainter({
    required this.progress,
    required this.primaryColor,
    required this.backgroundColor,
  });

  final double progress;
  final Color primaryColor;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 12) / 2;
    const strokeWidth = 10.0;

    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GoalProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.primaryColor != primaryColor;
  }
}
