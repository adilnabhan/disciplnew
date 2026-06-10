import 'package:customer_mobile_app/imports_bindings.dart';

class HealthStep extends StatefulWidget {
  final void Function(
    bool? healthStatus,
    List<String> selectedConditions,
    int? selectedRating,
    String? otherConditions,
  )
  onNext;

  final void Function() onSkip;
  final SentOtpEntity? sentOtpEntity;
  final ConstantChoicesModel? choices;
  final bool isLoading;
  final CustomerDetailsModel? customerDetailsModel;

  const HealthStep({
    super.key,
    required this.onNext,
    required this.onSkip,
    this.choices,
    this.isLoading = false,
    this.sentOtpEntity,
    this.customerDetailsModel,
  });

  @override
  State<HealthStep> createState() => HealthStepState();
}

class HealthStepState extends State<HealthStep> {
  TextEditingController otherCtrl = TextEditingController();

  final healthCondition = [
    {'value': 'healthy', 'label': 'I’m Healthy'},
    {'value': 'condition', 'label': 'I have a health condition'},
  ];

  String selectedHealthStatus = '';
  List<String> selectedOptions = [];
  int? selectedRating;

  @override
  void initState() {
    super.initState();

    if (widget.customerDetailsModel != null) {
      selectedHealthStatus =
          widget.customerDetailsModel!.isHealthy == false
              ? 'condition'
              : 'healthy';

      selectedOptions = List.from(
        widget.customerDetailsModel?.healthConditions ?? [],
      );

      selectedRating = widget.customerDetailsModel?.activeScale;

      otherCtrl.text = widget.customerDetailsModel?.healthConditionsOther ?? "";
    }
  }

  void validateAndProceed() {
    if (selectedHealthStatus.isEmpty) {
      Dialogs.showSnack(msg: 'Please select your health status.');
      return;
    }

    if (selectedHealthStatus == 'condition' && selectedOptions.isEmpty) {
      Dialogs.showSnack(msg: 'Please select at least one health condition.');
      return;
    }

    if (selectedRating == null) {
      Dialogs.showSnack(msg: 'Please select your activity rating.');
      return;
    }

    widget.onNext(
      selectedHealthStatus == 'healthy',
      selectedOptions,
      selectedRating,
      otherCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (widget.customerDetailsModel == null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Health, Your Start Point ❤️',
                style: AppStyles.text32Px.poppins.w600.dark,
              ),
              const SizedBox(height: 8),
              Text(
                'Every fitness journey begins with where you are today.',
                style: AppStyles.text15Px.poppins.w400.textGrey,
              ),
              const SizedBox(height: 24),
            ],
          )
        else
          const SizedBox(),

        /// RADIO BUTTON
        Question.radioBtn(
          heading: 'Are you healthy?',
          value: healthCondition,
          groupValue: selectedHealthStatus,
          onChanged: (value) {
            setState(() {
              selectedHealthStatus = value.toString();

              if (selectedHealthStatus == 'healthy') {
                selectedOptions.clear();
                otherCtrl.clear();
              } else if (selectedHealthStatus == 'condition') {
                if (widget.customerDetailsModel != null) {
                  selectedOptions = List.from(
                    widget.customerDetailsModel?.healthConditions ?? [],
                  );
                  otherCtrl.text =
                      widget.customerDetailsModel?.healthConditionsOther ?? "";
                }
              }
            });
          },
        ),

        /// MULTISELECT (ONLY WHEN CONDITION SELECTED)
        if (selectedHealthStatus == 'condition')
          MultiSelectDropdown(
            otherCtrl: otherCtrl,
            hintText: 'Select health condition/conditions',
            value:
                widget.choices!.data.healthConditions
                    .map((e) => {'value': e.value, 'label': e.label})
                    .toList(),
            selected: selectedOptions,
            onSelectionChanged: (newList) {
              setState(() {
                selectedOptions = newList;
              });
            },
          ),

        const SizedBox(height: 24),

