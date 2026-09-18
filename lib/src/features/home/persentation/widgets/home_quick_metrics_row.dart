import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/scorecard/domain/models/score_card_model.dart';
import 'package:customer_mobile_app/src/features/scorecard/logic/score_card_cubit.dart';
import 'package:customer_mobile_app/src/features/scorecard/logic/score_card_state.dart';

class HomeQuickMetricsRow extends StatefulWidget {
  const HomeQuickMetricsRow({super.key, this.scoreCardCubit});

  final ScoreCardCubit? scoreCardCubit;

  @override
  State<HomeQuickMetricsRow> createState() => _HomeQuickMetricsRowState();
}

class _HomeQuickMetricsRowState extends State<HomeQuickMetricsRow> {
  ScoreCardCubit? _internalCubit;

  ScoreCardCubit get _cubit {
    if (widget.scoreCardCubit != null) {
      return widget.scoreCardCubit!;
    }
    _internalCubit ??= ScoreCardCubit();
    return _internalCubit!;
  }

  @override
  void initState() {
    super.initState();
    if (widget.scoreCardCubit == null) {
      final bool isGuest = Feggy.read<AppCubit>()?.state.currentUser == null;
      if (!isGuest) {
        _cubit.fetchScoreCard();
      }
    }
  }

  @override
  void dispose() {
    _internalCubit?.close();
    super.dispose();
  }

  int? _extractUserRank(ScoreCardResponseModel? data) {
    if (data == null) return null;

    final myPosRank = data.myPosition?.rank ?? data.myPosition?.currentRank;
    if (myPosRank != null && myPosRank > 0) return myPosRank;

    final meRank = data.me?.rank;
    if (meRank != null && meRank > 0) return meRank;

    for (final member in data.podium) {
      if (member.isCurrentUser && member.rank != null && member.rank! > 0) {
        return member.rank;
      }
    }

    for (final member in data.leaderboard) {
      if (member.isCurrentUser && member.rank != null && member.rank! > 0) {
        return member.rank;
      }
    }

    return null;
  }

