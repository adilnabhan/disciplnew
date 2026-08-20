import 'package:shimmer/shimmer.dart';
import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:intl/intl.dart';
import 'package:customer_mobile_app/core/extensions/typography_extension.dart';
import 'pages/pages.dart';
import 'body_matrix_screen.dart';

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
                            () => const _ProfileShimmerLoading(),
                            (either) {
                              return either.fold(
                                (error) => RefreshIndicator(
                                  onRefresh: _fetch,
                                  child: SingleChildScrollView(
                                    physics: const AlwaysScrollableScrollPhysics(),
                                    child: SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height -
                                          120,
                                      child: error
                                          .maybeWhen(
                                            network:
                                                (e) => ErrorUi.network(
                                                  onTap: _fetch,
                                                ),
                                            notFound:
                                                (e) => ErrorUi.notFound(
                                                  onTap: _fetch,
                                                ),
                                            orElse:
                                                () =>
                                                    ErrorUi.server(onTap: _fetch),
                                          )
                                          .center,
                                    ),
                                  ),
                                ),
                                (customerDetails) {
                                  debugPrint(
                                    "DEBUG: assignedTrainer = ${customerDetails.assignedTrainer}",
                                  );
                                  debugPrint(
                                    "DEBUG: assignedFitnessCenter = ${customerDetails.assignedFitnessCenter}",
                                  );
                                  debugPrint(
                                    "DEBUG: trainerNotes = ${customerDetails.trainerNotes}",
                                  );
                                  return RefreshIndicator(
                                    onRefresh: _fetch,
                                    child: ListView(
                                      physics: const AlwaysScrollableScrollPhysics(),
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
                                          child: Stack(
                                            children: [
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute<void>(
                                                          builder:
                                                              (
                                                                _,
                                                              ) => BlocProvider.value(
                                                                value: _cubit,
                                                                child: ProfileDetailsScreen(
                                                                  customerDetailsModel:
                                                                      customerDetails,
                                                                ),
                                                              ),
                                                        ),
                                                      ).then((_) {
                                                        _fetch();
                                                      });
                                                    },
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
                                                      padding:
                                                          const EdgeInsets.all(
                                                            8,
                                                          ),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            customerDetails
                                                                    .fullName ??
                                                                '${customerDetails.firstName ?? ''} ${customerDetails.lastName ?? ''}'
                                                                    .trim(),
                                                            style:
                                                                AppStyles
                                                                    .text16Px
                                                                    .poppins
                                                                    .w600,
                                                          ),
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          if (customerDetails
                                                                  .mobileNumber !=
                                                              null) ...[
                                                            Row(
                                                              children: [
                                                                const Icon(
                                                                  Icons.phone_outlined,
                                                                  size: 15,
                                                                  color:
                                                                      AppColors
                                                                          .textGrey,
                                                                ),
                                                                const SizedBox(
                                                                  width: 6,
                                                                ),
                                                                Expanded(
                                                                  child: Text(
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
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 3,
                                                            ),
                                                          ],
                                                          Row(
                                                            children: [
                                                              const Icon(
                                                                Icons.email_outlined,
                                                                size: 15,
                                                                color:
                                                                    AppColors
                                                                        .textGrey,
                                                              ),
                                                              const SizedBox(
                                                                width: 6,
                                                              ),
                                                              Expanded(
                                                                child: Text(
                                                                  customerDetails
                                                                          .email ??
                                                                      '-',
                                                                  style: AppStyles
                                                                      .text14Px
                                                                      .poppins
                                                                      .w600
                                                                      .copyWith(
                                                                        color:
                                                                            AppColors
                                                                                .textGrey,
                                                                      ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 14,
                                                          ),
                                                          Wrap(
                                                            spacing: 8,
                                                            runSpacing: 6,
                                                            crossAxisAlignment:
                                                                WrapCrossAlignment
                                                                    .center,
                                                            children: [
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          4,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  color: const Color(
                                                                    0xFFEBFBEE,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        16,
                                                                      ),
                                                                ),
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    const Icon(
                                                                      Icons
                                                                          .circle,
                                                                      size: 8,
                                                                      color: Color(
                                                                        0xFF40C057,
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 6,
                                                                    ),
                                                                    Text(
                                                                      'Active',
                                                                      style: AppStyles
                                                                          .text13Px
                                                                          .poppins
                                                                          .w600
                                                                          .copyWith(
                                                                            color: const Color(
                                                                              0xFF2B8A3E,
                                                                            ),
                                                                          ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              if (customerDetails
                                                                          .gender !=
                                                                      null &&
                                                                  customerDetails
                                                                      .gender!
                                                                      .isNotEmpty)
                                                                Container(
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            12,
                                                                        vertical:
                                                                            4,
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
                                                                    '${customerDetails.gender![0].toUpperCase()}${customerDetails.gender!.substring(1).toLowerCase()}',
                                                                    style: AppStyles
                                                                        .text13Px
                                                                        .poppins
                                                                        .w500
                                                                        .copyWith(
                                                                          color:
                                                                              AppColors.textDark,
                                                                        ),
                                                                  ),
                                                                ),
                                                              if (customerDetails
                                                                          .bloodGroup !=
                                                                      null &&
                                                                  customerDetails
                                                                      .bloodGroup!
                                                                      .isNotEmpty &&
                                                                  customerDetails
                                                                          .bloodGroup!
                                                                          .toLowerCase() !=
                                                                      'unknown')
                                                                Container(
                                                                  padding:
                                                                      const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            12,
                                                                        vertical:
                                                                            4,
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
                                                                        .bloodGroup!,
                                                                    style: AppStyles
                                                                        .text13Px
                                                                        .poppins
                                                                        .w500
                                                                        .copyWith(
                                                                          color:
                                                                              AppColors.textDark,
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
                                              Positioned(
                                                top: 8,
                                                right: 8,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute<void>(
                                                        builder:
                                                            (
                                                              _,
                                                            ) => BlocProvider.value(
                                                              value: _cubit,
                                                              child: ProfileDetailsScreen(
                                                                customerDetailsModel:
                                                                    customerDetails,
                                                              ),
                                                            ),
                                                      ),
                                                    ).then((_) {
                                                      _fetch();
                                                    });
                                                  },
                                                  child: Container(
                                                    width: 30,
                                                    height: 30,
                                                    decoration:
                                                        const BoxDecoration(
                                                          color: Color(
                                                            0xFFF1F3F5,
                                                          ),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                    child: const Icon(
                                                      Icons.edit,
                                                      size: 14,
                                                      color: Color(0xFF495057),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        if (customerDetails.targetGoal !=
                                                null &&
                                            customerDetails
                                                .targetGoal!
                                                .isNotEmpty) ...[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Target Goal',
                                                style: AppStyles
                                                    .text16Px
                                                    .poppins
                                                    .w600
                                                    .copyWith(
                                                      color: AppColors.textDark,
                                                    ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute<void>(
                                                      builder:
                                                          (
                                                            _,
                                                          ) => BlocProvider.value(
                                                            value: _cubit,
                                                            child: EditTargetGoals(
                                                              customerDetailsModel:
                                                                  customerDetails,
                                                              choicesModel:
                                                                  choicesModel,
                                                            ),
                                                          ),
                                                    ),
                                                  ).then((_) {
                                                    _cubit
                                                        .fetchCustomerDetails();
                                                  });
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primary
                                                        .withOpacity(0.08),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.edit,
                                                        size: 14,
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        'Edit',
                                                        style: AppStyles
                                                            .text12Px
                                                            .poppins
                                                            .w600
                                                            .copyWith(
                                                              color:
                                                                  AppColors
                                                                      .primary,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
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
                                                          (goal.toLowerCase() ==
                                                                      "other" &&
                                                                  customerDetails
                                                                          .targetGoalOther !=
                                                                      null &&
                                                                  customerDetails
                                                                      .targetGoalOther!
                                                                      .isNotEmpty)
                                                              ? customerDetails
                                                                  .targetGoalOther!
                                                              : goal
                                                                  .split("_")
                                                                  .map(
                                                                    (e) =>
                                                                        e.isNotEmpty
                                                                            ? "${e[0].toUpperCase()}${e.substring(1).toLowerCase()}"
                                                                            : "",
                                                                  )
                                                                  .join(" "),
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
                                        _buildFitnessAnalyticsCard(
                                          customerDetails,
                                        ),
                                        () {
                                          Membership? activeMembership;
                                          if (customerDetails.memberships !=
                                                  null &&
                                              customerDetails
                                                  .memberships!
                                                  .isNotEmpty) {
                                            for (final m
                                                in customerDetails
                                                    .memberships!) {
                                              if (m.isActive == true ||
                                                  m.status?.toLowerCase() ==
                                                      'active') {
                                                activeMembership = m;
                                                break;
                                              }
                                            }
                                            activeMembership ??=
                                                customerDetails
                                                    .memberships!
                                                    .first;
                                          }
                                          return _buildMembershipCard(
                                            activeMembership,
                                          );
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Assigned Gym & Trainer section ──
        if (customerDetails.assignedFitnessCenter != null ||
            customerDetails.assignedTrainer != null) ...[
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
                          child:
                              customerDetails.assignedFitnessCenter!['logo'] !=
                                      null
                                  ? Image.network(
                                    customerDetails
                                            .assignedFitnessCenter!['logo']
                                        as String,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => const Icon(
                                          Icons.fitness_center,
                                          color: AppColors.primary,
                                        ),
                                  )
                                  : const Icon(
                                    Icons.fitness_center,
                                    color: AppColors.primary,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fitness Center',
                              style: AppStyles.text12Px.poppins.w500.copyWith(
                                color: AppColors.textGrey,
                              ),
                            ),
                            Text(
                              customerDetails.assignedFitnessCenter!['name']
                                      as String? ??
                                  '-',
                              style: AppStyles.text14Px.poppins.w600.copyWith(
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (customerDetails.assignedTrainer != null)
                    const Divider(height: 24, thickness: 0.5),
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
                          child:
                              customerDetails
                                          .assignedTrainer!['profile_image'] !=
                                      null
                                  ? Image.network(
                                    customerDetails
                                            .assignedTrainer!['profile_image']
                                        as String,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (_, __, ___) => const Icon(
                                          Icons.person,
                                          color: AppColors.primary,
                                        ),
                                  )
                                  : const Icon(
                                    Icons.person,
                                    color: AppColors.primary,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Personal Trainer',
                              style: AppStyles.text12Px.poppins.w500.copyWith(
                                color: AppColors.textGrey,
                              ),
                            ),
                            Text(
                              customerDetails.assignedTrainer!['name']
                                      as String? ??
                                  '-',
                              style: AppStyles.text14Px.poppins.w600.copyWith(
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                if (customerDetails.trainerNotes != null &&
                    customerDetails.trainerNotes!.isNotEmpty) ...[
                  const Divider(height: 24, thickness: 0.5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Trainer's Feedback & Notes",
                        style: AppStyles.text12Px.poppins.w500.copyWith(
                          color: AppColors.textGrey,
                        ),
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
              'Other Details',
              style: AppStyles.text16Px.poppins.w600.copyWith(
                color: AppColors.textDark,
              ),
            ),
            if (choicesModel != null)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder:
                          (_) => BlocProvider.value(
                            value: _cubit,
                            child: HealthStatusScreen(
                              choicesModel: choicesModel,
                            ),
                          ),
                    ),
                  ).then((_) {
                    _cubit.fetchCustomerDetails();
                  });
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Show all',
                      style: AppStyles.text14Px.poppins.w500.copyWith(
                        color: AppColors.textDark,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.north_east,
                      size: 14,
                      color: AppColors.textDark,
                    ),
                  ],
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
              _buildDetailRow('Age', age > 0 ? '$age' : '-'),
              const SizedBox(height: 14),
              _buildDetailRow(
                'Height',
                customerDetails.height != null &&
                        customerDetails.height!.isNotEmpty
                    ? (customerDetails.height!.toUpperCase().contains('CM') ||
                            customerDetails.height!.toUpperCase().contains('FT')
                        ? customerDetails.height!
                        : '${customerDetails.height} CM')
                    : '-',
              ),
              const SizedBox(height: 14),
              _buildDetailRow(
                'Weight',
                customerDetails.weight != null &&
                        customerDetails.weight!.isNotEmpty
                    ? (customerDetails.weight!.toUpperCase().contains('KG') ||
                            customerDetails.weight!.toUpperCase().contains('LBS')
                        ? customerDetails.weight!
                        : '${customerDetails.weight} KG')
                    : '-',
              ),
              const SizedBox(height: 14),
              _buildDetailRow('Health Issues', healthIssues),
            ],
          ),
        ),

        const SizedBox(height: 16),
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

  void _showBodyMetricsBottomSheet(
    BuildContext context, {
    required CustomerDetailsModel customerDetails,
  }) {
    // Pre-fill with existing values, store only the numeric part
    final existingHeight = double.tryParse(customerDetails.height ?? '');
    final existingWeight = double.tryParse(customerDetails.weight ?? '');
    DateTime? selectedDob = customerDetails.dateOfBirth;
    final existingGender = customerDetails.gender?.toString() ?? 'Male';

    final heightController = TextEditingController(
      text: existingHeight != null
          ? (existingHeight == existingHeight.toInt().toDouble()
              ? '${existingHeight.toInt()}'
              : existingHeight.toStringAsFixed(1))
          : '',
    );
    final weightController = TextEditingController(
      text: existingWeight != null
          ? (existingWeight == existingWeight.toInt().toDouble()
              ? '${existingWeight.toInt()}'
              : existingWeight.toStringAsFixed(1))
          : '',
    );
    final neckController = TextEditingController();
    final waistController = TextEditingController();
    final hipController = TextEditingController();

    CustomerDetailsRepository().fetchBodyMeasurements().then((res) {
      res.fold((_) => null, (data) {
        if (data.latest != null) {
          String fmt(double val) => val == val.toInt().toDouble()
              ? '${val.toInt()}'
              : val.toStringAsFixed(1);
          if (data.latest!.neckCm != null) neckController.text = fmt(data.latest!.neckCm!);
          if (data.latest!.waistCm != null) waistController.text = fmt(data.latest!.waistCm!);
          if (data.latest!.hipsCm != null) hipController.text = fmt(data.latest!.hipsCm!);
        }
      });
    });

    // Unit state
    String heightUnit = 'cm';
    String weightUnit = 'kg';
    String neckUnit = 'cm';
    String waistUnit = 'cm';
    String hipUnit = 'cm';
    String gender = existingGender.toLowerCase().startsWith('f') ? 'Female' : 'Male';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: _cubit,
          child: StatefulBuilder(
            builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Handle bar
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDEE2E6),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // Title row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Update Body Metrics',
                            style: AppStyles.text18Px.poppins.w600.copyWith(
                              color: AppColors.textDark,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.of(sheetContext).pop(),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1F3F5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: Color(0xFF495057),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Row 1: Height & Weight
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Height',
                                  style: AppStyles.text13Px.poppins.w600.copyWith(
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildMetricInputField(
                                  controller: heightController,
                                  hint: 'e.g. 170',
                                  selectedUnit: heightUnit,
                                  units: const ['cm', 'ft'],
                                  onUnitChanged: (val) {
                                    setSheetState(() => heightUnit = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Weight',
                                  style: AppStyles.text13Px.poppins.w600.copyWith(
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildMetricInputField(
                                  controller: weightController,
                                  hint: 'e.g. 65',
                                  selectedUnit: weightUnit,
                                  units: const ['kg', 'lbs'],
                                  onUnitChanged: (val) {
                                    setSheetState(() => weightUnit = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Row 2: Date of Birth & Gender
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Date of Birth',
                                  style: AppStyles.text13Px.poppins.w600.copyWith(
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildDateField(
                                  context: ctx,
                                  selectedDate: selectedDob,
                                  onDateSelected: (newDate) {
                                    setSheetState(() => selectedDob = newDate);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gender',
                                  style: AppStyles.text13Px.poppins.w600.copyWith(
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildGenderDropdown(
                                  selectedGender: gender,
                                  onChanged: (val) {
                                    setSheetState(() => gender = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Row 3: Neck & Waist
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Neck',
                                  style: AppStyles.text13Px.poppins.w600.copyWith(
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildMetricInputField(
                                  controller: neckController,
                                  hint: 'e.g. 38',
                                  selectedUnit: neckUnit,
                                  units: const ['cm', 'in'],
                                  onUnitChanged: (val) {
                                    setSheetState(() => neckUnit = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Waist',
                                  style: AppStyles.text13Px.poppins.w600.copyWith(
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildMetricInputField(
                                  controller: waistController,
                                  hint: 'e.g. 80',
                                  selectedUnit: waistUnit,
                                  units: const ['cm', 'in'],
                                  onUnitChanged: (val) {
                                    setSheetState(() => waistUnit = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Row 4: Hip & Placeholder
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hip',
                                  style: AppStyles.text13Px.poppins.w600.copyWith(
                                    color: AppColors.textDark,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildMetricInputField(
                                  controller: hipController,
                                  hint: 'e.g. 95',
                                  selectedUnit: hipUnit,
                                  units: const ['cm', 'in'],
                                  onUnitChanged: (val) {
                                    setSheetState(() => hipUnit = val);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Save button
                      BlocConsumer<ProfileCubit, ProfileState>(
                        listener: (ctx, state) {
                          state.updateProfileDetails?.fold(
                            () => null,
                            (either) => either.fold(
                              (error) {
                                Navigator.of(sheetContext).pop();
                                Dialogs.showSnack(
                                  msg: 'Failed to update metrics. Try again.',
                                );
                              },
                              (_) {
                                Navigator.of(sheetContext).pop();
                                Dialogs.showSnack(
                                  msg: 'Body metrics updated successfully!',
                                );
                              },
                            ),
                          );
                        },
                        builder: (ctx, state) {
                          final isLoading = false;
                          return SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      final heightText = heightController.text.trim();
                                      final weightText = weightController.text.trim();
                                      final neckText = neckController.text.trim();
                                      final waistText = waistController.text.trim();
                                      final hipText = hipController.text.trim();

                                      if (heightText.isEmpty || weightText.isEmpty || selectedDob == null) {
                                        Dialogs.showSnack(
                                          msg: 'Please enter height, weight, and date of birth.',
                                        );
                                        return;
                                      }
                                      double? heightVal = double.tryParse(heightText);
                                      double? weightVal = double.tryParse(weightText);
                                      if (heightVal == null || weightVal == null) {
                                        Dialogs.showSnack(
                                          msg: 'Please enter valid numbers.',
                                        );
                                        return;
                                      }
                                      final ageVal = DateTime.now().year - selectedDob!.year;
                                      // Convert to cm if needed
                                      if (heightUnit == 'ft') {
                                        heightVal = heightVal * 30.48;
                                      }
                                      // Convert to kg if needed
                                      if (weightUnit == 'lbs') {
                                        weightVal = weightVal * 0.453592;
                                      }

                                      double? neckVal =
                                          double.tryParse(neckText);
                                      double? waistVal =
                                          double.tryParse(waistText);
                                      double? hipVal =
                                          double.tryParse(hipText);

                                      // Calculate body fat percentage
                                      double bfPercentageVal;
                                      final bmiVal = weightVal / pow(heightVal / 100, 2);
                                      if (neckVal != null && waistVal != null && (gender.toLowerCase().startsWith('m') || hipVal != null)) {
                                        // Convert neck, waist, hip to cm
                                        double neckCm = neckVal;
                                        if (neckUnit == 'in') neckCm = neckVal * 2.54;
                                        double waistCm = waistVal;
                                        if (waistUnit == 'in') waistCm = waistVal * 2.54;
                                        
                                        if (gender.toLowerCase().startsWith('f')) {
                                          double hipCm = hipVal ?? 0.0;
                                          if (hipUnit == 'in') hipCm = hipVal! * 2.54;
                                          
                                          final val = 1.29579 - 0.35004 * (log(waistCm + hipCm - neckCm) / ln10) + 0.22100 * (log(heightVal) / ln10);
                                          bfPercentageVal = val > 0 ? (495 / val) - 450 : ((1.20 * bmiVal) + (0.23 * ageVal) - 5.4);
                                        } else {
                                          final val = 1.0324 - 0.19077 * (log(waistCm - neckCm) / ln10) + 0.15456 * (log(heightVal) / ln10);
                                          bfPercentageVal = val > 0 ? (495 / val) - 450 : ((1.20 * bmiVal) + (0.23 * ageVal) - 16.2);
                                        }
                                      } else {
                                        // Fallback to BMI-based body fat calculation
                                        if (gender.toLowerCase().startsWith('f')) {
                                          bfPercentageVal = (1.20 * bmiVal) + (0.23 * ageVal) - 5.4;
                                        } else {
                                          bfPercentageVal = (1.20 * bmiVal) + (0.23 * ageVal) - 16.2;
                                        }
                                      }

                                      // Clamp body fat percentage between 2% and 60% for safety
                                      bfPercentageVal = bfPercentageVal.clamp(2.0, 60.0);

                                      final heightStr = heightVal.toStringAsFixed(2);
                                      final weightStr = weightVal.toStringAsFixed(2);
                                      
                                      final dobStr = '${selectedDob!.year}-${selectedDob!.month.toString().padLeft(2, '0')}-${selectedDob!.day.toString().padLeft(2, '0')}';
                                      
                                      final Map<String, dynamic> extraPayload = {
                                        'blood_group': customerDetails.bloodGroup ?? '',
                                        'height': heightStr,
                                        'weight': weightStr,
                                        'gender': gender.toLowerCase(),
                                        'date_of_birth': dobStr,
                                        'bf_percentage': bfPercentageVal.toStringAsFixed(1),
                                      };

                                      if (neckVal != null) {
                                        double neckCm = neckVal;
                                        if (neckUnit == 'in') neckCm = neckVal * 2.54;
                                        extraPayload['neck'] = neckCm.toStringAsFixed(1);
                                      }
                                      if (waistVal != null) {
                                        double waistCm = waistVal;
                                        if (waistUnit == 'in') waistCm = waistVal * 2.54;
                                        extraPayload['waist'] = waistCm.toStringAsFixed(1);
                                      }
                                      if (hipVal != null) {
                                        double hipCm = hipVal;
                                        if (hipUnit == 'in') hipCm = hipVal * 2.54;
                                        extraPayload['hip'] = hipCm.toStringAsFixed(1);
                                      }

                                      if (neckVal != null || waistVal != null || hipVal != null) {
                                        double? finalNeckCm;
                                        double? finalWaistCm;
                                        double? finalHipCm;
                                        if (neckVal != null) {
                                          finalNeckCm = neckUnit == 'in' ? neckVal * 2.54 : neckVal;
                                        }
                                        if (waistVal != null) {
                                          finalWaistCm = waistUnit == 'in' ? waistVal * 2.54 : waistVal;
                                        }
                                        if (hipVal != null) {
                                          finalHipCm = hipUnit == 'in' ? hipVal * 2.54 : hipVal;
                                        }
                                        await CustomerDetailsRepository().logBodyMeasurements(
                                          neck: finalNeckCm,
                                          waist: finalWaistCm,
                                          hip: finalHipCm,
                                        );
                                      }

                                      await _cubit.updateHealthProfile(
                                        bloodGroup: customerDetails.bloodGroup ?? '',
                                        height: heightStr,
                                        weight: weightStr,
                                        extraBody: extraPayload,
                                      );
                                    },
                              child: isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      'Save Changes',
                                      style: AppStyles.text16Px.poppins.w600
                                          .copyWith(color: Colors.white),
                                    ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      // Cancel
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.of(sheetContext).pop(),
                          child: Text(
                            'Cancel',
                            style: AppStyles.text14Px.poppins.w600.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          ),
        );
      },
    );
  }

  Widget _buildMetricInputField({
    required TextEditingController controller,
    required String hint,
    required String selectedUnit,
    required List<String> units,
    required void Function(String) onUnitChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDEE2E6), width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: AppStyles.text16Px.poppins.w500.copyWith(
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
                  color: const Color(0xFFADB5BD),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 28,
            color: const Color(0xFFDEE2E6),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedUnit,
                onChanged: (v) => onUnitChanged(v!),
                style: AppStyles.text14Px.poppins.w600.copyWith(
                  color: AppColors.textDark,
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: Color(0xFF868E96),
                ),
                items: units
                    .map(
                      (u) => DropdownMenuItem(
                        value: u,
                        child: Text(u),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildSimpleInputField({
    required TextEditingController controller,
    required String hint,
    required TextInputType keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDEE2E6), width: 1.2),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppStyles.text16Px.poppins.w500.copyWith(
          color: AppColors.textDark,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppStyles.text14Px.poppins.w400.copyWith(
            color: const Color(0xFFADB5BD),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown({
    required String selectedGender,
    required void Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDEE2E6), width: 1.2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedGender,
          isExpanded: true,
          onChanged: (v) => onChanged(v!),
          style: AppStyles.text16Px.poppins.w500.copyWith(
            color: AppColors.textDark,
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 24,
            color: Color(0xFF868E96),
          ),
          items: const [
            DropdownMenuItem(value: 'Male', child: Text('Male')),
            DropdownMenuItem(value: 'Female', child: Text('Female')),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required DateTime? selectedDate,
    required void Function(DateTime) onDateSelected,
  }) {
    final text = selectedDate != null
        ? '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}'
        : 'DD/MM/YYYY';

    return GestureDetector(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime(2000, 1, 1),
          firstDate: DateTime(1900),
          lastDate: now,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(primary: AppColors.primary),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDEE2E6), width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: AppStyles.text14Px.poppins.w500.copyWith(
                color: selectedDate != null
                    ? AppColors.textDark
                    : const Color(0xFFADB5BD),
              ),
            ),
            const Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: Color(0xFF868E96),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDoubleString(String? val) {
    if (val == null || val.isEmpty) return '';
    final d = double.tryParse(val);
    if (d == null) return val;
    if (d == d.toInt().toDouble()) {
      return '${d.toInt()}';
    }
    return d.toStringAsFixed(1);
  }

  String _formatDynamicValue(dynamic val) {
    if (val == null) return '';
    if (val is num) {
      if (val == val.toInt().toDouble()) {
        return '${val.toInt()}';
      }
      return val.toStringAsFixed(1);
    }
    final d = double.tryParse(val.toString());
    if (d == null) return val.toString();
    if (d == d.toInt().toDouble()) {
      return '${d.toInt()}';
    }
    return d.toStringAsFixed(1);
  }

  String _formatHeight(String? val) {
    if (val == null || val.isEmpty) return '-';
    final d = double.tryParse(val);
    if (d == null) return val;
    return '${d.toStringAsFixed(2)} CM';
  }

  String _formatWeight(String? val) {
    if (val == null || val.isEmpty) return '-';
    final d = double.tryParse(val);
    if (d == null) return val;
    if (d == d.toInt().toDouble()) {
      return '${d.toInt()} KG';
    }
    return '${d.toStringAsFixed(1)} KG';
  }

  String formatWithCommas(num value) {
    final str = value.toStringAsFixed(0);
    return str.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Widget _buildFitnessAnalyticsCard(CustomerDetailsModel customerDetails) {
    int age = 0;
    if (customerDetails.dateOfBirth != null) {
      age = DateTime.now().year - customerDetails.dateOfBirth!.year;
    }

    double? bmi;
    double? bf;
    String bmiCategory = '-';
    Color categoryColor = Colors.grey;

    final heightVal = double.tryParse(customerDetails.height ?? '');
    final weightVal = double.tryParse(customerDetails.weight ?? '');

    if (heightVal != null && weightVal != null && heightVal > 0) {
      final heightInMeters = heightVal / 100;
      bmi = weightVal / (heightInMeters * heightInMeters);

      if (bmi < 18.5) {
        bmiCategory = 'Underweight';
        categoryColor = Colors.orange;
      } else if (bmi < 25.0) {
        bmiCategory = 'Normal';
        categoryColor = const Color(0xFF40C057);
      } else if (bmi < 30.0) {
        bmiCategory = 'Overweight';
        categoryColor = Colors.orange.shade700;
      } else {
        bmiCategory = 'Obese';
        categoryColor = Colors.red;
      }

      final gender = customerDetails.gender?.toString().toLowerCase() ?? 'male';
      if (age > 0) {
        if (gender.startsWith('f')) {
          bf = (1.20 * bmi) + (0.23 * age) - 5.4;
        } else {
          bf = (1.20 * bmi) + (0.23 * age) - 16.2;
        }
      }
    }

    // Fallbacks from model if calculation didn't run but model has it
    if (bmi == null && customerDetails.bmi != null) {
      bmi = double.tryParse(customerDetails.bmi.toString());
      if (bmi != null) {
        if (bmi < 18.5) {
          bmiCategory = 'Underweight';
          categoryColor = Colors.orange;
        } else if (bmi < 25.0) {
          bmiCategory = 'Normal';
          categoryColor = const Color(0xFF40C057);
        } else if (bmi < 30.0) {
          bmiCategory = 'Overweight';
          categoryColor = Colors.orange.shade700;
        } else {
          bmiCategory = 'Obese';
          categoryColor = Colors.red;
        }
      }
    }
    if (bf == null && customerDetails.bfPercentage != null) {
      final rawBf = customerDetails.bfPercentage;
      if (rawBf is num) {
        bf = rawBf.toDouble();
      } else if (rawBf is String) {
        bf = double.tryParse(rawBf);
      }
    }

    final bmiStr = bmi != null ? bmi.toStringAsFixed(1) : '-';
    final bfStr = bf != null ? bf.toStringAsFixed(1) : '-';

    String bfCategory = '-';
    Color bfCategoryColor = Colors.grey;

    if (bf != null) {
      if (bf < 2.0) {
        bfCategory = 'Low';
        bfCategoryColor = const Color(0xFF2F6FED);
      } else if (bf < 6.0) {
        bfCategory = 'Essential';
        bfCategoryColor = const Color(0xFF2F6FED);
      } else if (bf < 14.0) {
        bfCategory = 'Athletic';
        bfCategoryColor = const Color(0xFF00A896);
      } else if (bf < 18.0) {
        bfCategory = 'Fitness';
        bfCategoryColor = const Color(0xFF80C23A);
      } else if (bf < 25.0) {
        bfCategory = 'Average';
        bfCategoryColor = const Color(0xFFF9B824);
      } else {
        bfCategory = 'Above Average';
        bfCategoryColor = const Color(0xFFFA5252);
      }
    }

    final heightStr = _formatHeight(customerDetails.height);
    final weightStr = _formatWeight(customerDetails.weight);

    String updatedDateStr = '-';
    if (customerDetails.modified != null) {
      updatedDateStr = DateFormat(
        'dd MMM yyyy',
      ).format(customerDetails.modified!.toLocal());
    }

    // "Update" link → bottom sheet
    final void Function() onUpdateTap = () {
      _showBodyMetricsBottomSheet(
        context,
        customerDetails: customerDetails,
      );
    };

    final void Function() onChevronTap = () {
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider.value(
            value: _cubit,
            child: BodyMatrixScreen(customerDetails: customerDetails),
          ),
        ),
      );
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          'Health Matrix',
          style: AppStyles.text16Px.poppins.w600.copyWith(
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // BMI
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'BMI',
                                style: AppStyles.text12Px.poppins.w600.copyWith(
                                  color: const Color(0xFF868E96),
                                ),
                              ),
                              Text(
                                bmiStr,
                                style: AppStyles.text20Px.poppins.w700.copyWith(
                                  fontSize: 20,
                                  color: const Color(0xFF212529),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (bmi != null) ...[
                                    Icon(
                                      Icons.circle,
                                      color: categoryColor,
                                      size: 7,
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    bmiCategory,
                                    style: AppStyles.text12Px.poppins.w500
                                        .copyWith(
                                          color: const Color(0xFF212529),
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Middle divider and Heart Badge
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              top: -25,
                              bottom: -25,
                              child: Container(
                                width: 1.5,
                                color: const Color(0xFFD9D9D9),
                              ),
                            ),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFFD9D9D9),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/images/svg/icons/heart_icon.svg',
                                  width: 14,
                                  height: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Body Fat
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Body Fat',
                                style: AppStyles.text12Px.poppins.w600.copyWith(
                                  color: const Color(0xFF868E96),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                bfStr,
                                style: AppStyles.text20Px.poppins.w700.copyWith(
                                  fontSize: 20,
                                  color: const Color(0xFF212529),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (bf != null) ...[
                                    Icon(
                                      Icons.circle,
                                      color: bfCategoryColor,
                                      size: 7,
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    bfCategory,
                                    style: AppStyles.text12Px.poppins.w500
                                        .copyWith(
                                          color: const Color(0xFF212529),
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Inner metrics container
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE9ECEF),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Height
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.height,
                                  color: Color(0xFFFA5252),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Height',
                                  style: AppStyles.text13Px.poppins.w500
                                      .copyWith(color: const Color(0xFF212529)),
                                ),
                                const Spacer(),
                                Text(
                                  heightStr,
                                  style: AppStyles.text13Px.poppins.w600
                                      .copyWith(color: const Color(0xFF212529)),
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            height: 10,
                            thickness: 1,
                            color: Color(0xFFF1F3F5),
                          ),
                          // Weight
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.monitor_weight_outlined,
                                  color: Color(0xFFFA5252),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Weight',
                                  style: AppStyles.text13Px.poppins.w500
                                      .copyWith(color: const Color(0xFF212529)),
                                ),
                                const Spacer(),
                                Text(
                                  weightStr,
                                  style: AppStyles.text13Px.poppins.w600
                                      .copyWith(color: const Color(0xFF212529)),
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            height: 10,
                            thickness: 1,
                            color: Color(0xFFF1F3F5),
                          ),
                          // Last Updated
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.history,
                                  color: Color(0xFF868E96),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Last Updated',
                                  style: AppStyles.text13Px.poppins.w500
                                      .copyWith(color: const Color(0xFF212529)),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: onUpdateTap,
                                  child: RichText(
                                    text: TextSpan(
                                      style: AppStyles.text13Px.poppins.w500
                                          .copyWith(
                                            color: const Color(0xFF212529),
                                          ),
                                      children: [
                                        TextSpan(text: '$updatedDateStr '),
                                        TextSpan(
                                          text: 'Update',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            decoration:
                                                TextDecoration.underline,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: onChevronTap,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F3F5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF495057),
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return RichText(
      text: TextSpan(
        text: '$label : ',
        style: AppStyles.text13Px.poppins.w600.copyWith(
          color: AppColors.textGrey,
        ),
        children: [
          TextSpan(
            text: value,
            style: AppStyles.text13Px.poppins.w500.copyWith(
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
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
    final bool isExpired =
        !isPending &&
        (statusStr.toLowerCase() == 'expired' ||
            (localEndDate != null &&
                localEndDate.difference(DateTime.now()).inDays < 0));
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
                                    : '-',
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
                                    : '-',
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
                                    : '-',
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMembershipDetailItem(
                            icon: Icons.payment,
                            label: 'Payment Status',
                            value:
                                (membership.paymentStatus ?? '-').toUpperCase(),
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

class _ProfileShimmerLoading extends StatelessWidget {
  const _ProfileShimmerLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Top Profile Card Shimmer
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 120,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const CircleAvatar(radius: 40, backgroundColor: Colors.white),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 16,
                        width: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            height: 20,
                            width: 60,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            height: 20,
                            width: 45,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
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
        ),
        const SizedBox(height: 20),

        // Target Goal Shimmer
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 18,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 36,
                width: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Health Matrix Shimmer
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 18,
                width: 130,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Membership Shimmer
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 18,
                width: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
