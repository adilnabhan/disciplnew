//
// import 'package:customer_mobile_app/imports_bindings.dart';
//
// class HealthStatusScreen extends StatefulWidget {
//   final ConstantChoicesModel choicesModel;
//   final CustomerDetailsModel customerDetailsModel;
//
//   const HealthStatusScreen({
//     super.key,
//     required this.choicesModel,
//     required this.customerDetailsModel,
//   });
//
//   @override
//   State<HealthStatusScreen> createState() => _HealthStatusScreenState();
// }
//
// class _HealthStatusScreenState extends State<HealthStatusScreen> {
//   String? selectedHealthStatus;
//   List<dynamic> selectedHealthIssues = [];
//   TextEditingController otherCtrl = TextEditingController();
//   late final ProfileCubit _cubit;
//
//   @override
//   void initState() {
//     super.initState();
//     _cubit = context.read<ProfileCubit>();
//     var isHealthy = widget.customerDetailsModel.isHealthy;
//
//     if (isHealthy == true) {
//       selectedHealthStatus = 'healthy';
//     } else if (isHealthy == false) {
//       selectedHealthStatus = 'not_healthy';
//       print('erer');
//
//       /// Pre-select user's previously saved health issues (if any)
//       if (widget.customerDetailsModel.isHealthy == false) {
//         selectedHealthIssues = widget.customerDetailsModel.healthConditions!;
//       }
//       otherCtrl.text = widget.customerDetailsModel.healthConditionsOther ?? "";
//     } else {
//       /// isHealthy == null → treat as "other"
//       selectedHealthStatus = 'other';
//       otherCtrl.text = widget.customerDetailsModel.healthConditionsOther ?? "";
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final goals = [
//       ...(widget.customerDetailsModel.targetGoal ?? [])
//           .where((e) => e.toString().toLowerCase() != 'other')
//           .map((e) => e.toString().replaceAll('_', ' ')),
//
//       if ((widget.customerDetailsModel.targetGoalOther ?? '').trim().isNotEmpty)
//         widget.customerDetailsModel.targetGoalOther!.trim(),
//     ];
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Health Style And Fitness Goal')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: AppColors.light,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: AppColors.borderGrey),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             'Lifestyle',
//                             style: AppStyles.text16Px.poppins.w600.dark,
//                           ),
//                         ),
//                         InkWell(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder:
//                                     (_) => BlocProvider.value(
//                                       value: _cubit,
//                                       child: EditLifeStyle(
//                                         customerDetailsModel:
//                                             widget.customerDetailsModel,
//                                         choicesModel: widget.choicesModel,
//                                       ),
//                                     ),
//                               ),
//                             );
//
//                             // context.push(
//                             //   BlocProvider.value(
//                             //     value: _cubit,
//                             //     child: LifeStyleEditScreen(
//                             //       choicesModel: widget.choicesModel,
//                             //       customerDetailsModel:
//                             //           widget.customerDetailsModel,
//                             //       onUpdate: (ba) {
//                             //         print(ba.jobSatisfaction);
//                             //
//                             //         print(ba.workingHours);
//                             //         print(ba.sleepingHours);
//                             //       },
//                             //     ),
//                             //   ),
//                             // );
//                           },
//                           child: const Icon(
//                             Icons.edit,
//                             size: 20,
//                             color: Colors.red,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//
//                     // _buildRow(
//                     //   'Occupation',
//                     //   widget.customerDetailsModel.profession,
//                     // ),
//                     // _buildRow(
//                     //   'Work Condition',
//                     //   widget.customerDetailsModel.jobSatisfaction,
//                     // ),
//                     buildEmojiRatingRow(
//                       label: 'Work Condition',
//                       rating: int.tryParse(
//                         widget.customerDetailsModel.jobSatisfaction
//                                 .toString() ??
//                             '',
//                       ),
//                     ),
//                     _buildRow(
//                       'Working Hour (avg)',
//                       // widget.customerDetailsModel.averageWorkingHours,
//                       widget.choicesModel.data.workingHours
//                           .firstWhere(
//                             (element) =>
//                                 element.value ==
//                                 widget.customerDetailsModel.averageWorkingHours,
//                             orElse:
//                                 () => const Profession(label: '', value: ''),
//                           )
//                           .label,
//                     ),
//                     _buildRow(
//                       'Sleep Hour (avg)',
//                       // widget.customerDetailsModel.averageSleepingHours,
//                       widget.choicesModel.data.sleepHours
//                           .firstWhere(
//                             (element) =>
//                                 element.value ==
//                                 widget
//                                     .customerDetailsModel
//                                     .averageSleepingHours,
//                             orElse:
//                                 () => const Profession(label: '', value: ''),
//                           )
//                           .label,
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 10),
//
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: AppColors.light,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: AppColors.borderGrey),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             'Health Style',
//                             style: AppStyles.text16Px.poppins.w600.dark,
//                           ),
//                         ),
//                         InkWell(
//                           onTap: () {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder:
//                                     (_) => BlocProvider.value(
//                                       value: _cubit,
//                                       child: EditHealthStyle(
//                                         customerDetailsModel:
//                                             widget.customerDetailsModel,
//                                         choicesModel: widget.choicesModel,
//                                       ),
//                                     ),
//                               ),
//                             );
//                           },
//                           child: const Icon(
//                             Icons.edit,
//                             size: 20,
//                             color: Colors.red,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     _buildRow(
//                       'Health Status',
//                       widget.customerDetailsModel.isHealthy ?? false
//                           ? 'Healthy'
//                           : 'Not Healthy',
//                     ),
//                     if (widget.customerDetailsModel.isHealthy == false)
//                       _buildRow(
//                         bullet: true,
//                         'Health Issues',
//                         widget.customerDetailsModel.healthConditions!.join(','),
//                       )
//                     else
//                       const SizedBox(),
//                     if ((widget.customerDetailsModel.healthConditionsOther ==
//                             null) ||
//                         (widget.customerDetailsModel.healthConditionsOther ==
//                             ''))
//                       const SizedBox()
//                     else
//                       _buildRow(
//                         'Other Health Issues',
//                         widget.customerDetailsModel.healthConditionsOther,
//                       ),
//                     _buildRow(
//                       ' Active Scale',
//                       '${widget.customerDetailsModel.activeScale.toString()}/5',
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: AppColors.light,
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: AppColors.borderGrey),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//
//                   children: [
//                     // Text(
//                     //   'Fitness Goal',
//                     //   style: AppStyles.text16Px.poppins.w600.dark,
//                     // ),
//                     const SizedBox(height: 10),
//                     Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: _infoBulletList(
//                             title: 'Target Goals',
//                             items: goals,
//                           ),
//                         ),
//                         // InkWell(
//                         //   onTap: () {
//                         //     Navigator.push(
//                         //       context,
//                         //       MaterialPageRoute(
//                         //         builder:
//                         //             (_) => BlocProvider.value(
//                         //               value: _cubit,
//                         //               child: EditTargetGoals(
//                         //                 customerDetailsModel:
//                         //                     widget.customerDetailsModel,
//                         //                 choicesModel: widget.choicesModel,
//                         //               ),
//                         //             ),
//                         //       ),
//                         //     );
//                         //   },
//                         //   child:  const Icon(Icons.edit,
//                         //     size: 20,color: Colors.red,
//                         //   ),
//                         // ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _infoBulletList({required String title, required List<String> items}) {
//     if (items.isEmpty) return const SizedBox();
//
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               fontSize: 15,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 6),
//           // ...items.map(
//           //   (item) => Padding(
//           //     padding: const EdgeInsets.only(left: 12, bottom: 4),
//           //     child: Row(
//           //       crossAxisAlignment: CrossAxisAlignment.start,
//           //       children: [
//           //         const Text("•  ", style: TextStyle(fontSize: 15)),
//           //         Expanded(
//           //           child: Text(
//           //             item.replaceAll('_', ' '),
//           //             style: const TextStyle(
//           //               fontSize: 15,
//           //               color: Colors.black54,
//           //             ),
//           //           ),
//           //         ),
//           //       ],
//           //     ),
//           //   ),
//           // ),
//           const SizedBox(height: 10),
//           Wrap(
//             spacing: 8,
//             runSpacing: 8,
//             children: List.generate(items.length, (index) {
//               return Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 14,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFFFEBEE),
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(color: Colors.red, width: 1),
//                 ),
//                 child: Text(
//                   items[index],
//                   style: const TextStyle(
//                     color: Colors.red,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ********* FINAL REQUEST FORMAT *********
//   Map<String, dynamic> buildFinalRequest() {
//     if (selectedHealthStatus == 'healthy') {
//       return {'is_healthy': true, 'health_conditions': []};
//     }
//
//     if (selectedHealthStatus == 'not_healthy') {
//       return {
//         'is_healthy': false,
//         'health_conditions':
//             selectedHealthIssues
//                 .map((e) => {'id': e.id, 'label': e.label})
//                 .toList(),
//       };
//     }
//
//     if (selectedHealthStatus == 'other') {
//       return {'is_healthy': null, 'other_condition': otherCtrl.text.trim()};
//     }
//
//     return {};
//   }
//
//   Widget _buildRow(String label, dynamic value, {bool bullet = false}) {
//     var items = <String>[];
//
//     if (!bullet) {
//       // Skip bullet formatting, show plain text always
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             flex: 1,
//             child: Text(label, style: AppStyles.text13Px.poppins.w400.dark),
//           ),
//           Text(': ', style: AppStyles.text14Px.poppins.w500.dark),
//           Expanded(
//             flex: 2,
//             child: Text(
//               value?.toString() ?? '-',
//               style: AppStyles.text14Px.poppins.w500.dark,
//             ),
//           ),
//         ],
//       ).pOnly(bottom: 8);
//     }
//
//     // Below is your bullet logic
//     if (value == null) {
//       items = [];
//     } else if (value is String) {
//       items =
//           value.contains(',')
//               ? value.split(',').map((e) => e.trim()).toList()
//               : [value];
//     } else if (value is List<String>) {
//       items = value;
//     }
//
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           flex: 1,
//           child: Text(label, style: AppStyles.text13Px.poppins.w400.dark),
//         ),
//         Text(': ', style: AppStyles.text14Px.poppins.w500.dark),
//         Expanded(
//           flex: 2,
//           child:
//               items.isEmpty
//                   ? Text('-', style: AppStyles.text14Px.poppins.w500.dark)
//                   : Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children:
//                         items
//                             .map(
//                               (item) => Row(
//                                 children: [
//                                   const Text('• '),
//                                   Expanded(
//                                     child: Text(
//                                       item,
//                                       style:
//                                           AppStyles.text14Px.poppins.w500.dark,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             )
//                             .toList(),
//                   ),
//         ),
//       ],
//     ).pOnly(bottom: 8);
//   }
//
//   Widget buildEmojiRatingRow({
//     required String label,
//     required int? rating, // API value: 1–5
//   }) {
//     final emojiMap = <int, String>{5: '😄', 4: '🙂', 3: '😐', 2: '☹️', 1: '😔'};
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Expanded(
//           flex: 1,
//           child: Text(label, style: AppStyles.text13Px.poppins.w400.dark),
//         ),
//         Text(': ', style: AppStyles.text14Px.poppins.w500.dark),
//         Expanded(
//           flex: 2,
//           child: Row(
//             children: List.generate(5, (index) {
//               final value = index + 1;
//               final isSelected = rating == value;
//
//               return Container(
//                 margin: const EdgeInsets.only(right: 8),
//                 width: 30,
//                 height: 30,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color:
//                       isSelected ? Colors.orange.shade100 : Colors.transparent,
//                   border: Border.all(
//                     color:
//                         isSelected ? AppColors.primary : Colors.grey.shade300,
//                     width: 1.5,
//                   ),
//                 ),
//                 alignment: Alignment.center,
//                 child: Text(
//                   emojiMap[value]!,
//                   style: const TextStyle(fontSize: 18),
//                 ),
//               );
//             }),
//           ),
//         ),
//       ],
//     ).pOnly(bottom: 8);
//   }
// }
//
// class EditHealthStyle extends StatelessWidget {
//   const EditHealthStyle({
//     super.key,
//     required this.customerDetailsModel,
//
//     this.choicesModel,
//   });
//   final ConstantChoicesModel? choicesModel;
//   final CustomerDetailsModel customerDetailsModel;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Health Style Edit')),
//
//       body: BlocProvider(
//         create:
//             (_) => CreateAccountCubit(
//               sentOtp: const SentOtpEntity(),
//               constChoices: choicesModel,
//             ),
//         child: BlocConsumer<CreateAccountCubit, CreateAccountState>(
//           listener: (context, state) {
//             state.createOrUpdateOnboarding?.fold(
//               () => null,
//               (either) => either.fold(
//                 (error) {
//                   Dialogs.showSnack(msg: error.msg);
//                 },
//                 (success) {
//                   context.read<ProfileCubit>().fetchCustomerDetails();
//                   Navigator.pop(context);
//                   Navigator.pop(context);
//                 },
//               ),
//             );
//           },
//
//           builder: (context, state) {
//             return HealthStep(
//               isLoading: state.isLoading ?? false, // 👈 pass loader here
//               customerDetailsModel: customerDetailsModel,
//               choices: choicesModel,
//
//               onNext: (healthStatus, selectedConditions, rating, conditon) {
//                 print('Health Status: $healthStatus');
//                 print('otherConditions: $rating');
//                 print('Selected Conditions: $selectedConditions');
//                 print('Activity Rating:$conditon');
//
//                 context.read<CreateAccountCubit>().onboardingUpdate(
//                   id: customerDetailsModel.id,
//                   body:
//                       healthStatus ?? false
//                           ? {
//                             'is_healthy': healthStatus,
//                             'active_scale': rating,
//                             'profile_completeness': 3,
//                             'health_conditions_other': '',
//                           }
//                           : {
//                             'is_healthy': healthStatus,
//                             'active_scale': rating,
//                             'profile_completeness': 3,
//                             'health_conditions': selectedConditions,
//                             'health_conditions_other': conditon,
//                           },
//                 );
//               },
//
//               onSkip: () {},
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
// class EditTargetGoals extends StatelessWidget {
//   const EditTargetGoals({
//     super.key,
//     required this.customerDetailsModel,
//
//     this.choicesModel,
//   });
//   final ConstantChoicesModel? choicesModel;
//   final CustomerDetailsModel customerDetailsModel;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Target Goals Edit')),
//
//       body: BlocProvider(
//         create:
//             (_) => CreateAccountCubit(
//               sentOtp: const SentOtpEntity(),
//               constChoices: choicesModel,
//             ),
//         child: BlocConsumer<CreateAccountCubit, CreateAccountState>(
//           listener: (context, state) {
//             state.createOrUpdateOnboarding?.fold(
//               () => null,
//               (either) => either.fold(
//                 (error) {
//                   Dialogs.showSnack(msg: error.msg);
//                 },
//                 (success) {
//                   context.read<ProfileCubit>().fetchCustomerDetails();
//                   Navigator.pop(context);
//                   Navigator.pop(context);
//                 },
//               ),
//             );
//           },
//
//           builder: (context, state) {
//             return FitnessGoalStep(
//               isLoading: state.isLoading,
//               choices: choicesModel,
//               customerDetailsModel: customerDetailsModel,
//               onFinish: ({
//                 required List<String> targetGoal,
//                 required String targetGoalOther,
//               }) {
//                 print('Goal: $targetGoal');
//                 print('Goal Other: $targetGoalOther');
//
//                 print(targetGoal.contains('Other'));
//                 print(targetGoal);
//
//                 context.read<CreateAccountCubit>().onboardingUpdate(
//                   id: customerDetailsModel.id,
//                   body: {
//                     'target_goal': targetGoal,
//                     'target_goal_other': targetGoalOther,
//                     'profile_completeness': 3,
//                   },
//                   // targetGoal.contains('Other')
//                   //     ? {
//                   //       'target_goal': targetGoal,
//                   //       'target_goal_other':
//                   //           targetGoalOther,
//                   //       'profile_completeness': 3,
//                   //     }
//                   //     : {
//                   //       'target_goal': targetGoal,
//                   //       'profile_completeness': 3,
//                   //     },
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
//
// class EditLifeStyle extends StatelessWidget {
//   const EditLifeStyle({
//     super.key,
//     required this.customerDetailsModel,
//     this.choicesModel,
//   });
//   final ConstantChoicesModel? choicesModel;
//   final CustomerDetailsModel customerDetailsModel;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocProvider(
//         create:
//             (_) => CreateAccountCubit(
//               sentOtp: const SentOtpEntity(),
//               constChoices: choicesModel,
//             ),
//         child: BlocConsumer<CreateAccountCubit, CreateAccountState>(
//           listener: (context, state) {
//             state.createOrUpdateOnboarding?.fold(
//               () => null,
//               (either) => either.fold(
//                 (error) {
//                   Dialogs.showSnack(msg: error.msg);
//                 },
//                 (success) {
//                   context.read<ProfileCubit>().fetchCustomerDetails();
//                   Navigator.pop(context);
//                   Navigator.pop(context);
//                 },
//               ),
//             );
//           },
//
//           builder: (context, state) {
//             return LifeStyleEditScreen(
//               isLoading: state.isLoading,
//               choicesModel: choicesModel!,
//               customerDetailsModel: customerDetailsModel,
//               onUpdate: (value) {
//                 context.read<CreateAccountCubit>().onboardingUpdate(
//                   id: customerDetailsModel.id,
//                   body: {
//                     'average_working_hours': value.workingHours,
//                     'average_sleep_hours': value.sleepingHours,
//                     'job_satisfaction': value.jobSatisfaction,
//                   },
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:customer_mobile_app/imports_bindings.dart';

class HealthStatusScreen extends StatefulWidget {
  final ConstantChoicesModel choicesModel;
  // final CustomerDetailsModel customerDetailsModel;

  const HealthStatusScreen({
    super.key,
    required this.choicesModel,
    // required this.customerDetailsModel,
  });

  @override
  State<HealthStatusScreen> createState() => _HealthStatusScreenState();
}

class _HealthStatusScreenState extends State<HealthStatusScreen> {
  String? selectedHealthStatus;
  List<dynamic> selectedHealthIssues = [];
  TextEditingController otherCtrl = TextEditingController();
  late final ProfileCubit _cubit;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _cubit = context.read<ProfileCubit>();
  }

  void _setInitialHealthValues(CustomerDetailsModel customer) {
    final isHealthy = customer.isHealthy;

    if (isHealthy == true) {
      selectedHealthStatus = 'healthy';
    } else if (isHealthy == false) {
      selectedHealthStatus = 'not_healthy';
      selectedHealthIssues = customer.healthConditions ?? [];
      otherCtrl.text = customer.healthConditionsOther ?? '';
    } else {
      selectedHealthStatus = 'other';
      otherCtrl.text = customer.healthConditionsOther ?? '';
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listenWhen: (prev, curr) => prev.customerDetails != curr.customerDetails,
      listener: (context, state) {
        final customer = state.customerDetails.fold(
          () => null,
          (either) => either.fold((_) => null, (data) => data),
        );

        if (customer != null && !_initialized) {
          _setInitialHealthValues(customer);
          _initialized = true;
        }
      },
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          final customer = state.customerDetails.fold(
            () => null,
            (either) => either.fold((_) => null, (data) => data),
          );

          if (customer == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }



          int age = 0;
          if (customer.dateOfBirth != null) {
            age = DateTime.now().year - customer.dateOfBirth!.year;
          }

          String healthIssues = 'NO';
          if (customer.healthConditions != null &&
              customer.healthConditions!.isNotEmpty) {
            healthIssues = 'YES';
          } else if (customer.isHealthy == false) {
            healthIssues = 'YES';
          }

          return Scaffold(
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(80), // 👈 Adjust total height (AppBar height + padding)
              child: Padding(
                padding: const EdgeInsets.only(left:10,top: 20,bottom: 10), // 👈 Adjust vertical padding here
                child: AppBar(
                  leading: const PopButton().center,
                  title: const Text('Other Details'),
                  toolbarHeight: 50, // Height of the AppBar content
                ),
              ),
            ),
            body: Padding(
              
              padding: const EdgeInsets.all(16),
              
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Status',
                      style: AppStyles.text18Px.poppins.w600.dark,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildProfileDetailRow('Age', age > 0 ? '$age' : 'N/A'),
                          const SizedBox(height: 16),
                          _buildProfileDetailRow('Height', customer.height ?? 'N/A'),
                          const SizedBox(height: 16),
                          _buildProfileDetailRow('Weight', customer.weight ?? 'N/A'),
                          const SizedBox(height: 16),
                          _buildProfileDetailRow('Blood Group', customer.bloodGroup ?? 'N/A'),
                          const SizedBox(height: 16),
                          _buildProfileDetailRow('Health Issues', healthIssues),
                          const SizedBox(height: 16),
                          _buildProfileDetailRow(
                            'Health Status',
                            customer.isHealthy ?? false ? 'Healthy' : 'Not Healthy',
                          ),
                          const SizedBox(height: 16),
                          _buildProfileDetailRow(
                            'Active Scale',
                            '${customer.activeScale.toString()}/5',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Lifestyle',
                      style: AppStyles.text18Px.poppins.w600.dark,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [

                          _buildProfileDetailRow(
                            'Profession',
                            widget.choicesModel.data.professions
                                .firstWhere(
                                  (element) =>
                                      element.value == customer.profession,
                                  orElse:
                                      () => const Profession(
                                        label: 'N/A',
                                        value: '',
                                      ),
                                )
                                .label,
                          ),
                          const SizedBox(height: 16),
                          buildEmojiRatingRow(
                            label: 'Work Condition',
                            rating: int.tryParse(
                              customer.jobSatisfaction.toString() ?? '',
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildProfileDetailRow(
                            'Working Hour (avg)',
                            widget.choicesModel.data.workingHours
                                .firstWhere(
                                  (element) =>
                                      element.value ==
                                      customer.averageWorkingHours,
                                  orElse:
                                      () => const Profession(
                                        label: '',
                                        value: '',
                                      ),
                                )
                                .label,
                          ),
                          const SizedBox(height: 16),
                          _buildProfileDetailRow(
                            'Sleeping Hour (avg)',
                            widget.choicesModel.data.sleepHours
                                .firstWhere(
                                  (element) =>
                                      element.value ==
                                      customer.averageSleepingHours,
                                  orElse:
                                      () => const Profession(
                                        label: '',
                                        value: '',
                                      ),
                                )
                                .label,
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
            ),
            backgroundColor: AppColors.bgcolorgrey,
          );
        },
      ),
    );
  }



  // ********* FINAL REQUEST FORMAT *********
  Map<String, dynamic> buildFinalRequest() {
    if (selectedHealthStatus == 'healthy') {
      return {'is_healthy': true, 'health_conditions': []};
    }

    if (selectedHealthStatus == 'not_healthy') {
      return {
        'is_healthy': false,
        'health_conditions':
            selectedHealthIssues
                .map((e) => {'id': e.id, 'label': e.label})
                .toList(),
      };
    }

    if (selectedHealthStatus == 'other') {
      return {'is_healthy': null, 'other_condition': otherCtrl.text.trim()};
    }

    return {};
  }

  Widget _buildRow(String label, dynamic value, {bool bullet = false}) {
    var items = <String>[];

    if (!bullet) {
      // Skip bullet formatting, show plain text always
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Text(label, style: AppStyles.text13Px.poppins.w400.dark),
          ),
          Text(': ', style: AppStyles.text14Px.poppins.w500.dark),
          Expanded(
            flex: 2,
            child: Text(
              value?.toString() ?? '-',
              style: AppStyles.text14Px.poppins.w500.dark,
            ),
          ),
        ],
      ).pOnly(bottom: 8);
    }

    // Below is your bullet logic
    if (value == null) {
      items = [];
    } else if (value is String) {
      items =
          value.contains(',')
              ? value.split(',').map((e) => e.trim()).toList()
              : [value];
    } else if (value is List<String>) {
      items = value;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 1,
          child: Text(label, style: AppStyles.text13Px.poppins.w400.dark),
        ),
        Text(': ', style: AppStyles.text14Px.poppins.w500.dark),
        Expanded(
          flex: 2,
          child:
              items.isEmpty
                  ? Text('-', style: AppStyles.text14Px.poppins.w500.dark)
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        items
                            .map(
                              (item) => Row(
                                children: [
                                  const Text('• '),
                                  Expanded(
                                    child: Text(
                                      item,
                                      style:
                                          AppStyles.text14Px.poppins.w500.dark,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
                  ),
        ),
      ],
    ).pOnly(bottom: 8);
  }

  Widget buildEmojiRatingRow({
    required String label,
    required int? rating, // API value: 1–5
  }) {
    final emojiMap = <int, String>{5: '😄', 4: '🙂', 3: '😐', 2: '☹️', 1: '😔'};
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppStyles.text14Px.poppins.w500.copyWith(
            color: Colors.black87,
          ),
        ),
        Row(
          children: List.generate(5, (index) {
            // Note: Generating the emojis according to original reverse map (5 to 1) 
            final value = 5 - index;
            final isSelected = rating == value;

            return Container(
              margin: const EdgeInsets.only(left: 4),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isSelected ? Colors.red.shade50 : Colors.transparent,
                border: Border.all(
                  color:
                      isSelected ? Colors.red : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
                alignment: Alignment.center,
                child: Text(
                  emojiMap[value]!,
                  style: const TextStyle(fontSize: 18),
                ),
              );
            }),
        ),
      ],
    ).pOnly(bottom: 8);
  }
  Widget _buildProfileDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppStyles.text14Px.poppins.w500.copyWith(
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: AppStyles.text14Px.poppins.w600.copyWith(
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class EditHealthStyle extends StatelessWidget {
  const EditHealthStyle({
    super.key,
    required this.customerDetailsModel,

    this.choicesModel,
  });
  final ConstantChoicesModel? choicesModel;
  final CustomerDetailsModel customerDetailsModel;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Style Edit')),

      body: BlocProvider(
        create:
            (_) => CreateAccountCubit(
              sentOtp: const SentOtpEntity(),
              constChoices: choicesModel,
            ),
        child: BlocConsumer<CreateAccountCubit, CreateAccountState>(
          listener: (context, state) {
            state.createOrUpdateOnboarding?.fold(
              () => null,
              (either) => either.fold(
                (error) {
                  Dialogs.showSnack(msg: error.msg);
                },
                (success) {
                  context.read<ProfileCubit>().fetchCustomerDetails();
                  Navigator.pop(context);
                },
              ),
            );
          },

          builder: (context, state) {
            return HealthStep(
              isLoading: state.isLoading ?? false, // 👈 pass loader here
              customerDetailsModel: customerDetailsModel,
              choices: choicesModel,

              onNext: (healthStatus, selectedConditions, rating, conditon) {
                print('Health Status: $healthStatus');
                print('otherConditions: $rating');
                print('Selected Conditions: $selectedConditions');
                print('Activity Rating:$conditon');

                context.read<CreateAccountCubit>().onboardingUpdate(
                  id: customerDetailsModel.id,
                  body:
                      healthStatus ?? false
                          ? {
                            'is_healthy': healthStatus,
                            'active_scale': rating,
                            'profile_completeness': 3,
                            'health_conditions_other': '',
                          }
                          : {
                            'is_healthy': healthStatus,
                            'active_scale': rating,
                            'profile_completeness': 3,
                            'health_conditions': selectedConditions,
                            'health_conditions_other': conditon,
                          },
                );
              },

              onSkip: () {},
            );
          },
        ),
      ),
    );
  }
}

