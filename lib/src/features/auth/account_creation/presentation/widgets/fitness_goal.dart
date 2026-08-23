import 'package:customer_mobile_app/imports_bindings.dart';

class FitnessGoalStep extends StatefulWidget {
  final void Function({
    // required String targetGoal,
    required List<String> targetGoal,
    required String targetGoalOther,
  })
  onFinish;

  final SentOtpEntity? sentOtpEntity;
  final ConstantChoicesModel? choices;
  final bool isLoading;
  final CustomerDetailsModel? customerDetailsModel;
  const FitnessGoalStep({
    required this.onFinish,
    this.choices,
    this.isLoading = false,
    this.sentOtpEntity,
    this.customerDetailsModel,
  });

  @override
  State<FitnessGoalStep> createState() => FitnessGoalStepState();
}

class FitnessGoalStepState extends State<FitnessGoalStep> {
  List<String> selectedGoals = [];
  final TextEditingController _other = TextEditingController();

  void _onFinish() {
    if (selectedGoals.isEmpty) {
      Dialogs.showSnack(msg: 'Please select or enter your fitness goal');
      return;
    }

    String targetGoalOther = '';

    // 🟢 If "Other" is selected
    if (selectedGoals.contains('Other')) {
      if (_other.text.trim().isEmpty) {
        Dialogs.showSnack(msg: 'Please enter your custom goal');
        return;
      }
      targetGoalOther = _other.text.trim();
    }

    // ✅ Join multiple selected goals into one string (comma separated)
    final targetGoal = selectedGoals.join(',');

    widget.onFinish(
      targetGoal: selectedGoals,
      targetGoalOther: targetGoalOther,
    );
  }

  @override
  void initState() {
    super.initState();

    if (widget.customerDetailsModel != null) {
      selectedGoals = List.from(widget.customerDetailsModel?.targetGoal ?? []);

      _other.text = widget.customerDetailsModel?.targetGoalOther ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final goalsList =
        widget.choices?.data.targetGoals
            .map((e) => {'value': e.value, 'label': e.label})
            .toList() ??
        [];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (widget.customerDetailsModel == null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Fitness,\nYour Way 🎯',
                style: AppStyles.text32Px.poppins.w600.dark,
              ),
              const SizedBox(height: 8),
              Text(
                'What drives you to stay fit? 💡',
                style: AppStyles.text15Px.poppins.w500.dark,
              ),
              Text(
                'Your answer helps us to craft your perfect Discipl experience',
                style: AppStyles.text16Px.poppins.w400.dark,
              ),
              const SizedBox(height: 24),
            ],
          )
        else
          SizedBox(),

        // 🟢 Multiple Checkboxes
        Question.checkBox(
          heading: '',
          value: goalsList,
          selectedValues: selectedGoals,
          onChanged: (newSelectedList) {
            setState(() {
              selectedGoals = newSelectedList;
              if (!selectedGoals.contains('Other')) {
                _other.clear();
              }
            });
          },
        ),

        // 🟢 "Other" text field when selected
        if (selectedGoals.contains('Other'))
          Question.text(
            controller: _other,
            hintText: 'Please specify your goal',
            heading: '',
          ),

        const SizedBox(height: 32),

        // 🟢 Finish button
        Button.filled(
          isLoading: widget.isLoading,
          title:
              widget.customerDetailsModel == null ? 'Finish Setup' : 'Update',
          ontap: _onFinish,
        ),

        const SizedBox(height: 10),
        Text(
          textAlign: TextAlign.center,
          'You’re defining your ‘why’ — and that’s \npowerful',
          style: AppStyles.text15Px.poppins.w400.textGrey,
        ),
      ],
    );
  }
}

// import 'package:customer_mobile_app/imports_bindings.dart';
//
// class FitnessGoalStep extends StatefulWidget {
//   final void Function({
//   required String targetGoal,
//   required String targetGoalOther,
//   }) onFinish;
//
//   final SentOtpEntity? sentOtpEntity;
//   final ConstantChoicesModel? choices;
//   final bool isLoading;
//
//   const FitnessGoalStep({
//     required this.onFinish,
//     this.choices,
//     this.isLoading = false,
//     this.sentOtpEntity,
//   });
//
//   @override
//   State<FitnessGoalStep> createState() => FitnessGoalStepState();
// }
//
// class FitnessGoalStepState extends State<FitnessGoalStep> {
//   String selectedGoal = '';
//   final TextEditingController _other = TextEditingController();
//
//   void _onFinish() {
//     String? targetGoal;
//     String targetGoalOther = '';
//
//     // 🟢 If "Other" is selected
//     if (selectedGoal == 'Other') {
//       if (_other.text.trim().isEmpty) {
//         Dialogs.showSnack(msg: 'Please enter your custom goal');
//         return;
//       }
//
//       targetGoal = selectedGoal; // "Other"
//       targetGoalOther = _other.text.trim();
//     }
//
//     // 🟢 If a predefined goal is selected
//     else if (selectedGoal.isNotEmpty) {
//       targetGoal = selectedGoal;
//       targetGoalOther = '';
//     }
//
//     // 🚫 No selection at all
//     else {
//       Dialogs.showSnack(msg: 'Please select or enter your fitness goal');
//       return;
//     }
//
//     // ✅ Pass both values to parent
//     widget.onFinish(
//       targetGoal: targetGoal,
//       targetGoalOther: targetGoalOther,
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       padding: const EdgeInsets.all(20),
//       children: [
//         Text(
//           'Your Fitness,\nYour Way 🎯',
//           style: AppStyles.text32Px.poppins.w600.dark,
//         ),
//         const SizedBox(height: 8),
//         Text(
//           'What drives you to stay fit? 💡',
//           style: AppStyles.text15Px.poppins.w500.dark,
//         ),
//         Text(
//           'Your answer helps us to craft your perfect Discipl experience',
//           style: AppStyles.text16Px.poppins.w400.dark,
//         ),
//         const SizedBox(height: 24),
//
//         // 🟢 Radio buttons
//         Question.radioBtn(
//           heading: '',
//           value: widget.choices?.data.targetGoals
//               .map((e) => {'value': e.value, 'label': e.label})
//               .toList() ??
//               [],
//           groupValue: selectedGoal,
//           onChanged: (value) {
//             setState(() {
//               selectedGoal = value.toString();
//               _other.clear();
//             });
//           },
//         ),
//
//         // 🟢 "Other" field visible when selected
//         if (selectedGoal == 'Other')
//           Question.text(
//             controller: _other,
//             hintText: 'Please specify your goal',
//             heading: '',
//           ),
//
//         const SizedBox(height: 32),
//
//         // 🟢 Finish button
//         Button.filled(
//           isLoading:  widget.isLoading
//           ,
//           title: 'Finish Setup',
//           ontap: _onFinish,
//         ),
//
//         const SizedBox(height: 10),
//         Text(
//           textAlign: TextAlign.center,
//           'You’re defining your ‘why’ — and that’s \npowerful',
//           style: AppStyles.text15Px.poppins.w400.textGrey,
//         ),
//       ],
//     );
//   }
// }
