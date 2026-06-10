import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/screens/workout_plan_details.dart';
import 'package:customer_mobile_app/src/features/workout/domain/models/workout_model.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/completed_badge.dart';
import 'package:customer_mobile_app/core/themes/app_colors.dart';

class Workoutplanscreen extends StatefulWidget {
  const Workoutplanscreen({super.key});

  @override
  State<Workoutplanscreen> createState() => _WorkoutplanscreenState();
}

class _WorkoutplanscreenState extends State<Workoutplanscreen> {
  int selectedDay=3;

  final List<WorkoutModel> workoutDays = [
    const WorkoutModel(day: 1,  title: 'Chest Exercise',     exerciseCount: 4, isCompleted: true, isActive: false),
    const WorkoutModel(day: 2,  title: 'Triceps Exercise',   exerciseCount: 4, isCompleted: true, isActive: false),
    const WorkoutModel(day: 3,  title: 'Back Exercise',      exerciseCount: 4, isCompleted: false, isActive: false),
    const WorkoutModel(day: 10, title: 'Biceps Exercise',    exerciseCount: 4, isCompleted: false,isActive: false),
    const WorkoutModel(day: 30, title: 'Shoulder Exercise',  exerciseCount: 4, isCompleted: false,isActive: false),
  ];

  final TextEditingController searchcontroller = TextEditingController();

  @override
  void dispose() {
    searchcontroller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leadingWidth: Navigator.canPop(context) ? 56 : 0,
        leading: Navigator.canPop(context)
            ? Padding(
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
              )
            : null,
        title: const Text(
          'Workout plans',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            height: 1.0,
            color: Color(0xFF212121),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.push(const SettingsScreen());
            },
            icon: SvgPicture.asset(
              'assets/images/svg/icons/settings _icon.svg',
              width: 20,
              height: 20,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: searchBar(),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: Container(
              color: AppColors.bgcolorgrey,
              child: buildPlanContent(
                context,
                workoutDays,
                selectedDay: selectedDay,
                onDaySelected: (day) {
                  setState(() {
                    selectedDay = day;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget searchBar() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    child: Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD9D9D9),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            bottom: 0,
            child: SvgPicture.asset(
              'assets/images/svg/icons/search_workout_plan.svg',
              width: 38,
              height: 38,
              fit: BoxFit.contain,
            ),
          ),

          const Positioned(
            left: 72,
            right: 16,
            top: 0,
            bottom: 0,
            child: Center(
              child: TextField(
                decoration: InputDecoration(
                  filled: false,
                  fillColor: Colors.transparent,
                  hintText: 'Search for plan',
                  hintStyle: TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildplanheader() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
    color: const Color(0xFFF7F7F7),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Muscle Gain',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.0,
                color: Color(0xFF1C1C1E),
              ),
            ),

              const SizedBox(height: 8),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('30 days',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Color(0xFF888888),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.0,
                    ),
                  ),
                  _SortButton(onTap: (){}),
                ],
              ),
          ],
        ),
  );
}

class _SortButton extends StatelessWidget {

  const _SortButton({required this.onTap});
  final VoidCallback onTap;
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF8BDBE), width: 1.5),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list_rounded, size: 14, color: Color(0xFFE53E3E)),
            SizedBox(width: 5),
            Text(
              'Sort',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE53E3E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildPlanContent(BuildContext context,List<WorkoutModel> workoutDays,{
  required int selectedDay,
  required Function(int) onDaySelected,
  }){
  return ListView(
    padding: const EdgeInsets.only(top: 0,bottom: 24),
    children: [
      buildplanheader(),
      const SizedBox(height: 16,),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            ...workoutDays.map(
        (workoutModel) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: WorkoutDayCard(
            onTap: () {
              onDaySelected(workoutModel.day);
              Navigator.push(
                context, 
                MaterialPageRoute(
                builder: (_)=> WorkoutDetailsScreen(workoutModel: workoutModel)
                )
                );
            },
            workoutModel: workoutModel,
            isSelected: workoutModel.day == selectedDay,
            ),
        )
      )
          ],
        ),
      ),
    ],
  );
}

class WorkoutDayCard extends StatelessWidget {
  final VoidCallback onTap;
  final WorkoutModel workoutModel;
  final bool isSelected;

  const WorkoutDayCard({
    super.key,
    required this.workoutModel,
    required this.isSelected,
    required this.onTap
    });

  @override
  Widget build(BuildContext context) {
    // final bool isActive = workoutModel.isActive;
    final isCompleted = workoutModel.isCompleted;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: isSelected 
                  ? Border.all(color: const Color(0xFFE53E3E),width: 2)
                  : Border.all(color: Colors.transparent,width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 2)
                )
              ],
            ),
            child: SizedBox(
              height: 70,
              child: Row(
                children: [
                  _DayNumberBox(
                    day: workoutModel.day, 
                    isActive: isSelected,
                    ),
                    const SizedBox(width: 12,),
                    //title
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workoutModel.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1C1C1E),
                            ),
                          ),
                          const SizedBox(height: 4,),
                          Text(
                            'No of Exercises: ${workoutModel.exerciseCount}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF1C1C1E)
                            ),
                          )
                        ],
                      )
                      ),
                      const SizedBox(width: 8,),
                      CircleAvatar(
                        backgroundColor: const Color(0xFFF7F7F7),
                        child: IconButton(
                          onPressed: (){},
                          icon: const Icon(Icons.more_vert_rounded,color: Colors.black,),
                        ),
                      ),
                      const SizedBox(width: 12,)
                ],
              ),
            ),
          ),
        ),
        if (isCompleted)
          const Positioned(
            top: -7.0,
            right: -5.35,
            child: CompletedBadge(),
          ),
      ],
    );
  }
}

//------Daynumberbox----------------

class _DayNumberBox extends StatelessWidget {
  final int day;
  final bool isActive;
 
  const _DayNumberBox({required this.day, required this.isActive});
 
  @override
  Widget build(BuildContext context) {
    final labelColor = isActive ? AppColors.primary : const Color(0xFF1C1C1E);

    return Container(
      width: 72,
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.bgcolorgrey,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          bottomLeft: Radius.circular(14),
        ),
        border: Border.all(color: const Color(0xFF888888), width: 1),
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Day',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: labelColor,
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  '$day',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 35,
                    fontWeight: FontWeight.w500,
                    color: labelColor,
                    height: 0.92,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          if (isActive)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 2.5,
                height: double.infinity,
                color: AppColors.primary,
              ),
            ),
        ],
      ),
    );
  }
}
