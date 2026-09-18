import 'package:customer_mobile_app/imports_bindings.dart';

class FitnessPassportStep extends StatefulWidget {
  final SentOtpEntity? sentOtpEntity;
  final LoginSuccessModel? loginSuccessModel;
  final bool isLoading;
  final void Function(String, String, String, String, XFile? image) onNext;
  const FitnessPassportStep({
    required this.onNext,
    super.key,
    this.sentOtpEntity,
    this.loginSuccessModel,
    this.isLoading = false,
  });

  @override
  State<FitnessPassportStep> createState() => FitnessPassportStepState();
}

class FitnessPassportStepState extends State<FitnessPassportStep> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  XFile? _profilePicture;
  @override
  void initState() {
    super.initState();

    final mobileNum = widget.sentOtpEntity?.mobileNumber ??
        widget.loginSuccessModel?.mobileNumber;
    if (mobileNum != null && mobileNum.isNotEmpty) {
      _mobile.text = mobileNum;
    }

    final fName = widget.loginSuccessModel?.firstName;
    if (fName != null &&
        fName.trim().isNotEmpty &&
        fName.trim().toLowerCase() != 'null' &&
        fName.trim().toLowerCase() != 'none') {
      _firstName.text = fName.trim();
    }

    final lName = widget.loginSuccessModel?.lastName;
    if (lName != null &&
        lName.trim().isNotEmpty &&
        lName.trim().toLowerCase() != 'null' &&
        lName.trim().toLowerCase() != 'none') {
      _lastName.text = lName.trim();
    }

    final emailVal = widget.loginSuccessModel?.email;
    if (emailVal != null &&
        emailVal.trim().isNotEmpty &&
        emailVal.trim().toLowerCase() != 'null' &&
        emailVal.trim().toLowerCase() != 'none') {
      _email.text = emailVal.trim();
    }
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _mobile.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            "Your Fitness \nPassport ",
            style: AppStyles.text32Px.poppins.w600.dark,
          ),
          SizedBox(height: 8.h),
          Text(
            'Let’s get to know you so we can make Discipl truly yours.',
            style: AppStyles.text15Px.poppins.w400.textGrey,
          ),
          SizedBox(height: 24.h),
          ProfileImage(
            isEdit: true,
            onChanged: (image) => _profilePicture = image,
            radius: 80,
          ).pOnly(bottom: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name', style: AppStyles.text18Px.poppins.w500.dark),
              Question.text(
                hintText: 'First Name',
                controller: _firstName,
                heading: '',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              Question.text(
                controller: _lastName,
                hintText: 'Last Name',
                heading: '',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),

              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Email', style: AppStyles.text18Px.poppins.w500.dark),
                  Text(
                    '(optional)',
                    style: AppStyles.text18Px.poppins.w500.dark,
                  ),
                ],
              ),
              Question.text(
                controller: _email,
                hintText: 'Email',
                heading: '',
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v != null && v.trim().isNotEmpty) {
                    if (!RegExp(
                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                    ).hasMatch(v.trim())) {
                      return 'Invalid email address!';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),
              Text(
                'Mobile Number *',
                style: AppStyles.text18Px.poppins.w500.dark,
              ),
              Question.text(
                readonly: true,
                controller: _mobile,
                hintText: 'Mobile Number',
                heading: '',
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? '' : null,
              ),

              // const SizedBox(height: 32),
            ],
          ),
          const SizedBox(height: 32),
          Button.filled(
            isLoading: widget.isLoading,
            title: 'Next',
            ontap: () {
              if (_formKey.currentState!.validate()) {
                widget.onNext(
                  _firstName.text.trim(),
                  _lastName.text.trim(),
                  _email.text.trim(),
                  _mobile.text.trim(),
                  _profilePicture,
                );
              }
            },
          ),
          const SizedBox(height: 10),
          Text(
            textAlign: TextAlign.center,
            'Strong beginnings lead to stronger\n results.',
            style: AppStyles.text15Px.poppins.w400.textGrey,
          ),
        ],
      ),
    );
  }
}
