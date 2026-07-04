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
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2C1212), AppColors.dark],
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
                                            if (state.selectedSubscriptionModel != null) {
                                              _showCheckoutBottomSheet(context, state.selectedSubscriptionModel!);
                                            }
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

  void _showCheckoutBottomSheet(BuildContext context, FitnesscenterMembershipPlansModel plan) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return _CheckoutBottomSheetContent(
          plan: plan,
          cubit: _cubit,
        );
      },
    );
  }
}

class _CheckoutBottomSheetContent extends StatefulWidget {
  final FitnesscenterMembershipPlansModel plan;
  final SubscriptionCubit cubit;

  const _CheckoutBottomSheetContent({
    required this.plan,
    required this.cubit,
  });

  @override
  State<_CheckoutBottomSheetContent> createState() => _CheckoutBottomSheetContentState();
}

class _CheckoutBottomSheetContentState extends State<_CheckoutBottomSheetContent> {
  String _paymentMethod = 'online'; // 'online' or 'offline'
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final actual = double.tryParse(plan.actualPrice ?? '') ?? 0.0;
    final offer = double.tryParse(plan.offerPrice ?? '') ?? 0.0;
    final discount = actual - offer;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 30,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Confirm Subscription',
                style: AppStyles.text18Px.poppins.w600.light,
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name ?? 'Standard Package',
                  style: AppStyles.text16Px.poppins.w600.light,
                ),
                const SizedBox(height: 4),
                Text(
                  '${plan.durationDays ?? 30} Days Validity',
                  style: AppStyles.text13Px.poppins.w400.copyWith(color: Colors.white60),
                ),
                const Divider(height: 24, color: Colors.white12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Actual Price',
                      style: AppStyles.text14Px.poppins.w400.copyWith(color: Colors.white60),
                    ),
                    Text(
                      '₹${actual.toStringAsFixed(0)}',
                      style: AppStyles.text14Px.poppins.w400.copyWith(
                        color: Colors.white60,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (discount > 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Discount Amount',
                        style: AppStyles.text14Px.poppins.w400.copyWith(color: Colors.green),
                      ),
                      Text(
                        '-₹${discount.toStringAsFixed(0)}',
                        style: AppStyles.text14Px.poppins.w400.copyWith(color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Payable',
                      style: AppStyles.text16Px.poppins.w600.light,
                    ),
                    Text(
                      '₹${offer.toStringAsFixed(0)}',
                      style: AppStyles.text20Px.poppins.w700.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Choose Payment Method',
            style: AppStyles.text14Px.poppins.w600.light,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildPaymentMethodCard(
                  id: 'online',
                  title: 'Online Payment',
                  subtitle: 'UPI, Net Banking, Card',
                  icon: Icons.payment,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPaymentMethodCard(
                  id: 'offline',
                  title: 'Cash Payment',
                  subtitle: 'Pay directly at Gym',
                  icon: Icons.currency_rupee,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Button.filled(
            title: _paymentMethod == 'online'
                ? 'Proceed to Pay ₹${offer.toStringAsFixed(0)}'
                : 'Submit Membership Request',
            isLoading: _submitting,
            buttonColor: AppColors.primary,
            disabledButtonColor: AppColors.primary.withOpacity(0.5),
            ontap: _handleCheckout,
            raduis: 12,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _paymentMethod == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _paymentMethod = id;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2C1E1E) : const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.white70,
              size: 28,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppStyles.text13Px.poppins.w600.copyWith(
                color: isSelected ? AppColors.primary : Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppStyles.text10Px.poppins.w400.copyWith(color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCheckout() async {
    setState(() {
      _submitting = true;
    });

    if (_paymentMethod == 'online') {
      Navigator.pop(context);
      widget.cubit.payment();
    } else {
      final success = await widget.cubit.createOfflineMembershipRequest();
      setState(() {
        _submitting = false;
      });
      if (success) {
        Navigator.pop(context);
        showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E1E1E),
              title: Text(
                'Request Submitted',
                style: AppStyles.text16Px.poppins.w600.light,
              ),
              content: Text(
                'Your membership request has been submitted successfully to the gym. Please pay ₹${double.tryParse(widget.plan.offerPrice ?? '')?.toStringAsFixed(0) ?? widget.plan.offerPrice} in cash at the gym counters to activate your plan.',
                style: AppStyles.text13Px.poppins.w400.copyWith(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    context.read<AppCubit>().updateOrganizationId(widget.cubit.orgId);
                    context.pushAndRemoveUntil(const DashboardScreen());
                  },
                  child: Text(
                    'OK',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            );
          },
        );
      } else {
        Dialogs.showSnack(msg: 'Failed to submit request. Please try again.');
      }
    }
  }
}