        /// RATING SELECTOR
        Text(
          'How active are you on a scale of 1 to 5?',
          style: TextStyle(
            fontFamily: 'poppins',
            color: AppColors.dark,
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        RatingSelector(
          currentRating: selectedRating,
          onChanged: (rating) {
            setState(() {
              selectedRating = rating;
            });
          },
        ),

        const SizedBox(height: 32),

        /// BUTTONS
        Row(
          children: [
            const SizedBox(width: 12),
            Expanded(
              child: Button.filled(
                isLoading: widget.isLoading,
                title: widget.customerDetailsModel == null ? 'Next' : 'Update',
                ontap: validateAndProceed,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
        if (widget.customerDetailsModel == null)
          Text(
            textAlign: TextAlign.center,
            'Awareness is the first step towards\n progress',
            style: AppStyles.text15Px.poppins.w400.textGrey,
          )
        else
          const SizedBox(),
      ],
    );
  }
}

class MultiSelectDropdown extends StatefulWidget {
  final String hintText;
  final List<Map<String, dynamic>> value;
  final List<String> selected;
  final Color? activeColor;
  final TextEditingController? otherCtrl;
  final void Function(List<String>) onSelectionChanged;

  const MultiSelectDropdown({
    super.key,
    required this.hintText,
    required this.value,
    required this.selected,
    required this.onSelectionChanged,
    this.otherCtrl,
    this.activeColor,
  });

  @override
  State<MultiSelectDropdown> createState() => _MultiSelectDropdownState();
}

class _MultiSelectDropdownState extends State<MultiSelectDropdown> {
  late List<Map<String, dynamic>> _options;
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _options = List.from(widget.value);
    _selected = List.from(widget.selected);
  }

  @override
  void didUpdateWidget(covariant MultiSelectDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selected != widget.selected) {
      setState(() {
        _selected = List.from(widget.selected);
      });
    }
  }

  void _openMultiSelectSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setInnerState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                20,
                16,
                MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.hintText,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10.h),

                  /// OPTIONS LIST
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _options.length,
                      itemBuilder: (context, index) {
                        final item = _options[index];
                        final isChecked = _selected.contains(item['value']);

                        return Row(
                          children: [
                            Checkbox(
                              activeColor:
                                  widget.activeColor ?? AppColors.primary,
                              value: isChecked,
                              onChanged: (val) {
                                setInnerState(() {
                                  if (val ?? false) {
                                    _selected.add(item['value'].toString());
                                  } else {
                                    _selected.remove(item['value']);
                                  }
                                });
                              },
                            ),
                            Expanded(
                              child: Text(
                                item['label'].toString(),
                                style: TextStyle(fontSize: 15.sp),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  SizedBox(height: 10.h),

                  /// SHOW "OTHER" FIELD IF SELECTED
                  if (_selected.contains("Other"))
                    TextField(
                      controller: widget.otherCtrl,
                      decoration: InputDecoration(
                        hintText: 'Add other condition',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),

                  SizedBox(height: 15.h),

                  /// DONE BUTTON
                  GestureDetector(
                    onTap: () {
                      widget.onSelectionChanged(_selected);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedItems =
        _options.where((item) => _selected.contains(item['value'])).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _openMultiSelectSheet,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selectedItems.isEmpty
                        ? widget.hintText
                        : 'Selected ${selectedItems.length} condition(s)',
                    style: TextStyle(
                      color: selectedItems.isEmpty ? Colors.grey : Colors.black,
                      fontSize: 15.sp,
                    ),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              ],
            ),
          ),
        ),

        /// SELECTED TAGS
        if (selectedItems.isNotEmpty) ...[
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children:
                selectedItems.map((item) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(item['label'].toString()),
                        // SizedBox(width: 5.w),
                        // GestureDetector(
                        //   onTap: () {
                        //     setState(() {
                        //       _selected.remove(item['value']);
                        //     });
                        //   },
                        //   child: const Icon(
                        //     Icons.close,
                        //     size: 16,
                        //     color: Colors.black54,
                        //   ),
                        // ),
                      ],
                    ),
                  );
                }).toList(),
          ),
          if (widget.otherCtrl?.length == 0)
            const SizedBox()
          else
            Container(
              margin: const EdgeInsets.only(top: 10),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.otherCtrl!.text,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // SizedBox(width: 5.w),
                  // GestureDetector(
                  //   onTap: () {
                  //     setState(() {
                  //       widget.otherCtrl!.clear();
                  //     });
                  //   },
                  //   child: const Icon(
                  //     Icons.close,
                  //     size: 16,
                  //     color: Colors.black54,
                  //   ),
                  // ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class RatingSelector extends StatefulWidget {
  final int? currentRating;
  final void Function(int rating) onChanged;
  const RatingSelector({
    super.key,
    required this.onChanged,
    this.currentRating,
  });

  @override
  State<RatingSelector> createState() => _RatingSelectorState();
}

class _RatingSelectorState extends State<RatingSelector> {
  int selectedRating = 0;

  @override
  void initState() {
    super.initState();
    selectedRating = widget.currentRating ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(5, (index) {
        int value = index + 1;
        bool isSelected = selectedRating == value;

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedRating = value;
            });
            widget.onChanged(selectedRating);
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSelected ? Colors.red : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.red : Colors.grey,
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$value',
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        );
      }),
    );
  }
}
