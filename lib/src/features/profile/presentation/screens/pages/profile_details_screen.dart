import 'package:customer_mobile_app/imports_bindings.dart';

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

  @override
  void initState() {
    _profileCubit = context.read<ProfileCubit>();

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
          border: OutlineInputBorder(
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
          border: OutlineInputBorder(
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
        readOnly: true,
        controller: TextEditingController(
          text: widget.customerDetailsModel.email,
        ),
        focusNode: FocusNode(),
        validator: (value) {
          if (value?.isNotEmpty ?? false) {
            if (!RegExp(
              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
            ).hasMatch(value!)) {
              return 'Invalid email address!';
            }
          }
          return null;
        },
        onSubmitted: (value) {
          _personalDetails[3].focusNode?.requestFocus();
        },
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          hintText: 'Enter your email address',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: OutlineInputBorder(
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),

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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),

      /// ----------------------------------------
      /// 5 - Date of Birth
      /// ----------------------------------------
      FieldData(
        type: FieldType.date,
        textInputAction: TextInputAction.next,
        label: 'Date of Birth',
        // dateTimeShowFormat: DateFormat('dd MMM yyyy'),
        dateTimeShowFormat: DateFormat('dd/MM/yy'),
        endTime: DateTime.now(),
        requiredLabel: true,
        controller: TextEditingController(
          text: widget.customerDetailsModel.dateOfBirth?.format('dd/MM/yy'),
        ),
        validator: (value) {
          if (value?.isEmpty ?? true) {
            return 'Date of Birth must be selected';
          }
          return null;
        },
        onChanged: (p0) {
          _personalDetails[6].focusNode?.requestFocus();
        },
        decoration: InputDecoration(
          hintText: 'Select Date of Birth',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),

      /// ----------------------------------------
      /// 6 - Profession
      /// ----------------------------------------
      // FieldData(
      //   type: FieldType.word,
      //   textInputAction: TextInputAction.done,
      //   label: 'Profession',
      //   requiredLabel: true,
      //   validator: (value) {
      //     if (value?.trim().isEmpty ?? true) {
      //       return 'Profession is required';
      //     }
      //     return null;
      //   },
      //   onSubmitted: (value) {
      //     _personalDetails[6].focusNode?.unfocus();
      //
      //   },
      //   controller: TextEditingController(
      //     text: widget.customerDetailsModel.profession,
      //   ),
      //   focusNode: FocusNode(),
      //   keyboardType: TextInputType.name,
      //   decoration: InputDecoration(
      //     hintText: 'Enter Profession',
      //     hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
      //     border: const OutlineInputBorder(
      //       borderRadius: BorderRadius.all(Radius.circular(8)),
      //       borderSide: BorderSide(color: AppColors.borderGrey),
      //     ),
      //   ),
      // ),
      FieldData(
        type: FieldType.radio,
        textInputAction: TextInputAction.next,
        label: 'Profession',
        requiredLabel: true,
        controller: TextEditingController(
          text: widget.customerDetailsModel.profession,
        ),
        focusNode: FocusNode(),
        items:
            (widget.choicesModel?.data.professions ?? []).map((e) {
              return (label: e.label, value: e.value);
            }).toList(),

        onSubmitted: (value) {
          _personalDetails[6].focusNode?.unfocus();
        },
        decoration: InputDecoration(
          hintText: 'Select  Profession',
          hintStyle: AppStyles.text14Px.poppins.w400.textGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: AppColors.borderGrey),
          ),
        ),
      ),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_personalDetails[0].focusNode);
    });

    super.initState();
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
    if (_formKey.currentState?.validate() ?? false) {
      final firstName = _personalDetails[0].controller?.text;
      final lastName = _personalDetails[1].controller?.text;
      final email = _personalDetails[2].controller?.text;
      final phone = _personalDetails[3].controller?.text;
      final gender = _personalDetails[4].controller?.text;
      final dob = _personalDetails[5].selectedDateTime;
      final profession = _personalDetails[6].controller?.text;

      _profileCubit.updateProfileDetails(
        firstName: firstName ?? '',
        lastName: lastName ?? '',
        email: email ?? '',
        // phoneNumber: phone ?? '',
        dateOfBirth: dob!,
        gender: gender!.toLowerCase(),
        profession: profession!,
        image: _pickedImage,
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
            (l) => Dialogs.showSnack(msg: l.msg),
            (r) => context.pop(),
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
