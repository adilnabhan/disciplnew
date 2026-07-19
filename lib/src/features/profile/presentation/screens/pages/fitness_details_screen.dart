import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:intl/intl.dart';

class FitnessDetailsScreen extends StatefulWidget {
  final CustomerDetailsModel customerDetailsModel;
  final bool editBodyMetricsOnly;

  const FitnessDetailsScreen({
    required this.customerDetailsModel,
    this.editBodyMetricsOnly = false,
    super.key,
  });

  @override
  State<FitnessDetailsScreen> createState() => FitnessDetailsScreenState();
}

class FitnessDetailsScreenState extends State<FitnessDetailsScreen> {
  late final List<FieldData<dynamic>> _healthDetails;
  final _formKey = GlobalKey<FormState>();

  DateTime? _selectedDateOfBirth;
  bool _isHealthy = true;
  final TextEditingController _healthIssuesController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize age / DOB
    _selectedDateOfBirth = widget.customerDetailsModel.dateOfBirth;
    if (_selectedDateOfBirth != null) {
      _dobController.text = DateFormat('dd/MM/yyyy').format(_selectedDateOfBirth!);
    }

    // Initialize health status
    _isHealthy = widget.customerDetailsModel.isHealthy ?? true;

    // Initialize health issues
    final conditions = widget.customerDetailsModel.healthConditions;
    if (conditions != null && conditions.isNotEmpty) {
      _healthIssuesController.text = conditions.join(', ');
    }
    final otherConditions = widget.customerDetailsModel.healthConditionsOther;
    if (otherConditions != null && otherConditions.isNotEmpty) {
      if (_healthIssuesController.text.isNotEmpty) {
        _healthIssuesController.text += ', $otherConditions';
      } else {
        _healthIssuesController.text = otherConditions;
      }
    }

