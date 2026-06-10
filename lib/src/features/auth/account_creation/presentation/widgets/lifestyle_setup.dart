import 'package:customer_mobile_app/imports_bindings.dart';

class LifestyleStep extends StatefulWidget {
  final SentOtpEntity? sentOtpEntity;
  final ConstantChoicesModel? choices;
  final bool isLoading;
  final void Function({
    required String profession,
    required String workingHours,
    required String sleepHours,
    required String jobSatisfaction,
    required String other,
  })
  onNext;
  final void Function() onSkip;

  const LifestyleStep({
    required this.onNext,
    this.choices,
    this.isLoading = false,
    this.sentOtpEntity,
    required this.onSkip,
  });

  @override
  State<LifestyleStep> createState() => LifestyleStepState();
}

class LifestyleStepState extends State<LifestyleStep> {
  final _formKey = GlobalKey<FormState>();
  final _otherController = TextEditingController();

  String? selectedProfession;
  String? selectedWorkingHours;
  String? selectedSleepHours;
  String? selectedJobSatisfaction;

  bool get _isOtherSelected => selectedProfession == 'Other';

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  void _onNextPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onNext(
        profession: selectedProfession ?? '',
        workingHours: selectedWorkingHours ?? '',
        sleepHours: selectedSleepHours ?? '',
        jobSatisfaction: selectedJobSatisfaction ?? '',
        other: _otherController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Your Lifestyle, Your Story 🌍',
            style: AppStyles.text32Px.poppins.w600.dark,
          ),
          SizedBox(height: 8.h),
          Text(
            'Your routine shapes your health. Share a little so we can serve you better.',
            style: AppStyles.text15Px.poppins.w400.textGrey,
          ),
          SizedBox(height: 16.h),

          // --- Profession Dropdown ---
          Question.dropDown(
            value: selectedProfession,
            width: MediaQuery.of(context).size.width - 20,
            heading: 'What keeps you busy?',
            context: context,
            hint: 'Select your profession',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your profession';
              }
              return null;
            },
            items:
                widget.choices?.data.professions
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item.value,
                        child: Text(item.label),
                      ),
                    )
                    .toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedProfession = newValue;
              });
            },
          ),

          // --- Other Text Field (only if profession == Other) ---
          if (_isOtherSelected)
            Column(
              children: [
                SizedBox(height: 12.h),
                Question.text(
                  hintText: 'Specify your profession',
                  controller: _otherController,
                  heading: '',
                  validator: (value) {
                    if (_isOtherSelected &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Please enter your profession';
                    }
                    return null;
                  },
                ),
              ],
            ),

          SizedBox(height: 12.h),

          // --- Job Satisfaction ---
          // Question.dropDown(
          //   value: selectedJobSatisfaction,
          //   width: MediaQuery.of(context).size.width - 20,
          //   heading: 'How happy are you with your current job/profession?',
          //   context: context,
          //   hint: 'Select satisfaction level',
          //   validator: (value) {
          //     if (value == null || value.isEmpty) {
          //       return 'Please select your job satisfaction level';
          //     }
          //     return null;
          //   },
          //   items:
          //       widget.choices?.data.jobSatisfactions
          //           .map(
          //             (item) => DropdownMenuItem<String>(
          //               value: item.value.toString(),
          //               child: Text(item.label),
          //             ),
          //           )
          //           .toList(),
          //   onChanged: (String? newValue) {
          //     setState(() {
          //       selectedJobSatisfaction = newValue;
          //     });
          //   },
          // ),

          // --- Job Satisfaction ---
          // --- Job Satisfaction ---
          if ((widget.choices?.data.jobSatisfactions.length ?? 0) > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How happy are you with your current job/profession?',
                    style: AppStyles.text16Px.poppins.w500.dark,
                  ),
                  SizedBox(height: 10.h),
                  FormField<String>(
                    validator: (value) {
                      if (selectedJobSatisfaction == null ||
                          selectedJobSatisfaction!.isEmpty) {
                        return 'Please select your job satisfaction level';
                      }
                      return null;
                    },
                    builder: (field) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children:
                                widget.choices?.data.jobSatisfactions.map((
                                  item,
                                ) {
                                  // Emoji mapping
                                  final emojiMap = {
                                    '5': '😄',
                                    '4': '🙂',
                                    '3': '😐',
                                    '2': '☹️',
                                    '1': '😔',
                                  };

                                  final isSelected =
                                      selectedJobSatisfaction ==
                                      item.value.toString();

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedJobSatisfaction =
                                            item.value.toString();
                                        field.didChange(
                                          selectedJobSatisfaction,
                                        ); // notify form
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color:
                                                isSelected
                                                    ? AppColors.primary
                                                        .withOpacity(0.2)
                                                    : Colors.transparent,
                                            border: Border.all(
                                              color:
                                                  isSelected
                                                      ? AppColors.primary
                                                      : Colors.grey.shade400,
                                              width: isSelected ? 2 : 1,
                                            ),
                                          ),
                                          child: Text(
                                            emojiMap[item.value.toString()] ??
                                                '🙂',
                                            style: const TextStyle(
                                              fontSize: 27,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList() ??
                                [],
                          ),

                          // Validation message
                          if (field.hasError)
                            Padding(
                              padding: const EdgeInsets.only(top: 6, left: 8),
                              child: Text(
                                field.errorText!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            )
          else
            const SizedBox(),

          SizedBox(height: 12.h),

          // --- Working Hours ---
          Question.dropDown(
            value: selectedWorkingHours,
            width: MediaQuery.of(context).size.width - 20,
            heading: 'Average working hours',
            context: context,
            hint: 'Select working hours',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your working hours';
              }
              return null;
            },
            items:
                widget.choices?.data.workingHours
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item.value,
                        child: Text(item.label),
                      ),
                    )
                    .toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedWorkingHours = newValue;
              });
            },
          ),

          SizedBox(height: 12.h),

          // --- Sleep Hours ---
          Question.dropDown(
            value: selectedSleepHours,
            width: MediaQuery.of(context).size.width - 20,
            heading: 'Average sleep hours',
            context: context,
            hint: 'Select sleep hours',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your sleep hours';
              }
              return null;
            },
            items:
                widget.choices?.data.sleepHours
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item.value,
                        child: Text(item.label),
                      ),
                    )
                    .toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedSleepHours = newValue;
              });
            },
          ),

          const SizedBox(height: 40),

          // --- Buttons ---
          Row(
            children: [
              Expanded(
                child: Button.filled(
                  isLoading: widget.isLoading,
                  title: 'Next',
                  ontap: _onNextPressed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            textAlign: TextAlign.center,
            'Every choice you share helps us personalize your journey.',
            style: AppStyles.text15Px.poppins.w400.textGrey,
          ),
        ],
      ),
    );
  }
}
