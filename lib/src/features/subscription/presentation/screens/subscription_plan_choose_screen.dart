import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/fitnesscenters/persentation/components/plan_option_tile.dart';

class SubscriptionPlanChooseScreen extends StatelessWidget {
  const SubscriptionPlanChooseScreen({required this.orgId, super.key});

  final int orgId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubscriptionCubit(orgId: orgId),
      child: const _SubscriptionPlanChooseScreen(),
    );
  }
}

class _SubscriptionPlanChooseScreen extends StatefulWidget {
  const _SubscriptionPlanChooseScreen();

  @override
  State<_SubscriptionPlanChooseScreen> createState() =>
      __SubscriptionPlanChooseScreenState();
}

class __SubscriptionPlanChooseScreenState
    extends State<_SubscriptionPlanChooseScreen> {
  late final SubscriptionCubit _cubit;

  @override
  void initState() {
    _cubit = context.read<SubscriptionCubit>();
    _fetchPlans();
    super.initState();
  }

  Future<void> _fetchPlans() async {
    await _cubit.fetchSubscriptions();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubscriptionCubit, SubscriptionState>(
      listenWhen: (p, c) => p.payment != c.payment,
      listener: (context, state) {
        state.payment?.fold(() {}, (either) {
          either.fold(
            (error) {
              Dialogs.showSnack(msg: error.msg);
            },
            (razorpayOrder) async {
              context.read<AppCubit>().updateOrganizationId(_cubit.orgId);
              context.pushAndRemoveUntil(const DashboardScreen());
            },
          );
        });
      },
      child: BlocBuilder<SubscriptionCubit, SubscriptionState>(
        buildWhen: (p, c) => p.payment != c.payment,
        builder: (context, state) {
          return PopScope(
            canPop: !(state.payment?.isNone() ?? false),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF2C1212), AppColors.dark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Scaffold(
                  backgroundColor: Colors.transparent, // Background color
                  body: Stack(
                    children: [
                      Positioned(
                        top: context.height * .08,
                        right: 32,
                        child: SvgPicture.asset(
                          'assets/images/svg/vectors/dumble.svg',
                          fit: BoxFit.scaleDown,
                          height: 40,
                        ),
                      ),
                      Positioned(
                        top: context.height * .28,
                        right: context.width * .25,
                        child: SvgPicture.asset(
                          'assets/images/svg/vectors/hart.svg',
                          fit: BoxFit.scaleDown,
                          height: 40,
                        ),
                      ),
                      Positioned(
                        top: context.height * .38,
                        left: 32,
                        child: SvgPicture.asset(
                          'assets/images/svg/vectors/shoe.svg',
                          fit: BoxFit.scaleDown,
                          height: 40,
                        ),
                      ),
                      Positioned(
                        top: context.height * .4,
                        right: 16,
                        child: SvgPicture.asset(
                          'assets/images/svg/vectors/showing_power.svg',
                          fit: BoxFit.scaleDown,
                          height: 40,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: BlocBuilder<
                          SubscriptionCubit,
                          SubscriptionState
                        >(
                          buildWhen:
                              (p, c) =>
                                  p.plans != c.plans ||
                                  p.selectedSubscriptionModel !=
                                      c.selectedSubscriptionModel ||
                                  p.isPaymentLoading != c.isPaymentLoading,
                          builder: (context, state) {
                            return state.plans.fold(
                              () => Column(
                                children: [
                                  _buildPlanOptionShimmer(),
                                  const SizedBox(height: 16),
                                  _buildPlanOptionShimmer(),
                                ],
                              ),
                              (either) {
                                return either.fold(
                                  (error) {
                                    return SizedBox(
                                      width: 100,
                                      child: Button.filled(
                                        title: 'Retry',
                                        ontap: _fetchPlans,
                                        buttonColor: Colors.white,
                                        style:
                                            AppStyles
                                                .text14Px
                                                .poppins
                                                .w600
                                                .dark,
                                        raduis: 10000,
                                      ),
                                    ).center;
                                  },
                                  (plans) {
                                    if (plans.isEmpty) {
                                      return Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Spacer(flex: 4),
                                            Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.pink.shade100,
                                                    Colors.purple.shade200,
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.purple
                                                        .withValues(alpha: 0.3),
                                                    blurRadius: 24,
                                                    spreadRadius: 4,
                                                    offset: const Offset(0, 8),
                                                  ),
                                                ],
                                              ),
                                              padding: const EdgeInsets.all(24),
                                              child: Icon(
                                                Icons.sentiment_dissatisfied,
                                                size: 100,
                                                color: Colors.purple.shade700,
                                              ),
                                            ),
                                            const Spacer(flex: 2),
                                            const SizedBox(height: 24),
                                            Text(
                                              'No Membership Plans Available',
                                              style:
                                                  AppStyles
                                                      .text18Px
                                                      .poppins
                                                      .w600
                                                      .light,
                                              textAlign: TextAlign.center,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Currently, there are no plans to choose from for this gym. Please check back later or contact support.',
                                              style:
                                                  AppStyles
                                                      .text14Px
                                                      .poppins
                                                      .w400
                                                      .light,
                                              textAlign: TextAlign.center,
                                            ),
                                            const Spacer(),
                                            Button.filled(
                                              title: 'Explore Other Gyms',
                                              ontap: context.pop,
                                              buttonColor: Colors.white,
                                              disabledButtonColor: Colors.white
                                                  .withAlpha(125),
                                              loadingColor: Colors.black,
                                              style:
                                                  AppStyles
                                                      .text14Px
                                                      .poppins
                                                      .w600
                                                      .dark,
                                              raduis: 12,
                                            ),
                                            const Spacer(),
                                          ],
                                        ),
                                      );
                                    }
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 80),
                                        Text(
                                          'Select your Gym\nMembership Plan',
                                          style:
                                              AppStyles
                                                  .text24Px
                                                  .poppins
                                                  .w700
                                                  .light,
                                        ),
                                        const SizedBox(height: 20),
                                        Expanded(
                                          child: ListView.separated(
                                            shrinkWrap: true,
                                            // physics:
                                            //     const NeverScrollableScrollPhysics(),
                                            itemCount: plans.length,
                                            separatorBuilder:
                                                (_, __) =>
                                                    const SizedBox(height: 16),
                                            itemBuilder:
                                                (
                                                  context,
                                                  index,
                                                ) => _buildPlanOption(
                                                  plan: plans[index],
                                                  isSelected:
                                                      state
                                                          .selectedSubscriptionModel
                                                          ?.id ==
                                                      plans[index].id,
                                                ),
                                          ),
                                        ),
                                        const SizedBox(height: 40),
                                        Button.filled(
                                          title: 'Continue',
                                          isDisabled:
                                              state.selectedSubscriptionModel ==
                                              null,
                                          // isLoading:
                                          //     state.payment?.isNone() ?? false,
                                          isLoading: state.isPaymentLoading,
                                          ontap: () {
                                            if (state.payment?.isNone() ??
                                                false) {
                                              return;
                                            }
                                            _cubit.payment();
                                          },
                                          buttonColor: Colors.white,
                                          disabledButtonColor: Colors.white
                                              .withAlpha(125),
                                          loadingColor: Colors.black,
                                          style:
                                              AppStyles
                                                  .text14Px
                                                  .poppins
                                                  .w600
                                                  .dark,
                                          raduis: 12,
                                        ),
                                        const SizedBox(height: 40),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
                      // INSERT_YOUR_CODE
                      Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16, left: 8),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlanOption({
    required FitnesscenterMembershipPlansModel? plan,
    bool isSelected = false,
  }) {
    return PlanOptionTile(
      plan: plan,
      isSelected: isSelected,
      onTap: (p) => _cubit.selectSubscription(model: p),
      onEmiSelected:
          (p, emi) => _cubit.selectSubscription(model: p, emiId: emi?.id),
    );
  }

  Widget _buildPlanOptionShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF270A0A).withAlpha(150),
      highlightColor: const Color(0xFF581F1F),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF270A0A).withAlpha(150),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 70,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 90,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 60,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