  String _getOrdinalSuffix(int number) {
    if (number <= 0) return '';
    final tens = number % 100;
    if (tens >= 11 && tens <= 13) {
      return 'th';
    }
    switch (number % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  void _onScoreCardTap(BuildContext context) {
    try {
      context.read<DashboardCubit>().changeNav(index: 2);
    } catch (e) {
      debugPrint('Error navigating to scorecard tab: $e');
      try {
        Feggy.read<DashboardCubit>()?.changeNav(index: 2);
      } catch (_) {}
    }
  }

  Widget _buildRankContent(int? rank) {
    if (rank != null && rank > 0) {
      final suffix = _getOrdinalSuffix(rank);
      final rankStr = '$rank';
      final double fontSize =
          rankStr.length >= 4 ? 17 : (rankStr.length == 3 ? 21 : 23);

      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  '#',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
              ),
              Text(
                rankStr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                  height: 1.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  suffix,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return const Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            '#',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              height: 1.0,
            ),
          ),
        ),
        Text(
          '--',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            height: 1.0,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMetricItem(
            label: 'Steps',
            gradientColors: const [
              Color(0xFF5AB6FF),
              Color(0xFF2C7DF7),
            ],
            shadowColor: const Color(0xFF2C7DF7),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '5k',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 3),
                SvgPicture.string(
                  '''<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="white" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M4 17.5h16a1 1 0 0 0 1-1v-1a2 2 0 0 0-1-1.8l-5-2.5-2-4.5a1.5 1.5 0 0 0-2-.8l-2 1a1.5 1.5 0 0 0-.8 1.4v2.5l-4 3a2 2 0 0 0-.8 1.6V16.5a1 1 0 0 0 1 1z"/>
                    <path d="M9.5 10.5l2 1.5"/>
                    <path d="M8.5 13l2 1.5"/>
                  </svg>''',
                ),
              ],
            ),
          ),
          _buildMetricItem(
            label: 'Calorie',
            gradientColors: const [
              Color(0xFFFF8E76),
              Color(0xFFFF5238),
            ],
            shadowColor: const Color(0xFFFF5238),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: const [
                    Text(
                      '230',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        height: 1.0,
                      ),
                    ),
                    Text(
                      'kcl',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
          _buildMetricItem(
            label: 'Body Metrix',
            gradientColors: const [
              Color(0xFFFF718F),
              Color(0xFFFF2E59),
            ],
            shadowColor: const Color(0xFFFF2E59),
            child: Center(
              child: SvgPicture.string(
                '''<svg viewBox="0 0 40 40" width="36" height="36" fill="none">
                  <!-- Outer Hexagon Lines -->
                  <line x1="20" y1="5" x2="34" y2="13" stroke="white" stroke-width="2.2" stroke-linecap="round"/>
                  <line x1="34" y1="13" x2="34" y2="27" stroke="white" stroke-width="2.2" stroke-linecap="round"/>
                  <line x1="34" y1="27" x2="20" y2="35" stroke="white" stroke-width="2.2" stroke-linecap="round"/>
                  <line x1="20" y1="35" x2="6" y2="27" stroke="white" stroke-width="2.2" stroke-linecap="round"/>
                  <line x1="6" y1="27" x2="6" y2="13" stroke="white" stroke-width="2.2" stroke-linecap="round"/>
                  <line x1="6" y1="13" x2="20" y2="5" stroke="white" stroke-width="2.2" stroke-linecap="round"/>
                  <!-- Inner Triangle Solid Polygon -->
                  <polygon points="20,13 30,26 10,26" fill="white" fill-opacity="0.25" stroke="white" stroke-width="2.2" stroke-linejoin="round"/>
                  <!-- Connectors between Hexagon and Triangle -->
                  <line x1="20" y1="5" x2="20" y2="13" stroke="white" stroke-width="2.2" stroke-linecap="round"/>
                  <line x1="34" y1="13" x2="30" y2="26" stroke="white" stroke-width="2.2" stroke-linecap="round"/>
                  <line x1="6" y1="13" x2="10" y2="26" stroke="white" stroke-width="2.2" stroke-linecap="round"/>
                  <line x1="20" y1="35" x2="30" y2="26" stroke="white" stroke-width="2.2" stroke-linecap="round"/>
                  <line x1="20" y1="35" x2="10" y2="26" stroke="white" stroke-width="2.2" stroke-linecap="round"/>
                  <!-- 6 Vertex Nodes -->
                  <circle cx="20" cy="5" r="3.2" fill="white"/>
                  <circle cx="34" cy="13" r="3.2" fill="white"/>
                  <circle cx="34" cy="27" r="3.2" fill="white"/>
                  <circle cx="20" cy="35" r="3.2" fill="white"/>
                  <circle cx="6" cy="27" r="3.2" fill="white"/>
                  <circle cx="6" cy="13" r="3.2" fill="white"/>
                </svg>''',
              ),
            ),
          ),
          BlocBuilder<ScoreCardCubit, ScoreCardState>(
            bloc: _cubit,
            builder: (context, state) {
              final int? rank = _extractUserRank(state.data);
              return _buildMetricItem(
                label: 'Score Card',
                gradientColors: const [
                  Color(0xFFF7C844),
                  Color(0xFFB57D0A),
                ],
                shadowColor: const Color(0xFFB57D0A),
                onTap: () => _onScoreCardTap(context),
                child: Center(
                  child: _buildRankContent(rank),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String label,
    required List<Color> gradientColors,
    required Color shadowColor,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.25, -0.35),
                radius: 0.95,
                colors: gradientColors,
              ),
              boxShadow: [
                BoxShadow(
                  color: shadowColor.withValues(alpha: 0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppStyles.text12Px.poppins.w500.copyWith(
              color: const Color(0xFF71717A),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
