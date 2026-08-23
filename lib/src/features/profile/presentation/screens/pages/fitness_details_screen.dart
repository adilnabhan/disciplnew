import 'package:customer_mobile_app/imports_bindings.dart';

class FitnessDetailsScreen extends StatefulWidget {
  const FitnessDetailsScreen({required this.customerDetailsModel, super.key});

  final CustomerDetailsModel customerDetailsModel;

  @override
  State<FitnessDetailsScreen> createState() => FitnessDetailsScreenState();
}

class FitnessDetailsScreenState extends State<FitnessDetailsScreen> {
  late final List<FieldData<dynamic>> _healthDetails;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
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
          _healthDetails[2].focusNode?.unfocus();
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
  }

  void _onUpdate() {
    if (_formKey.currentState?.validate() ?? false) {
      /// Health Details
      final bloodGroup = _healthDetails[0].controller?.text;
      final height = _healthDetails[1].controller?.text;
      final weight = _healthDetails[2].controller?.text;
      print(' blood id---$bloodGroup');
      context.read<ProfileCubit>().updateHealthProfile(
        bloodGroup: bloodGroup!,
        height: height!,
        weight: weight!,
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
