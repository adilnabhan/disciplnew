import 'package:customer_mobile_app/imports_bindings.dart';

part 'profile_state.dart';
part 'profile_cubit.freezed.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(const ProfileState());

  Future<void> fetchCustomerDetails() async {
    if (state.customerDetails.isNone()) {
      emit(state.copyWith(customerDetails: none()));
    }
    final id = Feggy.read<AppCubit>()?.state.currentUser?.customer?.id;
    if (id == null) {
      emit(
        state.copyWith(
          customerDetails: some(left(const ApiException.unknown())),
        ),
      );
      return;
    }
    final response = await CustomerDetailsRepository().customerDetails(id: id);
    emit(state.copyWith(customerDetails: some(response)));
  }

  // Future<void> updateProfileDetails({
  //   required String firstName,
  //   required String lastName,
  //   required String email,
  //   required DateTime dateOfBirth,
  //   required String gender,
  //   required String profession,
  //   String? emergencyContactNumber,
  // }) async {
  //   if (state.updateProfileDetails?.isNone() ?? false) {
  //     return;
  //   }
  //   emit(state.copyWith(updateProfileDetails: none()));
  //   final id = Feggy.read<AppCubit>()?.state.currentUser?.customer?.id;
  //   if (id == null) {
  //     emit(
  //       state.copyWith(
  //         updateProfileDetails: some(left(const ApiException.unknown())),
  //       ),
  //     );
  //     return;
  //   }
  //
  //   final body = {
  //     'first_name': firstName,
  //     'last_name': lastName,
  //     'email': email,
  //     'date_of_birth':
  //         dateOfBirth
  //             .toIso8601String()
  //             .split('T')
  //             .first, // Format as yyyy-MM-dd
  //     'gender': gender.toLowerCase(),
  //     'profession': profession,
  //   };
  //
  //   // Only include emergency contact if provided
  //   if (emergencyContactNumber != null && emergencyContactNumber.isNotEmpty) {
  //     body['emergency_contact_number'] = emergencyContactNumber;
  //   }
  //
  //   final response = await CustomerDetailsRepository().updateProfileDetails(
  //     id: id,
  //     body: body,
  //   );
  //   response.fold(
  //     (error) {},
  //     (details) => emit(state.copyWith(customerDetails: some(right(details)))),
  //   );
  //   emit(state.copyWith(updateProfileDetails: some(response)));
  // }

  Future<void> updateProfileDetails({
    required String firstName,
    required String lastName,
    required String email,
    required DateTime dateOfBirth,
    required String gender,
    required String profession,
    String? otherProfession,
    String? emergencyContactNumber,
    String? bloodGroup,
    XFile? image,
  }) async {
    if (state.updateProfileDetails?.isNone() ?? false) {
      return;
    }

    emit(state.copyWith(updateProfileDetails: none()));

    final id = Feggy.read<AppCubit>()?.state.currentUser?.customer?.id;
    if (id == null) {
      emit(
        state.copyWith(
          updateProfileDetails: some(left(const ApiException.unknown())),
        ),
      );
      return;
    }

    final currentDetails = state.customerDetails?.fold(
      () => null,
      (either) => either.fold(
        (_) => null,
        (r) => r,
      ),
    );
    final currentProfession = currentDetails?.profession;
    final currentOtherProfession = currentDetails?.otherProfession;

    if (profession.isNotEmpty && (profession != currentProfession || otherProfession != currentOtherProfession)) {
      final profResponse = await CustomerDetailsRepository().updateProfessionDetails(
        id: id,
        profession: profession,
        otherProfession: otherProfession,
      );
      if (profResponse.isLeft()) {
        emit(
          state.copyWith(
            updateProfileDetails: some(left(profResponse.fold((l) => l, (r) => const ApiException.unknown()))),
          ),
        );
        return;
      }
    }

    // ✅ Create FormData
    final formData = FormData.fromMap({
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'date_of_birth': dateOfBirth.toIso8601String().split('T').first,
      'gender': gender.toLowerCase(),
      'profession': profession,
      if (bloodGroup != null && bloodGroup.isNotEmpty)
        'blood_group': bloodGroup,
      if (emergencyContactNumber != null && emergencyContactNumber.isNotEmpty)
        'emergency_contact_number': emergencyContactNumber,
    });
    if (image != null) {
      formData.files.add(
        MapEntry(
          'profile_picture',
          await MultipartFile.fromFile(image.path, filename: image.name),
        ),
      );
    }

    // ✅ Send FormData to repository
    final response = await CustomerDetailsRepository().updateProfileDetails(
      id: id,
      body: formData, // send as FormData
    );

    response.fold(
      (error) {
        debugPrint('❌ Error: $error');
      },
      (details) {
        emit(state.copyWith(customerDetails: some(right(details))));
        final profilePic = details.profilePicture;

        Feggy.read<AppCubit>()!.updateProfilePicture(profilePic);
      },
    );

    emit(state.copyWith(updateProfileDetails: some(response)));
  }

  Future<void> updateHealthProfile({
    required String bloodGroup,
    required String height,
    required String weight,
    Map<String, dynamic>? extraBody,
  }) async {
    if (state.updateProfileDetails?.isNone() ?? false) {
      return;
    }
    emit(state.copyWith(updateProfileDetails: none()));
    final id = Feggy.read<AppCubit>()?.state.currentUser?.customer?.id;
    if (id == null) {
      emit(
        state.copyWith(
          updateProfileDetails: some(left(const ApiException.unknown())),
        ),
      );
      return;
    }
    final body = extraBody ?? <String, dynamic>{
      'blood_group': bloodGroup,
      'height': height,
      'weight': weight,
    };

    print('passing data is--${body}');
    final response = await CustomerDetailsRepository().updateHealthProfile(
      id: id,
      body: body,
    );
    response.fold(
      (error) {},
      (details) => emit(state.copyWith(customerDetails: some(right(details)))),
    );
    emit(state.copyWith(updateProfileDetails: some(response)));
  }

  Future<void> updateCustomerProfile({
    required Map<String, dynamic> body,
  }) async {
    if (state.updateProfileDetails?.isNone() ?? false) {
      return;
    }
    emit(state.copyWith(updateProfileDetails: none()));
    final id = Feggy.read<AppCubit>()?.state.currentUser?.customer?.id;
    if (id == null) {
      emit(
        state.copyWith(
          updateProfileDetails: some(left(const ApiException.unknown())),
        ),
      );
      return;
    }

    final response = await CustomerDetailsRepository().updateCustomerProfile(
      id: id,
      body: body,
    );
    response.fold(
      (error) {},
      (details) => emit(state.copyWith(customerDetails: some(right(details)))),
    );
    emit(state.copyWith(updateProfileDetails: some(response)));
  }

  Future<void> fetchConstChoices() async {
    if (state.constChoice?.isNone() ?? true) {
      emit(state.copyWith(constChoice: none()));
    }
    final response = await AuthRepository().fetchConstChoices();
    emit(state.copyWith(constChoice: some(response)));
    print(state.constChoice);
  }

  Future<void> updateLifeStyle({
    String? sleepingHur,
    String? workingHur,
    String? jobSatisfaction,
  }) async {
    if (state.updateProfileDetails?.isNone() ?? false) {
      return;
    }
    emit(state.copyWith(updateProfileDetails: none()));
    final id = Feggy.read<AppCubit>()?.state.currentUser?.customer?.id;
    if (id == null) {
      emit(
        state.copyWith(
          updateProfileDetails: some(left(const ApiException.unknown())),
        ),
      );
      return;
    }
    final body = <String, dynamic>{
      'average_working_hours': workingHur,
      'average_sleep_hours': sleepingHur,
      'job_satisfaction': jobSatisfaction,
    };
    print('body is---$body');

    final response = await CustomerDetailsRepository().updateHealthProfile(
      id: id,
      body: body,
    );
    response.fold(
      (error) {},
      (details) => emit(state.copyWith(customerDetails: some(right(details)))),
    );

    // final result = await AuthRepository().onboardingUpdate(
    //   body: body,
    //   id: id,
    // );
    // response.fold(
    //       (error) {},
    //       (details) => emit(state.copyWith()),
    // );
    emit(state.copyWith(updateProfileDetails: some(response)));
  }

  Future<void> detailsUpdate({
    required Map<String, dynamic> body,
    required int? id,
  }) async {
    // Start loader
    emit(
      state.copyWith(
        // onboardingUser: none(),
        updateProfileDetails: none(),
      ),
    );

    try {
      final result = await AuthRepository().onboardingUpdate(
        body: body,
        id: id,
      );

      // Handle both success and failure properly
      result.fold(
        (failure) {
          // Emit error and stop loader
          emit(state.copyWith(updateProfileDetails: some(left(failure))));
        },
        (r) {
          // Emit success and stop loader
          emit(
            state.copyWith(
              updateProfileDetails: some(right(r)),
              // onboardingUser: some(right(r)),
            ),
          );
        },
      );
    } catch (e) {
      // Catch unhandled exceptions and stop loader
      emit(
        state.copyWith(
          updateProfileDetails: some(
            left(ApiException.unknown(msg: e.toString())),
          ),
        ),
      );
    }
  }

  Future<void> updateEmail({
    required String email,
    String? currentEmail,
  }) async {
    final trimmed = email.trim();

    // 1. Validation: Email cannot be empty
    if (trimmed.isEmpty) {
      Dialogs.showSnack(msg: 'Please enter your email address.');
      return;
    }

    // 2. Validation: Valid email format
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(trimmed)) {
      Dialogs.showSnack(msg: 'Please enter a valid email address.');
      return;
    }

    // 3. Skip API call if email hasn't changed
    if (currentEmail != null && trimmed == currentEmail.trim()) {
      return;
    }

    if (state.updateProfileDetails?.isNone() ?? false) {
      return;
    }

    // Emit loading state
    emit(state.copyWith(updateProfileDetails: none()));

    final response =
        await CustomerDetailsRepository().updateEmail(email: trimmed);

    response.fold(
      (error) {
        final errorMsg = error.msg.isNotEmpty
            ? error.msg
            : "Couldn't update your email. Please try again.";
        Dialogs.showSnack(msg: errorMsg);
        emit(
          state.copyWith(
            updateProfileDetails: some(left(error)),
          ),
        );
      },
      (details) {
        emit(
          state.copyWith(
            customerDetails: some(right(details)),
            updateProfileDetails: some(right(null)),
          ),
        );
        Dialogs.showSnack(msg: 'Email updated successfully.');
      },
    );
  }

  Future<void> logBodyMeasurements({
    double? neck,
    double? waist,
    double? hip,
    double? chest,
    double? biceps,
    double? thighs,
  }) async {
    final response = await CustomerDetailsRepository().logBodyMeasurements(
      neck: neck,
      waist: waist,
      hip: hip,
      chest: chest,
      biceps: biceps,
      thighs: thighs,
    );

    response.fold(
      (error) {
        debugPrint('❌ Error logging measurements: ${error.msg}');
      },
      (measurement) {
        fetchCustomerDetails();
      },
    );
  }
}
