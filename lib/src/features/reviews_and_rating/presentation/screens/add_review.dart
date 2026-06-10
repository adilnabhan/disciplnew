import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class AaddReviewScreen extends StatefulWidget {
  const AaddReviewScreen({required this.membership, super.key});

  final ActiveMembershipModel membership;

  @override
  State<AaddReviewScreen> createState() => _AaddReviewScreenState();
}

class _AaddReviewScreenState extends State<AaddReviewScreen> {
  final controller = TextEditingController();
  final _addReviewCubit = AddReviewCubit();
  final _formKey = GlobalKey<FormState>();
  double _rating = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    _formKey.currentState?.dispose();
    _addReviewCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membership = widget.membership;
    final outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8), // Reduced radius
      borderSide: BorderSide(
        color: Colors.grey.withAlpha(100), // Grey border when focused
        width: 1.5,
      ),
    );
    return BlocProvider.value(
      value: _addReviewCubit,
      child: BlocListener<AddReviewCubit, AddReviewState>(
        listener: (context, state) {
          state.addReview?.fold(
            () {},
            (t) => t.fold(
              (l) {
                Dialogs.showSnack(msg: l.msg);
              },
              (r) {
                context.pushAndRemoveUntil(const DashboardScreen());
              },
            ),
          );
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            appBar: AppBar(title: const Text('Add Review')),
            body: ListView(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              children: [
                // Fitness center info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        membership.organization?.logo ?? '',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            membership.organization?.name ?? '-',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              (membership.organization?.category?.isNotEmpty ??
                                      false)
                                  ? membership.organization!.category!.first
                                  : 'Gym',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Joined Date',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '-  ',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      ),
                      Text(
                        membership.startDate != null
                            ? DateFormat(
                              'dd MMM yyyy',
                            ).format(membership.startDate!)
                            : '-',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text('Rating', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                  itemBuilder:
                      (context, _) =>
                          const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _rating = rating;
                    });
                  },
                ),
                const SizedBox(height: 32),
                Text('Reviews', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    textInputAction:
                        TextInputAction
                            .done, // 👈 shows DONE button on iOS keyboard
                    onFieldSubmitted: (_) {
                      FocusScope.of(
                        context,
                      ).unfocus(); // 👈 hides the keyboard when DONE pressed
                    },
                    controller: controller,
                    minLines: 5,
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText: 'Type here',
                      border: outlineInputBorder,
                      enabledBorder: outlineInputBorder,
                      focusedBorder: outlineInputBorder,
                      errorBorder: outlineInputBorder.copyWith(
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: outlineInputBorder.copyWith(
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      filled: false,
                      fillColor: Colors.transparent,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your review';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey, // You can adjust the color as needed
                    width: 0.5, // You can adjust the width as needed
                  ),
                ),
              ),
              child: BlocBuilder<AddReviewCubit, AddReviewState>(
                buildWhen:
                    (previous, current) =>
                        previous.addReview != current.addReview,
                builder: (context, state) {
                  return Button.filled(
                    title: 'Add Review',
                    isLoading: state.addReview?.isNone() ?? false,
                    ontap: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        print('id---${widget.membership.id!}');
                        _addReviewCubit.addReview(
                          organizationId: widget.membership.organization!.id!,
                          rating: _rating.toInt(),
                          comment: controller.text,
                        );
                      }
                    },
                  );
                },
              ).pxy(x: 16, y: 24),
            ),
          ),
        ),
      ),
    );
  }
}