class EditTargetGoals extends StatelessWidget {
  const EditTargetGoals({
    super.key,
    required this.customerDetailsModel,

    this.choicesModel,
  });
  final ConstantChoicesModel? choicesModel;
  final CustomerDetailsModel customerDetailsModel;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Target Goals Edit')),

      body: BlocProvider(
        create:
            (_) => CreateAccountCubit(
              sentOtp: const SentOtpEntity(),
              constChoices: choicesModel,
            ),
        child: BlocConsumer<CreateAccountCubit, CreateAccountState>(
          listener: (context, state) {
            state.createOrUpdateOnboarding?.fold(
              () => null,
              (either) => either.fold(
                (error) {
                  Dialogs.showSnack(msg: error.msg);
                },
                (success) {
                  context.read<ProfileCubit>().fetchCustomerDetails();
                  Navigator.pop(context);
                },
              ),
            );
          },

          builder: (context, state) {
            return FitnessGoalStep(
              isLoading: state.isLoading,
              choices: choicesModel,
              customerDetailsModel: customerDetailsModel,
              onFinish: ({
                required List<String> targetGoal,
                required String targetGoalOther,
              }) {
                print('Goal: $targetGoal');
                print('Goal Other: $targetGoalOther');

                print(targetGoal.contains('Other'));
                print(targetGoal);

                context.read<CreateAccountCubit>().onboardingUpdate(
                  id: customerDetailsModel.id,
                  body: {
                    'target_goal': targetGoal,
                    'target_goal_other': targetGoalOther,
                    'profile_completeness': 3,
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class EditLifeStyle extends StatelessWidget {
  const EditLifeStyle({
    super.key,
    required this.customerDetailsModel,
    this.choicesModel,
  });
  final ConstantChoicesModel? choicesModel;
  final CustomerDetailsModel customerDetailsModel;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create:
            (_) => CreateAccountCubit(
              sentOtp: const SentOtpEntity(),
              constChoices: choicesModel,
            ),
        child: BlocConsumer<CreateAccountCubit, CreateAccountState>(
          listener: (context, state) {
            state.createOrUpdateOnboarding?.fold(
              () => null,
              (either) => either.fold(
                (error) {
                  Dialogs.showSnack(msg: error.msg);
                },
                (success) {
                  context.read<ProfileCubit>().fetchCustomerDetails();
                  Navigator.pop(context);
                },
              ),
            );
          },

          builder: (context, state) {
            return LifeStyleEditScreen(
              isLoading: state.isLoading,
              choicesModel: choicesModel!,
              customerDetailsModel: customerDetailsModel,
              onUpdate: (value) {
                context.read<CreateAccountCubit>().onboardingUpdate(
                  id: customerDetailsModel.id,
                  body: {
                    'average_working_hours': value.workingHours,
                    'average_sleep_hours': value.sleepingHours,
                    'job_satisfaction': value.jobSatisfaction,
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
