import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/screens/workout_details_screen.dart';

class WorkoutPreviewScreen extends StatefulWidget {
  const WorkoutPreviewScreen({
    required this.sessionId,
    required this.fallbackTitle,
    this.trainerName,
    super.key,
  });

  final int sessionId;
  final String fallbackTitle;
  final String? trainerName;

  @override
  State<WorkoutPreviewScreen> createState() => _WorkoutPreviewScreenState();
}

class _WorkoutPreviewScreenState extends State<WorkoutPreviewScreen> {
  late Future<Either<ApiException, Map<String, dynamic>>> _detailsFuture;
  Map<String, dynamic>? _sessionData;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  void _loadDetails() {
    setState(() {
      _sessionData = null;
      _detailsFuture = WorkoutRepository().getSessionDetails(sessionId: widget.sessionId).then((res) {
        res.fold((_) => null, (data) {
          if (mounted) {
            setState(() {
              _sessionData = data;
            });
          }
        });
        return res;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
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
                  Icons.chevron_left,
                  color: Color(0xFF444444),
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Workout Preview',
          style: AppStyles.text18Px.poppins.w600.copyWith(
            color: const Color(0xFF212121),
          ),
        ),
      ),
      body: FutureBuilder<Either<ApiException, Map<String, dynamic>>>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && _sessionData == null) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }

          if (snapshot.hasError && _sessionData == null) {
            return _buildErrorState('An unexpected error occurred.');
          }

          final result = snapshot.data;
          if (result == null && _sessionData == null) {
            return _buildErrorState('No details found for this session.');
          }

          if (_sessionData != null) {
            return _buildContent(_sessionData!);
          }

          return result!.fold(
            (error) => _buildErrorState('Error loading details: ${error.msg}'),
            (data) {
              _sessionData = data;
              return _buildContent(data);
            },
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.primary,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppStyles.text16Px.poppins.w500.copyWith(
                color: const Color(0xFF444444),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Retry',
                style: AppStyles.text14Px.poppins.w600.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic> data) {
    final title = data['title']?.toString() ?? widget.fallbackTitle;
    final logs = data['logs'] as List? ?? [];
    final trainer = widget.trainerName ?? data['trainer_name']?.toString() ?? 'Trainer';

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Summary card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xffF0B5B7), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppStyles.text18Px.poppins.w600.copyWith(
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline_rounded,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Assigned by: $trainer',
                          style: AppStyles.text14Px.poppins.w500.copyWith(
                            color: const Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.fitness_center_rounded,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Total Exercises: ${logs.length}',
                          style: AppStyles.text14Px.poppins.w600.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Exercises list',
                style: AppStyles.text16Px.poppins.w600.copyWith(
                  color: const Color(0xFF334155),
                ),
              ),
              const SizedBox(height: 12),
              if (logs.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Text(
                      'No exercises in this workout.',
                      style: AppStyles.text14Px.poppins.w400.copyWith(
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                )
              else
                ...List.generate(logs.length, (index) {
                  final log = logs[index] as Map<String, dynamic>;
                  final workoutName = log['workout_name']?.toString() ?? 'Exercise';
                  final muscle = log['muscle']?.toString() ?? '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4F4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              (index + 1).toString().padLeft(2, '0'),
                              style: AppStyles.text12Px.poppins.w600.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                workoutName,
                                style: AppStyles.text14Px.poppins.w600.copyWith(
                                  color: const Color(0xFF222222),
                                ),
                              ),
                              if (muscle.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  muscle,
                                  style: AppStyles.text12Px.poppins.w500.copyWith(
                                    color: const Color(0xFF888888),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
        // Sticky bottom button container
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Button.filled(
              size: const Size(double.infinity, 48),
              title: 'Start Workout',
              style: AppStyles.text16Px.poppins.w600.copyWith(color: Colors.white),
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
              raduis: 12,
              ontap: () async {
                final refresh = await Navigator.pushReplacement<dynamic, dynamic>(
                  context,
                  MaterialPageRoute<dynamic>(
                    builder: (context) => WorkoutDetailsScreen(
                      sessionId: widget.sessionId,
                      fallbackTitle: title,
                      startTimer: true,
                    ),
                  ),
                );
                if (mounted) {
                  Navigator.pop(context, refresh);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
