import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/profile/presentation/widgets/workout_history_calendar.dart';

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
      _cubit.fetchConstChoices();
    }
  }

  Future<void> _fetch() async {
    await _cubit.fetchCustomerDetails();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, appState) {
        final bool isCustomer =
            Feggy.read<AppCubit>()?.state.currentUser != null;
        return BlocProvider.value(
          value: _cubit,
          child: Scaffold(
            backgroundColor: AppColors.bgcolorgrey,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text('Profile', style: AppStyles.text16Px.poppins.w500),
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
                        return state.customerDetails.fold(() => const Center(child: CircularProgressIndicator()), (
                          either,
                        ) {
                          return either.fold(
                            (error) =>
                                error
                                    .maybeWhen(
                                      network:
                                          (e) => ErrorUi.network(onTap: _fetch),
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
                                        borderRadius: BorderRadius.circular(16),
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
                                                isEdit: true,
                                                onChanged: (image) {},
                                                radius: 100,
                                                url:
                                                    '${customerDetails.profilePicture}',
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.zero,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    customerDetails.firstName ??
                                                        '',
                                                    style: AppStyles.text16Px
                                                        .poppins.w600,
                                                  ),
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
                                                    customerDetails.email ?? '',
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
                                                  const SizedBox(height: 12),
                                                  Row(
                                                    children: [
                                                      if (customerDetails
                                                              .gender !=
                                                          null)
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 10,
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
                                    const WorkoutHistoryCalendar(),
                                    const SizedBox(height: 16),
                                    _buildOtherDetailsSection(customerDetails, choicesModel),
                                    const SizedBox(height: 16),
                                    ...[


                                      _ProfileListItem(
                                        label: 'Delete Account',
                                        onTap:
                                            () => DeleteAccountSheet().show(
                                              context,
                                            ),
                                        isLogout: true,
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          );
                        });
                      },
                    ),
          ),
        );
      },
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

  Widget _buildOtherDetailsSection(CustomerDetailsModel customerDetails, ConstantChoicesModel? choicesModel) {
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Other Details',
              style: AppStyles.text18Px.poppins.w600.copyWith(
                color: AppColors.textDark,
              ),
            ),
            InkWell(
              onTap: () {
                if (choicesModel != null) {
                  context.push(
                    BlocProvider.value(
                      value: _cubit,
                      child: HealthStatusScreen(
                        choicesModel: choicesModel,
                      ),
                    ),
                  );
                }
              },
              child: Row(
                children: [
                  Text(
                    'Show all',
                    style: AppStyles.text14Px.poppins.w600.copyWith(
                      color: AppColors.textDark,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_outward, size: 16),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildDetailRow('Age', age > 0 ? '$age' : 'N/A'),
              const SizedBox(height: 16),
              _buildDetailRow('Height', customerDetails.height ?? 'N/A'),
              const SizedBox(height: 16),
              _buildDetailRow('Weight', customerDetails.weight ?? 'N/A'),
              const SizedBox(height: 16),
              _buildDetailRow('Health Issues', healthIssues),
            ],
          ),
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
          style: AppStyles.text14Px.poppins.w600.copyWith(
            color: Colors.black87,
          ),
        ),
      ],
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
