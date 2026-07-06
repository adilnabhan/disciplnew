import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = ProfileCubit();
    final bool isCustomer = Feggy.read<AppCubit>()?.state.currentUser != null;

    if (isCustomer) {
      _fetch();
    }
  }

  Future<void> _fetch() async {
    await _cubit.fetchCustomerDetails();
    await _cubit.fetchConstChoices();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppCubit, AppState>(
      listenWhen: (previous, current) {
        return previous.currentUser?.access != current.currentUser?.access;
      },
      listener: (context, appState) {
        if (appState.currentUser != null) {
          _fetch();
        }
      },
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, appState) {
          final bool isCustomer =
              Feggy.read<AppCubit>()?.state.currentUser != null;
        return BlocProvider.value(
          value: _cubit,
          child: Scaffold(
            backgroundColor: AppColors.bgcolorgrey,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              centerTitle: false,
              title: Text('Profile', style: AppStyles.text20Px.poppins.w500),
              actions: [
                GestureDetector(
                  onTap: () {
                    context.push(const SettingsScreen());
                  },
                  child: SvgPicture.asset(
                    'assets/images/svg/icons/settings _icon.svg',
                    width: 22,
                    height: 22,
                  ),
                ).pOnly(right: 20),
              ],
            ),
            body:
                !isCustomer
                    ? _GuestProfileView(
                      onLoginTap: () {
                        context.push(const SentOtpScreen());
                      },
                    )
                    : BlocBuilder<ProfileCubit, ProfileState>(
                      builder: (context, state) {
                        ConstantChoicesModel? choicesModel;
                        state.constChoice?.fold(
                          () {},
                          (either) => either.fold(
                            (l) => null, // ApiException
                            (r) => choicesModel = r, // Success model
                          ),
                        );
                        return state.customerDetails.fold(
                          () =>
                              const Center(child: CircularProgressIndicator()),
                          (either) {
                            return either.fold(
                              (error) =>
                                  error
                                      .maybeWhen(
                                        network:
                                            (e) =>
                                                ErrorUi.network(onTap: _fetch),
                                        notFound:
                                            (e) =>
                                                ErrorUi.notFound(onTap: _fetch),
                                        orElse:
                                            () => ErrorUi.server(onTap: _fetch),
                                      )
                                      .center,
                              (customerDetails) {
                                return RefreshIndicator(
                                  onRefresh: _fetch,
                                  child: ListView(
                                    padding: const EdgeInsets.all(16),
                                    children: [
                                      Container(
                                        width: 320,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.light,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap:
                                                  () => context.push(
                                                    BlocProvider.value(
                                                      value: _cubit,
                                                      child:
                                                          ProfileDetailsScreen(
                                                            customerDetailsModel:
                                                                customerDetails,
                                                          ),
                                                    ),
                                                  ),
                                              child: AbsorbPointer(
                                                child: ProfileImage(
                                                  isEdit: false,
                                                  onChanged: (image) {},
                                                  radius: 110,
                                                  url:
                                                      '${customerDetails.profilePicture}',
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.all(8),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      customerDetails
                                                              .firstName ??
                                                          '',
                                                      style:
                                                          AppStyles
                                                              .text16Px
                                                              .poppins
                                                              .w600,
                                                    ),
                                                    SizedBox(height: 8),
                                                    if (customerDetails
                                                            .mobileNumber !=
                                                        null)
                                                      Text(
                                                        customerDetails
                                                            .mobileNumber!,
                                                        style: AppStyles
                                                            .text14Px
                                                            .poppins
                                                            .w600
                                                            .copyWith(
                                                              color:
                                                                  AppColors
                                                                      .textGrey,
                                                            ),
                                                      ),
                                                    Text(
                                                      customerDetails.email ??
                                                          '',
                                                      style: AppStyles
                                                          .text14Px
                                                          .poppins
                                                          .w600
                                                          .copyWith(
                                                            color:
                                                                AppColors
                                                                    .textGrey,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 14),
                                                    Row(
                                                      children: [
                                                        if (customerDetails
                                                                .gender !=
                                                            null)
                                                          Container(
                                                            padding:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 4,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  AppColors
                                                                      .iconBackground,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    16,
                                                                  ),
                                                            ),
                                                            child: Text(
                                                              customerDetails
                                                                  .gender!,
                                                              style: AppStyles
                                                                  .text13Px
                                                                  .poppins
                                                                  .w500
                                                                  .copyWith(
                                                                    color:
                                                                        AppColors
                                                                            .textDark,
                                                                  ),
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      if (customerDetails.targetGoal != null &&
                                          customerDetails
                                              .targetGoal!
                                              .isNotEmpty) ...[
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children:
                                              customerDetails.targetGoal!
                                                  .map(
                                                    (goal) => Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 12,
                                                            vertical: 6,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .lightPrimary
                                                            .withValues(
                                                              alpha: .2,
                                                            ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              16,
                                                            ),
                                                        border: Border.all(
                                                          color:
                                                              AppColors
                                                                  .lightPrimary,
                                                        ),
                                                      ),
                                                      child: Text(
                                                        goal
                                                            .split('_')
                                                            .map(
                                                              (e) =>
                                                                  e.isNotEmpty
                                                                      ? '${e[0].toUpperCase()}${e.substring(1).toLowerCase()}'
                                                                      : '',
                                                            )
                                                            .join(' '),
                                                        style: AppStyles
                                                            .text12Px
                                                            .poppins
                                                            .w500
                                                            .copyWith(
                                                              color:
                                                                  AppColors
                                                                      .primary,
                                                            ),
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                        ),
                                        const SizedBox(height: 16),
                                      ],
                                      () {
                                        Membership? activeMembership;
                                        if (customerDetails.memberships != null &&
                                            customerDetails.memberships!.isNotEmpty) {
                                          for (final m in customerDetails.memberships!) {
                                            if (m.isActive == true ||
                                                m.status?.toLowerCase() == 'active') {
                                              activeMembership = m;
                                              break;
                                            }
                                          }
                                          activeMembership ??=
                                              customerDetails.memberships!.first;
                                        }
                                        return _buildMembershipCard(activeMembership);
                                      }(),
                                      _buildOtherDetailsSection(
                                        customerDetails,
                                        choicesModel,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
          ),
        );
        },
      ),
    );
  }

  Widget _buildProfileListItem(String label, VoidCallback onTap) {
    return Column(
      children: [
        _ProfileListItem(label: label, onTap: onTap),
        const Divider(
          height: 1,
          thickness: 1,
          color: AppColors.grey, // Light grey color for the divider
        ),
      ],
    );
  }

  Widget _buildOtherDetailsSection(
    CustomerDetailsModel customerDetails,
    ConstantChoicesModel? choicesModel,
  ) {
    int age = 0;
    if (customerDetails.dateOfBirth != null) {
      age = DateTime.now().year - customerDetails.dateOfBirth!.year;
    }

    String healthIssues = 'NO';
    if (customerDetails.healthConditions != null &&
        customerDetails.healthConditions!.isNotEmpty) {
      healthIssues = 'YES';
    } else if (customerDetails.isHealthy == false) {
      healthIssues = 'YES';
    }

    // BMI and BMR Calculation
    double? bmi;
    double? bmr;
    String bmiCategory = '';
    
    final heightVal = double.tryParse(customerDetails.height ?? '');
    final weightVal = double.tryParse(customerDetails.weight ?? '');
    
    if (heightVal != null && weightVal != null && heightVal > 0) {
      final heightInMeters = heightVal / 100;
      bmi = weightVal / (heightInMeters * heightInMeters);
      
      if (bmi < 18.5) {
        bmiCategory = ' (Underweight)';
      } else if (bmi < 25.0) {
        bmiCategory = ' (Normal)';
      } else if (bmi < 30.0) {
        bmiCategory = ' (Overweight)';
      } else {
        bmiCategory = ' (Obese)';
      }

      // BMR Calculation (Revised Harris-Benedict Equation)
      final gender = customerDetails.gender?.toString().toLowerCase() ?? 'male';
      if (age > 0) {
        if (gender.startsWith('f')) {
          bmr = 447.593 + (9.247 * weightVal) + (3.098 * heightVal) - (4.330 * age);
        } else {
          bmr = 88.362 + (13.397 * weightVal) + (4.799 * heightVal) - (5.677 * age);
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Assigned Gym & Trainer section ──
        if (customerDetails.assignedFitnessCenter != null || customerDetails.assignedTrainer != null) ...[
          const SizedBox(height: 12),
          Text(
            'Assigned Gym ',
            style: AppStyles.text16Px.poppins.w600.copyWith(
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (customerDetails.assignedFitnessCenter != null) ...[
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.iconBackground,
                        ),
                        child: ClipOval(
                          child: customerDetails.assignedFitnessCenter!['logo'] != null
                              ? Image.network(
                                  customerDetails.assignedFitnessCenter!['logo'] as String,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.fitness_center, color: AppColors.primary),
                                )
                              : const Icon(Icons.fitness_center, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fitness Center',
                              style: AppStyles.text12Px.poppins.w500.copyWith(color: AppColors.textGrey),
                            ),
                            Text(
                              customerDetails.assignedFitnessCenter!['name'] as String? ?? 'N/A',
                              style: AppStyles.text14Px.poppins.w600.copyWith(color: AppColors.textDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (customerDetails.assignedTrainer != null) const Divider(height: 24, thickness: 0.5),
                ],
                if (customerDetails.assignedTrainer != null) ...[
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.iconBackground,
                        ),
                        child: ClipOval(
                          child: customerDetails.assignedTrainer!['profile_image'] != null
                              ? Image.network(
                                  customerDetails.assignedTrainer!['profile_image'] as String,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.person, color: AppColors.primary),
                                )
                              : const Icon(Icons.person, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Personal Trainer',
                              style: AppStyles.text12Px.poppins.w500.copyWith(color: AppColors.textGrey),
                            ),
                            Text(
                              customerDetails.assignedTrainer!['name'] as String? ?? 'N/A',
                              style: AppStyles.text14Px.poppins.w600.copyWith(color: AppColors.textDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                if (customerDetails.trainerNotes != null && customerDetails.trainerNotes!.isNotEmpty) ...[
                  const Divider(height: 24, thickness: 0.5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Trainer's Feedback & Notes",
                        style: AppStyles.text12Px.poppins.w500.copyWith(color: AppColors.textGrey),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        customerDetails.trainerNotes!,
                        style: AppStyles.text13Px.poppins.w500.copyWith(
                          color: AppColors.textDark,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Health Status',
              style: AppStyles.text16Px.poppins.w600.copyWith(
                color: AppColors.textDark,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => BlocProvider.value(
                      value: _cubit,
                      child: FitnessDetailsScreen(customerDetailsModel: customerDetails),
                    ),
                  ),
                ).then((_) {
                  _cubit.fetchCustomerDetails();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Edit',
                      style: AppStyles.text12Px.poppins.w600.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Age', age > 0 ? '$age' : 'N/A'),
              const SizedBox(height: 14),
              _buildDetailRow('Height', customerDetails.height != null ? '${customerDetails.height} cm' : 'N/A'),
              const SizedBox(height: 14),
              _buildDetailRow('Weight', customerDetails.weight != null ? '${customerDetails.weight} kg' : 'N/A'),
              const SizedBox(height: 14),
              _buildDetailRow('BMI', bmi != null ? '${bmi.toStringAsFixed(1)}$bmiCategory' : 'N/A'),
              const SizedBox(height: 14),
              _buildDetailRow('BMR', bmr != null ? '${bmr.toStringAsFixed(0)} kcal' : 'N/A'),
              const SizedBox(height: 14),
              _buildDetailRow(
                'Blood Group',
                customerDetails.bloodGroup ?? 'N/A',
              ),
              const SizedBox(height: 14),
              _buildDetailRow('Health Issues', healthIssues),
              const SizedBox(height: 14),
              _buildDetailRow(
                'Health Status',
                customerDetails.isHealthy ?? false ? 'Healthy' : 'Not Healthy',
              ),
              const SizedBox(height: 14),
              _buildDetailRow(
                'Active Scale',
                '${customerDetails.activeScale ?? 'N/A'}/5',
              ),
            ],
          ),
        ),

        // ── Health Report Card ──
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<bool>(
                builder: (_) => const HealthReportScreen(),
              ),
            ).then((shouldEditMeasurements) {
              if (shouldEditMeasurements == true) {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => BlocProvider.value(
                      value: _cubit,
                      child: FitnessDetailsScreen(customerDetailsModel: customerDetails),
                    ),
                  ),
                ).then((_) {
                  _cubit.fetchCustomerDetails();
                });
              }
            });
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.08),
                  AppColors.primary.withOpacity(0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.assessment,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Health Report',
                        style: AppStyles.text16Px.poppins.w600.copyWith(
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'View detailed BMI, BMR, TDEE & more',
                        style: AppStyles.text12Px.poppins.w400.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.primary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),

        if (choicesModel != null) ...[
          const SizedBox(height: 20),
          // ── Lifestyle section ──
          Text(
            'Lifestyle',
            style: AppStyles.text16Px.poppins.w600.copyWith(
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  'Profession',
                  choicesModel.data.professions
                      .firstWhere(
                        (e) => e.value == customerDetails.profession,
                        orElse: () => const Profession(label: 'N/A', value: ''),
                      )
                      .label,
                ),
                const SizedBox(height: 14),
                _buildEmojiRatingRow(
                  'Work Condition',
                  int.tryParse(
                    customerDetails.jobSatisfaction.toString() ?? '',
                  ),
                ),
                const SizedBox(height: 14),
                _buildDetailRow(
                  'Working Hour (avg)',
                  choicesModel.data.workingHours
                      .firstWhere(
                        (e) => e.value == customerDetails.averageWorkingHours,
                        orElse: () => const Profession(label: 'N/A', value: ''),
                      )
                      .label,
                ),
                const SizedBox(height: 14),
                _buildDetailRow(
                  'Sleeping Hour (avg)',
                  choicesModel.data.sleepHours
                      .firstWhere(
                        (e) => e.value == customerDetails.averageSleepingHours,
                        orElse: () => const Profession(label: 'N/A', value: ''),
                      )
                      .label,
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildEmojiRatingRow(String label, int? rating) {
    const emojiMap = {5: '😄', 4: '🙂', 3: '😐', 2: '☹️', 1: '😔'};
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppStyles.text14Px.poppins.w500.copyWith(
            color: Colors.black87,
          ),
        ),
        Row(
          children: List.generate(5, (index) {
            final value = 5 - index;
            final isSelected = rating == value;
            return Container(
              margin: const EdgeInsets.only(left: 4),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.red.shade50 : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Colors.red : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                emojiMap[value]!,
                style: const TextStyle(fontSize: 16),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
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
          style: AppStyles.text14Px.poppins.w500.copyWith(
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildMembershipCard(Membership? membership) {
    if (membership == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            'Membership',
            style: AppStyles.text16Px.poppins.w600.copyWith(
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No Active Membership',
                        style: AppStyles.text16Px.poppins.w600.copyWith(
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Please contact your gym to activate.',
                        style: AppStyles.text12Px.poppins.w500.copyWith(
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      );
    }

    final String statusStr = membership.status ?? 'Pending';
    final bool isActive = membership.isActive ?? false;
    final bool isPending = statusStr.toLowerCase() == 'pending';
    final localEndDate = membership.endDate?.toLocal();
    final bool isExpired = !isPending && (statusStr.toLowerCase() == 'expired' || (localEndDate != null && localEndDate.difference(DateTime.now()).inDays < 0));
    final bool actualIsActive = isActive && !isExpired && !isPending;

    // Remaining days calculation
    var remainingDays = 0;
    if (localEndDate != null) {
      remainingDays = localEndDate.difference(DateTime.now()).inDays;
      if (remainingDays < 0) remainingDays = 0;
    }

    // Progress calculation
    var progress = 0.0;
    if (membership.startDate != null && membership.endDate != null) {
      final totalSec =
          membership.endDate!.difference(membership.startDate!).inSeconds;
      final elapsedSec =
          DateTime.now().difference(membership.startDate!).inSeconds;
      if (totalSec > 0) {
        progress = elapsedSec / totalSec;
        if (progress > 1.0) progress = 1.0;
        if (progress < 0.0) progress = 0.0;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          'Membership',
          style: AppStyles.text16Px.poppins.w600.copyWith(
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  actualIsActive
                      ? Colors.green.withValues(alpha: 0.3)
                      : isExpired
                      ? Colors.red.withValues(alpha: 0.3)
                      : Colors.orange.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Card Header
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors:
                        actualIsActive
                            ? [Colors.green.shade50, Colors.green.shade100]
                            : isExpired
                            ? [Colors.red.shade50, Colors.red.shade100]
                            : [Colors.orange.shade50, Colors.orange.shade100],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            actualIsActive
                                ? Colors.green
                                : isExpired
                                ? Colors.red
                                : Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        actualIsActive
                            ? Icons.fitness_center
                            : isExpired
                            ? Icons.cancel
                            : Icons.pending,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            membership.membershipName ?? 'Standard Plan',
                            style: AppStyles.text16Px.poppins.w600.copyWith(
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                actualIsActive
                                    ? Icons.check_circle
                                    : isExpired
                                    ? Icons.cancel
                                    : Icons.schedule,
                                size: 14,
                                color:
                                    actualIsActive
                                        ? Colors.green
                                        : isExpired
                                        ? Colors.red
                                        : Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                actualIsActive
                                    ? 'Active'
                                    : isExpired
                                    ? 'Expired'
                                    : 'Pending',
                                style: AppStyles.text12Px.poppins.w600.copyWith(
                                  color:
                                      actualIsActive
                                          ? Colors.green
                                          : isExpired
                                          ? Colors.red
                                          : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Card Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress bar (only for active/expired)
                    if (membership.startDate != null &&
                        membership.endDate != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Membership Progress',
                            style: AppStyles.text13Px.poppins.w600.copyWith(
                              color: AppColors.textDark,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: AppStyles.text13Px.poppins.w600.copyWith(
                              color: actualIsActive ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade100,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          actualIsActive ? Colors.green : Colors.red,
                        ),
                        minHeight: 6,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        !isExpired
                            ? '🕒 $remainingDays days remaining'
                            : '✅ Membership completed',
                        style: AppStyles.text12Px.poppins.w500.copyWith(
                          color:
                              !isExpired ? Colors.orange.shade800 : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Details Grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildMembershipDetailItem(
                            icon: Icons.calendar_today,
                            label: 'Start Date',
                            value:
                                membership.startDate != null
                                    ? DateFormat(
                                      'dd MMM yyyy',
                                    ).format(membership.startDate!.toLocal())
                                    : 'N/A',
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMembershipDetailItem(
                            icon: Icons.event_busy,
                            label: 'Expiry Date',
                            value:
                                membership.endDate != null
                                    ? DateFormat(
                                      'dd MMM yyyy',
                                    ).format(membership.endDate!.toLocal())
                                    : 'N/A',
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMembershipDetailItem(
                            icon: Icons.currency_rupee,
                            label: 'Amount Paid',
                            value:
                                membership.amount != null
                                    ? '₹${membership.amount}'
                                    : 'N/A',
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMembershipDetailItem(
                            icon: Icons.payment,
                            label: 'Payment Status',
                            value:
                                (membership.paymentStatus ?? 'N/A')
                                    .toUpperCase(),
                            color:
                                (membership.paymentStatus ?? '')
                                            .toLowerCase() ==
                                        'completed'
                                    ? Colors.green
                                    : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildMembershipDetailItem(
                      icon: Icons.category,
                      label: 'Membership Type',
                      value: membership.isTrial == true ? 'Trial' : 'Regular',
                      color: Colors.purple,
                      fullWidth: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildMembershipDetailItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool fullWidth = false,
  }) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: AppStyles.text12Px.poppins.w500.copyWith(
                    color: AppColors.textGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppStyles.text13Px.poppins.w600.copyWith(
              color: AppColors.textDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ProfileListItem extends StatelessWidget {
  const _ProfileListItem({
    required this.label,
    required this.onTap,
    this.isLogout = false,
  });
  final String label;
  final VoidCallback onTap;
  final bool isLogout;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style:
            isLogout
                ? AppStyles.text14Px.poppins.w500.copyWith(color: Colors.red)
                : AppStyles.text14Px.poppins.w500,
      ),
      trailing:
          isLogout
              ? null
              : const Icon(Icons.chevron_right, color: Colors.black),
      onTap: onTap,
    );
  }
}

class _GuestProfileView extends StatelessWidget {
  const _GuestProfileView({required this.onLoginTap});

  final VoidCallback onLoginTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_outline, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Guest Account',
              style: AppStyles.text16Px.poppins.w500,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please log in to view and manage your profile details.',
              style: AppStyles.text12Px.poppins.w400,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onLoginTap,
                child: const Text('Log In'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
