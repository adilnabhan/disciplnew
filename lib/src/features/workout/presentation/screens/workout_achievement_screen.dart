import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:customer_mobile_app/src/features/workout/domain/repositories/workout_repository.dart';
import 'package:customer_mobile_app/src/features/profile/domain/repositories/customer_details_repository.dart';
import 'package:customer_mobile_app/src/features/profile/domain/models/customer_details_model.dart';

class WorkoutAchievementScreen extends StatefulWidget {
  const WorkoutAchievementScreen({
    required this.sessionData,
    this.fallbackTitle,
    this.trainerName,
    this.gymName,
    this.gymLogo,
    super.key,
  });

  final Map<String, dynamic> sessionData;
  final String? fallbackTitle;
  final String? trainerName;
  final String? gymName;
  final String? gymLogo;

  @override
  State<WorkoutAchievementScreen> createState() =>
      _WorkoutAchievementScreenState();
}

class _WorkoutAchievementScreenState extends State<WorkoutAchievementScreen> {
  int _workoutCount = 1;
  bool _isLoadingCount = true;
  bool _isLoadingDetails = true;
  bool _isCapturing = false;
  Map<String, dynamic>? _fullSessionData;
  CustomerDetailsModel? _customerDetails;
  final GlobalKey _cardKey = GlobalKey();

  Future<File?> _captureCardImage() async {
    try {
      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        print('DEBUG CAPTURE: cardKey context render object is null');
        return null;
      }
      if (boundary.debugNeedsPaint) {
        print('DEBUG CAPTURE: boundary needs paint, waiting 50ms');
        await Future.delayed(const Duration(milliseconds: 50));
      }

      ui.Image image;
      try {
        image = await boundary.toImage(pixelRatio: 2.0);
      } catch (e) {
        print('DEBUG CAPTURE: 2.0x failed ($e), falling back to 1.5x');
        try {
          image = await boundary.toImage(pixelRatio: 1.5);
        } catch (_) {
          image = await boundary.toImage(pixelRatio: 1.0);
        }
      }

      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) return null;

