// import 'package:customer_mobile_app/imports_bindings.dart';
// import 'package:customer_mobile_app/src/features/workout_log/cubit/cubit.dart';
// import 'package:date_picker_timeline/date_picker_widget.dart';
//
// class WorkoutLogScreen extends StatefulWidget {
//   const WorkoutLogScreen({super.key, this.activeMembership});
//
//   final ActiveMembershipModel? activeMembership;
//
//   @override
//   State<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
// }
//
// class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
//   late final WorkoutLogCubit _cubit;
//   final ScrollController _scrollController = ScrollController();
//
//   // 🔥 NEW: Track expand/collapse for each item
//   List<bool> expandedList = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _cubit = WorkoutLogCubit();
//     _fetch();
//   }
//
//   @override
//   void dispose() {
//     _cubit.close();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _fetch() async {
//     // await _cubit.fetchPaymentHistory();
//     // await _cubit.fetchPaymentHistoryDetails();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider.value(
//       value: _cubit,
//       child: Scaffold(
//         appBar: AppBar(
//           leading: const PopButton().center,
//           title: Text('Workout Log', style: AppStyles.text16Px.poppins.w500),
//         ),
//         body: BlocBuilder<WorkoutLogCubit, WorkoutLogState>(
//           builder: (context, state) {
//             return Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 DatePicker(
//                   DateTime.now(),
//                   height: 95,
//                   width: 65,
//                   initialSelectedDate: DateTime.now(),
//                   daysCount: 30, // number of days to scroll
//                   selectionColor: Colors.red, // like your screenshot
//                   selectedTextColor: Colors.white,
//                   dateTextStyle: const TextStyle(
//                     fontSize: 22,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   dayTextStyle: const TextStyle(
//                     fontSize: 12,
//                     color: Colors.black54,
//                   ),
//                   monthTextStyle: const TextStyle(
//                     fontSize: 10,
//                     color: Colors.black54,
//                   ),
//
//                   onDateChange: (date) {
//                     // context.read<WorkoutLogCubit>().selectDate(date);
//                   },
//                 ),
//               ],
//             );
//
//             //   state.paymentHistory.data.fold(
//             //   () => const Center(child: CircularProgressIndicator()),
//             //   (either) => either.fold(
//             //     (error) {
//             //       return error
//             //           .maybeWhen(
//             //             network: (e) => ErrorUi.network(onTap: _fetch),
//             //             notFound: (e) => ErrorUi.notFound(onTap: _fetch),
//             //             orElse: () => ErrorUi.server(onTap: _fetch),
//             //           )
//             //           .center;
//             //     },
//             //     (paymentHistory) {
//             //       final results = paymentHistory.memberships ?? [];
//             //
//             //       if (results.isEmpty) {
//             //         return _emptyPaymentsUi(context);
//             //       }
//             //
//             //       // 🔥 Initialize expansion states when list length changes
//             //       if (expandedList.length != results.length) {
//             //         expandedList = List.generate(results.length, (_) => false);
//             //       }
//             //
//             //       return ListView.separated(
//             //         controller: _scrollController,
//             //         padding: const EdgeInsets.symmetric(
//             //           horizontal: 16,
//             //           vertical: 8,
//             //         ),
//             //         itemCount: results.length,
//             //         separatorBuilder: (_, __) => const SizedBox(height: 16),
//             //         itemBuilder: (context, index) {
//             //           return EmiCard(
//             //             data: results[index],
//             //             isExpanded: expandedList[index],
//             //             onExpandTap: () {
//             //               setState(() {
//             //                 expandedList[index] = !expandedList[index];
//             //               });
//             //             },
//             //           );
//             //         },
//             //       );
//             //     },
//             //   ),
//             // );
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _emptyPaymentsUi(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 gradient: LinearGradient(
//                   colors: [
//                     AppColors.primary.withAlpha(32),
//                     AppColors.primary.withAlpha(8),
//                   ],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//               ),
//               padding: const EdgeInsets.all(32),
//               child: Icon(
//                 Icons.receipt_long_rounded,
//                 size: 80,
//                 color: AppColors.primary.withAlpha(178),
//               ),
//             ),
//             const SizedBox(height: 32),
//             Text(
//               'No Payments Yet',
//               style: AppStyles.text22Px.poppins.w700.dark,
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 12),
//             Text(
//               "You haven't made any payments yet.\nStart your fitness journey today!",
//               style: AppStyles.text16Px.poppins.w400.textGrey,
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 32),
//             Button.filled(
//               title: 'Explore Fitness Centers',
//               ontap: () {
//                 context.read<DashboardCubit>().changeNav(index: 1);
//               },
//               icon: SvgPicture.asset(
//                 'assets/images/svg/icons/search.svg',
//                 width: 24,
//                 height: 24,
//                 colorFilter: const ColorFilter.mode(
//                   Colors.white,
//                   BlendMode.srcIn,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
