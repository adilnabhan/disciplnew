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

  bool _isHealthy = true;
  final TextEditingController _healthIssuesController = TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();

  String? _selectedActivityLevel;
  String? _selectedFitnessLevel;

  @override
  void initState() {
    super.initState();

    // Initialize new fields
    _selectedActivityLevel = widget.customerDetailsModel.activityLevel?.toString();
    _selectedFitnessLevel = widget.customerDetailsModel.fitnessLevel?.toString();
    if (widget.customerDetailsModel.targetWeight != null) {
      _targetWeightController.text = widget.customerDetailsModel.targetWeight.toString();
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
      _healthDetails = [];
    }
  }

  @override
  void dispose() {
    super.dispose();
    for (final element in _healthDetails) {
      element.controller?.dispose();
      element.focusNode?.dispose();
    }
    _healthIssuesController.dispose();
    _targetWeightController.dispose();
  }

  void _onUpdate() {
    if (_formKey.currentState?.validate() ?? false) {
      String? bloodGroup = widget.customerDetailsModel.bloodGroup;
      String? height;
      String? weight;
      int? bfPercentage;

      if (widget.editBodyMetricsOnly) {
        height = _healthDetails[0].controller?.text;
        weight = _healthDetails[1].controller?.text;
      } else {
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

      if (_selectedActivityLevel != null && _selectedActivityLevel!.isNotEmpty) {
        body['activity_level'] = _selectedActivityLevel;
      }
      if (_selectedFitnessLevel != null && _selectedFitnessLevel!.isNotEmpty) {
        body['fitness_level'] = _selectedFitnessLevel;
      }
      final targetWStr = _targetWeightController.text.trim();
      if (targetWStr.isNotEmpty) {
        body['target_weight'] = double.tryParse(targetWStr) ?? targetWStr;
      }

      if (widget.customerDetailsModel.dateOfBirth != null) {
        body['date_of_birth'] = DateFormat('yyyy-MM-dd').format(widget.customerDetailsModel.dateOfBirth!);
      }

      if (widget.editBodyMetricsOnly) {
        body['is_healthy'] = widget.customerDetailsModel.isHealthy ?? true;
        final conditions = widget.customerDetailsModel.healthConditionsOther;
        if (conditions != null && conditions.isNotEmpty) {
          body['health_conditions_other'] = conditions;
        }
      } else {
        body['is_healthy'] = _isHealthy;
        final healthIssuesText = _healthIssuesController.text.trim();
        if (healthIssuesText.isNotEmpty) {
          body['health_conditions_other'] = healthIssuesText;
        }
      }

      print(' passing data is--$body');
      context.read<ProfileCubit>().updateCustomerProfile(
        body: body,
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
              if (_healthDetails.isNotEmpty) ...[
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
              ] else
                const SizedBox(height: 16),

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

                const SizedBox(height: 22),

                // ── Activity Level ──
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activity Level',
                      style: AppStyles.text14Px.poppins.w500.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: [
                        'Sedentary',
                        'Lightly_Active',
                        'Moderately_Active',
                        'Very_Active',
                        'Extra_Active'
                      ].contains(_selectedActivityLevel)
                          ? _selectedActivityLevel
                          : null,
                      decoration: InputDecoration(
                        hintText: 'Select Activity Level',
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
                      items: const [
                        DropdownMenuItem(
                          value: 'Sedentary',
                          child: Text('Sedentary'),
                        ),
                        DropdownMenuItem(
                          value: 'Lightly_Active',
                          child: Text('Lightly Active'),
                        ),
                        DropdownMenuItem(
                          value: 'Moderately_Active',
                          child: Text('Moderately Active'),
                        ),
                        DropdownMenuItem(
                          value: 'Very_Active',
                          child: Text('Very Active'),
                        ),
                        DropdownMenuItem(
                          value: 'Extra_Active',
                          child: Text('Extra Active'),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedActivityLevel = val;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // ── Fitness Level ──
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fitness Level',
                      style: AppStyles.text14Px.poppins.w500.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: ['Beginner', 'Intermediate', 'Advanced']
                              .contains(_selectedFitnessLevel)
                          ? _selectedFitnessLevel
                          : null,
                      decoration: InputDecoration(
                        hintText: 'Select Fitness Level',
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
                      items: const [
                        DropdownMenuItem(
                          value: 'Beginner',
                          child: Text('Beginner'),
                        ),
                        DropdownMenuItem(
                          value: 'Intermediate',
                          child: Text('Intermediate'),
                        ),
                        DropdownMenuItem(
                          value: 'Advanced',
                          child: Text('Advanced'),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedFitnessLevel = val;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // ── Target Weight ──
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target Weight',
                      style: AppStyles.text14Px.poppins.w500.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _targetWeightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      decoration: InputDecoration(
                        hintText: 'E.g., 70.5',
                        hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
                        suffixIcon: SizedBox.square(
                          dimension: 22,
                          child: Center(
                            child: Text('KG', style: AppStyles.text14Px.poppins.w400.dark),
                          ),
                        ),
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
