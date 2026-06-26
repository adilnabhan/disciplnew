// import 'package:customer_mobile_app/imports_bindings.dart';
//
// class CreateAccountScreen extends StatelessWidget {
//   const CreateAccountScreen({required this.sentOtpEntity, super.key});
//
//   final SentOtpEntity sentOtpEntity;
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => CreateAccountCubit(sentOtp: sentOtpEntity),
//       child: const _CreateAccountScreen(),
//     );
//   }
// }
//
// class _CreateAccountScreen extends StatefulWidget {
//   const _CreateAccountScreen();
//
//   @override
//   State<_CreateAccountScreen> createState() => __CreateAccountScreenState();
// }
//
// class __CreateAccountScreenState extends State<_CreateAccountScreen> {
//   late final List<FieldData<dynamic>> _personalDetails;
//   late final List<FieldData<dynamic>> _healthDetails;
//   bool _isHealthDetailsPickingState = false;
//   final _formKey = GlobalKey<FormState>();
//
//   @override
//   void initState() {
//     _personalDetails = [
//       FieldData(
//         type: FieldType.word,
//         textInputAction: TextInputAction.next,
//         label: 'First Name',
//         requiredLabel: true,
//         validator: (value) {
//           if (value?.trim().isEmpty ?? true) {
//             return 'First name is required';
//           }
//           return null;
//         },
//         onSubmitted: (value) {
//           _personalDetails[1].focusNode?.requestFocus();
//         },
//         controller: TextEditingController(),
//         focusNode: FocusNode(),
//         keyboardType: TextInputType.name,
//         decoration: InputDecoration(
//           hintText: 'Enter First Name',
//           hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
//           border: const OutlineInputBorder(
//             borderRadius: BorderRadius.all(Radius.circular(8)),
//             borderSide: BorderSide(color: AppColors.borderGrey),
//           ),
//         ),
//       ),
//       FieldData(
//         type: FieldType.word,
//         textInputAction: TextInputAction.next,
//         label: 'Last Name',
//         requiredLabel: true,
//         validator: (value) {
//           if (value?.trim().isEmpty ?? true) {
//             return 'Last name is required';
//           }
//           return null;
//         },
//         onSubmitted: (value) {
//           _personalDetails[2].focusNode?.requestFocus();
//         },
//         controller: TextEditingController(),
//         focusNode: FocusNode(),
//         keyboardType: TextInputType.name,
//         decoration: InputDecoration(
//           hintText: 'Enter Last Name',
//           hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
//           border: const OutlineInputBorder(
//             borderRadius: BorderRadius.all(Radius.circular(8)),
//             borderSide: BorderSide(color: AppColors.borderGrey),
//           ),
//         ),
//       ),
//       FieldData(
//         type: FieldType.word,
//         textInputAction: TextInputAction.done,
//         label: 'Email Address',
//         requiredLabel: true,
//         controller: TextEditingController(),
//         focusNode: FocusNode(),
//         validator: (value) {
//           if (value?.isNotEmpty ?? false) {
//             if (!RegExp(
//               r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
//             ).hasMatch(value!)) {
//               return 'Invalid email address!';
//             }
//           }
//           return null;
//         },
//         onSubmitted: (value) {
//           _personalDetails[3].focusNode?.requestFocus();
//         },
//         keyboardType: TextInputType.emailAddress,
//         decoration: InputDecoration(
//           hintText: 'Enter your email address',
//           hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
//           border: const OutlineInputBorder(
//             borderRadius: BorderRadius.all(Radius.circular(8)),
//             borderSide: BorderSide(color: AppColors.borderGrey),
//           ),
//         ),
//       ),
//       FieldData(
//         type: FieldType.radio,
//         textInputAction: TextInputAction.done,
//         label: 'Gender',
//         requiredLabel: true,
//         controller: TextEditingController(),
//         focusNode: FocusNode(),
//         items: [
//           (label: 'Male', value: 'male'),
//           (label: 'Female', value: 'female'),
//           (label: 'Other', value: 'other'),
//         ],
//         validator: (value) {
//           if (value?.isEmpty ?? true) {
//             return 'Geneder must be selected';
//           }
//           return null;
//         },
//         onValueChanged: (p0) {
//           _personalDetails[4].requestToFocus();
//         },
//         onSubmitted: (value) {
//           _personalDetails[4].requestToFocus();
//         },
//         decoration: InputDecoration(
//           hintText: 'Select Gender',
//           hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
//           border: const OutlineInputBorder(
//             borderRadius: BorderRadius.all(Radius.circular(8)),
//             borderSide: BorderSide(color: AppColors.borderGrey),
//           ),
//         ),
//       ),
//       FieldData(
//         type: FieldType.date,
//         textInputAction: TextInputAction.done,
//         label: 'Date of Birth',
//         dateTimeShowFormat: DateFormat('dd MMM yyyy'),
//         endTime: DateTime.now(),
//         requiredLabel: true,
//         controller: TextEditingController(),
//         focusNode: FocusNode(),
//         validator: (value) {
//           if (value?.isEmpty ?? true) {
//             return 'Date of Birth must be selected';
//           }
//           return null;
//         },
//         onChanged: (p0) {
//           _personalDetails[5].focusNode?.requestFocus();
//         },
//         decoration: InputDecoration(
//           hintText: 'Select Date of Birth',
//           hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
//           border: const OutlineInputBorder(
//             borderRadius: BorderRadius.all(Radius.circular(8)),
//             borderSide: BorderSide(color: AppColors.borderGrey),
//           ),
//         ),
//       ),
//       FieldData(
//         type: FieldType.word,
//         textInputAction: TextInputAction.done,
//         label: 'Emergency Contact',
//         requiredLabel: true,
//         controller: TextEditingController(),
//         focusNode: FocusNode(),
//         keyboardType: TextInputType.phone,
//         maxLength: 10,
//         inputFormatters: [
//           FilteringTextInputFormatter.digitsOnly,
//           LengthLimitingTextInputFormatter(10),
//         ],
//         validator: (value) {
//           if (value?.isEmpty ?? true) {
//             return 'Emergency Contact is required';
//           }
//           return null;
//         },
//         onSubmitted: (value) {
//           _personalDetails[6].focusNode?.requestFocus();
//         },
//         decoration: InputDecoration(
//           hintText: 'Enter Mobile Number',
//           hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
//           border: const OutlineInputBorder(
//             borderRadius: BorderRadius.all(Radius.circular(8)),
//             borderSide: BorderSide(color: AppColors.borderGrey),
//           ),
//         ),
//       ),
//       FieldData(
//         type: FieldType.word,
//         textInputAction: TextInputAction.next,
//         label: 'Profession',
//         requiredLabel: true,
//         validator: (value) {
//           if (value?.trim().isEmpty ?? true) {
//             return 'Profession is required';
//           }
//           return null;
//         },
//         onSubmitted: (value) {
//           _personalDetails[6].focusNode?.unfocus();
//           _onContinue();
//         },
//         controller: TextEditingController(),
//         focusNode: FocusNode(),
//         keyboardType: TextInputType.name,
//         decoration: InputDecoration(
//           hintText: 'Enter Profession',
//           hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
//           border: const OutlineInputBorder(
//             borderRadius: BorderRadius.all(Radius.circular(8)),
//             borderSide: BorderSide(color: AppColors.borderGrey),
//           ),
//         ),
//       ),
//     ];
//     _healthDetails = [
//       FieldData(
//         type: FieldType.radio,
//         textInputAction: TextInputAction.done,
//         label: 'Blood Group',
//         requiredLabel: true,
//         controller: TextEditingController(),
//         focusNode: FocusNode(),
//         items: [
//           (label: 'A+', value: 'A+'),
//           (label: 'A-', value: 'A-'),
//           (label: 'B+', value: 'B+'),
//           (label: 'B-', value: 'B-'),
//           (label: 'AB+', value: 'AB+'),
//           (label: 'AB-', value: 'AB-'),
//           (label: 'O+', value: 'O+'),
//           (label: 'O-', value: 'O-'),
//         ],
//         validator: (value) {
//           if (value?.isEmpty ?? true) {
//             return 'Blood Group must be selected';
//           }
//           return null;
//         },
//         onValueChanged: (p0) {
//           _healthDetails[1].focusNode?.requestFocus();
//         },
//         onSubmitted: (value) {
//           _healthDetails[1].focusNode?.requestFocus();
//         },
//         decoration: InputDecoration(
//           hintText: 'Select Blood Group',
//           hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
//           border: const OutlineInputBorder(
//             borderRadius: BorderRadius.all(Radius.circular(8)),
//             borderSide: BorderSide(color: AppColors.borderGrey),
//           ),
//         ),
//       ),
//       FieldData(
//         type: FieldType.word,
//         textInputAction: TextInputAction.done,
//         label: 'Height',
//         requiredLabel: true,
//         controller: TextEditingController(),
//         focusNode: FocusNode(),
//         keyboardType: TextInputType.number,
//         maxLength: 3,
//         inputFormatters: [
//           FilteringTextInputFormatter.digitsOnly,
//           LengthLimitingTextInputFormatter(3),
//         ],
//         validator: (value) {
//           if (value?.isEmpty ?? true) {
//             return 'Height is required';
//           }
//           return null;
//         },
//         onSubmitted: (value) {
//           _healthDetails[2].focusNode?.requestFocus();
//         },
//         decoration: InputDecoration(
//           hintText: '0',
//           hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
//           suffixIcon: SizedBox.square(
//             dimension: 22,
//             child: Center(
//               child: Text('CM', style: AppStyles.text14Px.poppins.w400.dark),
//             ),
//           ),
//           border: const OutlineInputBorder(
//             borderRadius: BorderRadius.all(Radius.circular(8)),
//             borderSide: BorderSide(color: AppColors.borderGrey),
//           ),
//         ),
//       ),
//       FieldData(
//         type: FieldType.word,
//         textInputAction: TextInputAction.done,
//         label: 'Weight',
//         requiredLabel: true,
//         controller: TextEditingController(),
//         focusNode: FocusNode(),
//         keyboardType: TextInputType.number,
//         maxLength: 3,
//         inputFormatters: [
//           FilteringTextInputFormatter.digitsOnly,
//           LengthLimitingTextInputFormatter(3),
//         ],
//         validator: (value) {
//           if (value?.isEmpty ?? true) {
//             return 'Weight is required';
//           }
//           return null;
//         },
//         onSubmitted: (value) {
//           _healthDetails[2].focusNode?.unfocus();
//         },
//         decoration: InputDecoration(
//           hintText: '0',
//           hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
//           suffixIcon: SizedBox.square(
//             dimension: 22,
//             child: Center(
//               child: Text('KG', style: AppStyles.text14Px.poppins.w400.dark),
//             ),
//           ),
//           border: const OutlineInputBorder(
//             borderRadius: BorderRadius.all(Radius.circular(8)),
//             borderSide: BorderSide(color: AppColors.borderGrey),
//           ),
//         ),
//       ),
//     ];
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       FocusScope.of(context).requestFocus(_personalDetails[0].focusNode);
//     });
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     for (final element in _personalDetails) {
//       element.controller?.dispose();
//       element.focusNode?.dispose();
//     }
//   }
//
//   void _changeHealthDetailsPickingState(bool value) {
//     setState(() {
//       _isHealthDetailsPickingState = value;
//     });
//   }
//
//   void _onContinue() {
//     if (_isHealthDetailsPickingState) {
//       _onHealthDetailsContinue();
//     } else {
//       _onPersonalDetailsContinue();
//     }
//   }
//
//   void _onPersonalDetailsContinue() {
//     if (_formKey.currentState?.validate() ?? false) {
//       _changeHealthDetailsPickingState(true);
//     } else {
//       Dialogs.showSnack(msg: 'Please fill all the fields');
//     }
//   }
//
//   void _onHealthDetailsContinue() {
//     if (_formKey.currentState?.validate() ?? false) {
//       /// Personal Details
//       final firstName = _personalDetails[0].controller?.text;
//       final lastName = _personalDetails[1].controller?.text;
//       final email = _personalDetails[2].controller?.text;
//       final gender = _personalDetails[3].controller?.text;
//       final dob = _personalDetails[4].selectedDateTime;
//       final emergencyContact = _personalDetails[5].controller?.text;
//       final profession = _personalDetails[6].controller?.text;
//
//       /// Health Details
//       final bloodGroup = _healthDetails[0].controller?.text;
//       final height = _healthDetails[1].controller?.text;
//       final weight = _healthDetails[2].controller?.text;
//       context.read<CreateAccountCubit>().onboardUser(
//         firstName: firstName ?? '',
//         lastName: lastName ?? '',
//         email: email ?? '',
//         dateOfBirth: dob!,
//         gender: gender!.toLowerCase(),
//         emergencyContactNumber: emergencyContact!,
//         profession: profession!,
//         bloodGroup: bloodGroup!,
//         height: height!,
//         weight: weight!,
//       );
//     } else {
//       Dialogs.showSnack(msg: 'Please fill all the fields');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<CreateAccountCubit, CreateAccountState>(
//       listener: (context, state) {
//         state.onboardingUser?.fold(
//           () => null,
//           (t) => t.fold(
//             (l) {
//               Dialogs.showSnack(msg: l.msg);
//             },
//             (r) {
//               context.read<AppCubit>().addUser(r);
//               context.push(const DashboardScreen());
//             },
//           ),
//         );
//       },
//       child: Scaffold(
//         appBar: AppBar(leading: const PopButton().center),
//         body: Form(
//           key: _formKey,
//           child: ListView(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             children: [
//               const SizedBox(height: 22),
//               Text(
//                 'Register Account',
//                 style: AppStyles.text22Px.poppins.w600.dark,
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 32),
//               ListView.separated(
//                 itemCount:
//                     _isHealthDetailsPickingState
//                         ? _healthDetails.length
//                         : _personalDetails.length,
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 separatorBuilder: (BuildContext context, int index) {
//                   return const SizedBox(height: 22);
//                 },
//                 itemBuilder: (BuildContext context, int index) {
//                   return Field(
//                     data:
//                         _isHealthDetailsPickingState
//                             ? _healthDetails[index]
//                             : _personalDetails[index],
//                   );
//                 },
//               ),
//               const SizedBox(height: 32),
//             ],
//           ),
//         ),
//         bottomNavigationBar:
//             BlocBuilder<CreateAccountCubit, CreateAccountState>(
//               buildWhen: (p, c) {
//                 return p.onboardingUser != c.onboardingUser;
//               },
//               builder: (context, state) {
//                 return Button.filled(
//                   title: _isHealthDetailsPickingState ? 'Register' : 'Continue',
//                   ontap: _onContinue,
//                   isLoading: state.onboardingUser?.isNone() ?? false,
//                 ).pad(16);
//               },
//             ),
//       ),
//     );
//   }
// }

import 'package:customer_mobile_app/imports_bindings.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({
    required this.sentOtpEntity,
    super.key,
    this.choicesModel,
    this.loginSuccessModel,
    this.loginData,
  });
  final SentOtpEntity sentOtpEntity;
  final ConstantChoicesModel? choicesModel;
  final LoginSuccessModel? loginSuccessModel;
  final Option<Either<ApiException, LoginSuccessModel>>? loginData;
  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  late final PageController _pageController;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.loginSuccessModel?.customer?.profileCompleteness ?? 0;
    _pageController = PageController(
      initialPage: currentPage(
        step: widget.loginSuccessModel?.customer?.profileCompleteness,
      ),
    );
  }

  // Data variables (you can later move to Cubit)
  String firstName = '';
  String lastName = '';
  String email = '';
  String mobile = '';
  String profession = '';
  String bloodGroup = '';
  String height = '';
  String weight = '';
  String goal = 'Build muscles';
  bool isHealthy = true;

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // void onboarding({
  //   required String firstName,
  //   required String lastName,
  //   required String email,
  // }) {
  //   context.read<CreateAccountCubit>().onboardUser(
  //     firstName: firstName,
  //     lastName: lastName,
  //     email: email,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => CreateAccountCubit(
            sentOtp: widget.sentOtpEntity,
            constChoices: widget.choicesModel,
            loginSuccessModel: widget.loginData,
          ),
      child: BlocListener<CreateAccountCubit, CreateAccountState>(
        listener: (context, state) {
          // state.onboardingUser?.fold(
          //   () => null,
          //   (either) => either.fold(
          //     (error) => Dialogs.showSnack(msg: error.msg),
          //     (success) => context.push(const DashboardScreen()),
          //   ),
          // );
          state.createOrUpdateOnboarding?.fold(
            () => null,
            (either) => either.fold(
              (error) {
                Dialogs.showSnack(msg: error.msg);
              },
              (success) {
                _nextStep();

                if (_currentStep == 3) {
                  LoginSuccessModel? login;
                  state.onboardingUser?.fold(
                    () {},
                    (either) => either.fold(
                      (l) => null, // ApiException
                      (r) => login = r, // Success model
                    ),
                  );
                  final finalUser = login ?? widget.loginSuccessModel;
                  if (finalUser != null) {
                    context.read<AppCubit>().addUser(finalUser);
                  }
                }
              },
            ),
          );
        },
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            if (_currentStep > 0) {
              _previousStep();
            } else {
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () {
                  if (_currentStep > 0) {
                    _previousStep();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          body: Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              image: _currentStep == 4 ? null : _getStepImage(_currentStep),
            ),
            child: Column(
              children: [
                _ProgressIndicator(currentStep: _currentStep),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      BlocBuilder<CreateAccountCubit, CreateAccountState>(
                        buildWhen:
                            (previous, current) =>
                                previous.isLoading != current.isLoading,
                        builder: (context, state) {
                          return FitnessPassportStep(
                            isLoading: state.isLoading,
                            sentOtpEntity: widget.sentOtpEntity,
                            onNext: (fName, lName, mail, phone, image) {
                              context.read<CreateAccountCubit>().onboardUser(
                                firstName: fName,
                                lastName: lName,
                                email: mail,
                                image: image,
                              );
                            },
                          );
                        },
                      ),

                      BlocBuilder<CreateAccountCubit, CreateAccountState>(
                        buildWhen:
                            (previous, current) =>
                                previous.isLoading != current.isLoading,
                        builder: (context, state) {
                          return LifestyleStep(
                            isLoading: state.isLoading,
                            choices: widget.choicesModel,
                            sentOtpEntity: widget.sentOtpEntity,
                            onNext: ({
                              required profession,
                              required workingHours,
                              required sleepHours,
                              required jobSatisfaction,
                              required other,
                            }) {
                              print('Profession: $profession');
                              print('Working Hours: $workingHours');
                              print('Sleep Hours: $sleepHours');
                              print('Sleep Hours: $jobSatisfaction');
                              int? id;
                              // if (widget.loginSuccessModel?.id == null) {
                              //   LoginSuccessModel? login;
                              //   state.onboardingUser?.fold(
                              //     () {},
                              //     (either) => either.fold(
                              //       (l) => null, // ApiException
                              //       (r) => login = r, // Success model
                              //     ),
                              //   );
                              //   print('id iss--${login!.id}');
                              //   id = login!.customer?.id;
                              // } else {
                              //   print(
                              //     'Other: $other---${widget.loginSuccessModel?.id}',
                              //   );
                              //   id = widget.loginSuccessModel?.customer?.id;
                              // }

                              LoginSuccessModel? login;
                              state.onboardingUser?.fold(
                                () {},
                                (either) => either.fold(
                                  (l) => null, // ApiException
                                  (r) => login = r, // Success model
                                ),
                              );
                              // Fallback to loginSuccessModel if state onboardingUser is empty
                              id = login?.customer?.id ?? widget.loginSuccessModel?.customer?.id;
                              print('id iss--${id}');

                              if (id != null) {
                                context
                                    .read<CreateAccountCubit>()
                                    .onboardingUpdate(
                                      id: id,
                                      body:
                                          profession == 'Other'
                                              ? {
                                                'other_profession': other,
                                                'job_satisfaction':
                                                    jobSatisfaction,
                                                'average_working_hours':
                                                    workingHours,
                                                'average_sleep_hours':
                                                    sleepHours,
                                                'profile_completeness': 1,
                                              }
                                              : {
                                                'profession': profession,
                                                'job_satisfaction':
                                                    jobSatisfaction,
                                                'average_working_hours':
                                                    workingHours,
                                                'average_sleep_hours':
                                                    sleepHours,
                                                'profile_completeness': 1,
                                              },
                                    );
                              } else {
                                // If still no ID, just advance to next step
                                _nextStep();
                              }
                              // _nextStep();
                            },
                            onSkip: _nextStep,
                          );
                        },
                      ),

                      BlocBuilder<CreateAccountCubit, CreateAccountState>(
                        buildWhen:
                            (previous, current) =>
                                previous.isLoading != current.isLoading,
                        builder: (context, state) {
                          return HealthStep(
                            isLoading: state.isLoading,
                            choices: widget.choicesModel,
                            sentOtpEntity: widget.sentOtpEntity,
                            onNext: (
                              healthStatus,
                              selectedConditions,
                              rating,
                              otherConditions,
                            ) {
                              print('Health Status: $healthStatus');
                              print('otherConditions: $otherConditions');
                              print('Selected Conditions: $selectedConditions');
                              print(
                                'Activity Rating: $rating--${widget.loginSuccessModel?.customer?.id}',
                              );
                              int? id;
                              LoginSuccessModel? login;
                              state.onboardingUser?.fold(
                                () {},
                                (either) => either.fold(
                                  (l) => null, // ApiException
                                  (r) => login = r, // Success model
                                ),
                              );
                              // Fallback to loginSuccessModel if state onboardingUser is empty
                              id = login?.customer?.id ?? widget.loginSuccessModel?.customer?.id;
                              if (id != null) {
                                context
                                    .read<CreateAccountCubit>()
                                    .onboardingUpdate(
                                      id: id,
                                      body:
                                          healthStatus ?? false
                                              ? {
                                                'is_healthy': healthStatus,
                                                'active_scale': rating,
                                                'profile_completeness': 2,
                                              }
                                              : {
                                                'is_healthy': healthStatus,
                                                'active_scale': rating,
                                                'profile_completeness': 2,
                                                'health_conditions':
                                                    selectedConditions,
                                                'health_conditions_other':
                                                    otherConditions,
                                              },
                                    );
                              } else {
                                // If still no ID, just advance to next step
                                _nextStep();
                              }
                            },
                            onSkip: () {
                              print('Skipped health step');
                              _nextStep();
                            },
                          );
                        },
                      ),

                      BlocBuilder<CreateAccountCubit, CreateAccountState>(
                        buildWhen:
                            (previous, current) =>
                                previous.isLoading != current.isLoading,
                        builder: (context, state) {
                          return FitnessGoalStep(
                            isLoading: state.isLoading,
                            choices: widget.choicesModel,
                            sentOtpEntity: widget.sentOtpEntity,
                            onFinish: ({
                              required List<String> targetGoal,
                              required String targetGoalOther,
                            }) {
                              print('Goal: $targetGoal');
                              print('Goal Other: $targetGoalOther');
                              int? id;
                              LoginSuccessModel? login;
                              state.onboardingUser?.fold(
                                () {},
                                (either) => either.fold(
                                  (l) => null, // ApiException
                                  (r) => login = r, // Success model
                                ),
                              );

                              print(targetGoal.contains('Other'));
                              print(targetGoal);

                              id = login?.customer?.id ?? widget.loginSuccessModel?.customer?.id;
                              if (id != null) {
                                context
                                    .read<CreateAccountCubit>()
                                    .onboardingUpdate(
                                      id: id,
                                      body: {
                                        'target_goal': targetGoal,
                                        'target_goal_other': targetGoalOther,
                                        'profile_completeness': 3,
                                      },
                                    );
                              } else {
                                _nextStep();
                              }
                            },
                          );
                        },
                      ),

                      // BlocBuilder<CreateAccountCubit, CreateAccountState>(
                      //   buildWhen:
                      //       (previous, current) =>
                      //           previous.isLoading != current.isLoading,
                      //   builder: (context, state) {
                      //     return FitnessGoalStep(
                      //       isLoading: state.isLoading,
                      //       choices: widget.choicesModel,
                      //       sentOtpEntity: widget.sentOtpEntity,
                      //       onFinish: ({
                      //         required String targetGoal,
                      //         required String targetGoalOther,
                      //       }) {
                      //         print('Goal: $targetGoal');
                      //         print('Goal Other: $targetGoalOther');
                      //         int? id;
                      //         LoginSuccessModel? login;
                      //         state.onboardingUser?.fold(
                      //           () {},
                      //           (either) => either.fold(
                      //             (l) => null, // ApiException
                      //             (r) => login = r, // Success model
                      //           ),
                      //         );
                      //         id = login?.customer?.id;
                      //         if (id != null) {
                      //           context
                      //               .read<CreateAccountCubit>()
                      //               .onboardingUpdate(
                      //                 id: id,
                      //                 body:
                      //                     targetGoal == 'Other'
                      //                         ? {
                      //                           'target_goal': targetGoal,
                      //                           'target_goal_other':
                      //                               targetGoalOther,
                      //                           'profile_completeness': 3,
                      //                         }
                      //                         : {
                      //                           'target_goal': targetGoal,
                      //                           'profile_completeness': 3,
                      //                         },
                      //               );
                      //         }
                      //       },
                      //     );
                      //   },
                      // ),
                      BlocBuilder<CreateAccountCubit, CreateAccountState>(
                        buildWhen:
                            (previous, current) =>
                                previous.isLoading != current.isLoading,
                        builder: (context, state) {
                          LoginSuccessModel? login;
                          state.onboardingUser?.fold(
                            () {},
                            (either) => either.fold(
                              (l) => null, // ApiException
                              (r) => login = r, // Success model
                            ),
                          );

                          return SetupCompleteStep(login: login);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  final int currentStep;
  const _ProgressIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          final isActive = index <= currentStep;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 55,
            height: 4,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.borderGrey,
              borderRadius: BorderRadius.circular(4),
            ),
          );
        }),
      ),
    );
  }
}

DecorationImage? _getStepImage(int step) {
  switch (step) {
    case 0:
      return const DecorationImage(
        image: AssetImage('assets/images/png/vectors/fitnessPassport.png'),
        // fit: BoxFit.cover,
      );
    case 1:
      return const DecorationImage(
        image: AssetImage('assets/images/png/vectors/step2.png'),
        // fit: BoxFit.cover,
      );
    case 2:
      return const DecorationImage(
        image: AssetImage('assets/images/png/vectors/step3.png'),
        // fit: BoxFit.cover,
      );
    case 3:
      return const DecorationImage(
        image: AssetImage('assets/images/png/vectors/step4.png'),
        // fit: BoxFit.cover,
      );
    case 4:
    default:
      return null;
  }
}

int currentPage({int? step}) {
  switch (step) {
    case 0:
      return 1;
    case 1:
      return 2;
    case 2:
      return 3;
    case 3:
      return 4;
    default:
      return 0;
  }
}
