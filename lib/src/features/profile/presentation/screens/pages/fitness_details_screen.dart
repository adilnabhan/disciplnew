import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:intl/intl.dart';

class FitnessDetailsScreen extends StatefulWidget {
  const FitnessDetailsScreen({required this.customerDetailsModel, super.key});

  final CustomerDetailsModel customerDetailsModel;

  @override
  State<FitnessDetailsScreen> createState() => FitnessDetailsScreenState();
}

class FitnessDetailsScreenState extends State<FitnessDetailsScreen> {
  late final List<FieldData<dynamic>> _healthDetails;
  final _formKey = GlobalKey<FormState>();

  DateTime? _selectedDateOfBirth;
  bool _isHealthy = true;
  String? _selectedActivityLevel;
  String? _selectedFitnessGoal;
  final TextEditingController _healthIssuesController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  @override
  void initState() {
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

    // Initialize activity level
    _selectedActivityLevel = widget.customerDetailsModel.activityLevel;
    if (_selectedActivityLevel != null) {
      _selectedActivityLevel = _selectedActivityLevel!.replaceAll(' ', '_');
    }

    // Initialize fitness goal
    _selectedFitnessGoal = widget.customerDetailsModel.fitnessGoal;
    if (_selectedFitnessGoal != null) {
      _selectedFitnessGoal = _selectedFitnessGoal!.replaceAll(' ', '_');
    }

    _healthDetails = [
      FieldData(
        type: FieldType.radio,
        textInputAction: TextInputAction.done,
        label: 'Blood Group',
        requiredLabel: true,
        controller: TextEditingController(
          text: widget.customerDetailsModel.bloodGroup,
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
        onValueChanged: (p0) {
          _healthDetails[1].focusNode?.requestFocus();
        },
        onSubmitted: (value) {
          _healthDetails[1].focusNode?.requestFocus();
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
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.done,
        label: 'Height',
        requiredLabel: true,
        controller: TextEditingController(
          text: widget.customerDetailsModel.height,
        ),
        focusNode: FocusNode(),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        maxLength: 5,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}\.?\d{0,1}')),
          LengthLimitingTextInputFormatter(5),
        ],
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Height is required';
          }
          return null;
        },
        onSubmitted: (value) {
          _healthDetails[2].focusNode?.requestFocus();
        },
        decoration: InputDecoration(
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
            borderSide: BorderSide(color: AppColors.borderGrey),
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
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        maxLength: 5,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}\.?\d{0,1}')),
          LengthLimitingTextInputFormatter(5),
        ],
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Weight is required';
          }
          return null;
        },
        onSubmitted: (value) {
          _healthDetails[3].focusNode?.requestFocus();
        },
        decoration: InputDecoration(
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
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.done,
        label: 'Waist Circumference (cm)',
        requiredLabel: false,
        controller: TextEditingController(
          text: widget.customerDetailsModel.waistCircumference?.toString() ?? '',
        ),
        focusNode: FocusNode(),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        maxLength: 5,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}\.?\d{0,1}')),
          LengthLimitingTextInputFormatter(5),
        ],
        validator: (value) {
          if (value != null && value.isNotEmpty) {
            final v = double.tryParse(value);
            if (v == null || v < 30 || v > 200) {
              return 'Must be between 30 and 200 cm';
            }
          }
          return null;
        },
        onSubmitted: (value) {
          _healthDetails[4].focusNode?.requestFocus();
        },
        decoration: InputDecoration(
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
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.done,
        label: 'Hip Circumference (cm)',
        requiredLabel: false,
        controller: TextEditingController(
          text: widget.customerDetailsModel.hipCircumference?.toString() ?? '',
        ),
        focusNode: FocusNode(),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        maxLength: 5,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d{0,3}\.?\d{0,1}')),
          LengthLimitingTextInputFormatter(5),
        ],
        validator: (value) {
          if (value != null && value.isNotEmpty) {
            final v = double.tryParse(value);
            if (v == null || v < 30 || v > 200) {
              return 'Must be between 30 and 200 cm';
            }
          }
          return null;
        },
        onSubmitted: (value) {
          _healthDetails[5].focusNode?.requestFocus();
        },
        decoration: InputDecoration(
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
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.done,
        label: 'Neck Circumference (cm)',
        requiredLabel: false,
        controller: TextEditingController(
          text: widget.customerDetailsModel.neckCircumference?.toString() ?? '',
        ),
        focusNode: FocusNode(),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        maxLength: 4,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d{0,2}\.?\d{0,1}')),
          LengthLimitingTextInputFormatter(4),
        ],
        validator: (value) {
          if (value != null && value.isNotEmpty) {
            final v = double.tryParse(value);
            if (v == null || v < 20 || v > 70) {
              return 'Must be between 20 and 70 cm';
            }
          }
          return null;
        },
        onSubmitted: (value) {
          _healthDetails[5].focusNode?.unfocus();
        },
        decoration: InputDecoration(
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
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),
    ];
    super.initState();
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

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(now.year - 25),
      firstDate: DateTime(1940),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDateOfBirth = picked;
        _dobController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _onUpdate() {
    if (_formKey.currentState?.validate() ?? false) {
      /// Health Details
      final bloodGroup = _healthDetails[0].controller?.text;
      final height = _healthDetails[1].controller?.text;
      final weight = _healthDetails[2].controller?.text;
      final waistCircumference = _healthDetails[3].controller?.text;
      final hipCircumference = _healthDetails[4].controller?.text;
      final neckCircumference = _healthDetails[5].controller?.text;

      final body = <String, dynamic>{
        'blood_group': bloodGroup,
        'height': height,
        'weight': weight,
        'is_healthy': _isHealthy,
      };

      // Add date_of_birth if selected
      if (_selectedDateOfBirth != null) {
        body['date_of_birth'] = DateFormat('yyyy-MM-dd').format(_selectedDateOfBirth!);
      }

      // Add health issues
      final healthIssuesText = _healthIssuesController.text.trim();
      if (healthIssuesText.isNotEmpty) {
        body['health_conditions_other'] = healthIssuesText;
      }

      // Add measurement fields
      if (waistCircumference != null && waistCircumference.isNotEmpty) {
        body['waist_circumference'] = double.tryParse(waistCircumference);
      }
      if (hipCircumference != null && hipCircumference.isNotEmpty) {
        body['hip_circumference'] = double.tryParse(hipCircumference);
      }
      if (neckCircumference != null && neckCircumference.isNotEmpty) {
        body['neck_circumference'] = double.tryParse(neckCircumference);
      }
      if (_selectedActivityLevel != null && _selectedActivityLevel!.isNotEmpty) {
        body['activity_level'] = _selectedActivityLevel;
      }
      if (_selectedFitnessGoal != null && _selectedFitnessGoal!.isNotEmpty) {
        body['fitness_goal'] = _selectedFitnessGoal;
      }

      print(' passing data is--$body');
      context.read<ProfileCubit>().updateHealthProfile(
        bloodGroup: bloodGroup!,
        height: height!,
        weight: weight!,
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
        appBar: AppBar(
          leading: const PopButton().center,
          title: Text(
            'Fitness Details',
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
                    value: _selectedActivityLevel,
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
                      DropdownMenuItem(value: 'Sedentary', child: Text('Sedentary')),
                      DropdownMenuItem(value: 'Lightly_Active', child: Text('Lightly Active')),
                      DropdownMenuItem(value: 'Moderately_Active', child: Text('Moderately Active')),
                      DropdownMenuItem(value: 'Very_Active', child: Text('Very Active')),
                      DropdownMenuItem(value: 'Extra_Active', child: Text('Extra Active')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedActivityLevel = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // ── Fitness Goal ──
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fitness Goal',
                    style: AppStyles.text14Px.poppins.w500.copyWith(
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedFitnessGoal,
                    decoration: InputDecoration(
                      hintText: 'Select Fitness Goal',
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
                      DropdownMenuItem(value: 'Weight_Loss', child: Text('Weight Loss')),
                      DropdownMenuItem(value: 'Muscle_Gain', child: Text('Muscle Gain')),
                      DropdownMenuItem(value: 'Fat_Loss', child: Text('Fat Loss')),
                      DropdownMenuItem(value: 'Maintain_Weight', child: Text('Maintain Weight')),
                      DropdownMenuItem(value: 'Improve_Fitness', child: Text('Improve Fitness')),
                      DropdownMenuItem(value: 'Athletic_Performance', child: Text('Athletic Performance')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedFitnessGoal = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 22),

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
                          onTap: () => setState(() => _isHealthy = true),
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

              const SizedBox(height: 32),
            ],
          ),
        ),
        bottomNavigationBar: BlocBuilder<ProfileCubit, ProfileState>(
          buildWhen: (p, c) {
            return p.updateProfileDetails != c.updateProfileDetails;
          },
          builder: (context, state) {
            return Button.filled(
              title: 'Update',
              ontap: _onUpdate,
              isLoading: state.updateProfileDetails?.isNone() ?? false,
            ).pad(16);
          },
        ),
      ),
    );
  }
}
