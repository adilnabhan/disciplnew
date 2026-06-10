import 'package:customer_mobile_app/imports_bindings.dart';

class FitnessPassportStep extends StatefulWidget {
  final SentOtpEntity? sentOtpEntity;
  final bool isLoading;
  final void Function(String, String, String, String, XFile? image) onNext;
  const FitnessPassportStep({required this.onNext, this.sentOtpEntity,this.isLoading=false});

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

    if (widget.sentOtpEntity!.mobileNumber != null) {
      _mobile.text = widget.sentOtpEntity!.mobileNumber!;
    }
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
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 10),
              Question.text(
                controller: _lastName,
                hintText: 'Last Name',
                heading: '',
                validator: (v) => v!.isEmpty ? 'Required' : null,
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
              Question.text(controller: _email, hintText: 'Email', heading: ''),

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
                  _firstName.text,
                  _lastName.text,
                  _email.text,
                  _mobile.text,
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
