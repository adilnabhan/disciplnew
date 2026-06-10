// import 'package:customer_mobile_app/imports_bindings.dart';
//
// class LifeStyleEditScreen extends StatefulWidget {
//   final ConstantChoicesModel choicesModel;
//   final CustomerDetailsModel customerDetailsModel;
//
//   const LifeStyleEditScreen({
//     super.key,
//     required this.choicesModel,
//     required this.customerDetailsModel,
//   });
//
//   @override
//   State<LifeStyleEditScreen> createState() => _LifeStyleEditScreenState();
// }
//
// class _LifeStyleEditScreenState extends State<LifeStyleEditScreen> {
//   late final ProfileCubit _profileCubit;
//   final _formKey = GlobalKey<FormState>();
//
//   late TextEditingController happyCtrl;
//   late TextEditingController workCtrl;
//   late TextEditingController sleepCtrl;
//
//   @override
//   void initState() {
//     super.initState();
//     _profileCubit = context.read<ProfileCubit>();
//     happyCtrl = TextEditingController(
//       text:
//           widget.choicesModel.data.jobSatisfactions
//               .firstWhere(
//                 (element) =>
//                     element.value ==
//                     widget.customerDetailsModel.jobSatisfaction,
//                 orElse: () => const JobSatisfaction(label: '', value: 0),
//               )
//               .label,
//     );
//     workCtrl = TextEditingController(
//       text:
//           widget.choicesModel.data.workingHours
//               .firstWhere(
//                 (element) =>
//                     element.value ==
//                     widget.customerDetailsModel.averageWorkingHours,
//                 orElse: () => const Profession(label: '', value: ''),
//               )
//               .label,
//     );
//     sleepCtrl = TextEditingController(
//       text:
//           widget.choicesModel.data.sleepHours
//               .firstWhere(
//                 (element) =>
//                     element.value ==
//                     widget.customerDetailsModel.averageSleepingHours,
//                 orElse: () => const Profession(label: '', value: ''),
//               )
//               .label,
//     );
//   }
//
//   @override
//   void dispose() {
//     happyCtrl.dispose();
//     workCtrl.dispose();
//     sleepCtrl.dispose();
//     super.dispose();
//   }
//
//   // Convert API data to FieldData-compatible radio items
//   List<({String label, dynamic value})> toRadioItems(List<dynamic>? list) {
//     return list
//             ?.map((e) => (label: e.toString(), value: e.toString()))
//             .toList() ??
//         [];
//   }
//
//   void _onContinue() {
//     if (_formKey.currentState?.validate() ?? false) {
//       debugPrint('Job Satisfaction: ${happyCtrl.text}');
//       debugPrint('Working Hours: ${workCtrl.text}');
//       debugPrint('Sleeping Hours: ${sleepCtrl.text}');
//
//       final jobSatisfactionValue =
//           widget.choicesModel.data.jobSatisfactions
//               .firstWhere(
//                 (e) => e.label == happyCtrl.text,
//                 orElse: () => const JobSatisfaction(label: '', value: 0),
//               )
//               .value;
//
//       final sleepHourValue =
//           widget.choicesModel.data.sleepHours
//               .firstWhere(
//                 (e) => e.label == sleepCtrl.text,
//                 orElse: () => const Profession(label: '', value: ''),
//               )
//               .value;
//
//       final workingHourValue =
//           widget.choicesModel.data.workingHours
//               .firstWhere(
//                 (e) => e.label == workCtrl.text,
//                 orElse: () => const Profession(label: '', value: ''),
//               )
//               .value;
//
//       _profileCubit.detailsUpdate(
//         id: widget.customerDetailsModel.id,
//         body: {
//           'average_working_hours': workingHourValue,
//           'average_sleep_hours': sleepHourValue,
//           'job_satisfaction': jobSatisfactionValue,
//         },
//       );
//
//       // _profileCubit.updateLifeStyle(
//       //   jobSatisfaction: jobSatisfactionValue.toString(),
//       //   sleepingHur: sleepHourValue,
//       //   workingHur: workingHourValue,
//       // );
//     } else {
//       Dialogs.showSnack(msg: 'Please fill all the fields');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final happyItems =
//         (widget.choicesModel.data.jobSatisfactions ?? []).map((e) {
//           return (label: e.label, value: e.value);
//         }).toList();
//     final workHourItems =
//         (widget.choicesModel.data.workingHours ?? []).map((e) {
//           return (label: e.label, value: e.value);
//         }).toList();
//     final sleepHourItems =
//         (widget.choicesModel.data.sleepHours ?? []).map((e) {
//           return (label: e.label, value: e.value);
//         }).toList();
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Edit Lifestyle Details')),
//       body: BlocListener<ProfileCubit, ProfileState>(
//         listener: (context, state) {
//           state.updateProfileDetails?.fold(
//             () => null,
//             (t) => t.fold(
//               (l) => Dialogs.showSnack(msg: l.msg),
//                   (r) {
//                 context.read<ProfileCubit>().fetchCustomerDetails();
//                 Navigator.pop(context);
//               },
//             ),
//           );
//         },
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 Field(
//                   data: FieldData(
//                     type: FieldType.radio,
//                     label: 'How happy are you?',
//                     requiredLabel: true,
//                     controller: happyCtrl,
//                     items: happyItems,
//                     onChanged: (val) {
//                       print('sdfas--$val');
//                       happyCtrl.text = val;
//                       setState(() {});
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Field(
//                   data: FieldData(
//                     type: FieldType.radio,
//                     label: 'Working hours',
//                     requiredLabel: true,
//                     controller: workCtrl,
//                     items: workHourItems,
//
//                     onChanged: (val) {
//                       workCtrl.text = val;
//                       setState(() {});
//                     },
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Field(
//                   data: FieldData(
//                     type: FieldType.radio,
//                     label: 'Sleeping hours',
//                     requiredLabel: true,
//                     controller: sleepCtrl,
//                     items: sleepHourItems,
//                     onChanged: (val) {
//                       sleepCtrl.text = val;
//                       setState(() {});
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//
//       bottomNavigationBar: BlocBuilder<ProfileCubit, ProfileState>(
//         buildWhen: (p, c) => p.updateProfileDetails != c.updateProfileDetails,
//         builder: (context, state) {
//           return Button.filled(
//             title: 'Update',
//             ontap: _onContinue,
//             isLoading: state.updateProfileDetails?.isNone() ?? false,
//           ).pad(16);
//         },
//       ),
//       // bottomNavigationBar: BlocBuilder<CreateAccountCubit, CreateAccountState>(
//       //   buildWhen:
//       //       (p, c) => p.createOrUpdateOnboarding != c.createOrUpdateOnboarding,
//       //   builder: (context, state) {
//       //     return Button.filled(
//       //       title: 'Update',
//       //       // ontap: _onContinue,
//       //       ontap: () {
//       //         context.read<CreateAccountCubit>().onboardingUpdate(
//       //           id: widget.customerDetailsModel.id,
//           body: {
//             'average_working_hours': workCtrl.text,
//             'average_sleep_hours': sleepCtrl.text,
//             'job_satisfaction': happyCtrl.text,
//           },
//         );
//       },
//       //       isLoading: state.createOrUpdateOnboarding?.isNone() ?? false,
//       //     ).pad(16);
//       //   },
//       // ),
//     );
//   }
// }

import 'package:customer_mobile_app/imports_bindings.dart';

class LifeStyleEditScreen extends StatefulWidget {
  final ConstantChoicesModel choicesModel;
  final CustomerDetailsModel customerDetailsModel;
  final bool? isLoading;

  /// 🔥 CALLBACK TO RETURN VALUES
  final ValueChanged<LifeStyleResult> onUpdate;

  const LifeStyleEditScreen({
    super.key,
    required this.choicesModel,
    required this.customerDetailsModel,
    required this.onUpdate,
    this.isLoading = false,
  });

  @override
  State<LifeStyleEditScreen> createState() => _LifeStyleEditScreenState();
}

class _LifeStyleEditScreenState extends State<LifeStyleEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController happyCtrl;
  late TextEditingController workCtrl;
  late TextEditingController sleepCtrl;
  late TextEditingController professionCtrl;

  int? selectedJobSatisfaction;
  String? selectedWorkingHours;
  String? selectedSleepingHours;
  String? selectedProfession;

  @override
  void initState() {
    super.initState();

    selectedJobSatisfaction = widget.customerDetailsModel.jobSatisfaction;
    selectedWorkingHours = widget.customerDetailsModel.averageWorkingHours;
    selectedSleepingHours = widget.customerDetailsModel.averageSleepingHours;
    selectedProfession = widget.customerDetailsModel.profession;
    happyCtrl = TextEditingController(
      text:
          widget.choicesModel.data.jobSatisfactions
              .firstWhere(
                (e) => e.value == selectedJobSatisfaction,
                orElse: () => const JobSatisfaction(label: '', value: 0),
              )
              .label,
    );

    workCtrl = TextEditingController(
      text:
          widget.choicesModel.data.workingHours
              .firstWhere(
                (e) => e.value == selectedWorkingHours,
                orElse: () => const Profession(label: '', value: ''),
              )
              .label,
    );

    sleepCtrl = TextEditingController(
      text:
          widget.choicesModel.data.sleepHours
              .firstWhere(
                (e) => e.value == selectedSleepingHours,
                orElse: () => const Profession(label: '', value: ''),
              )
              .label,
    );
    professionCtrl = TextEditingController(
      text:
          widget.choicesModel.data.professions
              .firstWhere(
                (e) => e.value == selectedSleepingHours,
                orElse: () => const Profession(label: '', value: ''),
              )
              .label,
    );
  }

  @override
  void dispose() {
    happyCtrl.dispose();
    workCtrl.dispose();
    sleepCtrl.dispose();
    professionCtrl.dispose();
    super.dispose();
  }

  void _onUpdatePressed() {
    if (_formKey.currentState?.validate() ?? false) {
      final jobSatisfactionValue =
          widget.choicesModel.data.jobSatisfactions
              .firstWhere(
                (e) => e.label == happyCtrl.text,
                orElse: () => const JobSatisfaction(label: '', value: 0),
              )
              .value;

      final sleepHourValue =
          widget.choicesModel.data.sleepHours
              .firstWhere(
                (e) => e.label == sleepCtrl.text,
                orElse: () => const Profession(label: '', value: ''),
              )
              .value;

      final workingHourValue =
          widget.choicesModel.data.workingHours
              .firstWhere(
                (e) => e.label == workCtrl.text,
                orElse: () => const Profession(label: '', value: ''),
              )
              .value;
      final professionValue =
          widget.choicesModel.data.professions
              .firstWhere(
                (e) => e.label == workCtrl.text,
                orElse: () => const Profession(label: '', value: ''),
              )
              .value;
      widget.onUpdate(
        LifeStyleResult(
          jobSatisfaction: jobSatisfactionValue,
          workingHours: workingHourValue,
          sleepingHours: sleepHourValue,
          professionValue: professionValue
        ),
      );
    } else {
      Dialogs.showSnack(msg: 'Please fill all the fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    final happyItems =
        widget.choicesModel.data.jobSatisfactions
            .map((e) => (label: e.label, value: e.value))
            .toList();

    final workItems =
        widget.choicesModel.data.workingHours
            .map((e) => (label: e.label, value: e.value))
            .toList();

    final sleepItems =
        widget.choicesModel.data.sleepHours
            .map((e) => (label: e.label, value: e.value))
            .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Lifestyle Details')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              /// Job Satisfaction
              Field(
                data: FieldData(
                  type: FieldType.radio,
                  label: 'How happy are you?',
                  requiredLabel: true,
                  controller: happyCtrl,
                  items: happyItems,
                  onChanged: (val) {
                    final item = widget.choicesModel.data.jobSatisfactions
                        .firstWhere((e) => e.label == val);
                    happyCtrl.text = val;
                    selectedJobSatisfaction = item.value;
                  },
                ),
              ),
              const SizedBox(height: 20),

              /// Working Hours
              Field(
                data: FieldData(
                  type: FieldType.radio,
                  label: 'Working hours',
                  requiredLabel: true,
                  controller: workCtrl,
                  items: workItems,
                  onChanged: (val) {
                    final item = widget.choicesModel.data.workingHours
                        .firstWhere((e) => e.label == val);
                    workCtrl.text = val;
                    selectedWorkingHours = item.value;
                  },
                ),
              ),
              const SizedBox(height: 20),

              /// Sleeping Hours
              Field(
                data: FieldData(
                  type: FieldType.radio,
                  label: 'Sleeping hours',
                  requiredLabel: true,
                  controller: sleepCtrl,
                  items: sleepItems,
                  onChanged: (val) {
                    final item = widget.choicesModel.data.sleepHours.firstWhere(
                      (e) => e.label == val,
                    );
                    sleepCtrl.text = val;
                    selectedSleepingHours = item.value;
                  },
                ),
              ),


            ],
          ),
        ),
      ),
      bottomNavigationBar: Button.filled(
        isLoading: widget.isLoading!,
        title: 'Update',
        ontap: _onUpdatePressed,
      ).pad(16),
    );
  }
}

class LifeStyleResult {
  final int jobSatisfaction;
  final String workingHours;
  final String sleepingHours;
  final String professionValue;

  const LifeStyleResult({
    required this.jobSatisfaction,
    required this.workingHours,
    required this.sleepingHours,
    required this.professionValue,
  });
}