    if (widget.editBodyMetricsOnly) {
      _healthDetails = [
        FieldData(
          type: FieldType.word,
          textInputAction: TextInputAction.next,
          label: 'Height',
          requiredLabel: true,
          controller: TextEditingController(
            text: widget.customerDetailsModel.height,
          ),
          focusNode: FocusNode(),
          keyboardType: TextInputType.number,
          maxLength: 3,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Height is required';
            }
            return null;
          },
          onSubmitted: (value) {
            _healthDetails[1].focusNode?.requestFocus();
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: '0',
            hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
            suffixIcon: SizedBox.square(
              dimension: 22,
              child: Center(
                child: Text('CM', style: AppStyles.text14Px.poppins.w400.dark),
              ),
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide.none,
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
        FieldData(
          type: FieldType.word,
          textInputAction: TextInputAction.done,
          label: 'Weight',
          requiredLabel: true,
          controller: TextEditingController(
            text: widget.customerDetailsModel.weight,
          ),
          focusNode: FocusNode(),
          keyboardType: TextInputType.number,
          maxLength: 3,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Weight is required';
            }
            return null;
          },
          onSubmitted: (value) {
            _healthDetails[1].focusNode?.unfocus();
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: '0',
            hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
            suffixIcon: SizedBox.square(
              dimension: 22,
              child: Center(
                child: Text('KG', style: AppStyles.text14Px.poppins.w400.dark),
              ),
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide.none,
            ),
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide.none,
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ];
    } else {
      _healthDetails = [
        FieldData(
          type: FieldType.radio,
          textInputAction: TextInputAction.done,
          label: 'Blood Group',
          requiredLabel: true,
          controller: TextEditingController(
            text: (widget.customerDetailsModel.bloodGroup == null ||
                    widget.customerDetailsModel.bloodGroup!.toLowerCase() == 'unknown')
                ? ''
                : widget.customerDetailsModel.bloodGroup,
          ),
          focusNode: FocusNode(),
          items: [
            (label: 'A+', value: 'A+'),
            (label: 'A-', value: 'A-'),
            (label: 'B+', value: 'B+'),
            (label: 'B-', value: 'B-'),
            (label: 'AB+', value: 'AB+'),
            (label: 'AB-', value: 'AB-'),
            (label: 'O+', value: 'O+'),
            (label: 'O-', value: 'O-'),
          ],
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'Blood Group must be selected';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Select Blood Group',
            hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide(color: AppColors.borderGrey),
            ),
          ),
        ),
      ];
    }
  }

  @override
  void dispose() {
    super.dispose();
    for (final element in _healthDetails) {
      element.controller?.dispose();
      element.focusNode?.dispose();
    }
    _dobController.dispose();
    _healthIssuesController.dispose();
  }

  void _pickDateOfBirth() async {
    final first = DateTime(1900);
    final last = DateTime.now();
    DateTime initial = _selectedDateOfBirth ?? DateTime(2000);
    if (initial.isAfter(last)) {
      initial = last;
    }
    if (initial.isBefore(first)) {
      initial = first;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _onUpdate() {
    if (_formKey.currentState?.validate() ?? false) {
      String? bloodGroup;
      String? height;
      String? weight;
      int? bfPercentage;

      if (widget.editBodyMetricsOnly) {
        bloodGroup = widget.customerDetailsModel.bloodGroup;
        height = _healthDetails[0].controller?.text;
        weight = _healthDetails[1].controller?.text;
      } else {
        bloodGroup = _healthDetails[0].controller?.text;
        height = widget.customerDetailsModel.height;
        weight = widget.customerDetailsModel.weight;
      }

      final rawBf = widget.customerDetailsModel.bfPercentage;
      if (rawBf != null) {
        if (rawBf is num) {
          bfPercentage = rawBf.toInt();
        } else if (rawBf is String) {
          bfPercentage = int.tryParse(rawBf);
        }
      }

      final body = <String, dynamic>{
        'blood_group': bloodGroup,
        'height': height,
        'weight': weight,
        'bf_percentage': bfPercentage,
      };

      if (widget.editBodyMetricsOnly) {
        body['is_healthy'] = widget.customerDetailsModel.isHealthy ?? true;
        if (widget.customerDetailsModel.dateOfBirth != null) {
          body['date_of_birth'] = DateFormat('yyyy-MM-dd').format(widget.customerDetailsModel.dateOfBirth!);
        }
        final conditions = widget.customerDetailsModel.healthConditionsOther;
        if (conditions != null && conditions.isNotEmpty) {
          body['health_conditions_other'] = conditions;
        }
      } else {
        body['is_healthy'] = _isHealthy;
        if (_selectedDateOfBirth != null) {
          body['date_of_birth'] = DateFormat('yyyy-MM-dd').format(_selectedDateOfBirth!);
        }
        final healthIssuesText = _healthIssuesController.text.trim();
        if (healthIssuesText.isNotEmpty) {
          body['health_conditions_other'] = healthIssuesText;
        }
      }

      print(' passing data is--$body');
      context.read<ProfileCubit>().updateHealthProfile(
        bloodGroup: bloodGroup ?? '',
        height: height ?? '',
        weight: weight ?? '',
        extraBody: body,
      );
    } else {
      Dialogs.showSnack(msg: 'Please fill all the fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        state.updateProfileDetails?.fold(
          () => null,
          (t) => t.fold(
            (l) {
              Dialogs.showSnack(msg: l.msg);
            },
            (r) {
              Dialogs.showSnack(msg: 'Health details updated successfully');
              context.pop();
            },
          ),
        );
      },
      child: Scaffold(
        backgroundColor: widget.editBodyMetricsOnly ? const Color(0xFFF5F5F7) : null,
        appBar: AppBar(
          leading: const PopButton().center,
          title: Text(
            widget.editBodyMetricsOnly ? 'Body Metrix' : 'Health Details',
            style: AppStyles.text16Px.poppins.w500,
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              const SizedBox(height: 32),
              ListView.separated(
                itemCount: _healthDetails.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: 22);
                },
                itemBuilder: (BuildContext context, int index) {
                  return Field(data: _healthDetails[index]);
                },
              ),
              const SizedBox(height: 22),

              if (widget.editBodyMetricsOnly) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: Color(0xFF2E7D32),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tip',
                              style: AppStyles.text14Px.poppins.w600.copyWith(
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Keep your body metrics updated to get more accurate insights and recommendations.',
                              style: AppStyles.text12Px.poppins.w400.copyWith(
                                color: AppColors.textDark,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
              ],

              if (!widget.editBodyMetricsOnly) ...[
                // ── Age / Date of Birth ──
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        text: 'Date of Birth',
                        style: AppStyles.text14Px.poppins.w500.copyWith(
                          color: AppColors.textDark,
                        ),
                        children: const [
                          TextSpan(
                            text: ' *',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickDateOfBirth,
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: _dobController,
                          decoration: InputDecoration(
                            hintText: 'Select Date of Birth',
                            hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
                            suffixIcon: const Icon(Icons.calendar_today, size: 20),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide(color: AppColors.borderGrey),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide(color: AppColors.borderGrey),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_selectedDateOfBirth != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'Age: ${DateTime.now().year - _selectedDateOfBirth!.year} years',
                          style: AppStyles.text12Px.poppins.w400.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 22),

                // ── Health Status ──
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Status',
                      style: AppStyles.text14Px.poppins.w500.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _isHealthy = true;
                              _healthIssuesController.clear();
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isHealthy
                                    ? AppColors.primary.withOpacity(0.1)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _isHealthy
                                      ? AppColors.primary
                                      : AppColors.borderGrey,
                                  width: _isHealthy ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _isHealthy
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    size: 18,
                                    color: _isHealthy
                                        ? AppColors.primary
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Healthy',
                                    style: AppStyles.text14Px.poppins.w500.copyWith(
                                      color: _isHealthy
                                          ? AppColors.primary
                                          : AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isHealthy = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isHealthy
                                    ? Colors.red.withOpacity(0.1)
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: !_isHealthy
                                      ? Colors.red
                                      : AppColors.borderGrey,
                                  width: !_isHealthy ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    !_isHealthy
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    size: 18,
                                    color: !_isHealthy
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Not Healthy',
                                    style: AppStyles.text14Px.poppins.w500.copyWith(
                                      color: !_isHealthy
                                          ? Colors.red
                                          : AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (!_isHealthy) ...[
                  const SizedBox(height: 22),
                  // ── Health Issues ──
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Health Issues',
                        style: AppStyles.text14Px.poppins.w500.copyWith(
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _healthIssuesController,
                        maxLines: 3,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: 'E.g., Diabetes, Back pain, Asthma...',
                          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: AppColors.borderGrey),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: AppColors.borderGrey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
        bottomNavigationBar: BlocBuilder<ProfileCubit, ProfileState>(
          buildWhen: (p, c) {
            return p.updateProfileDetails != c.updateProfileDetails;
          },
          builder: (context, state) {
            return Container(
              color: widget.editBodyMetricsOnly ? const Color(0xFFF5F5F7) : null,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: 24,
                  ),
                  child: Button.filled(
                    title: 'Update',
                    ontap: _onUpdate,
                    isLoading: state.updateProfileDetails?.isNone() ?? false,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
