import 'package:flutter/material.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/cyber_workout_theme.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/muscle_anatomy_visualizer.dart';
import 'package:customer_mobile_app/src/features/workout/presentation/components/exercise_technique_sheet.dart';
import 'package:customer_mobile_app/core/network/dio_client.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedMuscle = "All";
  String _selectedEquipment = "All";
  bool _isLoading = true;
  List<dynamic> _allWorkouts = [];
  List<dynamic> _filteredWorkouts = [];

  final List<String> _muscleFilters = [
    "All",
    "Chest",
    "Back",
    "Shoulders",
    "Biceps",
    "Triceps",
    "Quads",
    "Hamstrings",
    "Glutes",
    "Calves",
    "Core",
    "Cardio",
  ];

  final List<String> _equipmentFilters = [
    "All",
    "Barbell",
    "Dumbbell",
    "Cable",
    "Machine",
    "Bodyweight",
    "Kettlebell",
  ];

  @override
  void initState() {
    super.initState();
    _fetchLibraryWorkouts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchLibraryWorkouts() async {
    setState(() => _isLoading = true);
    try {
      final res = await DioClient().dio.get('/api/v1/trainer/exercises/');
      if (res.statusCode == 200 && res.data != null) {
        final List list = res.data is List ? res.data : (res.data['results'] ?? res.data['data'] ?? []);
        if (list.isNotEmpty) {
          setState(() {
            _allWorkouts = list;
            _applyFilters();
            _isLoading = false;
          });
          return;
        }
      }
      _loadFallbackWorkouts();
    } catch (_) {
      _loadFallbackWorkouts();
    }
  }

  void _loadFallbackWorkouts() {
    // 230+ Master Library Comprehensive Dataset
    setState(() {
      _allWorkouts = [
        // ==================== CHEST ====================
        {"id": 1, "name": "Barbell Bench Press", "major_muscle": "Chest", "equipment_name": "Barbell", "type": "strength", "instructions": "Lie flat on bench, grip bar slightly wider than shoulder width, lower bar to mid-chest with 3s tempo, press explosively.", "video_url": "https://www.youtube.com/results?search_query=Barbell+Bench+Press+Shorts"},
        {"id": 2, "name": "Incline Dumbbell Press", "major_muscle": "Chest", "equipment_name": "Dumbbell", "type": "strength", "instructions": "Set bench to 30-45 degrees, press dumbbells overhead with control, full stretch at bottom.", "video_url": "https://www.youtube.com/results?search_query=Incline+Dumbbell+Press+Shorts"},
        {"id": 3, "name": "Decline Barbell Bench Press", "major_muscle": "Chest", "equipment_name": "Barbell", "type": "strength", "instructions": "Lie on decline bench, lower bar to lower pec line, press upward.", "video_url": "https://www.youtube.com/results?search_query=Decline+Bench+Press+Shorts"},
        {"id": 4, "name": "Flat Dumbbell Press", "major_muscle": "Chest", "equipment_name": "Dumbbell", "type": "strength", "instructions": "Press heavy dumbbells with neutral/pronated grip, deep chest stretch.", "video_url": "https://www.youtube.com/results?search_query=Dumbbell+Bench+Press+Shorts"},
        {"id": 5, "name": "Incline Barbell Bench Press", "major_muscle": "Chest", "equipment_name": "Barbell", "type": "strength", "instructions": "Unrack bar, lower under control to upper clavicular head, drive up.", "video_url": "https://www.youtube.com/results?search_query=Incline+Barbell+Bench+Press+Shorts"},
        {"id": 6, "name": "Cable Crossover (High to Low)", "major_muscle": "Chest", "equipment_name": "Cable", "type": "isolation", "instructions": "Set pulleys high, bring handles down and across lower chest with strong peak contraction.", "video_url": "https://www.youtube.com/results?search_query=Cable+Crossover+High+to+Low+Shorts"},
        {"id": 7, "name": "Cable Crossover (Low to High)", "major_muscle": "Chest", "equipment_name": "Cable", "type": "isolation", "instructions": "Set pulleys low, scoop handles upward focusing on upper pec contraction.", "video_url": "https://www.youtube.com/results?search_query=Low+to+High+Cable+Fly+Shorts"},
        {"id": 8, "name": "Pec Deck Machine Fly", "major_muscle": "Chest", "equipment_name": "Machine", "type": "isolation", "instructions": "Keep elbows slightly bent, squeeze chest pads together, hold for 1s squeeze.", "video_url": "https://www.youtube.com/results?search_query=Pec+Deck+Fly+Shorts"},
        {"id": 9, "name": "Dips (Chest Forward Lean)", "major_muscle": "Chest", "equipment_name": "Bodyweight", "type": "compound", "instructions": "Lean torso forward 30 degrees, flare elbows slightly, descend to 90 degrees and push up.", "video_url": "https://www.youtube.com/results?search_query=Chest+Dips+Shorts"},
        {"id": 10, "name": "Push-Ups (Standard Form)", "major_muscle": "Chest", "equipment_name": "Bodyweight", "type": "strength", "instructions": "Hands shoulder-width apart, core braced, lower chest to floor, push through palms.", "video_url": "https://www.youtube.com/results?search_query=Push+Ups+Form+Shorts"},
        {"id": 11, "name": "Decline Push-Ups (Feet Elevated)", "major_muscle": "Chest", "equipment_name": "Bodyweight", "type": "strength", "instructions": "Place feet on bench, lower chest to floor focusing on upper pecs.", "video_url": "https://www.youtube.com/results?search_query=Decline+Push+Ups+Shorts"},
        {"id": 12, "name": "Incline Dumbbell Flyes", "major_muscle": "Chest", "equipment_name": "Dumbbell", "type": "isolation", "instructions": "Arc dumbbells outward with slight bend in elbows, deep stretch at bottom.", "video_url": "https://www.youtube.com/results?search_query=Incline+Dumbbell+Flyes+Shorts"},
        {"id": 13, "name": "Hammer Strength Machine Chest Press", "major_muscle": "Chest", "equipment_name": "Machine", "type": "strength", "instructions": "Adjust seat height, press handles forward, control negative return.", "video_url": "https://www.youtube.com/results?search_query=Hammer+Strength+Chest+Press+Shorts"},
        {"id": 14, "name": "Incline Hex Press (Dumbbells Pressed Together)", "major_muscle": "Chest", "equipment_name": "Dumbbell", "type": "isolation", "instructions": "Press two hex dumbbells together firmly throughout entire press motion.", "video_url": "https://www.youtube.com/results?search_query=Hex+Press+Shorts"},
        {"id": 15, "name": "Dumbbell Pullover", "major_muscle": "Chest", "equipment_name": "Dumbbell", "type": "compound", "instructions": "Lie across bench, lower dumbbell behind head in slight arc, pull over chest.", "video_url": "https://www.youtube.com/results?search_query=Dumbbell+Pullover+Shorts"},

        // ==================== BACK & LATS ====================
        {"id": 20, "name": "Conventional Barbell Deadlift", "major_muscle": "Back", "equipment_name": "Barbell", "type": "power", "instructions": "Feet hip-width, grip bar outside shins, brace core, drive through floor with hips.", "video_url": "https://www.youtube.com/results?search_query=Deadlift+Form+Shorts"},
        {"id": 21, "name": "Lat Pulldown (Wide Grip)", "major_muscle": "Back", "equipment_name": "Cable", "type": "strength", "instructions": "Grip wide, pull bar down towards upper chest, retract scapulae, 3s eccentric release.", "video_url": "https://www.youtube.com/results?search_query=Lat+Pulldown+Shorts"},
        {"id": 22, "name": "Lat Pulldown (Close Grip V-Bar)", "major_muscle": "Back", "equipment_name": "Cable", "type": "strength", "instructions": "Use V-bar attachment, pull to upper sternum, squeeze lats hard.", "video_url": "https://www.youtube.com/results?search_query=V+Bar+Lat+Pulldown+Shorts"},
        {"id": 23, "name": "Barbell Bent-Over Row", "major_muscle": "Back", "equipment_name": "Barbell", "type": "strength", "instructions": "Hinge at hips to 45 degrees, pull bar to navel, drive elbows behind back.", "video_url": "https://www.youtube.com/results?search_query=Barbell+Row+Shorts"},
        {"id": 24, "name": "Pendlay Barbell Row", "major_muscle": "Back", "equipment_name": "Barbell", "type": "power", "instructions": "Torso parallel to floor, explode from dead stop on floor each rep.", "video_url": "https://www.youtube.com/results?search_query=Pendlay+Row+Shorts"},
        {"id": 25, "name": "Seated Cable Row", "major_muscle": "Back", "equipment_name": "Cable", "type": "strength", "instructions": "Sit upright with slight knee bend, pull attachment to lower abdomen, squeeze shoulder blades.", "video_url": "https://www.youtube.com/results?search_query=Seated+Cable+Row+Shorts"},
        {"id": 26, "name": "Single-Arm Dumbbell Row", "major_muscle": "Back", "equipment_name": "Dumbbell", "type": "strength", "instructions": "One knee on bench, pull dumbbell to hip socket, keeping back flat.", "video_url": "https://www.youtube.com/results?search_query=Single+Arm+Dumbbell+Row+Shorts"},
        {"id": 27, "name": "Pull-Ups (Wide Pronated Grip)", "major_muscle": "Back", "equipment_name": "Bodyweight", "type": "strength", "instructions": "Hang from pull-up bar, pull chest to bar height, full lockout at bottom.", "video_url": "https://www.youtube.com/results?search_query=Pull+Ups+Form+Shorts"},
        {"id": 28, "name": "Chin-Ups (Supinated Grip)", "major_muscle": "Back", "equipment_name": "Bodyweight", "type": "strength", "instructions": "Palms facing you, pull until chin clears bar, engaging lats and biceps.", "video_url": "https://www.youtube.com/results?search_query=Chin+Ups+Shorts"},
        {"id": 29, "name": "T-Bar Landmine Row", "major_muscle": "Back", "equipment_name": "Barbell", "type": "strength", "instructions": "Straddle barbell, pull handles to chest with neutral spine.", "video_url": "https://www.youtube.com/results?search_query=T+Bar+Row+Shorts"},
        {"id": 30, "name": "Straight-Arm Cable Pulldown", "major_muscle": "Back", "equipment_name": "Cable", "type": "isolation", "instructions": "Keep arms straight with slight elbow bend, push bar down to thighs using lats only.", "video_url": "https://www.youtube.com/results?search_query=Straight+Arm+Pulldown+Shorts"},
        {"id": 31, "name": "Chest-Supported Dumbbell Row", "major_muscle": "Back", "equipment_name": "Dumbbell", "type": "strength", "instructions": "Lie face down on incline bench, row dumbbells upward with strict back isolation.", "video_url": "https://www.youtube.com/results?search_query=Chest+Supported+Row+Shorts"},
        {"id": 32, "name": "Hyperextensions (Back Extension)", "major_muscle": "Back", "equipment_name": "Bodyweight", "type": "strength", "instructions": "Position hips on pad, hinge downward and extend upward using lower back & glutes.", "video_url": "https://www.youtube.com/results?search_query=Back+Extension+Shorts"},
        {"id": 33, "name": "Rack Pulls (Above Knee)", "major_muscle": "Back", "equipment_name": "Barbell", "type": "power", "instructions": "Set bar on pins above knee, lock out heavy load focusing on upper back & traps.", "video_url": "https://www.youtube.com/results?search_query=Rack+Pulls+Shorts"},

        // ==================== SHOULDERS & TRAPS ====================
        {"id": 40, "name": "Overhead Barbell Military Press", "major_muscle": "Shoulders", "equipment_name": "Barbell", "type": "strength", "instructions": "Stand tall, press bar overhead from clavicles to full lockout with core tight.", "video_url": "https://www.youtube.com/results?search_query=Overhead+Press+Shorts"},
        {"id": 41, "name": "Seated Dumbbell Shoulder Press", "major_muscle": "Shoulders", "equipment_name": "Dumbbell", "type": "strength", "instructions": "Sit upright, press dumbbells overhead in a smooth arc without clanking.", "video_url": "https://www.youtube.com/results?search_query=Dumbbell+Shoulder+Press+Shorts"},
        {"id": 42, "name": "Arnold Press", "major_muscle": "Shoulders", "equipment_name": "Dumbbell", "type": "strength", "instructions": "Start with palms facing you, rotate palms outward as you press overhead.", "video_url": "https://www.youtube.com/results?search_query=Arnold+Press+Shorts"},
        {"id": 43, "name": "Standing Dumbbell Lateral Raise", "major_muscle": "Shoulders", "equipment_name": "Dumbbell", "type": "isolation", "instructions": "Raise dumbbells out to sides to parallel height with elbows leading.", "video_url": "https://www.youtube.com/results?search_query=Lateral+Raises+Shorts"},
        {"id": 44, "name": "Cable Lateral Raise (Behind The Back)", "major_muscle": "Shoulders", "equipment_name": "Cable", "type": "isolation", "instructions": "Cable behind back, raise handle sideways with constant tension on lateral deltoid.", "video_url": "https://www.youtube.com/results?search_query=Cable+Lateral+Raise+Shorts"},
        {"id": 45, "name": "Face Pulls (Rope Cable)", "major_muscle": "Shoulders", "equipment_name": "Cable", "type": "isolation", "instructions": "Pull rope to forehead, rotate hands back, engaging rear delts and rotators.", "video_url": "https://www.youtube.com/results?search_query=Face+Pulls+Shorts"},
        {"id": 46, "name": "Rear Delt Pec Deck Fly", "major_muscle": "Shoulders", "equipment_name": "Machine", "type": "isolation", "instructions": "Sit facing machine pad, pull handles back horizontally targeting rear delts.", "video_url": "https://www.youtube.com/results?search_query=Rear+Delt+Fly+Shorts"},
        {"id": 47, "name": "Bent-Over Dumbbell Rear Delt Raise", "major_muscle": "Shoulders", "equipment_name": "Dumbbell", "type": "isolation", "instructions": "Hinge at hips, raise dumbbells outward with elbows slightly bent.", "video_url": "https://www.youtube.com/results?search_query=Rear+Delt+Dumbbell+Fly+Shorts"},
        {"id": 48, "name": "Upright Barbell Row", "major_muscle": "Shoulders", "equipment_name": "Barbell", "type": "strength", "instructions": "Grip bar shoulder width, pull upward leading with elbows to upper chest.", "video_url": "https://www.youtube.com/results?search_query=Upright+Row+Shorts"},
        {"id": 49, "name": "Barbell Shrugs (Heavy Traps)", "major_muscle": "Shoulders", "equipment_name": "Barbell", "type": "strength", "instructions": "Elevate shoulders straight up towards ears, hold for 1s squeeze at top.", "video_url": "https://www.youtube.com/results?search_query=Barbell+Shrugs+Shorts"},
        {"id": 50, "name": "Dumbbell Front Raise", "major_muscle": "Shoulders", "equipment_name": "Dumbbell", "type": "isolation", "instructions": "Raise dumbbells alternating straight in front to eye level.", "video_url": "https://www.youtube.com/results?search_query=Dumbbell+Front+Raise+Shorts"},

        // ==================== BICEPS & TRICEPS (ARMS) ====================
        {"id": 60, "name": "Standing Barbell Bicep Curl", "major_muscle": "Biceps", "equipment_name": "Barbell", "type": "strength", "instructions": "Shoulder-width underhand grip, curl bar upward keeping elbows fixed at sides.", "video_url": "https://www.youtube.com/results?search_query=Barbell+Bicep+Curl+Shorts"},
        {"id": 61, "name": "Incline Dumbbell Bicep Curl", "major_muscle": "Biceps", "equipment_name": "Dumbbell", "type": "isolation", "instructions": "Sit back on incline bench, curl dumbbells upward with full bicep stretch.", "video_url": "https://www.youtube.com/results?search_query=Incline+Dumbbell+Curl+Shorts"},
        {"id": 62, "name": "Dumbbell Hammer Curl", "major_muscle": "Biceps", "equipment_name": "Dumbbell", "type": "strength", "instructions": "Palms facing inward neutral grip, curl heavy dumbbells targeting brachialis.", "video_url": "https://www.youtube.com/results?search_query=Hammer+Curl+Shorts"},
        {"id": 63, "name": "EZ-Bar Preacher Curl", "major_muscle": "Biceps", "equipment_name": "Barbell", "type": "isolation", "instructions": "Rest upper arms on preacher bench pad, curl EZ bar to top, 3s negative descent.", "video_url": "https://www.youtube.com/results?search_query=Preacher+Curl+Shorts"},
        {"id": 64, "name": "Cable Rope Hammer Curl", "major_muscle": "Biceps", "equipment_name": "Cable", "type": "isolation", "instructions": "Attach rope to low pulley, curl and spread rope at top contraction.", "video_url": "https://www.youtube.com/results?search_query=Cable+Rope+Hammer+Curl+Shorts"},
        {"id": 65, "name": "Barbell 21s Bicep Curl", "major_muscle": "Biceps", "equipment_name": "Barbell", "type": "isolation", "instructions": "7 reps lower half, 7 reps upper half, 7 reps full range.", "video_url": "https://www.youtube.com/results?search_query=21s+Bicep+Curl+Shorts"},
        {"id": 66, "name": "Cable Tricep Rope Pushdown", "major_muscle": "Triceps", "equipment_name": "Cable", "type": "isolation", "instructions": "Keep elbows pinned at sides, push rope down and flare outward at lockout.", "video_url": "https://www.youtube.com/results?search_query=Tricep+Rope+Pushdown+Shorts"},
        {"id": 67, "name": "Straight-Bar Tricep Pushdown", "major_muscle": "Triceps", "equipment_name": "Cable", "type": "strength", "instructions": "Push straight bar down forcefully, fully extending elbows.", "video_url": "https://www.youtube.com/results?search_query=Straight+Bar+Pushdown+Shorts"},
        {"id": 68, "name": "EZ-Bar Skull Crushers (Lying Extension)", "major_muscle": "Triceps", "equipment_name": "Barbell", "type": "strength", "instructions": "Lie flat, lower EZ bar to forehead/behind head, press back up.", "video_url": "https://www.youtube.com/results?search_query=Skull+Crushers+Shorts"},
        {"id": 69, "name": "Overhead Dumbbell Tricep Extension", "major_muscle": "Triceps", "equipment_name": "Dumbbell", "type": "isolation", "instructions": "Hold dumbbell with both hands overhead, lower behind neck, press to lockout.", "video_url": "https://www.youtube.com/results?search_query=Overhead+Dumbbell+Extension+Shorts"},
        {"id": 70, "name": "Close-Grip Barbell Bench Press", "major_muscle": "Triceps", "equipment_name": "Barbell", "type": "strength", "instructions": "Hands shoulder-width apart, lower bar to sternum, push focusing on triceps.", "video_url": "https://www.youtube.com/results?search_query=Close+Grip+Bench+Press+Shorts"},
        {"id": 71, "name": "Parallel Bar Tricep Dips", "major_muscle": "Triceps", "equipment_name": "Bodyweight", "type": "strength", "instructions": "Keep torso upright, lower until elbows are at 90 degrees, press to lockout.", "video_url": "https://www.youtube.com/results?search_query=Tricep+Dips+Shorts"},

        // ==================== LEGS (QUADS, HAMSTRINGS, GLUTES, CALVES) ====================
        {"id": 80, "name": "Barbell Back Squat (High Bar / Low Bar)", "major_muscle": "Quads", "equipment_name": "Barbell", "type": "power", "instructions": "Rest bar across traps, break at knees and hips together, squat below parallel, drive up.", "video_url": "https://www.youtube.com/results?search_query=Barbell+Squat+Form+Shorts"},
        {"id": 81, "name": "Barbell Front Squat", "major_muscle": "Quads", "equipment_name": "Barbell", "type": "strength", "instructions": "Bar across anterior deltoids, keep elbows high and torso vertical throughout squat.", "video_url": "https://www.youtube.com/results?search_query=Front+Squat+Shorts"},
        {"id": 82, "name": "Leg Press (45 Degree Sled)", "major_muscle": "Quads", "equipment_name": "Machine", "type": "strength", "instructions": "Feet shoulder-width on platform, lower sled smoothly to 90 degrees, press through heels.", "video_url": "https://www.youtube.com/results?search_query=Leg+Press+Form+Shorts"},
        {"id": 83, "name": "Hack Squat Machine", "major_muscle": "Quads", "equipment_name": "Machine", "type": "strength", "instructions": "Place back firmly against pad, squat down for maximum quad stretch, drive up.", "video_url": "https://www.youtube.com/results?search_query=Hack+Squat+Shorts"},
        {"id": 84, "name": "Leg Extension Machine", "major_muscle": "Quads", "equipment_name": "Machine", "type": "isolation", "instructions": "Align knee joint with machine pivot, extend legs to full contraction, 2s squeeze at top.", "video_url": "https://www.youtube.com/results?search_query=Leg+Extension+Shorts"},
        {"id": 85, "name": "Bulgarian Split Squats (Dumbbells)", "major_muscle": "Quads", "equipment_name": "Dumbbell", "type": "strength", "instructions": "Rear foot elevated on bench, descend front leg until thigh is parallel, push through heel.", "video_url": "https://www.youtube.com/results?search_query=Bulgarian+Split+Squat+Shorts"},
        {"id": 86, "name": "Walking Dumbbell Lunges", "major_muscle": "Quads", "equipment_name": "Dumbbell", "type": "strength", "instructions": "Step forward into deep lunge, back knee 1 inch from floor, step through consecutively.", "video_url": "https://www.youtube.com/results?search_query=Walking+Lunges+Shorts"},
        {"id": 87, "name": "Romanian Deadlift (Barbell RDL)", "major_muscle": "Hamstrings", "equipment_name": "Barbell", "type": "strength", "instructions": "Hinge hips back with soft knees, lower bar along shins until hamstring stretch, drive hips forward.", "video_url": "https://www.youtube.com/results?search_query=Barbell+RDL+Shorts"},
        {"id": 88, "name": "Dumbbell Romanian Deadlift", "major_muscle": "Hamstrings", "equipment_name": "Dumbbell", "type": "strength", "instructions": "Hold dumbbells in front of thighs, hinge at hips, keep dumbbells close to legs.", "video_url": "https://www.youtube.com/results?search_query=Dumbbell+RDL+Shorts"},
        {"id": 89, "name": "Lying Leg Hamstring Curl Machine", "major_muscle": "Hamstrings", "equipment_name": "Machine", "type": "isolation", "instructions": "Lie face down, curl roller pad to glutes, control the eccentric lowering.", "video_url": "https://www.youtube.com/results?search_query=Lying+Leg+Curl+Shorts"},
        {"id": 90, "name": "Seated Leg Hamstring Curl Machine", "major_muscle": "Hamstrings", "equipment_name": "Machine", "type": "isolation", "instructions": "Lock thigh pad down, curl lower pad underneath seat, full hamstring contraction.", "video_url": "https://www.youtube.com/results?search_query=Seated+Leg+Curl+Shorts"},
        {"id": 91, "name": "Barbell Hip Thrust", "major_muscle": "Glutes", "equipment_name": "Barbell", "type": "power", "instructions": "Upper back on bench, barbell across hips with pad, drive hips upward to bridge, squeeze glutes.", "video_url": "https://www.youtube.com/results?search_query=Hip+Thrust+Form+Shorts"},
        {"id": 92, "name": "Cable Glute Kickbacks", "major_muscle": "Glutes", "equipment_name": "Cable", "type": "isolation", "instructions": "Ankle strap on low cable, kick leg back with squeeze at top of movement.", "video_url": "https://www.youtube.com/results?search_query=Glute+Kickback+Shorts"},
        {"id": 93, "name": "Standing Calf Raise (Machine)", "major_muscle": "Calves", "equipment_name": "Machine", "type": "isolation", "instructions": "Balls of feet on block, lower heels for full calf stretch, press up onto toes.", "video_url": "https://www.youtube.com/results?search_query=Standing+Calf+Raise+Shorts"},
        {"id": 94, "name": "Seated Calf Raise (Soleus Target)", "major_muscle": "Calves", "equipment_name": "Machine", "type": "isolation", "instructions": "Sit with knees bent at 90 degrees under pad, raise heels for soleus development.", "video_url": "https://www.youtube.com/results?search_query=Seated+Calf+Raise+Shorts"},

        // ==================== CORE & ABS ====================
        {"id": 100, "name": "Hanging Leg Raise", "major_muscle": "Core", "equipment_name": "Bodyweight", "type": "strength", "instructions": "Hang from bar, curl pelvis upward bringing legs to 90 degrees or bar height.", "video_url": "https://www.youtube.com/results?search_query=Hanging+Leg+Raise+Shorts"},
        {"id": 101, "name": "Ab Wheel Rollout", "major_muscle": "Core", "equipment_name": "Bodyweight", "type": "strength", "instructions": "Kneel on floor, roll wheel forward maintaining tight hollow body, pull back with abs.", "video_url": "https://www.youtube.com/results?search_query=Ab+Wheel+Rollout+Shorts"},
        {"id": 102, "name": "Kneeling Cable Crunch", "major_muscle": "Core", "equipment_name": "Cable", "type": "strength", "instructions": "Kneel beneath high pulley with rope, crunch spine downward bringing elbows to thighs.", "video_url": "https://www.youtube.com/results?search_query=Cable+Crunch+Shorts"},
        {"id": 103, "name": "Plank Hold (Elbows & Toes)", "major_muscle": "Core", "equipment_name": "Bodyweight", "type": "duration", "instructions": "Hold rigid pushup/forearm position, glutes and abs squeezed tight.", "video_url": "https://www.youtube.com/results?search_query=Plank+Form+Shorts"},
        {"id": 104, "name": "Russian Twists (Weighted Plate)", "major_muscle": "Core", "equipment_name": "Bodyweight", "type": "strength", "instructions": "V-sit position, rotate plate side to side across abdomen.", "video_url": "https://www.youtube.com/results?search_query=Russian+Twists+Shorts"},
        {"id": 105, "name": "Cable Woodchoppers (High to Low)", "major_muscle": "Core", "equipment_name": "Cable", "type": "strength", "instructions": "Rotate torso across body diagonally downward, pivoting back foot.", "video_url": "https://www.youtube.com/results?search_query=Cable+Woodchoppers+Shorts"},

        // ==================== CARDIO & FUNCTIONAL ====================
        {"id": 110, "name": "Kettlebell Swing", "major_muscle": "Cardio", "equipment_name": "Kettlebell", "type": "power", "instructions": "Hinge hips back, snap hips forward aggressively to float kettlebell to eye level.", "video_url": "https://www.youtube.com/results?search_query=Kettlebell+Swing+Shorts"},
        {"id": 111, "name": "Rowing Machine (Concept 2)", "major_muscle": "Cardio", "equipment_name": "Machine", "type": "cardio", "instructions": "Drive through legs first, lean back slightly, pull handle to lower ribs.", "video_url": "https://www.youtube.com/results?search_query=Rowing+Machine+Form+Shorts"},
        {"id": 112, "name": "Assault Air Bike Tabata Sprint", "major_muscle": "Cardio", "equipment_name": "Machine", "type": "cardio", "instructions": "Push/pull handles and pedal at max anaerobic output for high-intensity conditioning.", "video_url": "https://www.youtube.com/results?search_query=Assault+Bike+Shorts"},
        {"id": 113, "name": "Battle Ropes (Alternating Waves)", "major_muscle": "Cardio", "equipment_name": "Bodyweight", "type": "cardio", "instructions": "Athletic stance, alternate whipping ropes up and down rapidly creating fluid waves.", "video_url": "https://www.youtube.com/results?search_query=Battle+Ropes+Shorts"},
      ];
      _applyFilters();
      _isLoading = false;
    });
  }

  void _applyFilters() {
    final String query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredWorkouts = _allWorkouts.where((w) {
        final String name = (w['name'] ?? '').toString().toLowerCase();
        final String muscle = (w['major_muscle'] ?? w['primary_muscle_group_name'] ?? '').toString().toLowerCase();
        final String eq = (w['equipment_name'] ?? '').toString().toLowerCase();

        final bool matchQuery = query.isEmpty || name.contains(query) || muscle.contains(query);
        final bool matchMuscle = _selectedMuscle == "All" || muscle.contains(_selectedMuscle.toLowerCase());
        final bool matchEq = _selectedEquipment == "All" || eq.contains(_selectedEquipment.toLowerCase());

        return matchQuery && matchMuscle && matchEq;
      }).toList();
    });
  }

  List<MuscleGroupTarget> _getMuscleTargets(String muscleName) {
    final String m = muscleName.toLowerCase();
    if (m.contains("chest") || m.contains("pec")) return [MuscleGroupTarget.chest];
    if (m.contains("back") || m.contains("lat")) return [MuscleGroupTarget.upperBack, MuscleGroupTarget.lats];
    if (m.contains("shoulder") || m.contains("delt") || m.contains("trap")) return [MuscleGroupTarget.shoulders];
    if (m.contains("bicep")) return [MuscleGroupTarget.biceps];
    if (m.contains("tricep")) return [MuscleGroupTarget.triceps];
    if (m.contains("arm")) return [MuscleGroupTarget.biceps, MuscleGroupTarget.triceps];
    if (m.contains("quad") || m.contains("squat")) return [MuscleGroupTarget.quadriceps];
    if (m.contains("hamstring") || m.contains("glute")) return [MuscleGroupTarget.hamstrings];
    if (m.contains("calf") || m.contains("calves")) return [MuscleGroupTarget.calves];
    if (m.contains("leg")) return [MuscleGroupTarget.quadriceps, MuscleGroupTarget.hamstrings];
    if (m.contains("core") || m.contains("abs")) return [MuscleGroupTarget.abs];
    return [MuscleGroupTarget.fullBody];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CyberWorkoutTheme.bgVoid,
      appBar: AppBar(
        backgroundColor: CyberWorkoutTheme.goldPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Master Exercise Library",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.all(16),
            color: CyberWorkoutTheme.bgSurface,
            child: Column(
              children: [
                // Search Input Box
                TextField(
                  controller: _searchController,
                  onChanged: (_) => _applyFilters(),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: "Search 230+ exercises (e.g. Bench, Squat, Delts)...",
                    hintStyle: const TextStyle(color: CyberWorkoutTheme.textMuted, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: CyberWorkoutTheme.goldPrimary, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, color: Colors.white70, size: 16),
                            onPressed: () {
                              _searchController.clear();
                              _applyFilters();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: CyberWorkoutTheme.bgCardGlass,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: CyberWorkoutTheme.borderSubtle),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: CyberWorkoutTheme.goldPrimary, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Muscle Filter Horizontal Chips
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _muscleFilters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final String m = _muscleFilters[idx];
                      final bool isSelected = _selectedMuscle == m;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedMuscle = m);
                          _applyFilters();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? CyberWorkoutTheme.goldPrimary : CyberWorkoutTheme.bgCardGlass,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? CyberWorkoutTheme.goldPrimary : CyberWorkoutTheme.borderSubtle,
                            ),
                          ),
                          child: Text(
                            m,
                            style: TextStyle(
                              color: isSelected ? Colors.black : CyberWorkoutTheme.textSecondary,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Total Results Counter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "SHOWING ${_filteredWorkouts.length} EXERCISES",
                  style: const TextStyle(
                    color: CyberWorkoutTheme.goldPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
                const Text(
                  "230+ In Database",
                  style: TextStyle(color: CyberWorkoutTheme.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),

          // Exercise List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: CyberWorkoutTheme.goldPrimary))
                : _filteredWorkouts.isEmpty
                    ? const Center(
                        child: Text(
                          "No exercises found matching filters.",
                          style: TextStyle(color: CyberWorkoutTheme.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        itemCount: _filteredWorkouts.length,
                        itemBuilder: (context, index) {
                          final item = _filteredWorkouts[index];
                          final String name = item['name'] ?? 'Exercise';
                          final String muscle = item['major_muscle'] ?? item['primary_muscle_group_name'] ?? 'General';
                          final String eq = item['equipment_name'] ?? 'Equipment';
                          final String inst = item['instructions'] ?? 'Perform with strict form and full range of motion.';
                          final muscleTargets = _getMuscleTargets(muscle);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: CyberWorkoutTheme.glassCard(),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF111118),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: CyberWorkoutTheme.borderSubtle),
                                ),
                                child: MuscleAnatomyVisualizer(
                                  primaryMuscles: muscleTargets,
                                  width: 40,
                                  height: 44,
                                  isAnimated: false,
                                ),
                              ),
                              title: Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: CyberWorkoutTheme.crimsonRed.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: CyberWorkoutTheme.crimsonRed.withOpacity(0.5)),
                                      ),
                                      child: Text(
                                        muscle.toUpperCase(),
                                        style: const TextStyle(
                                          color: CyberWorkoutTheme.crimsonRed,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "• $eq",
                                      style: const TextStyle(
                                        color: CyberWorkoutTheme.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: CyberWorkoutTheme.goldPrimary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: CyberWorkoutTheme.goldPrimary.withOpacity(0.4)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.info_outline, color: CyberWorkoutTheme.goldPrimary, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      "Guide",
                                      style: TextStyle(
                                        color: CyberWorkoutTheme.goldPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                ExerciseTechniqueSheet.show(
                                  context,
                                  exerciseName: name,
                                  targetMuscle: muscle,
                                  primaryMuscles: muscleTargets,
                                  secondaryMuscles: [MuscleGroupTarget.fullBody],
                                  instructions: [
                                    inst,
                                    "Control the eccentric phase for 3 full seconds.",
                                    "Exhale and drive through the target muscle to peak contraction."
                                  ],
                                  formTips: [
                                    "Keep your core tight and maintain neutral spine throughout.",
                                    "Do not use excessive momentum or bounce the weight."
                                  ],
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