      final Uint8List pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/discipl_workout_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes);
      print(
        'DEBUG CAPTURE: Saved image to ${file.path} (${pngBytes.length} bytes)',
      );
      return file;
    } catch (e, stack) {
      print('DEBUG CAPTURE ERROR: $e\n$stack');
      debugPrint('Error capturing workout summary card: $e');
      return null;
    }
  }

  Future<void> _handleDownload() async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);
    try {
      final file = await _captureCardImage();
      if (file == null) {
        Dialogs.showSnack(msg: 'Failed to generate card image');
        return;
      }
      try {
        bool hasAccess = await Gal.hasAccess();
        if (!hasAccess) {
          hasAccess = await Gal.requestAccess();
        }

        if (!hasAccess && Platform.isAndroid) {
          // Additional fallback check for Android storage / photos permission
          final storageStatus = await Permission.storage.request();
          if (storageStatus.isGranted) {
            hasAccess = true;
          } else {
            final photosStatus = await Permission.photos.request();
            if (photosStatus.isGranted) {
              hasAccess = true;
            }
          }
        }

        if (hasAccess) {
          await Gal.putImage(file.path);
          Dialogs.showSnack(msg: 'Workout card saved to Gallery! 📥');
        } else {
          // If permission returned false, attempt direct save first (supported on Android 10+ MediaStore)
          try {
            await Gal.putImage(file.path);
            Dialogs.showSnack(msg: 'Workout card saved to Gallery! 📥');
          } catch (_) {
            Dialogs.showSnack(msg: 'Opening export options...');
            final RenderBox? box = context.findRenderObject() as RenderBox?;
            final Rect? sharePositionOrigin =
                box != null ? box.localToGlobal(Offset.zero) & box.size : null;
            await Share.shareXFiles(
              [XFile(file.path)],
              text: 'Workout Summary',
              sharePositionOrigin: sharePositionOrigin,
            );
          }
        }
      } catch (ge) {
        print('DEBUG GAL SAVE ERROR: $ge');
        try {
          await Gal.putImage(file.path);
          Dialogs.showSnack(msg: 'Workout card saved to Gallery! 📥');
        } catch (_) {
          final RenderBox? box = context.findRenderObject() as RenderBox?;
          final Rect? sharePositionOrigin =
              box != null ? box.localToGlobal(Offset.zero) & box.size : null;
          await Share.shareXFiles(
            [XFile(file.path)],
            text: 'Workout Summary',
            sharePositionOrigin: sharePositionOrigin,
          );
        }
      }
    } catch (e) {
      print('DEBUG DOWNLOAD ERROR: $e');
      Dialogs.showSnack(msg: 'Download failed: $e');
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  Future<void> _handleShare({String? text}) async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);
    try {
      final file = await _captureCardImage();
      if (file == null) {
        Dialogs.showSnack(msg: 'Failed to generate card image');
        return;
      }
      final RenderBox? box = context.findRenderObject() as RenderBox?;
      final Rect? sharePositionOrigin =
          box != null ? box.localToGlobal(Offset.zero) & box.size : null;
      final result = await Share.shareXFiles(
        [XFile(file.path)],
        text: text ?? 'Check out my workout on Discipl! 💪 #discipl',
        sharePositionOrigin: sharePositionOrigin,
      );
      print('DEBUG SHARE RESULT: ${result.status}');
    } catch (e) {
      print('DEBUG SHARE ERROR: $e');
      Dialogs.showSnack(msg: 'Share failed: $e');
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadWorkoutCount();
    _loadFullSessionDetails();
    _loadCustomerDetails();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadCustomerDetails() async {
    try {
      final user = Feggy.read<AppCubit>()?.state.currentUser;
      final customerId = user?.customer?.id ?? user?.id;
      if (customerId != null) {
        final res = await CustomerDetailsRepository().customerDetails(
          id: customerId,
        );
        res.fold((_) => null, (details) {
          if (mounted) {
            setState(() {
              _customerDetails = details;
            });
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading customer details in achievement screen: $e');
    }
  }

  Future<void> _loadWorkoutCount() async {
    try {
      final now = DateTime.now();
      final res = await WorkoutRepository().getWorkoutCalendarForMonth(
        year: now.year,
        month: now.month,
        forceRefresh: true,
      );
      res.fold((_) => null, (dataMap) {
        final data = dataMap;
        int count = 0;

        // Try to get a direct workout count field if returned
        final directCount =
            data['workout_count'] ??
            data['completed_count'] ??
            data['count'] ??
            data['total_workouts'] ??
            data['total_completed_workouts'];
        if (directCount != null) {
          final parsedCount = int.tryParse(directCount.toString());
          if (parsedCount != null) {
            count = parsedCount;
          }
        }

        if (count == 0) {
          // Try to extract days list
          final List<dynamic> days =
              (data['days'] as List<dynamic>?) ??
              (data['calendar'] as List<dynamic>?) ??
              (data['results'] as List<dynamic>?) ??
              [];
          if (days.isNotEmpty) {
            for (final dayItem in days) {
              if (dayItem is Map) {
                final isCompleted =
                    dayItem['is_completed'] == true ||
                    dayItem['completed'] == true ||
                    dayItem['checked'] == true;
                if (isCompleted) {
                  count++;
                }
              }
            }
          } else {
            // Try checking if it's a map containing date keys
            data.forEach((key, value) {
              if (value is Map) {
                final isCompleted =
                    value['is_completed'] == true ||
                    value['completed'] == true ||
                    value['checked'] == true;
                if (isCompleted) {
                  count++;
                }
              } else if (value is bool) {
                if (value == true) {
                  count++;
                }
              }
            });
          }
        }

        if (count > 0 && mounted) {
          setState(() {
            _workoutCount = count;
          });
        }
      });
    } catch (e) {
      debugPrint('Error fetching workout count: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCount = false;
        });
      }
    }
  }

  Future<void> _loadFullSessionDetails() async {
    try {
      final sessionMap =
          widget.sessionData['session'] is Map
              ? widget.sessionData['session'] as Map
              : null;
      final sessionDetailsMap =
          widget.sessionData['session_details'] is Map
              ? widget.sessionData['session_details'] as Map
              : null;
      final rawId =
          widget.sessionData['id'] ??
          widget.sessionData['session_id'] ??
          sessionMap?['id'] ??
          sessionMap?['session_id'] ??
          sessionDetailsMap?['id'];
      final sessionId = int.tryParse(rawId?.toString() ?? '');
      if (sessionId != null) {
        final res = await WorkoutRepository().getSessionDetails(
          sessionId: sessionId,
        );
        res.fold(
          (_) {
            if (mounted) {
              setState(() {
                _fullSessionData = widget.sessionData;
                _isLoadingDetails = false;
              });
            }
          },
          (data) {
            if (mounted) {
              setState(() {
                _fullSessionData = data;
                _isLoadingDetails = false;
              });
            }
          },
        );
      } else {
        if (mounted) {
          setState(() {
            _fullSessionData = widget.sessionData;
            _isLoadingDetails = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading full session details: $e');
      if (mounted) {
        setState(() {
          _fullSessionData = widget.sessionData;
          _isLoadingDetails = false;
        });
      }
    }
  }

  String _getOrdinal(int number) {
    if (number >= 11 && number <= 13) {
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

  double _calculateVolume(List<dynamic> logs) {
    double total = 0;
    bool hasCompleted = false;
    for (final log in logs) {
      if (log is Map) {
        final setLogs = log['set_logs'] as List? ?? log['sets'] as List? ?? [];
        for (final set in setLogs) {
          if (set is Map) {
            final isCompleted =
                (set['is_completed'] == true) || (set['checked'] == true);
            if (isCompleted) {
              hasCompleted = true;
              final reps = double.tryParse(set['reps']?.toString() ?? '') ?? 0;
              final weight =
                  double.tryParse(
                    set['weight_kg']?.toString() ??
                        set['kg']?.toString() ??
                        set['weight']?.toString() ??
                        '',
                  ) ??
                  0;
              total += reps * weight;
            }
          }
        }
      }
    }
    if (!hasCompleted) {
      for (final log in logs) {
        if (log is Map) {
          final setLogs =
              log['set_logs'] as List? ?? log['sets'] as List? ?? [];
          for (final set in setLogs) {
            if (set is Map) {
              final reps = double.tryParse(set['reps']?.toString() ?? '') ?? 0;
              final weight =
                  double.tryParse(
                    set['weight_kg']?.toString() ??
                        set['kg']?.toString() ??
                        set['weight']?.toString() ??
                        '',
                  ) ??
                  0;
              total += reps * weight;
            }
          }
        }
      }
    }
    return total;
  }

  ({int completed, int total}) _countExercises(List<dynamic> logs) {
    if (logs.isEmpty) return (completed: 0, total: 0);

    int total = logs.length;
    int completed = 0;

    for (final log in logs) {
      if (log is Map) {
        final setLogs = log['set_logs'] as List? ?? log['sets'] as List? ?? [];
        final completedSetsCount =
            setLogs.where((set) {
              if (set is Map) {
                return (set['is_completed'] == true) ||
                    (set['checked'] == true) ||
                    (set['status']?.toString().toLowerCase() == 'completed');
              }
              return false;
            }).length;

        if (completedSetsCount > 0) {
          completed++;
        }
      }
    }

    return (completed: completed, total: total);
  }

  ({int completed, int total}) _countSets(List<dynamic> logs) {
    int total = 0;
    int completed = 0;
    for (final log in logs) {
      if (log is Map) {
        final setLogs = log['set_logs'] as List? ?? log['sets'] as List? ?? [];
        total += setLogs.length;
        for (final set in setLogs) {
          if (set is Map) {
            final isCompleted =
                (set['is_completed'] == true) ||
                (set['checked'] == true) ||
                (set['status']?.toString().toLowerCase() == 'completed');
            if (isCompleted) {
              completed++;
            }
          }
        }
      }
    }
    return (completed: completed, total: total);
  }

  String _getExactDuration(Map<String, dynamic> data) {
    int totalSeconds = 0;

    // 1. Check direct elapsed_seconds or duration_seconds or duration field
    final rawElapsed = data['elapsed_seconds'] ?? data['duration_seconds'];
    if (rawElapsed != null) {
      final parsed = int.tryParse(rawElapsed.toString());
      if (parsed != null && parsed > 0) {
        totalSeconds = parsed;
      }
    }

    if (totalSeconds == 0 && data['duration'] != null) {
      final durVal = data['duration'].toString().trim();
      if (durVal.contains(':')) {
        final parts = durVal.split(':');
        if (parts.length == 3) {
          final h = int.tryParse(parts[0]) ?? 0;
          final m = int.tryParse(parts[1]) ?? 0;
          final s = int.tryParse(parts[2]) ?? 0;
          totalSeconds = (h * 3600) + (m * 60) + s;
        } else if (parts.length == 2) {
          final m = int.tryParse(parts[0]) ?? 0;
          final s = int.tryParse(parts[1]) ?? 0;
          totalSeconds = (m * 60) + s;
        }
      } else {
        final numVal = double.tryParse(durVal) ?? 0;
        if (numVal > 0) {
          if (numVal > 100000) {
            totalSeconds = (numVal / 1000).round();
          } else {
            totalSeconds = numVal.round();
          }
        }
      }
    }

    // 2. Check started_at and completed_at/updated_at timestamps
    final startedAtStr =
        data['started_at']?.toString() ??
        data['created_at']?.toString() ??
        data['start_time']?.toString();
    final completedAtStr =
        data['completed_at']?.toString() ??
        data['updated_at']?.toString() ??
        data['end_time']?.toString();

    if (startedAtStr != null && completedAtStr != null) {
      try {
        final start = DateTime.parse(startedAtStr);
        final end = DateTime.parse(completedAtStr);
        final diffInSecs = end.difference(start).inSeconds;
        if (diffInSecs > 0) {
          totalSeconds = diffInSecs;
        }
      } catch (_) {}
    }

    // 3. Fallback: check nested session / session_details map
    if (totalSeconds == 0 && data['session'] is Map) {
      return _getExactDuration(data['session'] as Map<String, dynamic>);
    }
    if (totalSeconds == 0 && data['session_details'] is Map) {
      return _getExactDuration(data['session_details'] as Map<String, dynamic>);
    }

    if (totalSeconds <= 0) {
      return '1min';
    }

    // 4. Format totalSeconds into exact string
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      if (minutes > 0) {
        return '${hours}h ${minutes}m';
      }
      return '${hours}h';
    } else if (minutes > 0) {
      if (seconds > 0) {
        return '${minutes}min ${seconds}s';
      }
      return '${minutes}min';
    } else {
      return '${seconds}s';
    }
  }

  Widget _buildMetric(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppStyles.text24Px.poppins.w700.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppStyles.text10Px.poppins.w600.copyWith(
            color: const Color(0xFF6E5D5D),
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildShareButton({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
    bool useRawIcon = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (useRawIcon)
            icon
          else
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F3F9),
                shape: BoxShape.circle,
              ),
              child: Center(child: icon),
            ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppStyles.text12Px.poppins.w500.copyWith(
              color: const Color(0xFF6E5D5D),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingDetails) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FA),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final data = _fullSessionData ?? widget.sessionData;
    final title =
        data['title']?.toString() ??
        data['plan_name']?.toString() ??
        widget.fallbackTitle ??
        'Workout';
    final logs =
        data['logs'] as List? ??
        data['exercises'] as List? ??
        data['session_exercises'] as List? ??
        [];
    final durationStr = _getExactDuration(data);
    final volume = _calculateVolume(logs);
    final volumeStr = volume > 0 ? '${volume.toStringAsFixed(0)} kg' : '0 kg';
    final exCounts = _countExercises(logs);
    final setCounts = _countSets(logs);
    final exerciseDisplay =
        exCounts.total > 0 ? '${exCounts.completed}/${exCounts.total}' : '0';
    final setsDisplay =
        setCounts.total > 0 ? '${setCounts.completed}/${setCounts.total}' : '0';

    // 1. Is this a trainer-assigned workout or assigned gym user?
    final bool isTrainerAssigned =
        (widget.trainerName != null && widget.trainerName!.trim().isNotEmpty) ||
        (data['trainer_name'] != null &&
            data['trainer_name'].toString().trim().isNotEmpty) ||
        (data['assigned_by'] != null &&
            data['assigned_by'].toString().trim().isNotEmpty) ||
        (data['is_mentor_workout'] == true) ||
        (data['is_trainer_assigned'] == true) ||
        (data['source']?.toString().toLowerCase() == 'trainer');

    final currentUserCustomer =
        Feggy.read<AppCubit>()?.state.currentUser?.customer;

    // 2. Resolve Assigned Gym Name (MUST NOT use trainer name)
    String? resolvedGymName = widget.gymName;
    if (resolvedGymName == null || resolvedGymName.trim().isEmpty) {
      resolvedGymName =
          data['gym_name']?.toString() ??
          data['fitness_center_name']?.toString() ??
          data['assigned_gym_name']?.toString() ??
          (data['assigned_fitness_center'] is Map
              ? (data['assigned_fitness_center']['name'] ??
                      data['assigned_fitness_center']['center_name'] ??
                      data['assigned_fitness_center']['title'])
                  ?.toString()
              : null) ??
          (data['fitness_center'] is Map
              ? (data['fitness_center']['name'] ??
                      data['fitness_center']['center_name'] ??
                      data['fitness_center']['title'])
                  ?.toString()
              : null) ??
          (data['gym'] is Map ? data['gym']['name']?.toString() : null);
    }
    if (resolvedGymName == null || resolvedGymName.trim().isEmpty) {
      final gymMap =
          _customerDetails?.assignedFitnessCenter ??
          currentUserCustomer?.assignedFitnessCenter;
      resolvedGymName =
          gymMap?['name']?.toString() ??
          gymMap?['center_name']?.toString() ??
          gymMap?['fitness_center_name']?.toString() ??
          gymMap?['title']?.toString();
    }
    final String assignedGymName =
        (resolvedGymName != null && resolvedGymName.trim().isNotEmpty)
            ? resolvedGymName
            : 'Assigned Gym';

    // 3. Resolve Assigned Gym Logo
    String? resolvedGymLogo = widget.gymLogo;
    if (resolvedGymLogo == null || resolvedGymLogo.trim().isEmpty) {
      resolvedGymLogo =
          data['gym_logo']?.toString() ??
          data['fitness_center_logo']?.toString() ??
          data['assigned_gym_logo']?.toString() ??
          (data['assigned_fitness_center'] is Map
              ? (data['assigned_fitness_center']['logo'] ??
                      data['assigned_fitness_center']['image'] ??
                      data['assigned_fitness_center']['profile_image'] ??
                      data['assigned_fitness_center']['photo'])
                  ?.toString()
              : null) ??
          (data['fitness_center'] is Map
              ? (data['fitness_center']['logo'] ??
                      data['fitness_center']['image'] ??
                      data['fitness_center']['profile_image'] ??
                      data['fitness_center']['photo'])
                  ?.toString()
              : null) ??
          (data['gym'] is Map
              ? (data['gym']['logo'] ?? data['gym']['image'])?.toString()
              : null);
    }
    if (resolvedGymLogo == null || resolvedGymLogo.trim().isEmpty) {
      final gymMap =
          _customerDetails?.assignedFitnessCenter ??
          currentUserCustomer?.assignedFitnessCenter;
      resolvedGymLogo =
          gymMap?['logo']?.toString() ??
          gymMap?['image']?.toString() ??
          gymMap?['photo']?.toString() ??
          gymMap?['profile_image']?.toString() ??
          gymMap?['logo_url']?.toString();
    }
    final String? assignedGymLogo = resolvedGymLogo;

    // 4. Resolve Trainer Name & Photo
    String? resolvedTrainerName = widget.trainerName;
    if (resolvedTrainerName == null || resolvedTrainerName.trim().isEmpty) {
      resolvedTrainerName =
          data['trainer_name']?.toString() ??
          data['assigned_by']?.toString() ??
          (data['assigned_trainer'] is Map
              ? (data['assigned_trainer']['full_name'] ??
                      data['assigned_trainer']['name'] ??
                      '${data['assigned_trainer']['first_name'] ?? ''} ${data['assigned_trainer']['last_name'] ?? ''}')
                  .toString()
              : null);
    }
    if (resolvedTrainerName == null || resolvedTrainerName.trim().isEmpty) {
      final t = _customerDetails?.assignedTrainer;
      if (t != null) {
        final fn = t['full_name']?.toString() ?? t['name']?.toString();
        if (fn != null && fn.trim().isNotEmpty) {
          resolvedTrainerName = fn;
        } else {
          final first = t['first_name']?.toString() ?? '';
          final last = t['last_name']?.toString() ?? '';
          final combined = '$first $last'.trim();
          if (combined.isNotEmpty) resolvedTrainerName = combined;
        }
      }
    }
    final String? assignedTrainerName =
        (resolvedTrainerName != null && resolvedTrainerName.trim().isNotEmpty)
            ? resolvedTrainerName
            : null;

    String? resolvedTrainerPhoto =
        (data['assigned_trainer'] is Map
            ? (data['assigned_trainer']['profile_image'] ??
                    data['assigned_trainer']['photo'] ??
                    data['assigned_trainer']['image'])
                ?.toString()
            : null) ??
        _customerDetails?.assignedTrainer?['profile_image']?.toString() ??
        _customerDetails?.assignedTrainer?['photo']?.toString() ??
        _customerDetails?.assignedTrainer?['image']?.toString();
    final String? assignedTrainerPhoto = resolvedTrainerPhoto;

    final user = Feggy.read<AppCubit>()?.state.currentUser;
    final fName = user?.firstName ?? '';
    final lName = user?.lastName ?? '';
    String username = '@user';
    if (fName.isNotEmpty || lName.isNotEmpty) {
      username = '@${(fName + lName).toLowerCase().replaceAll(' ', '')}';
    } else if (user?.email != null && user!.email!.contains('@')) {
      username = '@${user.email!.split('@').first.toLowerCase()}';
    }

    Widget buildAchievementCard() {
      return Column(
        children: [
          // Assigned Gym Card (Shown ONLY for trainer assigned workouts)
          if (isTrainerAssigned) ...[
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                children: [
                  // Fitness Center Row
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E293B),
                          shape: BoxShape.circle,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child:
                            (assignedGymLogo != null &&
                                    assignedGymLogo.isNotEmpty)
                                ? Image.network(
                                  assignedGymLogo,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) => const Center(
                                        child: Icon(
                                          Icons.fitness_center_rounded,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                )
                                : const Center(
                                  child: Icon(
                                    Icons.fitness_center_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ASSIGNED GYM',
                              style: AppStyles.text10Px.poppins.w600.copyWith(
                                color: const Color(0xFF94A3B8),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    assignedGymName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppStyles.text16Px.poppins.w700
                                        .copyWith(
                                          color: const Color(0xFF0F172A),
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFFEF4444),
                                  size: 16,
                                ),
                              ],
                            ),
                            if (assignedTrainerName == null ||
                                assignedTrainerName.isEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Stay strong, keep going!',
                                style: AppStyles.text12Px.poppins.w400.copyWith(
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Personal Trainer Row (If assigned trainer exists)
                  if (assignedTrainerName != null &&
                      assignedTrainerName.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(
                        height: 1,
                        thickness: 0.5,
                        color: Color(0xFFE2E8F0),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child:
                              (assignedTrainerPhoto != null &&
                                      assignedTrainerPhoto.isNotEmpty)
                                  ? Image.network(
                                    assignedTrainerPhoto,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => const Center(
                                          child: Icon(
                                            Icons.person_rounded,
                                            color: Color(0xFF64748B),
                                            size: 22,
                                          ),
                                        ),
                                  )
                                  : const Center(
                                    child: Icon(
                                      Icons.person_rounded,
                                      color: Color(0xFF64748B),
                                      size: 22,
                                    ),
                                  ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'PERSONAL TRAINER',
                                style: AppStyles.text10Px.poppins.w600.copyWith(
                                  color: const Color(0xFF94A3B8),
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                assignedTrainerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppStyles.text15Px.poppins.w700.copyWith(
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Achievement Card (Shareable Workout Summary Card)
          RepaintBoundary(
            key: _cardKey,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xffF0B5B7), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card Title
                  Text(
                    title,
                    style: AppStyles.text20Px.poppins.w700.copyWith(
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Metrics Grid (2x2 Column/Row structure)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMetric(durationStr, 'DURATION'),
                            const SizedBox(height: 14),
                            _buildMetric(exerciseDisplay, 'EXERCISES'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMetric(volumeStr, 'VOLUME'),
                            const SizedBox(height: 14),
                            _buildMetric(setsDisplay, 'SETS'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Divider
                  const Divider(
                    color: Color(0xFFF1D1D2),
                    height: 24,
                    thickness: 1,
                  ),

                  // Bottom Row: Logo & Username
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'assets/images/png/vectors/discipl_spell.png',
                        height: 20,
                      ),
                      Text(
                        username,
                        style: AppStyles.text14Px.poppins.w500.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 10.0,
                    ),
                    children: [
                      // Top Back button
                      Align(
                        alignment: Alignment.topLeft,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context, true),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Color(0xFFEEEEEE),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chevron_left,
                              color: Color(0xFF444444),
                              size: 24,
                            ),
                          ),
                        ),
                      ),

                      // Mascot / Non-seasonal Graphic
                      Center(
                        child: Lottie.asset(
                          'assets/images/svg/vectors/thumbsUp_achievement.json',
                          height: 160,
                          fit: BoxFit.contain,
                          repeat: false,
                        ),
                      ),

                      // Headers
                      Center(
                        child: Text(
                          'Good Job!',
                          style: AppStyles.text24Px.poppins.w700.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Center(
                        child: Text(
                          'Workout Completed',
                          style: AppStyles.text16Px.poppins.w500.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 1,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.star,
                            color: AppColors.primary,
                            size: 10,
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.star,
                            color: AppColors.primary,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.star,
                            color: AppColors.primary,
                            size: 10,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 40,
                            height: 1,
                            color: Colors.grey.shade300,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Workout Summary Card
                      buildAchievementCard(),

                      const SizedBox(height: 24),
                    ],
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Lottie.asset(
                        'assets/images/svg/vectors/celebrations.json',
                        fit: BoxFit.cover,
                        repeat: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Share Section
            buildShareSection(),
            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: 24,
                top: 16,
              ),
              child: Button.filled(
                title: 'Done',
                ontap: () => Navigator.pop(context, true),
                buttonColor: AppColors.primary,
                style: AppStyles.text16Px.poppins.w600.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildShareSection() {
    return Column(
      children: [
        Center(
          child: Text(
            'Share workout – Tag @discipl',
            style: AppStyles.text14Px.poppins.w600.copyWith(
              color: const Color(0xFF6E5D5D),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Share Options Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 📥 Download (Gallery)
            _buildShareButton(
              icon: Icon(
                Icons.file_download_outlined,
                color: Colors.grey.shade700,
                size: 24,
              ),
              label: 'Download',
              onTap: _handleDownload,
            ),

            // 📸 Stories (Instagram)
            _buildShareButton(
              useRawIcon: true,
              icon: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF833AB4),
                      Color(0xFFFD1D1D),
                      Color(0xFFF56040),
                      Color(0xFFFCAF45),
                    ],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              label: 'Stories',
              onTap:
                  () => _handleShare(
                    text:
                        'Check out my workout on Discipl! 💪 #discipl #workout',
                  ),
            ),
            // 💬 WhatsApp
            _buildShareButton(
              useRawIcon: true,
              icon: SizedBox(
                width: 50,
                height: 50,
                child: SvgPicture.asset(
                  'assets/images/svg/icons/whatsapp_logo.svg',
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                ),
              ),
              label: 'WhatsApp',
              onTap:
                  () => _handleShare(
                    text: 'Check out my workout summary on Discipl! 💪',
                  ),
            ),

            // 📤 More (Native Share Sheet)
            _buildShareButton(
              icon: Icon(
                Icons.ios_share,
                color: Colors.grey.shade700,
                size: 22,
              ),
              label: 'More',
              onTap: () => _handleShare(),
            ),
          ],
        ),
      ],
    );
  }
}
