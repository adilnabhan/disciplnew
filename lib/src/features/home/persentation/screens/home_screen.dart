import 'package:customer_mobile_app/src/features/home/services/health_sync_service.dart';
import 'package:customer_mobile_app/src/features/marathon/presentation/screens/marathon_ticket_scanner_screen.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/core/network/dio_client.dart';
import 'package:customer_mobile_app/src/features/home/cubit/home_cubit.dart';
import 'package:customer_mobile_app/src/features/home/domain/models/home_model.dart';
import 'package:customer_mobile_app/src/features/home/persentation/screens/partner_qr_pass_screen.dart';
import 'package:customer_mobile_app/src/features/marathon/presentation/screens/marathon_registration_screen.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/screens/presets_screen.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/cyber_workout_theme.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/muscle_anatomy_visualizer.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/equipment_anatomy_guide_modal.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/screens/exercise_library_screen.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/screens/workout_execution_screen.dart';
import 'package:customer_mobile_app/src/features/workout/domain/models/workout_model.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.activeMembership});

  final ActiveMembershipModel? activeMembership;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final DashboardCubit _dashboardCubit;
  late final HomeCubit _homeCubit;
  StreamSubscription<StepCount>? _stepSubscription;
  StreamSubscription<HealthActivityData>? _healthSubscription;
  HealthActivityData _healthData = HealthActivityData.initial();
  int _realSteps = 0;
  int _initialSteps = -1;
  bool _isConnectingHealth = false;

  // Real Leaderboard data fetched from API
  List<Map<String, dynamic>> _leaderboardMembers = [];
  bool _isLoadingLeaderboard = true;

  // Selected Difficulty Level / Routine Tier
  int _selectedTierIndex = 1; // 0: Beginner, 1: Intermediate, 2: High/Advanced, 3: Master/Pro

  final List<Map<String, dynamic>> _tierRoutines = [
    {
      'tier': 'BEGINNER',
      'split': 'DAY 1 • 3-DAY SPLIT',
      'title': 'Foundation & Movement Primer',
      'subtitle': 'Full Body mechanics, core bracing & posture mastery.',
      'tagColor': const Color(0xFF00E676),
      'exercisesCount': 4,
      'duration': '35 Mins',
      'calories': '280 kcal',
      'primaryMuscles': [MuscleGroupTarget.chest, MuscleGroupTarget.quadriceps, MuscleGroupTarget.abs],
      'secondaryMuscles': [MuscleGroupTarget.shoulders, MuscleGroupTarget.upperBack],
      'workoutModel': const WorkoutModel(
        day: 1,
        title: 'Foundation & Movement Primer',
        exerciseCount: 4,
        isCompleted: false,
        isActive: true,
      ),
      'exercises': [
        {
          'id': 1001,
          'title': 'Goblet Squat (Dumbbell)',
          'subtitle': 'Quadriceps / Dumbbells / strength',
          'sets': [
            {'setNum': 1, 'previous': 'no data', 'kg': '10', 'reps': '12', 'checked': false},
            {'setNum': 2, 'previous': '10 kg x 12', 'kg': '12', 'reps': '12', 'checked': false},
            {'setNum': 3, 'previous': '12 kg x 12', 'kg': '14', 'reps': '10', 'checked': false},
          ],
          'video_url': 'https://www.youtube.com/results?search_query=Goblet+Squat+Shorts',
        },
        {
          'id': 1002,
          'title': 'Push-Ups (Form Control)',
          'subtitle': 'Chest / Bodyweight / strength',
          'sets': [
            {'setNum': 1, 'previous': 'no data', 'kg': '0', 'reps': '10', 'checked': false},
            {'setNum': 2, 'previous': 'Bodyweight x 10', 'kg': '0', 'reps': '10', 'checked': false},
            {'setNum': 3, 'previous': 'Bodyweight x 10', 'kg': '0', 'reps': '10', 'checked': false},
          ],
          'video_url': 'https://www.youtube.com/results?search_query=Push+Ups+Shorts',
        },
        {
          'id': 1003,
          'title': 'Lat Pulldown (Wide Grip)',
          'subtitle': 'Lats / Cable / strength',
          'sets': [
            {'setNum': 1, 'previous': 'no data', 'kg': '35', 'reps': '12', 'checked': false},
            {'setNum': 2, 'previous': '35 kg x 12', 'kg': '40', 'reps': '10', 'checked': false},
          ],
          'video_url': 'https://www.youtube.com/results?search_query=Lat+Pulldown+Shorts',
        },
        {
          'id': 1004,
          'title': 'Plank Hold (Core Stability)',
          'subtitle': 'Abs / Bodyweight / duration',
          'sets': [
            {'setNum': 1, 'previous': 'no data', 'kg': '0', 'reps': '45', 'checked': false},
            {'setNum': 2, 'previous': '45s', 'kg': '0', 'reps': '45', 'checked': false},
          ],
          'video_url': 'https://www.youtube.com/results?search_query=Plank+Shorts',
        },
      ],
    },
    {
      'tier': 'INTERMEDIATE',
      'split': 'DAY 1 • 4-DAY SPLIT',
      'title': 'Upper Body Hypertrophy',
      'subtitle': 'Chest, Front Deltoids & Triceps focus with high intensity supersets.',
      'tagColor': CyberWorkoutTheme.goldPrimary,
      'exercisesCount': 5,
      'duration': '45 Mins',
      'calories': '380 kcal',
      'primaryMuscles': [MuscleGroupTarget.chest, MuscleGroupTarget.shoulders, MuscleGroupTarget.triceps],
      'secondaryMuscles': [MuscleGroupTarget.abs],
      'workoutModel': const WorkoutModel(
        day: 1,
        title: 'Upper Body Hypertrophy',
        exerciseCount: 5,
        isCompleted: false,
        isActive: true,
      ),
      'exercises': [
        {
          'id': 101,
          'title': 'Arnold Press',
          'subtitle': 'Front Deltoid / Dumbbells / strength',
          'sets': [
            {'setNum': 1, 'previous': 'no data', 'kg': '10', 'reps': '15', 'checked': false},
            {'setNum': 2, 'previous': '10 kg x 15', 'kg': '12', 'reps': '12', 'checked': false},
            {'setNum': 3, 'previous': '12 kg x 12', 'kg': '14', 'reps': '10', 'checked': false},
          ],
          'video_url': 'https://www.youtube.com/results?search_query=Arnold+Press+Shorts',
        },
        {
          'id': 102,
          'title': 'Incline Barbell Bench Press',
          'subtitle': 'Upper Chest / Barbell / strength',
          'sets': [
            {'setNum': 1, 'previous': 'no data', 'kg': '40', 'reps': '10', 'checked': false},
            {'setNum': 2, 'previous': '40 kg x 10', 'kg': '45', 'reps': '8', 'checked': false},
            {'setNum': 3, 'previous': '45 kg x 8', 'kg': '50', 'reps': '6', 'checked': false},
          ],
          'video_url': 'https://www.youtube.com/results?search_query=Incline+Bench+Press+Shorts',
        },
        {
          'id': 103,
          'title': 'Standing Dumbbell Lateral Raise',
          'subtitle': 'Lateral Deltoid / Dumbbells / isolation',
          'sets': [
            {'setNum': 1, 'previous': 'no data', 'kg': '8', 'reps': '15', 'checked': false},
            {'setNum': 2, 'previous': '8 kg x 15', 'kg': '10', 'reps': '12', 'checked': false},
          ],
          'video_url': 'https://www.youtube.com/results?search_query=Lateral+Raises+Shorts',
        },
        {
          'id': 104,
          'title': 'Cable Tricep Rope Pushdown',
          'subtitle': 'Triceps / Cable / isolation',
          'sets': [
            {'setNum': 1, 'previous': 'no data', 'kg': '20', 'reps': '12', 'checked': false},
            {'setNum': 2, 'previous': '20 kg x 12', 'kg': '25', 'reps': '10', 'checked': false},
          ],
          'video_url': 'https://www.youtube.com/results?search_query=Tricep+Rope+Pushdown+Shorts',
        },
        {
          'id': 105,
          'title': 'Kneeling Cable Crunch',
          'subtitle': 'Abs / Cable / strength',
          'sets': [
            {'setNum': 1, 'previous': 'no data', 'kg': '30', 'reps': '15', 'checked': false},
            {'setNum': 2, 'previous': '30 kg x 15', 'kg': '35', 'reps': '12', 'checked': false},
          ],
          'video_url': 'https://www.youtube.com/results?search_query=Cable+Crunch+Shorts',
        },
      ],
    },
    {
      'tier': 'HIGH / ADVANCED',
      'split': 'DAY 1 • 5-DAY PPL',
      'title': 'Push Heavy Power & Density',
      'subtitle': 'Max mechanical tension, explosive barbell press & drop sets.',
      'tagColor': CyberWorkoutTheme.crimsonRed,
      'exercisesCount': 6,
      'duration': '60 Mins',
      'calories': '520 kcal',
      'primaryMuscles': [MuscleGroupTarget.chest, MuscleGroupTarget.triceps, MuscleGroupTarget.shoulders],
      'secondaryMuscles': [MuscleGroupTarget.upperBack, MuscleGroupTarget.abs],
      'workoutModel': const WorkoutModel(
        day: 1,
        title: 'Push Heavy Power & Density',
        exerciseCount: 6,
        isCompleted: false,
        isActive: true,
      ),
      'exercises': [
        {
          'id': 2001,
          'title': 'Flat Barbell Bench Press',
          'subtitle': 'Chest / Barbell / strength',
          'sets': [
            {'setNum': 1, 'previous': 'no data', 'kg': '60', 'reps': '8', 'checked': false},
            {'setNum': 2, 'previous': '60 kg x 8', 'kg': '70', 'reps': '6', 'checked': false},
            {'setNum': 3, 'previous': '70 kg x 6', 'kg': '80', 'reps': '4', 'checked': false},
            {'setNum': 4, 'previous': '80 kg x 4', 'kg': '85', 'reps': '3', 'checked': false},
          ],
          'video_url': 'https://www.youtube.com/results?search_query=Bench+Press+Form+Shorts',
        },
        {
          'id': 2002,
          'title': 'Overhead Barbell Military Press',
          'subtitle': 'Shoulders / Barbell / strength',
          'sets': [
            {'setNum': 1, 'previous': 'no data', 'kg': '40', 'reps': '8', 'checked': false},
            {'setNum': 2, 'previous': '40 kg x 8', 'kg': '45', 'reps': '6', 'checked': false},
            {'setNum': 3, 'previous': '45 kg x 6', 'kg': '50', 'reps': '5', 'checked': false},
          ],
          'video_url': 'https://www.youtube.com/results?search_query=Overhead+Press+Shorts',
        },
        {
          'id': 2003,
          'title': 'Weighted Chest Dips',
          'subtitle': 'Chest & Triceps / Bodyweight+ / compound',
          'sets': [
            {'setNum': 1, 'previous': 'no data', 'kg': '10', 'reps': '10', 'checked': false},
            {'setNum': 2, 'previous': '10 kg x 10', 'kg': '15', 'reps': '8', 'checked': false},
          ],
          'video_url': 'https://www.youtube.com/results?search_query=Weighted+Dips+Shorts',
        },
        {
          'id': 2004,
          'title': 'EZ Bar Skull Crushers',
          'subtitle': 'Triceps / Barbell / isolation',
          'sets': [
            {'setNum': 1, 'previous': 'no data', 'kg': '25', 'reps': '10', 'checked': false},
            {'setNum': 2, 'previous': '25 kg x 10', 'kg': '30', 'reps': '8', 'checked': false},
          ],
          'video_url': 'https://www.youtube.com/results?search_query=Skull+Crushers+Shorts',
        },
        {
          'id': 2005,
          'title': 'Cable Flyes (Middle Peak Squeeze)',
          'subtitle': 'Chest / Cable / isolation',
          'sets': [
            {'setNum': 1, 'previous': 'no data', 'kg': '15', 'reps': '15', 'checked': false},
            {'setNum': 2, 'previous': '15 kg x 15', 'kg': '17.5', 'reps': '12', 'checked': false},
          ],
          'video_url': 'https://www.youtube.com/results?search_query=Cable+Fly+Shorts',
        },
        {
          'id': 2006,
          'title': 'Hanging Leg Raises',
          'subtitle': 'Core & Abs / Bodyweight / strength',
          'sets': [
            {'setNum': 1, 'previous': 'no data', 'kg': '0', 'reps': '15', 'checked': false},
            {'setNum': 2, 'previous': 'Bodyweight x 15', 'kg': '0', 'reps': '12', 'checked': false},
          ],
          'video_url': 'https://www.youtube.com/results?search_query=Hanging+Leg+Raise+Shorts',
        },
      ],
    },
    {
      'tier': 'MASTER / PRO',
      'split': 'DAY 1 • 6-DAY CYBER ELITE',
      'title': 'Kinetic Performance & Mass Overload',
      'subtitle': 'Olympic compound lifting, cluster sets, and peak athletic power.',
      'tagColor': const Color(0xFFD500F9),
      'exercisesCount': 7,
      'duration': '75 Mins',
      'calories': '680 kcal',
      'primaryMuscles': [MuscleGroupTarget.fullBody, MuscleGroupTarget.quadriceps, MuscleGroupTarget.upperBack],
      'secondaryMuscles': [MuscleGroupTarget.chest, MuscleGroupTarget.shoulders, MuscleGroupTarget.calves],
      'workoutModel': const WorkoutModel(
        day: 1,
        title: 'Kinetic Performance & Mass Overload',
        exerciseCount: 7,
        isCompleted: false,
        isActive: true,
      ),
      'exercises': [
        {
          'id': 3001,
          'title': 'Barbell Conventional Deadlift',
          'subtitle': 'Back & Hamstrings / Barbell / power',
          'sets': [
            {'setNum': 1, 'previous': 'no data', 'kg': '100', 'reps': '5', 'checked': false},
            {'setNum': 2, 'previous': '100 kg x 5', 'kg': '120', 'reps': '5', 'checked': false},
            {'setNum': 3, 'previous': '120 kg x 5', 'kg': '140', 'reps': '3', 'checked': false},
            {'setNum': 4, 'previous': '140 kg x 3', 'kg': '150', 'reps': '2', 'checked': false},
          ],
          'video_url': 'https://www.youtube.com/results?search_query=Deadlift+Form+Shorts',
        },
        {
          'id': 3002,
          'title': 'Barbell Back Squat (Deep ATG)',
          'subtitle': 'Quads & Glutes / Barbell / compound',
          'sets': [
            {'setNum': 1, 'previous': 'no data', 'kg': '80', 'reps': '6', 'checked': false},
            {'setNum': 2, 'previous': '80 kg x 6', 'kg': '100', 'reps': '5', 'checked': false},
            {'setNum': 3, 'previous': '100 kg x 5', 'kg': '110', 'reps': '4', 'checked': false},
          ],
          'video_url': 'https://www.youtube.com/results?search_query=Squat+Form+Shorts',
        },
        {
          'id': 3003,
          'title': 'Pendlay Barbell Row',
          'subtitle': 'Upper Back & Lats / Barbell / power',
          'sets': [
            {'setNum': 1, 'previous': 'no data', 'kg': '60', 'reps': '8', 'checked': false},
            {'setNum': 2, 'previous': '60 kg x 8', 'kg': '70', 'reps': '6', 'checked': false},
          ],
          'video_url': 'https://www.youtube.com/results?search_query=Pendlay+Row+Shorts',
        },
        {
          'id': 3004,
          'title': 'Bulgarian Split Squats (Dumbbells)',
          'subtitle': 'Quads & Glutes / Dumbbells / unilateral',
          'sets': [
            {'setNum': 1, 'previous': 'no data', 'kg': '20', 'reps': '10', 'checked': false},
            {'setNum': 2, 'previous': '20 kg x 10', 'kg': '24', 'reps': '8', 'checked': false},
          ],
          'video_url': 'https://www.youtube.com/results?search_query=Bulgarian+Split+Squat+Shorts',
        },
        {
          'id': 3005,
          'title': 'Incline Dumbbell Hex Press',
          'subtitle': 'Chest / Dumbbells / isolation',
          'sets': [
            {'setNum': 1, 'previous': 'no data', 'kg': '22', 'reps': '12', 'checked': false},
            {'setNum': 2, 'previous': '22 kg x 12', 'kg': '26', 'reps': '10', 'checked': false},
          ],
          'video_url': 'https://www.youtube.com/results?search_query=Hex+Press+Shorts',
        },
        {
          'id': 3006,
          'title': 'Barbell 21s Bicep Curl',
          'subtitle': 'Biceps / Barbell / pump',
          'sets': [
            {'setNum': 1, 'previous': 'no data', 'kg': '20', 'reps': '21', 'checked': false},
            {'setNum': 2, 'previous': '20 kg x 21', 'kg': '25', 'reps': '21', 'checked': false},
          ],
          'video_url': 'https://www.youtube.com/results?search_query=21s+Bicep+Curl+Shorts',
        },
        {
          'id': 3007,
          'title': 'Assault Air Bike Tabata Sprint',
          'subtitle': 'Full Body & Conditioning / Machine / cardio',
          'sets': [
            {'setNum': 1, 'previous': 'no data', 'kg': '0', 'reps': '30', 'checked': false},
            {'setNum': 2, 'previous': '30s sprint', 'kg': '0', 'reps': '30', 'checked': false},
            {'setNum': 3, 'previous': '30s sprint', 'kg': '0', 'reps': '30', 'checked': false},
          ],
          'video_url': 'https://www.youtube.com/results?search_query=Assault+Bike+Tabata+Shorts',
        },
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _dashboardCubit = DashboardCubit();
    _homeCubit = HomeCubit();
    _initHealthSync();
    final bool isGuest = Feggy.read<AppCubit>()?.state.currentUser == null;
    if (!isGuest) {
      _fetchActiveMembership();
      _homeCubit.fetchHomeData();
      _fetchScoreboard();
    }
  }

  Future<void> _fetchScoreboard() async {
    try {
      final res = await DioClient().dio.get(ApiUris.scoreboard);
      if (res.statusCode == 200 && res.data != null) {
        final List list = res.data['results'] ?? res.data['leaderboard'] ?? res.data['data'] ?? [];
        if (list.isNotEmpty) {
          setState(() {
            _leaderboardMembers = list.take(4).map<Map<String, dynamic>>((item) {
              return {
                'rank': item['rank'] ?? 1,
                'name': item['customer_name'] ?? item['name'] ?? 'Member',
                'pts': (item['points'] ?? item['pts'] ?? 0).round(),
              };
            }).toList();
            _isLoadingLeaderboard = false;
          });
        }
      }
    } catch (_) {}
  }

  void _initHealthSync() {
    final healthService = HealthSyncService();
    healthService.initialize();
    _healthSubscription = healthService.activityStream.listen((data) {
      if (mounted) {
        setState(() {
          _healthData = data;
          if (data.steps > 0) {
            _realSteps = data.steps;
          }
        });
      }
    });
  }

  Future<void> _handleConnectHealth() async {
    setState(() => _isConnectingHealth = true);
    final granted = await HealthSyncService().connectGoogleFitOrHealthConnect();
    if (mounted) {
      setState(() => _isConnectingHealth = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            granted
                ? '✅ Google Fit / Health Connect connected successfully!'
                : 'Granted permissions or using live hardware step sensor.',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          backgroundColor: granted ? const Color(0xFF00E676) : const Color(0xFF3395FF),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _initPedometer() async {
    try {
      if (await Permission.activityRecognition.request().isGranted) {
        _stepSubscription = Pedometer.stepCountStream.listen(
          (StepCount event) {
            if (_initialSteps == -1) {
              _initialSteps = event.steps;
            }
            if (mounted) {
              setState(() {
                _realSteps = (event.steps - _initialSteps).clamp(0, 99999);
              });
            }
          },
          onError: (error) {
            debugPrint("Pedometer error: $error");
          },
        );
      }
    } catch (e) {
      debugPrint("Pedometer init error: $e");
    }
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    _healthSubscription?.cancel();
    _homeCubit.close();
    super.dispose();
  }

  Future<void> _fetchActiveMembership() async {
    _dashboardCubit.fetchActiveMembership();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberWorkoutTheme.bgVoid,
      body: SafeArea(
        child: RefreshIndicator(
          color: CyberWorkoutTheme.goldPrimary,
          backgroundColor: CyberWorkoutTheme.bgCardGlass,
          onRefresh: () async {
            _homeCubit.fetchHomeData();
            _fetchActiveMembership();
            _fetchScoreboard();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top App Header
                _buildTopCyberHeader(),
                const SizedBox(height: 16),

                // Major Event / Marathon 2026 Registration Banner Card (Top Hero Placement)
                _buildMarathonBannerCard(),
                const SizedBox(height: 16),

                // Interactive Workout Level / Routine Tier Selector (Beginner, Intermediate, High, Master)
                _buildDifficultyTierSelector(),
                const SizedBox(height: 14),

                // Hero Today's Workout Routine Card (Hale Cyber Style)
                _buildHeroRoutineCard(),
                const SizedBox(height: 20),

                // 3D Equipment & Kinetic Guide Showcase Card
                _build3DTechniqueShowcaseCard(),
                const SizedBox(height: 20),

                // Interactive 6-Action Quick Access Hub
                _buildQuickActionsGrid(),
                const SizedBox(height: 20),

                // Live Health Gauge & Steps Counter
                _buildHealthActivityWidget(),
                const SizedBox(height: 20),

                // Cyber Scoreboard / Leaderboard
                _buildLeaderboardScoreCard(),
                const SizedBox(height: 20),

                // VIP Partner QR Pass Banner
                _buildPartnerPassBanner(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopCyberHeader() {
    final user = Feggy.read<AppCubit>()?.state.currentUser;
    final userName = user != null ? (user.firstName ?? 'Athlete') : 'Athlete';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [CyberWorkoutTheme.crimsonRed, CyberWorkoutTheme.goldPrimary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: CyberWorkoutTheme.goldPrimary.withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'D',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WELCOME BACK',
                  style: TextStyle(
                    color: CyberWorkoutTheme.goldPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Quick VIP QR Pass Badge
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PartnerQrPassScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E0F14), Color(0xFF1E1428)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: CyberWorkoutTheme.crimsonRed.withOpacity(0.8)),
              boxShadow: [
                BoxShadow(
                  color: CyberWorkoutTheme.crimsonRed.withOpacity(0.2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.qr_code_scanner, color: CyberWorkoutTheme.goldPrimary, size: 16),
                SizedBox(width: 6),
                Text(
                  'QR PASS',
                  style: TextStyle(
                    color: CyberWorkoutTheme.goldPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyTierSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "WORKOUT LEVEL",
              style: TextStyle(
                color: CyberWorkoutTheme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: CyberWorkoutTheme.bgCardGlass,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: CyberWorkoutTheme.borderSubtle),
              ),
              child: Text(
                _tierRoutines[_selectedTierIndex]['tier'] as String,
                style: TextStyle(
                  color: _tierRoutines[_selectedTierIndex]['tagColor'] as Color,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _tierRoutines.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final item = _tierRoutines[idx];
              final bool isSelected = _selectedTierIndex == idx;
              final Color color = item['tagColor'] as Color;

              IconData icon;
              if (idx == 0) {
                icon = Icons.shield_outlined;
              } else if (idx == 1) {
                icon = Icons.bolt_outlined;
              } else if (idx == 2) {
                icon = Icons.local_fire_department_rounded;
              } else {
                icon = Icons.military_tech_rounded;
              }

              return GestureDetector(
                onTap: () => setState(() => _selectedTierIndex = idx),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.18) : CyberWorkoutTheme.bgCardGlass,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? color : CyberWorkoutTheme.borderSubtle,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, color: isSelected ? color : CyberWorkoutTheme.textMuted, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        item['tier'] as String,
                        style: TextStyle(
                          color: isSelected ? Colors.white : CyberWorkoutTheme.textSecondary,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeroRoutineCard() {
    final routine = _tierRoutines[_selectedTierIndex];
    final Color tagColor = routine['tagColor'] as Color;
    final List<MuscleGroupTarget> primaryMuscles = routine['primaryMuscles'] as List<MuscleGroupTarget>;
    final List<MuscleGroupTarget> secondaryMuscles = (routine['secondaryMuscles'] ?? <MuscleGroupTarget>[]) as List<MuscleGroupTarget>;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B1424), Color(0xFF12121C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: tagColor.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: tagColor.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: tagColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: tagColor),
                  ),
                  child: Text(
                    routine['tier'] as String,
                    style: TextStyle(
                      color: tagColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 10,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.local_fire_department, color: tagColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      routine['split'] as String,
                      style: TextStyle(
                        color: tagColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        routine['title'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        routine['subtitle'] as String,
                        style: const TextStyle(
                          color: CyberWorkoutTheme.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _buildStatChip(Icons.fitness_center, "${routine['exercisesCount']} Exercises"),
                          _buildStatChip(Icons.timer_outlined, routine['duration'] as String),
                          _buildStatChip(Icons.local_fire_department, routine['calories'] as String),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Glowing Anatomical Muscle Heatmap Thumbnail
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C0C12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: CyberWorkoutTheme.borderSubtle),
                  ),
                  child: MuscleAnatomyVisualizer(
                    primaryMuscles: primaryMuscles,
                    secondaryMuscles: secondaryMuscles,
                    width: 70,
                    height: 90,
                    isAnimated: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Start Workout CTA Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: tagColor,
                  foregroundColor: Colors.black,
                  elevation: 6,
                  shadowColor: tagColor.withOpacity(0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkoutExecutionScreen(
                        workoutModel: routine['workoutModel'] as WorkoutModel,
                        exercises: List<Map<String, dynamic>>.from(routine['exercises']),
                      ),
                    ),
                  );
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded, color: Colors.black, size: 24),
                    SizedBox(width: 6),
                    Text(
                      "START WORKOUT",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF222232),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: CyberWorkoutTheme.goldPrimary, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _build3DTechniqueShowcaseCard() {
    return GestureDetector(
      onTap: () {
        EquipmentAnatomyGuideModal.show(
          context,
          exerciseName: "Arnold Dumbbell Press",
          targetMuscle: "Front Deltoids & Shoulders",
          equipment: "Dumbbells & Incline Bench",
          videoUrl: "https://www.youtube.com/watch?v=3ml7BH7mNwQ",
          instructions: [
            "Sit on bench with dumbbells held at shoulder level, palms facing your chest.",
            "As you press upward, rotate your wrists until palms face forward at the top.",
            "Lower back down in a smooth 3-second eccentric arc, reversing the rotation.",
          ],
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: CyberWorkoutTheme.glassCard(),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFF20162A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: CyberWorkoutTheme.crimsonRed.withOpacity(0.6)),
              ),
              child: const Icon(Icons.fitness_center, color: CyberWorkoutTheme.crimsonRed, size: 28),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "3D EQUIPMENT & FORM GUIDE",
                        style: TextStyle(
                          color: CyberWorkoutTheme.goldPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.touch_app, color: CyberWorkoutTheme.goldPrimary, size: 13),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Learn any exercise instantly",
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 3),
                  Text(
                    "Tap to inspect 3D gear, muscle heatmaps & cadence tempo.",
                    style: TextStyle(color: CyberWorkoutTheme.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    final items = [
      {
        'title': 'Marathon 2026',
        'sub': '18 Oct • ₹50 Entry',
        'icon': Icons.directions_run_rounded,
        'color': const Color(0xFFFF5722),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MarathonRegistrationScreen()),
          );
        },
      },
      {
        'title': 'Venue Scanner',
        'sub': 'Verify Ticket QR',
        'icon': Icons.qr_code_scanner_rounded,
        'color': const Color(0xFF00E676),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MarathonTicketScannerScreen()),
          );
        },
      },
      {
        'title': 'My Presets',
        'sub': 'Saved Routines',
        'icon': Icons.fitness_center_rounded,
        'color': const Color(0xFFE040FB),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PresetsScreen()),
          );
        },
      },
      {
        'title': '230+ Library',
        'sub': 'All DB Workouts',
        'icon': Icons.menu_book_rounded,
        'color': CyberWorkoutTheme.goldPrimary,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExerciseLibraryScreen()),
          );
        },
      },
      {
        'title': 'VIP QR Pass',
        'sub': 'Partner Gyms',
        'icon': Icons.qr_code_2_rounded,
        'color': const Color(0xFF38BDF8),
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PartnerQrPassScreen()),
          );
        },
      },
      {
        'title': 'Nutrition & Fuel',
        'sub': 'Macro Split & XP',
        'icon': Icons.restaurant_menu_rounded,
        'color': const Color(0xFF00E676),
        'onTap': () {
          // Open nutrition
        },
      },
      {
        'title': '6-Day Cycle',
        'sub': 'Custom Schedule',
        'icon': Icons.calendar_month_rounded,
        'color': CyberWorkoutTheme.crimsonRed,
        'onTap': () {
          // Open workout log
        },
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "POWER HUB",
          style: TextStyle(
            color: CyberWorkoutTheme.goldPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.1,
          ),
          itemCount: items.length,
          itemBuilder: (context, i) {
            final item = items[i];
            final Color itemCol = item['color'] as Color;
            return GestureDetector(
              onTap: item['onTap'] as VoidCallback?,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF14141E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: itemCol.withOpacity(0.4), width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: itemCol.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item['icon'] as IconData, color: itemCol, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['sub'] as String,
                            style: const TextStyle(
                              color: CyberWorkoutTheme.textSecondary,
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHealthActivityWidget() {
    final int displaySteps = _healthData.steps > 0 ? _healthData.steps : (_realSteps > 0 ? _realSteps : 0);
    final String distStr = _healthData.distanceKm > 0
        ? _healthData.distanceKm.toStringAsFixed(1)
        : (displaySteps > 0 ? (displaySteps * 0.00075).toStringAsFixed(1) : "0.0");
    final int kcalVal = _healthData.calories > 0
        ? _healthData.calories
        : (displaySteps > 0 ? (displaySteps * 0.045).round() : 0);
    final int heartRateVal = _healthData.heartRate > 0 ? _healthData.heartRate : 74;

    final bool isGoogleFit = _healthData.sourceType == HealthSourceType.googleFitHealthConnect;
    final bool isSensor = _healthData.sourceType == HealthSourceType.pedometerSensor;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF14141E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CyberWorkoutTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.directions_run_rounded, color: CyberWorkoutTheme.goldPrimary, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "TODAY'S ACTIVITY",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              // Interactive Google Fit / Health Connect Status Button
              InkWell(
                onTap: _isConnectingHealth ? null : _handleConnectHealth,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isGoogleFit
                        ? const Color(0xFF4285F4).withOpacity(0.2)
                        : (isSensor
                            ? const Color(0xFF00E676).withOpacity(0.2)
                            : CyberWorkoutTheme.goldPrimary.withOpacity(0.15)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isGoogleFit
                          ? const Color(0xFF4285F4)
                          : (isSensor ? const Color(0xFF00E676) : CyberWorkoutTheme.goldPrimary),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isConnectingHealth) ...[
                        const SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white),
                        ),
                        const SizedBox(width: 5),
                      ] else ...[
                        Icon(
                          isGoogleFit
                              ? Icons.health_and_safety_rounded
                              : (isSensor ? Icons.sensors_rounded : Icons.sync_rounded),
                          color: isGoogleFit
                              ? const Color(0xFF4285F4)
                              : (isSensor ? const Color(0xFF00E676) : CyberWorkoutTheme.goldPrimary),
                          size: 12,
                        ),
                        const SizedBox(width: 5),
                      ],
                      Text(
                        isGoogleFit
                            ? "GOOGLE FIT"
                            : (isSensor ? "LIVE SENSOR" : "CONNECT FIT"),
                        style: TextStyle(
                          color: isGoogleFit
                              ? const Color(0xFF4285F4)
                              : (isSensor ? const Color(0xFF00E676) : CyberWorkoutTheme.goldPrimary),
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              // Circular step ring
              Container(
                width: 85,
                height: 85,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: displaySteps >= 10000
                        ? const Color(0xFF00E676)
                        : (displaySteps > 0 ? CyberWorkoutTheme.goldPrimary : Colors.white24),
                    width: 5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$displaySteps',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                    const Text(
                      '/ 10,000\nSteps',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: CyberWorkoutTheme.textSecondary, fontSize: 8),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow(Icons.local_fire_department_rounded, "Active Burn", "$kcalVal kcal", CyberWorkoutTheme.crimsonRed),
                    const SizedBox(height: 8),
                    _buildStatRow(Icons.straighten_rounded, "Distance", "$distStr km", CyberWorkoutTheme.goldPrimary),
                    const SizedBox(height: 8),
                    _buildStatRow(Icons.favorite_rounded, "Heart Rate", "$heartRateVal BPM", const Color(0xFFFF5252)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Text(
          "$label: ",
          style: const TextStyle(color: CyberWorkoutTheme.textSecondary, fontSize: 11),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _buildLeaderboardScoreCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF14141E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: CyberWorkoutTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.emoji_events_rounded, color: CyberWorkoutTheme.goldPrimary, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "GYM SCOREBOARD",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Text(
                "THIS WEEK",
                style: TextStyle(color: CyberWorkoutTheme.goldPrimary, fontSize: 10, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (_leaderboardMembers.isEmpty) ...[
            _buildLeaderboardRow(1, "Alex Mercer", 2450, CyberWorkoutTheme.goldPrimary),
            _buildLeaderboardRow(2, "Sarah Jenkins", 2180, const Color(0xFFE0E0E0)),
            _buildLeaderboardRow(3, "Rahul Nair", 1950, const Color(0xFFCD7F32)),
          ] else ...[
            for (final m in _leaderboardMembers)
              _buildLeaderboardRow(
                m['rank'] as int? ?? 1,
                m['name'] as String? ?? 'Member',
                m['pts'] as int? ?? 0,
                (m['rank'] == 1)
                    ? CyberWorkoutTheme.goldPrimary
                    : (m['rank'] == 2)
                        ? const Color(0xFFE0E0E0)
                        : const Color(0xFFCD7F32),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow(int rank, String name, int points, Color medalColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: medalColor.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: medalColor),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(color: medalColor, fontSize: 11, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '$points XP',
            style: const TextStyle(color: CyberWorkoutTheme.goldPrimary, fontSize: 12, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildMarathonBannerCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MarathonRegistrationScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE50914), Color(0xFFFF6D00), Color(0xFF1E0A2A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE50914).withOpacity(0.3),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions_run_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'LIVE EVENT',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: CyberWorkoutTheme.goldPrimary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '₹50 / PERSON',
                    style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'DISCIPL ANNUAL\nMARATHON 2026',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Run for Fitness • 5K / 10K / 21K • Calicut Beach',
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.calendar_today_rounded, color: Colors.white, size: 12),
                SizedBox(width: 6),
                Text(
                  '18 Oct 2026 • 05:30 AM',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'REGISTER NOW  →',
                  style: TextStyle(
                    color: Color(0xFFE50914),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnerPassBanner() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PartnerQrPassScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF261018), Color(0xFF14141E)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: CyberWorkoutTheme.crimsonRed.withOpacity(0.6)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: CyberWorkoutTheme.crimsonRed.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.qr_code_2, color: CyberWorkoutTheme.crimsonRed, size: 28),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "VIP PARTNER ACCESS",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Scan your personal QR pass at partner gyms and cafes for instant perks.",
                    style: TextStyle(color: CyberWorkoutTheme.textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
          ],
        ),
      ),
    );
  }
}
