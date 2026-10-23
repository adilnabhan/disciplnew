import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/profile/presentation/widgets/personal_record_state_views.dart';

/// Details screen for a single Personal Record (PR) workout.
class PersonalRecordDetailsScreen extends StatefulWidget {
  const PersonalRecordDetailsScreen({
    required this.workoutId,
    this.initialRecord,
    super.key,
  });

  final int workoutId;
  final PersonalRecordItemModel? initialRecord;

  @override
  State<PersonalRecordDetailsScreen> createState() =>
      _PersonalRecordDetailsScreenState();
}

class _PersonalRecordDetailsScreenState
    extends State<PersonalRecordDetailsScreen> {
  final PersonalRecordsRepository _repository = PersonalRecordsRepository();

  bool _isLoading = true;
  String? _errorMessage;
  PersonalRecordDetailData? _detail;

  String _selectedMetric = 'Max Weight';

  final List<String> _metrics = const [
    'Max Weight',
    'Best Rep',
    'Total Volume',
  ];

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  String _metricToParam(String metric) {
    switch (metric) {
      case 'Best Rep':
        return 'best_reps';
      case 'Total Volume':
        return 'total_volume';
      case 'Max Weight':
      default:
        return 'max_weight';
    }
  }

  Future<void> _fetchDetail({bool isRefresh = false}) async {
    if (!isRefresh && _detail == null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    final result = await _repository.fetchPersonalRecordDetail(
      workoutId: widget.workoutId,
      metric: _metricToParam(_selectedMetric),
    );

    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoading = false;
          _errorMessage = AppErrorHandler.formatUserFriendlyMessage(failure.msg, fallback: 'Unable to fetch exercise details. Please try again.');
        });
      },
      (data) {
        setState(() {
          _isLoading = false;
          _errorMessage = null;
          _detail = data;
        });
      },
    );
  }

  void _showMetricSelector() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder:
          (ctx) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Metric',
                    style: AppStyles.text18Px.poppins.w600.copyWith(
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._metrics.map((metric) {
                    final isSelected = _selectedMetric == metric;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color:
                            isSelected
                                ? const Color(0xFFE53935)
                                : const Color(0xFF9CA3AF),
                      ),
                      title: Text(
                        metric,
                        style: AppStyles.text15Px.poppins.w500.copyWith(
                          color:
                              isSelected
                                  ? const Color(0xFFE53935)
                                  : const Color(0xFF1F2937),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          _selectedMetric = metric;
                        });
                        Navigator.pop(ctx);
                        _fetchDetail();
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
    );
  }

  void _showAllTimeBestsInfo() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder:
          (ctx) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFEEEE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emoji_events_outlined,
                          color: Color(0xFFE53935),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'All Time Bests',
                        style: AppStyles.text18Px.poppins.w600.copyWith(
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'This section tracks your historical records across three key metrics:\n\n'
                    '• Max Weight: Your highest verified weight load lifted.\n'
                    '• Best Reps: The highest number of repetitions performed at a given weight.\n'
                    '• Total Volume: The total weight moved (sets × reps × weight) in a single training session.',
                    style: AppStyles.text14Px.poppins.w400.copyWith(
                      color: const Color(0xFF4B5563),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Understood',
                        style: AppStyles.text14Px.poppins.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFEEEEEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: Color(0xFF222222),
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Details',
          style: AppStyles.text18Px.poppins.w600.copyWith(
            color: const Color(0xFF1F2937),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _detail == null) {
      return const PRDetailLoadingSkeleton();
    }

    if (_errorMessage != null && _detail == null) {
      return PRErrorView(message: _errorMessage, onRetry: _fetchDetail);
    }

    final detail = _detail;
    if (detail == null) {
      return PRNoDataView(
        title: 'No Breakdown Available',
        message: 'No PR breakdown data recorded for this exercise yet.',
        onRefresh: _fetchDetail,
      );
    }

    final progress = detail.progressOverTime;
    final allTimeBests = detail.allTimeBests;

    return RefreshIndicator(
      onRefresh: () => _fetchDetail(isRefresh: true),
      color: const Color(0xFFE53935),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // ── Exercise Header ──
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(
                    Icons.fitness_center_rounded,
                    color: Color(0xFF1F2937),
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.name,
                      style: AppStyles.text20Px.poppins.w700.copyWith(
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail.category,
                      style: AppStyles.text13Px.poppins.w400.copyWith(
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── "Progress Over Time" Section ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress Over Time',
                style: AppStyles.text16Px.poppins.w600.copyWith(
                  color: const Color(0xFF1F2937),
                ),
              ),
              GestureDetector(
                onTap: _showMetricSelector,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _selectedMetric,
                        style: AppStyles.text12Px.poppins.w500.copyWith(
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF6B7280),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Progress Chart Card ──
          Container(
            padding: const EdgeInsets.only(
              top: 20,
              bottom: 14,
              left: 10,
              right: 14,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SizedBox(
              height: 180,
              child:
                  progress != null && progress.timeline.isNotEmpty
                      ? _PRProgressChart(
                        timeline: progress.timeline,
                        chartMeta: progress.chartMeta,
                        metric: _selectedMetric,
                      )
                      : Center(
                        child: Text(
                          'No progress history recorded yet',
                          style: AppStyles.text13Px.poppins.w400.copyWith(
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 22),

          // ── "All Time Bests" Section ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Time Bests',
                style: AppStyles.text16Px.poppins.w600.copyWith(
                  color: const Color(0xFF1F2937),
                ),
              ),
              GestureDetector(
                onTap: _showAllTimeBestsInfo,
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF9CA3AF),
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── All Time Bests List Card ──
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child:
                allTimeBests.isNotEmpty
                    ? Column(
                      children: List.generate(allTimeBests.length, (index) {
                        final item = allTimeBests[index];
                        final isLast = index == allTimeBests.length - 1;
                        final (
                          icon,
                          iconColor,
                          iconBgColor,
                        ) = _resolveBestItemIcon(item.key);

                        return _buildBestRow(
                          icon: icon,
                          iconColor: iconColor,
                          iconBgColor: iconBgColor,
                          title: item.title ?? 'Record',
                          subtitle: item.description ?? '',
                          value: item.displayValue ?? '-',
                          isLast: isLast,
                        );
                      }),
                    )
                    : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'No all-time bests recorded yet',
                          style: AppStyles.text13Px.poppins.w400.copyWith(
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    ),
          ),

          // ── Insights Card (if provided by API) ──
          if (detail.insights != null && detail.insights!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEF3C7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lightbulb_rounded,
                      color: Color(0xFFD97706),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coach Insights',
                          style: AppStyles.text14Px.poppins.w600.copyWith(
                            color: const Color(0xFF92400E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          detail.insights!,
                          style: AppStyles.text13Px.poppins.w400.copyWith(
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
          ],

          // ── Instructions Card (if provided by API) ──
          if (detail.instructions != null &&
              detail.instructions!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF4B5563),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Form & Instructions',
                        style: AppStyles.text14Px.poppins.w600.copyWith(
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    detail.instructions!,
                    style: AppStyles.text13Px.poppins.w400.copyWith(
                      color: const Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  (IconData, Color, Color) _resolveBestItemIcon(String? key) {
    switch (key) {
      case 'best_reps':
        return (
          Icons.repeat_rounded,
          const Color(0xFF10B981),
          const Color(0xFFE8F5E9),
        );
      case 'total_volume':
        return (
          Icons.bar_chart_rounded,
          const Color(0xFF2563EB),
          const Color(0xFFEFF6FF),
        );
      case 'max_weight':
      default:
        return (
          Icons.emoji_events,
          const Color(0xFFE53935),
          const Color(0xFFFFEEEE),
        );
    }
  }

  Widget _buildBestRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String value,
    required bool isLast,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(child: Icon(icon, color: iconColor, size: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppStyles.text14Px.poppins.w600.copyWith(
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppStyles.text11Px.poppins.w400.copyWith(
                          color: const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                value,
                style: AppStyles.text14Px.poppins.w700.copyWith(
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Container(
            height: 1,
            margin: const EdgeInsets.only(left: 66, right: 16),
            color: const Color(0xFFF1F3F5),
          ),
      ],
    );
  }
}

/// Custom line chart displaying progress over months with interactive tap and drag.
class _PRProgressChart extends StatefulWidget {
  const _PRProgressChart({
    required this.timeline,
    this.chartMeta,
    this.metric = 'Max Weight',
  });

  final List<PRTimelinePoint> timeline;
  final PRChartMeta? chartMeta;
  final String metric;

  @override
  State<_PRProgressChart> createState() => _PRProgressChartState();
}

class _PRProgressChartState extends State<_PRProgressChart> {
  int? _selectedIndex;

  void _onPan(Offset localPos, Size size) {
    if (widget.timeline.isEmpty) return;

    const leftPadding = 32.0;
    const rightPadding = 24.0;
    final chartWidth = size.width - leftPadding - rightPadding;

    final n = widget.timeline.length;
    var closestIndex = 0;
    var minDistance = double.infinity;

    for (var i = 0; i < n; i++) {
      final x =
          n == 1
              ? leftPadding + (chartWidth / 2)
              : leftPadding + (i * (chartWidth / (n - 1)));
      final dist = (x - localPos.dx).abs();
      if (dist < minDistance) {
        minDistance = dist;
        closestIndex = i;
      }
    }

    if (_selectedIndex != closestIndex) {
      setState(() {
        _selectedIndex = closestIndex;
      });
    }
  }

  void _onTapUp(Offset localPos, Size size) {
    if (widget.timeline.isEmpty) return;

    const leftPadding = 32.0;
    const rightPadding = 24.0;
    final chartWidth = size.width - leftPadding - rightPadding;

    final n = widget.timeline.length;
    var closestIndex = 0;
    var minDistance = double.infinity;

    for (var i = 0; i < n; i++) {
      final x =
          n == 1
              ? leftPadding + (chartWidth / 2)
              : leftPadding + (i * (chartWidth / (n - 1)));
      final dist = (x - localPos.dx).abs();
      if (dist < minDistance) {
        minDistance = dist;
        closestIndex = i;
      }
    }

    setState(() {
      if (_selectedIndex == closestIndex) {
        _selectedIndex = null;
      } else {
        _selectedIndex = closestIndex;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) => _onTapUp(details.localPosition, size),
          onPanUpdate: (details) => _onPan(details.localPosition, size),
          child: CustomPaint(
            size: Size.infinite,
            painter: _PRChartPainter(
              timeline: widget.timeline,
              chartMeta: widget.chartMeta,
              selectedIndex: _selectedIndex,
              metric: widget.metric,
            ),
          ),
        );
      },
    );
  }
}

class _PRChartPainter extends CustomPainter {
  const _PRChartPainter({
    required this.timeline,
    this.chartMeta,
    this.selectedIndex,
    this.metric = 'Max Weight',
  });

  final List<PRTimelinePoint> timeline;
  final PRChartMeta? chartMeta;
  final int? selectedIndex;
  final String metric;

  @override
  void paint(Canvas canvas, Size size) {
    if (timeline.isEmpty) return;

    const bottomPadding = 26.0;
    const topPadding = 36.0;
    const leftPadding = 32.0;
    const rightPadding = 24.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    var minVal = chartMeta?.minValue ?? 0;
    var maxVal = chartMeta?.maxValue ?? 150;

    for (final pt in timeline) {
      if (pt.value < minVal) minVal = pt.value;
      if (pt.value > maxVal) maxVal = pt.value;
    }
    if (maxVal <= minVal) {
      maxVal = minVal + 10;
    }

    final gridPaint =
        Paint()
          ..color = const Color(0xFFF1F3F5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    final ySteps = [
      minVal.toDouble(),
      (minVal + maxVal) / 2,
      maxVal.toDouble(),
    ];
    for (final val in ySteps) {
      final norm = (val - minVal) / (maxVal - minVal);
      final y = size.height - bottomPadding - (norm * chartHeight);

      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );

      final yPainter = TextPainter(
        text: TextSpan(
          text: val.toInt().toString(),
          style: const TextStyle(
            color: Color(0xFFADB5BD),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      yPainter.paint(
        canvas,
        Offset(leftPadding - yPainter.width - 6, y - (yPainter.height / 2)),
      );
    }

    final points = <Offset>[];
    for (var i = 0; i < timeline.length; i++) {
      final pt = timeline[i];
      final x =
          timeline.length == 1
              ? leftPadding + (chartWidth / 2)
              : leftPadding + (i * (chartWidth / (timeline.length - 1)));
      final norm = (pt.value - minVal) / (maxVal - minVal);
      final y = size.height - bottomPadding - (norm * chartHeight);
      points.add(Offset(x, y));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );
    }

    final fillPath =
        Path.from(path)
          ..lineTo(points.last.dx, size.height - bottomPadding)
          ..lineTo(points.first.dx, size.height - bottomPadding)
          ..close();

    final fillPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFE53935).withValues(alpha: 0.18),
              const Color(0xFFE53935).withValues(alpha: 0),
            ],
          ).createShader(Rect.fromLTWH(0, topPadding, size.width, chartHeight));

    canvas.drawPath(fillPath, fillPaint);

    final linePaint =
        Paint()
          ..color = const Color(0xFFE53935)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // If a point is selected, draw vertical dashed indicator line
    if (selectedIndex != null && selectedIndex! < points.length) {
      final selPt = points[selectedIndex!];
      final guidePaint =
          Paint()
            ..color = const Color(0xFFE53935).withValues(alpha: 0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2;

      const dashHeight = 4.0;
      const dashSpace = 3.0;
      var startY = topPadding;
      final endY = size.height - bottomPadding;
      while (startY < endY) {
        canvas.drawLine(
          Offset(selPt.dx, startY),
          Offset(selPt.dx, (startY + dashHeight).clamp(startY, endY)),
          guidePaint,
        );
        startY += dashHeight + dashSpace;
      }
    }

    final dotPaint = Paint()..color = const Color(0xFFE53935);
    final dotInnerPaint = Paint()..color = Colors.white;
    final dotRadius = points.length > 12 ? 3.5 : 4.5;
    final dotInnerRadius = points.length > 12 ? 1.5 : 2.0;

    // 1. Draw points
    for (var i = 0; i < points.length; i++) {
      final pt = points[i];
      final isSelected = selectedIndex == i;

      if (isSelected) {
        canvas
          ..drawCircle(
            pt,
            8,
            Paint()..color = const Color(0xFFE53935).withValues(alpha: 0.25),
          )
          ..drawCircle(pt, 5, dotPaint)
          ..drawCircle(pt, 2.5, dotInnerPaint);
      } else {
        canvas
          ..drawCircle(pt, dotRadius, dotPaint)
          ..drawCircle(pt, dotInnerRadius, dotInnerPaint);
      }
    }

    // 2. Draw consolidated, non-overlapping X-axis labels
    final labelSpans = <_PRLabelSpan>[];
    for (var i = 0; i < timeline.length; i++) {
      final item = timeline[i];
      final pt = points[i];
      if (labelSpans.isNotEmpty && labelSpans.last.text == item.displayDate) {
        labelSpans.last.endX = pt.dx;
        if (item.isPeak) {
          labelSpans.last.isPeak = true;
        }
      } else {
        labelSpans.add(
          _PRLabelSpan(
            text: item.displayDate,
            startX: pt.dx,
            endX: pt.dx,
            isPeak: item.isPeak,
          ),
        );
      }
    }

    var lastRightEdge = -100.0;
    for (final span in labelSpans) {
      final centerX = (span.startX + span.endX) / 2;

      final labelPainter = TextPainter(
        text: TextSpan(
          text: span.text,
          style: TextStyle(
            color:
                span.isPeak ? const Color(0xFFE53935) : const Color(0xFF9CA3AF),
            fontSize: 11,
            fontWeight: span.isPeak ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final labelLeft = centerX - (labelPainter.width / 2);
      final labelRight = labelLeft + labelPainter.width;

      if (labelLeft >= lastRightEdge + 8) {
        labelPainter.paint(canvas, Offset(labelLeft, size.height - 18));
        lastRightEdge = labelRight;
      }
    }

    // 3. Draw Badge (selected point tooltip if tapped, otherwise default peak badge)
    if (selectedIndex != null && selectedIndex! < points.length) {
      final pt = points[selectedIndex!];
      final item = timeline[selectedIndex!];

      String tooltipText;
      if (metric == 'Best Rep') {
        tooltipText = '${item.value} reps';
      } else if (metric == 'Total Volume') {
        tooltipText = '${item.value} kg';
      } else {
        tooltipText = '${item.value} kg';
        if (item.reps != null && item.reps! > 0) {
          tooltipText += ' × ${item.reps}';
        }
      }

      if (item.isPeak) {
        tooltipText = '👑 $tooltipText';
      }

      _drawInteractiveTooltip(
        canvas,
        pt,
        tooltipText,
        size,
        isPeak: item.isPeak,
      );
    } else {
      for (var i = 0; i < points.length; i++) {
        final item = timeline[i];
        if (item.isPeak) {
          final pt = points[i];
          final peakText = chartMeta?.peakFormatted ?? '${item.value} kg';
          _drawPeakBadge(canvas, pt, peakText, size);
        }
      }
    }
  }

  void _drawPeakBadge(Canvas canvas, Offset pt, String text, Size canvasSize) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeWidth = textPainter.width + 12;
    const badgeHeight = 20.0;

    final badgeCenterX = pt.dx.clamp(
      badgeWidth / 2 + 6,
      canvasSize.width - badgeWidth / 2 - 6,
    );
    final badgeCenterY = (pt.dy - 17).clamp(
      badgeHeight / 2 + 2,
      canvasSize.height - 30,
    );

    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(badgeCenterX, badgeCenterY),
        width: badgeWidth,
        height: badgeHeight,
      ),
      const Radius.circular(6),
    );

    final badgePaint = Paint()..color = const Color(0xFFE53935);
    canvas.drawRRect(badgeRect, badgePaint);

    textPainter.paint(
      canvas,
      Offset(
        badgeCenterX - (textPainter.width / 2),
        badgeCenterY - (textPainter.height / 2),
      ),
    );
  }

  void _drawInteractiveTooltip(
    Canvas canvas,
    Offset pt,
    String text,
    Size canvasSize, {
    required bool isPeak,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeWidth = textPainter.width + 16;
    const badgeHeight = 22.0;

    final badgeCenterX = pt.dx.clamp(
      badgeWidth / 2 + 8,
      canvasSize.width - badgeWidth / 2 - 8,
    );
    final badgeCenterY = (pt.dy - 20).clamp(
      badgeHeight / 2 + 4,
      canvasSize.height - 30,
    );

    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(badgeCenterX, badgeCenterY),
        width: badgeWidth,
        height: badgeHeight,
      ),
      const Radius.circular(8),
    );

    // Soft drop shadow
    final shadowPaint =
        Paint()
          ..color = Colors.black.withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawRRect(badgeRect.shift(const Offset(0, 2)), shadowPaint);

    // Background pill
    final badgePaint =
        Paint()
          ..color = isPeak ? const Color(0xFFE53935) : const Color(0xFF1F2937);
    canvas.drawRRect(badgeRect, badgePaint);

    // Pointer tail triangle
    final trianglePath =
        Path()
          ..moveTo(pt.dx - 4, badgeCenterY + (badgeHeight / 2))
          ..lineTo(pt.dx + 4, badgeCenterY + (badgeHeight / 2))
          ..lineTo(
            pt.dx,
            (badgeCenterY + (badgeHeight / 2) + 4).clamp(badgeCenterY, pt.dy),
          )
          ..close();
    canvas.drawPath(trianglePath, badgePaint);

    textPainter.paint(
      canvas,
      Offset(
        badgeCenterX - (textPainter.width / 2),
        badgeCenterY - (textPainter.height / 2),
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _PRChartPainter oldDelegate) {
    return oldDelegate.timeline != timeline ||
        oldDelegate.chartMeta != chartMeta ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.metric != metric;
  }
}

class _PRLabelSpan {
  _PRLabelSpan({
    required this.text,
    required this.startX,
    required this.endX,
    required this.isPeak,
  });

  final String text;
  final double startX;
  double endX;
  bool isPeak;
}
