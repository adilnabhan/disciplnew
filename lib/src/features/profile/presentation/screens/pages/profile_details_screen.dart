import 'package:customer_mobile_app/imports_bindings.dart';
import 'package:customer_mobile_app/src/features/auth/login/domain/repositories/auth_repository.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({
    required this.customerDetailsModel,
    super.key,
    this.choicesModel,
  });
  final ConstantChoicesModel? choicesModel;
  final CustomerDetailsModel customerDetailsModel;

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  late final ProfileCubit _profileCubit;
  late final List<FieldData<dynamic>> _personalDetails;
  final _formKey = GlobalKey<FormState>();
  XFile? _pickedImage;
  List<Profession> _professions = [];
  String? _customProfession;

  @override
  void initState() {
    _profileCubit = context.read<ProfileCubit>();
    _customProfession = widget.customerDetailsModel.otherProfession;

    _personalDetails = [
      /// ----------------------------------------
      /// 0 - First Name
      /// ----------------------------------------
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.next,
        label: 'First Name',
        requiredLabel: true,
        validator: (value) {
          if (value?.trim().isEmpty ?? true) {
            return 'First name is required';
          }
          return null;
        },
        onSubmitted: (value) {
          _personalDetails[1].focusNode?.requestFocus();
        },
        controller: TextEditingController(
          text: widget.customerDetailsModel.firstName,
        ),
        // focusNode: FocusNode(),
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
          hintText: 'Enter First Name',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),

      /// ----------------------------------------
      /// 1 - Last Name
      /// ----------------------------------------
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.next,
        label: 'Last Name',
        requiredLabel: true,
        validator: (value) {
          if (value?.trim().isEmpty ?? true) {
            return 'Last name is required';
          }
          return null;
        },
        onSubmitted: (value) {
          _personalDetails[2].focusNode?.requestFocus();
        },
        controller: TextEditingController(
          text: widget.customerDetailsModel.lastName,
        ),
        focusNode: FocusNode(),
        keyboardType: TextInputType.name,
        decoration: InputDecoration(
          hintText: 'Enter Last Name',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),

      /// ----------------------------------------
      /// 2 - Email Address
      /// ----------------------------------------
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.next,
        label: 'Email Address',
        requiredLabel: true,
        readOnly: false,
        controller: TextEditingController(
          text: widget.customerDetailsModel.email ?? '',
        ),
        focusNode: FocusNode(),
        validator: (value) {
          final trimmed = value?.trim();
          if (trimmed == null || trimmed.isEmpty) {
            return 'Please enter your email address.';
          }
          if (!RegExp(
            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
          ).hasMatch(trimmed)) {
            return 'Please enter a valid email address.';
          }
          return null;
        },
        onSubmitted: (value) {
          _personalDetails[3].focusNode?.requestFocus();
        },
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'Enter your email',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),

      /// ----------------------------------------
      /// 3 - Phone Number (NEW FIELD)
      /// ----------------------------------------
      FieldData(
        type: FieldType.word,
        textInputAction: TextInputAction.next,
        label: 'Phone Number',
        requiredLabel: true,
        readOnly: true,
        controller: TextEditingController(
          text: widget.customerDetailsModel.mobileNumber ?? '',
        ),
        focusNode: FocusNode(),
        validator: (value) {
          if (value?.trim().isEmpty ?? true) {
            return 'Phone number is required';
          }
          return null;
        },
        onSubmitted: (value) {
          _personalDetails[4].focusNode?.requestFocus(); // next = gender
        },
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          hintText: 'Phone Number',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),

      /// ----------------------------------------
      /// 4 - Gender
      /// ----------------------------------------
      /// ----------------------------------------
      /// 4 - Gender
      /// ----------------------------------------
      FieldData(
        type: FieldType.radio,
        textInputAction: TextInputAction.next,
        label: 'Gender',
        requiredLabel: true,
        controller: TextEditingController(
          text: widget.customerDetailsModel.gender?.pascalCase,
        ),
        focusNode: FocusNode(),
        items: [
          (label: 'Male', value: 'male'),
          (label: 'Female', value: 'female'),
          (label: 'Other', value: 'other'),
        ],
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Geneder must be selected';
          }
          return null;
        },
        onSubmitted: (value) {
          _personalDetails[5].focusNode?.requestFocus();
        },
        decoration: InputDecoration(
          hintText: 'Select Gender',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),

      /// ----------------------------------------
      /// 5 - Blood Group
      /// ----------------------------------------
      FieldData(
        type: FieldType.radio,
        textInputAction: TextInputAction.next,
        label: 'Blood Group',
        requiredLabel: false,
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
        onSubmitted: (value) {
          _personalDetails[6].focusNode?.requestFocus();
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

      /// ----------------------------------------
      /// 6 - Date of Birth
      /// ----------------------------------------
      FieldData(
        type: FieldType.date,
        textInputAction: TextInputAction.next,
        label: 'Date of Birth',
        dateTimeShowFormat: DateFormat('dd/MM/yyyy'),
        endTime: DateTime.now(),
        requiredLabel: true,
        controller: TextEditingController(
          text: widget.customerDetailsModel.dateOfBirth?.format('dd/MM/yyyy'),
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Date of Birth must be selected';
          }
          return null;
        },
        onChanged: (p0) {
          _personalDetails[7].focusNode?.requestFocus();
        },
        decoration: InputDecoration(
          hintText: 'Select Date of Birth',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),

      /// ----------------------------------------
      /// 7 - Profession
      /// ----------------------------------------
      FieldData(
        type: FieldType.radio,
        textInputAction: TextInputAction.next,
        label: 'Profession',
        requiredLabel: true,
        controller: TextEditingController(
          text: widget.customerDetailsModel.profession == 'Other'
              ? (widget.customerDetailsModel.otherProfession ?? 'Other')
              : widget.customerDetailsModel.profession,
        ),
        focusNode: FocusNode(),
        items: [],
        onValueChanged: (value) async {
          final selectedItem = value.isNotEmpty ? value.first : null;
          if (selectedItem?.value == 'Other') {
            final customProfession = await _showCustomProfessionDialog(context);
            if (customProfession != null && customProfession.trim().isNotEmpty) {
              _customProfession = customProfession.trim();
              _personalDetails[7].controller?.text = customProfession.trim();
            } else {
              _personalDetails[7].controller?.text = '';
              _customProfession = null;
            }
          } else {
            _customProfession = null;
          }
        },
        onSubmitted: (value) {
          _personalDetails[7].focusNode?.unfocus();
        },
        decoration: InputDecoration(
          hintText: 'Select Profession',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_personalDetails[0].focusNode);
    });

    _loadProfessions();

    super.initState();
  }

  Future<void> _loadProfessions() async {
    final result = await CustomerDetailsRepository().fetchProfessionsList();
    result.fold(
      (error) async {
        debugPrint('❌ Error fetching professions list: $error');
        // Fallback: Fetch from constant choices
        final choicesResult = await AuthRepository().fetchConstChoices();
        choicesResult.fold(
          (choicesError) {
            debugPrint('❌ Error fetching constant choices: $choicesError');
          },
          (choices) {
            _updateProfessionsList(choices.data.professions);
          },
        );
      },
      (professions) {
        _updateProfessionsList(professions);
      },
    );
  }

  void _updateProfessionsList(List<Profession> professions) {
    if (mounted) {
      setState(() {
        _professions = professions;
        _personalDetails[7] = _personalDetails[7].copyWith(
          items: professions.map((e) => (label: e.label, value: e.value)).toList(),
        );

        // Match initial value or label to update the text field controller
        final initialVal = widget.customerDetailsModel.profession;
        final initialOtherVal = widget.customerDetailsModel.otherProfession;

        if (initialVal == 'Other' && initialOtherVal != null) {
          _personalDetails[7].controller?.text = initialOtherVal;
        } else if (initialVal != null) {
          Profession? matched;
          for (final p in professions) {
            if (p.value == initialVal || p.label == initialVal) {
              matched = p;
              break;
            }
          }
          if (matched != null) {
            _personalDetails[7].controller?.text = matched.label;
          }
        }
      });
    }
  }

  Future<String?> _showCustomProfessionDialog(BuildContext context) async {
    final textController = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Custom Profession',
            style: AppStyles.text18Px.poppins.w600,
          ),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Enter your profession',
              hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(color: AppColors.borderGrey),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: AppStyles.text14Px.poppins.w500.copyWith(color: AppColors.textGrey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, textController.text),
              child: Text(
                'OK',
                style: AppStyles.text14Px.poppins.w500.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    for (final element in _personalDetails) {
      element.controller?.dispose();
      element.focusNode?.dispose();
    }
    super.dispose();
  }

  void _onContinue() {
    if (_profileCubit.state.updateProfileDetails?.isNone() ?? false) {
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      final firstName = _personalDetails[0].controller?.text;
      final lastName = _personalDetails[1].controller?.text;
      final email = _personalDetails[2].controller?.text?.trim() ?? '';
      final phone = _personalDetails[3].controller?.text;
      final gender = _personalDetails[4].controller?.text;
      final bloodGroup = _personalDetails[5].controller?.text;
      final dob = _personalDetails[6].selectedDateTime;

      final professionLabel = _personalDetails[7].controller?.text;
      String selectedProfessionValue = '';
      for (final p in _professions) {
        if (p.label == professionLabel) {
          selectedProfessionValue = p.value;
          break;
        }
      }
      if (_customProfession != null || selectedProfessionValue == 'Other') {
        selectedProfessionValue = 'Other';
      }

      final currentEmail = widget.customerDetailsModel.email?.trim() ?? '';

      _profileCubit.updateProfileDetails(
        firstName: firstName ?? '',
        lastName: lastName ?? '',
        email: email,
        currentEmail: currentEmail,
        dateOfBirth: dob ?? widget.customerDetailsModel.dateOfBirth ?? DateTime.now(),
        gender: (gender ?? '').toLowerCase(),
        bloodGroup: bloodGroup,
        profession: selectedProfessionValue,
        otherProfession: _customProfession,
        image: _pickedImage,
      );
    } else {
      Dialogs.showSnack(msg: 'Please check your inputs.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {
        state.updateProfileDetails?.fold(
          () => null,
          (t) => t.fold(
            (l) => Dialogs.showSnack(
              msg: l.msg.isNotEmpty
                  ? l.msg
                  : "Couldn't update profile details. Please try again.",
            ),
            (r) {
              Navigator.pop(context);
            },
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const PopButton().center,
          title: Text(
            'Profile Details',
            style: AppStyles.text18Px.poppins.w600,
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              ProfileImage(
                isEdit: true,
                onChanged: (image) => _pickedImage = image,
                radius: 100.w,
                url: widget.customerDetailsModel.profilePicture.toString(),
              ).pxy(y: 16),
              const SizedBox(height: 32),
              ListView.separated(
                itemCount: _personalDetails.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (_, __) => const SizedBox(height: 22),
                itemBuilder: (context, index) {
                  return Field(data: _personalDetails[index]);
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        bottomNavigationBar: BlocBuilder<ProfileCubit, ProfileState>(
          buildWhen: (p, c) => p.updateProfileDetails != c.updateProfileDetails,
          builder: (context, state) {
            return Button.filled(
              title: 'Update',
              ontap: _onContinue,
              isLoading: state.updateProfileDetails?.isNone() ?? false,
            ).pad(16);
          },
        ),
      ),
    );
  }
}
